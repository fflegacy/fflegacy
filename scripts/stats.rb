# This script is for populating player data based off of weekly starting statistics.

require 'csv'
require 'json'

def scrub_personal
  files = Dir[File.expand_path("../../yql/weekly/*.json", __FILE__)]

  files.each do |filename|
    puts "Scrubbing #{filename}..."
    out = ''
    File.open(filename, 'r') do |file|
      file.each do |line|
        out << line.gsub(/\"email\": \".+@.+\.com\"/, '"email": "nope@nope.com"')
                   .gsub(/\"nickname\": \".+\"/, '"nickname": "nope"')
      end
    end
    File.open(f, 'w') do |file|
      file.write out
    end
  end
end

def populate_stats(week_id)
  files = Dir[File.expand_path("../../yql/weekly/*_#{week_id}.json", __FILE__)]
  # files = [File.expand_path("../../yql/weekly/1_#{week_id}.json", __FILE__)] # NOTE for testing

  # order of the stats in the 2014_stats.csv, from left to right
  stat_mappings = [
    5, # Passing TDs
    6, # Interceptions
    4, # Passing Yards
    10, # Rushing TDs
    9, # Rushing Yds
    13, # Reception TDs
    11, # Receptions
    12, # Receiving Yds
    15, # Return TDs
    16, # 2pt Conversions
    18, # Fumbles Lost
    57, # Offensive Fumble Return TDs
    19, # FGs 0-19
    20, # FGs 20-29
    21, # FGs 30-39
    22, # FGs 40-49
    23, # FGs 50+
    29, # PATs
    38, # Solo Tackles
    39, # Tackle Assists
    40, # Sacks
    41, # Interceptions
    42, # Forced Fumbles
    43, # Recovered Fumbles
    44, # Defensive TDs
    45, # Safeties
    46, # Passes Defended
    47, # Kicks Blocked
    65 # Tackles for a Loss
  ]
  # Other stats
  # 8 - Rushing Attempts
  # 78 - Targeted

  files.each do |filename|
    puts "Reading #{filename}..."
    json = {}

    File.open(filename, 'r') do |file|
      json = JSON.load(file)['query']['results']['team']
    end

    # owner_id = json['managers']['manager']['manager_id']
    week = json['roster']['week']

    players = json['roster']['players']['player']
    player_rows = []

    players.each do |p|
      name = p['name']['full']
      pid = p['player_id']

      stats = p['player_stats']['stats']['stat']
      stats_hash = Hash.new(0)
      stats.each { |s| stats_hash[s['stat_id']] = s['value'] }

      row = "#{pid},#{name},#{week}"
      stat_mappings.each { |i| row += ",#{stats_hash[i.to_s]}" }
      player_rows << row
    end

    File.open(File.expand_path("../../seasons/2014_stats.csv", __FILE__), 'a') do |file|
      file.puts player_rows
    end
  end

  puts "Done."
end

# Execute definitions, pass in week number
# populate_stats(1)
