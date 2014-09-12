# This script is for checking the current rosters of each team based on the full
# history of transactions. When prompted, enter in the initials of the team you
# want to check.

require 'csv'

puts "Enter team:"
team = gets.strip.upcase
players = []
# determines roster of a team given the list of transactions
CSV.foreach(File.expand_path("../../seasons/2014_transactions.csv", __FILE__), headers: true) do |csv|
  if csv['Team'].eql? team
    if csv['Type'].eql? 'Add'
      players.push csv['Player']
    else
      if players.delete(csv['Player']).nil?
        raise "Cannot drop #{csv['Player']}: not on #{team}'s roster"
      end
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
