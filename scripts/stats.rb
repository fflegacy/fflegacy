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

def generate_stats(year, week)
  stats_filename = File.expand_path("../../seasons/2014/weeks/#{week}/stats.csv", __FILE__)
  files = Dir[File.expand_path("../../yql/weekly/*_#{week}.json", __FILE__)]
  # files = [File.expand_path("../../yql/weekly/1_#{week}.json", __FILE__)] # NOTE for testing

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

  player_rows = []

  files.each do |filename|
    puts "Reading #{filename}..."
    json = {}

    File.open(filename, 'r') do |file|
      json = JSON.load(file)['query']['results']['team']
    end

    # owner_id = json['managers']['manager']['manager_id']
    if week.to_s != json['roster']['week']
      raise "#{filename} data may not be for Week #{week}"
    end

    players = json['roster']['players']['player']

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
  end

  File.open(stats_filename, 'w') do |file|
    file.puts "PID,Player,Week,Passing TD,Interceptions,1 Passing Yd,Rushing TD,1 Rushing Yd,Reception TD,Receptions,1 Reception Yd,Return TD,2-pt Conversion,Fumbles Lost,Offensive Fumble Return TD,FG 0-19 Yds,FG 20-29 Yds,FG 30-39 Yds,FG 40-49 Yds,FG 50+ Yds,PAT,Tackle Solo,Tackle Assist,Sack,Interception,Fumble Force,Fumble Recovery,Defensive TD,Safety,Pass Defended,Block Kick,Tackles For Loss"
    file.puts player_rows
  end

  puts "Done."
end

# Execute definitions, pass in year, week
# scrub_personal # TODO specify week as argument
# generate_stats(2014, 1)
