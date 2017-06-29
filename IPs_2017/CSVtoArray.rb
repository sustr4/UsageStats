#!/usr/bin/ruby

require 'csv'
require 'set'
require 'date'

segment = Set.new

CSV.foreach(ARGV[0]) do |line|
  segment.add(line[4])
end

state = Hash.new

print "timestamp,date,"

segment.each do |seg|
  state[seg] = 0
  print "#{seg},"
end

puts

last = 0

CSV.foreach(ARGV[0]) do |line|

  if line[0] != last then
    print "#{last},#{Time.at(last.to_i).to_datetime.strftime("%Y-%m-%d")},"
    segment.each do |seg|
      print "#{state[seg]},"
    end
    puts
  end
  last = line[0]


  state[line[4]] = state[line[4]] + line[2].to_i

end


print "#{last},#{Time.at(last.to_i).to_datetime.strftime("%Y-%m-%d")},"
segment.each do |seg|
  print "#{state[seg]},"
end

puts


