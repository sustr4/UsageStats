#!/usr/bin/ruby

require 'csv'

def printrow (row)
  csv_string = CSV.generate do |csv|
    csv << row
  end
  print csv_string
end

last = ""
maxim = Array.new

CSV.foreach(ARGV[0]) do |line|

  if line[1] != last then

    printrow maxim
    last = line[1]
    maxim = line
  else
    [line, maxim].transpose.map(&:max)
  end
end

printrow maxim

