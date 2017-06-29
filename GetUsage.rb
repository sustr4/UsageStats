#!/usr/bin/env ruby



require 'opennebula'
include OpenNebula

# XML_RPC endpoint where OpenNebula is listening
ONE_HOST=ENV["ONE_HOST"]
ENDPOINT=ENV["ONE_XMLRPC"]

age = 2 #Two months
agets = age * 2592000
now = Time.now.to_i
thresh = now - agets

#Sorry, I know this is dirty
VM_STATE = %w{INIT PENDING HOLD ACTIVE STOPPED SUSPENDED DONE FAILED POWEROFF UNDEPLOYED}

template = File.read("template_warn.txt")


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

vm_pool.each do |vm|
  uid = vm['UID'].to_i
#  puts "Virtual Machine\t#{vm.id}\t#{uid}(#{vm['UNAME']})\t#{vm.name}\t#{vm['TEMPLATE/CPU']}\t#{vm['TEMPLATE/VCPU']}\t#{vm['TEMPLATE/CONTEXT/PUBLIC_IP']}\t#{vm['STATE']}"
  if (userStats[uid].nil?)
    userStats[uid] = { :vms => 0, :oldvms => 0, :vmlist => String.new }
  end
  if ( vm['STATE'].to_i < 9 ) # Skip undeployed machines
    userStats[uid][:vms] = userStats[uid][:vms] + 1
    if ( vm['STIME'].to_i < thresh )
      userStats[uid][:oldvms] = userStats[uid][:oldvms] + 1
      userStats[uid][:vmlist] << "#{vm.name} (id #{vm.id}#{vm['TEMPLATE/CONTEXT/PUBLIC_IP'].nil? ? "" : ", IP "}#{vm['TEMPLATE/CONTEXT/PUBLIC_IP']}), #{VM_STATE[vm['STATE'].to_i]}, #{vm['TEMPLATE/VCPU']} CPU, #{vm['TEMPLATE/MEMORY']} MB RAM (start #{Time.at(vm['STIME'].to_i)})\n"
    end
  end
end

user_pool.each do |user|
#  puts "User\t#{user.id}\t#{user['UNAME']}\t#{user.name}\t#{user['TEMPLATE/EMAIL']}"
  if ( (! userStats[user.id].nil?) and userStats[user.id][:oldvms] > 0 )
#    puts "#{user['TEMPLATE/EMAIL']} (#{user.name} -- #{userStats[user.id][:vms]} #{userStats[user.id][:vms] > 1 ? "VMs" : "VM"} older than #{age} months)\n#{userStats[user.id][:vmlist]}"
    message = template.gsub(/\$TOTALOLD/, "%d" % userStats[user.id][:oldvms]).gsub(/\$TOTAL/, "%d" % userStats[user.id][:vms]).gsub(/\$THRESHOLD/, "%d" % age).gsub(/\$VMLIST/,userStats[user.id][:vmlist]).gsub(/\$USERNAME/,user.name)
    File.open("#{user['TEMPLATE/EMAIL']}", 'wt') { |file| file.write(message) }
  end
end

exit 0

