#!/usr/bin/ruby

require 'nokogiri'
require 'pp'

def augmentSeg (ip, user)
  subnet = ip[/\d+\.\d+\.\d+/]
  loc = ip[/\d+$/]
  if subnet.match(/147.251.253/) and loc.to_i < 127 then
    subnet = "metaBrno"
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

#IPs
template.xpath("//#{roottag}/TEMPLATE/NIC").each do |nic|

  ip = nic.at_xpath("./IP").content
  user = template.at_xpath("//#{roottag}/UNAME").content
  subnet = augmentSeg ip, user
  
  puts "#{template.at_xpath("//#{roottag}/STIME").content},up,1,#{ip},#{subnet},#{template.at_xpath("//#{roottag}/ID").content},#{user}"
  puts "#{template.at_xpath("//#{roottag}/ETIME").content},down,-1,#{ip},#{subnet},#{template.at_xpath("//#{roottag}/ID").content},#{user}"

end


#template.xpath("//#{roottag}/HISTORY_RECORDS/HISTORY").each do |hist|
#
#  puts "#{template.at_xpath("//#{roottag}/ID").content};#{template.at_xpath("//#{roottag}/UNAME").content};#{ips.sub(/,$/, "")}"
#
#end




