#!/usr/bin/ruby

require 'nokogiri'
require 'pp'
require 'date'

roottag = 'VM'

xml = File.read(ARGV[0])

year = ARGV[1].nil? ? 2017 : ARGV[1].to_i
ystart = DateTime.parse("#{year}-01-01T00:00:00+01:00").to_time.to_i
yend = DateTime.parse("#{year+1}-01-01T00:00:00+01:00").to_time.to_i

template = Nokogiri::XML(xml)

id = template.at_xpath("//#{roottag}/ID").content.to_i
if template.at_xpath("//#{roottag}/USER_TEMPLATE/USER_IDENTITY").nil? then
  user = template.at_xpath("//#{roottag}/UNAME").content
else
  user = template.at_xpath("//#{roottag}/USER_TEMPLATE/USER_IDENTITY").content
end

group = template.at_xpath("//#{roottag}/GNAME").content
cpu = template.at_xpath("//#{roottag}/TEMPLATE/CPU").content.to_i
if template.at_xpath("//#{roottag}/TEMPLATE/VCPU").nil? then
  vcpu = cpu
else
  vcpu = template.at_xpath("//#{roottag}/TEMPLATE/VCPU").content.to_i
end
vmstime = template.at_xpath("//#{roottag}/STIME").content.to_i
vmetime = template.at_xpath("//#{roottag}/ETIME").content.to_i

puts "\"id\",\"cluster\",\"user\",\"group\",\"VM Start\",\"VM End\",\"Segment Start\",\"Segment End\",\"CPU\",\"vCPU\",\"Lifetime (s)\",\"Lifetime (hrs)\",\"< 1 hr\",\"< 1 day\",\"< 1 week\",\"< 1 month\",\"> 1 month\""

template.xpath("//#{roottag}/HISTORY_RECORDS/HISTORY").each do |hist|

  cluster = hist.at_xpath("./HOSTNAME").content.gsub(/\d*\..*/, "")
  stime = hist.at_xpath("./STIME").content.to_i
  etime = hist.at_xpath("./ETIME").content.to_i

  stime = ystart if (stime < ystart)
  etime = ystart if (etime < ystart)
  etime = yend if (etime > yend)
  stime = yend if (stime > yend)

  if stime != etime then
    puts "#{id},#{cluster},\"#{user}\",\"#{group}\",#{vmstime},#{vmetime},#{stime},#{etime},#{cpu},#{vcpu},#{etime-stime},#{'%.2f' % ((etime-stime)/3600.0)}"
  end
end



