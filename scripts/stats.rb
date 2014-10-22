# This script is for populating player data based off of weekly starting statistics.

require 'csv'
require 'json'

def scrub_personal
  files = Dir[File.expand_path("../../yql/weekly/*.json", __FILE__)]

  files.each do |f|
    puts "Scrubbing #{f}..."
    out = ''
    File.open(f, 'r') do |file|
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

scrub_personal
