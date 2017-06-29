#!/usr/bin/env ruby



require 'opennebula'
include OpenNebula


unless $stdin.tty?
  ids = $stdin.readlines.map(&:chomp).map{|l| l.to_i}
else
  puts "No input from STDIN!"
  abort
end

# XML_RPC endpoint where OpenNebula is listening
ONE_HOST=ENV["ONE_HOST"]
ENDPOINT=ENV["ONE_XMLRPC"]

#Sorry, I know this is dirty
VM_STATE = %w{INIT PENDING HOLD ACTIVE STOPPED SUSPENDED DONE FAILED POWEROFF UNDEPLOYED}

template = File.read("template_kill.txt")


client = Client.new(nil, ENDPOINT)

vm_pool = VirtualMachinePool.new(client, -1)
user_pool = UserPool.new(client)

rc = vm_pool.info_all
if OpenNebula.is_error?(rc)
  puts rc.message
  exit -1
end

if OpenNebula.is_error?(user_pool.info)
  exit -1
end

userStats = Array.new

puts "id,uid,uname,vm_name,CPU,vCPU,IP,state,hostname"
existing=Array.new
vm_pool.each do |vm|
  uid = vm['UID'].to_i
  if (userStats[uid].nil?)
    userStats[uid] = { :vms => 0, :oldvms => 0, :vmlist => String.new }
  end
  if ids.include? vm.id.to_i
    userStats[uid][:oldvms] = userStats[uid][:oldvms] + 1
    userStats[uid][:vmlist] << "#{vm.name} (id #{vm.id}#{vm['TEMPLATE/CONTEXT/PUBLIC_IP'].nil? ? "" : ", IP "}#{vm['TEMPLATE/CONTEXT/PUBLIC_IP']}), #{VM_STATE[vm['STATE'].to_i]}, #{vm['TEMPLATE/VCPU']} CPU, #{vm['TEMPLATE/MEMORY']} MB RAM (start #{Time.at(vm['STIME'].to_i)})\n"
    existing.insert(vm.id)
    puts "#{vm.id},#{vm['UID']}(#{vm['UNAME']}),#{vm.name},#{vm['TEMPLATE/CPU']},#{vm['TEMPLATE/VCPU']},#{vm['TEMPLATE/CONTEXT/PUBLIC_IP']},#{VM_STATE[vm['STATE'].to_i]},#{vm['HISTORY_RECORDS/HISTORY/HOSTNAME']}"
  end
end

puts "IDs that no longer exist: #{ids - existing}"


user_pool.each do |user|
  if ( (! userStats[user.id].nil?) and userStats[user.id][:oldvms] > 0 )
    message = template.gsub(/\$TOTALOLD/, "%d" % userStats[user.id][:oldvms]).gsub(/\$TOTAL/, "%d" % userStats[user.id][:vms]).gsub(/\$VMLIST/,userStats[user.id][:vmlist]).gsub(/\$USERNAME/,user.name)
    File.open("#{user['TEMPLATE/EMAIL']}", 'wt') { |file| file.write(message) }
  end
end


exit 0

