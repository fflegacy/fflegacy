# frozen_string_literal: true

require "csv"

class Transaction
  attr_accessor :action, :player, :owner, :round_drafted, :year_drafted

  def kept?
    @action == :kept
  end

  def drafted?
    @action == :drafted
  end
end

# This script is for calculating keeper values for each year

START_YEAR = 2014
CURRENT_YEAR = 2018 # feel free to change me as needed
KEEPER = "keeper"
DRAFTED = "draftpicks"

def calc_keeper_val(previous_val)
  if previous_val.kind_of?(Integer) && previous_val > 2
    previous_val - 2
  elsif previous_val.kind_of?(Integer) && previous_val <= 2
    "CAN'T BE KEPT"
  else
    10
  end
end

def load_draft_picks(year)
  transactions_path = File.expand_path("../seasons/#{year}/transactions.csv", __dir__)

  # init
  pick = 1
  transactions = []
  CSV.foreach(transactions_path, headers: true)
     .select { |l| [KEEPER, DRAFTED].include? l["Source"] }
     .each do |l|
       t = Transaction.new
       t.action = :kept if l["Source"] == KEEPER
       t.action = :drafted if l["Source"] == DRAFTED
       t.player = l["Player/Pick"]
       t.owner = l["Destination"]
       t.round_drafted = (pick - 1) / 10 + 1 if l["Source"] == DRAFTED
       t.year_drafted = year

       pick += 1 if l["Source"] == DRAFTED
       transactions << t
     end

  transactions
end

players = {}
# player:
#   year:
#     round_drafted
#     owner
#     kept?
#     keeper_value

(START_YEAR...CURRENT_YEAR).each do |year|
  transactions = load_draft_picks(year)

  transactions.each do |t|
    players[t.player] = {} unless players.include? t.player

    # keeper transaction
    if t.kept?
      players[t.player][year] = {}
      players[t.player][year]["owner"] = t.owner

      # verify keeper -- check previous year
      if players[t.player].include?(year - 1)
        players[t.player][year]["kept?"] = true
        players[t.player][year]["keeper_value"] = calc_keeper_val(players[t.player][year - 1]["keeper_value"])
      else # they got picked up
        players[t.player][year] = {}
        players[t.player][year]["round_drafted"] = t.round_drafted
        players[t.player][year]["kept?"] = false
      end
    elsif players[t.player].include?(year)
      # populate rest of info
      players[t.player][year]["round_drafted"] = t.round_drafted
    else
      # not kept
      players[t.player][year] = {}
      players[t.player][year]["round_drafted"] = t.round_drafted
      players[t.player][year]["owner"] = t.owner
      players[t.player][year]["kept?"] = false
      players[t.player][year]["keeper_value"] = if t.round_drafted > 12
                                                  12
                                                else
                                                  t.round_drafted
                                                end
    end
  end
end

# load current year players
CSV.foreach(File.expand_path("current_players.csv", __dir__), headers: true) do |r|
  players[r["Player"]] = {} unless players.include? r["Player"]
  players[r["Player"]][CURRENT_YEAR] = { "Owner" => r["Owner"] }
  players[r["Player"]][CURRENT_YEAR]["keeper_value"] = if players[r["Player"]].include?(CURRENT_YEAR - 1)
                                                         calc_keeper_val(players[r["Player"]][CURRENT_YEAR - 1]["keeper_value"])

                                                       else
                                                         10
                                                       end
end

# write keepers.csv file
File.open(File.expand_path("../keepers.csv", __dir__), "w") do |file|
  headers = "Owner,Player Name"
  (START_YEAR..CURRENT_YEAR).each { |y| headers += ",#{y} Keeper Value" }
  file << "#{headers},Kept?\n"

  players.each do |player, info|
    next unless info.include? CURRENT_YEAR

    owner = info[CURRENT_YEAR]["Owner"]
    new_row = "#{owner},#{player},"

    (START_YEAR..CURRENT_YEAR).each do |y|
      new_row += if info.include? y
                   "#{info[y]['keeper_value']},"
                 else
                   ","
                 end
    end

    file << "#{new_row}\n"
  end
end
