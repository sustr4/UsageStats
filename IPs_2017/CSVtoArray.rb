#!/usr/bin/ruby

require 'csv'
require 'set'
require 'date'

def augmentSeg (seg, user)
  if seg.match(/^147.251/) then
    if user.match(/kypo-on/) then
      "KYPO"
    elsif user.match(/cerit-sc-admin.*/) then
      "Cerit WN"
    else
      "User VM @Cerit"
    end
  elsif seg.match(/^147.228/) then
    "ZCU"
  else
    seg
  end
end

segment = Set.new

CSV.foreach(ARGV[0]) do |line|
  segment.add(augmentSeg(line[4],line[6]))
end

state = Hash.new

print "timestamp,date,"

segment.each do |seg|
  state[augmentSeg(line[4],line[6])] = 0
  print "#{augmentSeg(line[4],line[6])},"
end

puts

last = 0

CSV.foreach(ARGV[0]) do |line|

  if line[0] != last then
    print "#{last},#{Time.at(last.to_i).to_datetime.strftime("%Y-%m-%d")},"
    segment.each do |seg|
      print "#{state[augmentSeg(line[4],line[6])]},"
    end
    puts
  end
  last = line[0]


  state[augmentSeg(line[4],line[6])] = state[augmentSeg(line[4],line[6])] + line[2].to_i

end


print "#{last},#{Time.at(last.to_i).to_datetime.strftime("%Y-%m-%d")},"
segment.each do |seg|
  print "#{state[augmentSeg(line[4],line[6])]},"
end

puts


