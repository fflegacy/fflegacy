# This script is for checking the current rosters of each team based on the full
# history of transactions. When prompted, enter in the initials of the team you
# want to check. Close the program by typing "exit" or using ctrl+c.
#
# Requirements:
# $ gem install colarize

require 'colorize'
require 'csv'
require 'json'

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
    owners = ['DB', 'TP', 'SC', 'MP', 'CR', 'MM', 'MW', 'BT', 'TJ', 'JC']
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
  File.open(File.expand_path("../../seasons/2014_transactions.json", __FILE__), 'r') do |f|
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

  transactions_array.reverse.each do |a|
    puts a.to_s
  end
end

def lookup_team
  print "Enter team:".underline + ' '
  begin
    team = gets.strip.upcase
  rescue Interrupt
    puts "\nClosing program..."
    raise SystemExit
  end

  if team == 'EXIT'
    puts "\nClosing program..."
    raise SystemExit
  end

  players = []
  # determines roster of a team given the list of transactions
  CSV.foreach(File.expand_path("../../seasons/2014_transactions.csv", __FILE__), headers: true) do |csv|
    if csv['Destination'].eql? team
      players.push csv['Player/Pick']
    elsif csv['Source'].eql? team
      if players.delete(csv['Player/Pick']).nil?
        raise "Cannot drop #{csv['Player/Pick']}: not on #{team}'s roster"
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

while true
  lookup_team
end
