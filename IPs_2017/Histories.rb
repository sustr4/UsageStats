#!/usr/bin/ruby

require 'nokogiri'
require 'pp'

actions = [
  "NONE_ACTION",
  "MIGRATE_ACTION",
  "LIVE_MIGRATE_ACTION",
  "SHUTDOWN_ACTION",
  "SHUTDOWN_HARD_ACTION",
  "UNDEPLOY_ACTION",
  "UNDEPLOY_HARD_ACTION",
  "HOLD_ACTION",
  "RELEASE_ACTION",
  "STOP_ACTION",
  "SUSPEND_ACTION",
  "RESUME_ACTION",
  "BOOT_ACTION",
  "DELETE_ACTION",
  "DELETE_RECREATE_ACTION",
  "REBOOT_ACTION",
  "REBOOT_HARD_ACTION",
  "RESCHED_ACTION",
  "UNRESCHED_ACTION",
  "POWEROFF_ACTION",
  "POWEROFF_HARD_ACTION",
  "DISK_ATTACH_ACTION",
  "DISK_DETACH_ACTION",
  "NIC_ATTACH_ACTION",
  "NIC_DETACH_ACTION",
  "DISK_SNAPSHOT_CREATE_ACTION",
  "DISK_SNAPSHOT_DELETE_ACTION",
  "TERMINATE_ACTION",
  "TERMINATE_HARD_ACTION" ]

roottag = 'VM'

xml = File.read(ARGV[0])

template = Nokogiri::XML(xml)

template.xpath("//#{roottag}/HISTORY_RECORDS/HISTORY").each do |hist|


  puts "#{template.at_xpath("//#{roottag}/ID").content},#{hist.at_xpath("./STIME").content},#{hist.at_xpath("./ETIME").content},#{hist.at_xpath("./SEQ").content},#{hist.at_xpath("./ACTION").content},#{actions[hist.at_xpath("./ACTION").content.to_i]}"
   
end

