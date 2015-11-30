# This script is for calculating matchup results for a team

require "colorize"
require "csv"
require "json"

class Matchup
  attr_reader(:week, :year, :owner1, :owner2)

  def initialize week, year, owner1, owner2
    @week = week
    @year = year
    @owner1 = owner1
    @owner2 = owner2
  end

  def owners
    return [@owner1, @owner2]
  end

  def has_owner? owner
    if owner == @owner1 or owner == @owner2
      return true
    else
      return false
    end
  end

  def owner_against owner
    if owner == @owner1
      return @owner2
    elsif owner == @owner2
      return @owner1
    else
      return nil
    end
  end
end

### Run that program!

# import matchups

matchups = []

files = Dir[File.expand_path("../../seasons/**/matchups.csv", __FILE__)]

files.each do |filepath|
  year = filepath.match(/seasons\/(\d+)\//)[1]

  CSV.foreach(filepath, headers: true) do |row|
    # start with regular season
    if row["Type"] == "Season"
      matchups << Matchup.new(row["Week"], year, row["Home Team"], row["Away Team"])
    end
  end
end

# debugging stuff below -- feel free to toss!

matchups.each do |matchup|
  if matchup.has_owner? "DB"
    puts matchup.owners
    puts
  end
end
