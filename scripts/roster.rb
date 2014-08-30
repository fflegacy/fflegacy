require 'csv'

puts "Enter team:"
team = gets.strip.upcase
players = []
# determines roster of a team given the list of transactions
CSV.foreach(File.expand_path("../../seasons/2014_transactions.csv", __FILE__), headers: true, col_sep: ', ') do |csv|
  if csv['Team'].eql? team
    if csv['Type'].eql? 'Add'
      players.push csv['Player']
    else
      players.delete csv['Player']
    end
  end
end

players.sort!

puts "---"
players.each do |player|
  puts player
end
puts "---"
puts "Roster size: #{players.size}"
