# This script is for checking the current rosters of each team based on the full
# history of transactions. When prompted, enter in the initials of the team you
# want to check. Close the program by typing "exit" or using ctrl+c.

require 'colorize'
require 'csv'
require 'json'

YEAR = 2016

class Transaction
  require 'date'
  attr_reader(:date, :name, :type, :source, :destination)

  def initialize player, timestamp
    @date = DateTime.strptime(timestamp, '%s').new_offset(-5.0/24).strftime('%Y-%m-%d')

    source_dest = nil
    if player['name']
      @type = player['transaction_data']['type']
      @name = player['name']['full']
      source_dest = player['transaction_data']
    else # actually a pick, god I hate these names
      @type = 'trade'
      @name = "Round #{player['round']}"
      source_dest = player
    end

    unless source_dest['source_team_key'].nil?
      @source = initials(source_dest['source_team_key'].match(/t\.(\d+)/)[1])
    else
      @source = source_dest['source_type']
    end

    unless source_dest['destination_team_key'].nil?
      @destination = initials(source_dest['destination_team_key'].match(/t\.(\d+)/)[1])
    else
      @destination = source_dest['destination_type']
    end
  end

  def initials id
    # TODO map this to a file or something, don't hardcode it
    # it will probably change from year to year

    # 2014 owners = ['DB', 'TP', 'SC', 'MP', 'CR', 'MM', 'MW', 'BT', 'TJ', 'JC']
    owners = ['DB', 'MP', 'TP', 'SC', 'TJ', 'MW', 'JC', 'BT', 'CR', 'MM']
    return owners[id.to_i - 1]
  end

  def array
    [@date, @type, @name, @source, @destination]
  end

  def csv_row
    string = ''
    self.array.each do |item|
      string << item + ','
    end
    return string.chop
  end
end

def update_from_json
  transactions = {}
  File.open(File.expand_path("../../yql/#{YEAR}_transactions.json", __FILE__), 'r') do |f|
    transactions = JSON.load(f)['query']['results']['league']['transactions']
  end

  transactions_array = []

  transactions['transaction'].each do |t|
    unless t['players'].nil?
      if t['players']['count'] == '1'
        transaction = Transaction.new t['players']['player'], t['timestamp']

        transactions_array << transaction.csv_row
      elsif t['type'] == 'trade'
        t['players']['player'].each do |p|
          transaction = Transaction.new p, t['timestamp']

          transactions_array << transaction.csv_row
        end

        unless t['picks'].nil?
          t['picks']['pick'].each do |p|
            transaction = Transaction.new p, t['timestamp']

            transactions_array << transaction.csv_row
          end
        end
      else
        t['players']['player'].each do |p|
          transaction = Transaction.new p, t['timestamp']

          transactions_array << transaction.csv_row
        end
      end
    end
  end

  # TODO there's a bug where the script won't add new transactions if the only
  # existing transactions are from the draft

  # load existing transactions, and then find the most recent recorded transaction
  transactions_path = File.expand_path("../../seasons/#{YEAR}/transactions.csv", __FILE__)

  # assume existing file because it needs to be prepopulated with draft picks
  existing_transactions = CSV.read(transactions_path)
  existing_index = transactions_array.find_index existing_transactions[-1].to_csv.chop

  File.open(File.expand_path("../../seasons/#{YEAR}/transactions.csv", __FILE__), 'a') do |file|
    # if existing_index is nil, then add all new transactions
    # if existing_index is i, then add all transactions after it
    count = 0
    transactions_array.to_enum.with_index.reverse_each do |transaction, index|
      if existing_index.nil? or index < existing_index
        file << "#{transaction}\n"
        count += 1
      end
    end
    puts "Added #{count} transactions from YQL.\n"
  end
end

def close_program
  puts "\nClosing program..."
  raise SystemExit
end

def lookup_team
  print "Enter team:".underline + ' '
  begin
    team = gets.strip.upcase
  rescue Interrupt
    close_program
  end

  if team == 'EXIT'
    close_program
  end

  players = []
  # determines roster of a team given the list of transactions
  CSV.foreach(File.expand_path("../../seasons/#{YEAR}/transactions.csv", __FILE__), headers: true) do |csv|
    unless csv['Player/Pick'].match(/Round \d+/) or csv['Source'] == 'keeper'
      if csv['Destination'].eql? team
        players.push csv['Player/Pick']
      elsif csv['Source'].eql? team
        index = players.index(csv["Player/Pick"])

        if index.nil?
          raise "Cannot drop #{csv['Player/Pick']}: not on #{team}'s roster"
        else
          players.delete_at(index)
        end
      end
    end
  end

  players.sort!

  players.each do |player|
    puts player
  end
  puts "---"
  puts "Roster size: ".green + "#{players.size}"
  puts "--- ---"
end

# Execute definitions TODO currently just prints csv
# update_from_json

def prompt_update
  print "Do you want to update from the YQL? (Y/n) "
  begin
    response = gets.strip.upcase
  rescue Interrupt
    puts "\nClosing program..."
    raise SystemExit
  end

  if response == 'Y'
    puts ""
    update_from_json
  end
end

### EXECUTION BELOW ###

prompt_update

while true
  lookup_team
end
