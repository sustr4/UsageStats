#!/usr/bin/ruby

require 'nokogiri'
require 'pp'

def augmentSeg (ip, user)
  subnet = ip[/\d+\.\d+\.\d+/]
  loc = ip[/\d+$/]
  if subnet.match(/147.251.253/) and loc.to_i < 127 then
    subnet = "Meta Brno"
  elsif subnet.match(/^147.251.9/) then
    subnet = "Meta Brno old"
  elsif subnet.match(/^147.251/) then
    if user.match(/kypo-on/) then
      subnet = "KYPO"
    elsif user.match(/cerit-sc-admin.*/) then
      subnet = "Cerit WN"
    else
      subnet = "User VM @Cerit"
    end
  elsif subnet.match(/^147.228/) then
    subnet = "ZCU"
  elsif subnet.match(/^172\./) 
    subnet = "172.0.0.0/8"
  elsif subnet.match(/^10\./) 
    subnet = "10.0.0.0/8"
  elsif subnet.match(/^192\./) 
    subnet = "192.0.0.0/8"
  end

  subnet
end



roottag = 'VM'

xml = File.read(ARGV[0])

template = Nokogiri::XML(xml)

user = template.at_xpath("//#{roottag}/UNAME").content

#IPs
template.xpath("//#{roottag}/TEMPLATE/NIC").each do |nic|

  ip = nic.at_xpath("./IP").content
  subnet = augmentSeg ip, user
  
  puts "#{template.at_xpath("//#{roottag}/STIME").content},up,1,#{ip},#{subnet},#{template.at_xpath("//#{roottag}/ID").content},#{user}"
  puts "#{template.at_xpath("//#{roottag}/ETIME").content},down,-1,#{ip},#{subnet},#{template.at_xpath("//#{roottag}/ID").content},#{user}"

end


template.xpath("//#{roottag}/HISTORY_RECORDS/HISTORY").each do |hist|

  stime = hist.at_xpath("./STIME").content.to_i
  etime = hist.at_xpath("./ETIME").content.to_i
  if stime > 0 and stime < etime then
    puts "#{stime},up,1,,VM,#{template.at_xpath("//#{roottag}/ID").content},#{user}"
    puts "#{etime},down,-1,,VM,#{template.at_xpath("//#{roottag}/ID").content},#{user}"
  end

end

#Whole lifetime of the machine
stime = template.at_xpath("//#{roottag}/STIME").content.to_i
etime = template.at_xpath("//#{roottag}/ETIME").content.to_i
if stime > 0 then
  puts "#{stime},up,1,,fullVM,#{template.at_xpath("//#{roottag}/ID").content},#{user}"
  if etime > stime then
    puts "#{etime},down,-1,,fullVM,#{template.at_xpath("//#{roottag}/ID").content},#{user}"
  end
end

