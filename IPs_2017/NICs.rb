#!/usr/bin/ruby

require 'nokogiri'
require 'pp'

roottag = 'ALL'

xml = File.read(ARGV[0])

template = Nokogiri::XML(xml)

puts template.xpath("//#{roottag}/VM").count

template.xpath("//#{roottag}/VM").each do |vm|

  puts "#{vm.at_xpath("./ID").content},#{vm.xpath("./TEMPLATE/NIC").count}"

end
