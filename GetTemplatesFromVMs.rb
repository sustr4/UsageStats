#!/usr/bin/env ruby



require 'opennebula'
include OpenNebula

# XML_RPC endpoint where OpenNebula is listening
ONE_HOST=ENV["ONE_HOST"]
ENDPOINT=ENV["ONE_XMLRPC"]

#Sorry, I know this is dirty
VM_STATE = %w{INIT PENDING HOLD ACTIVE STOPPED SUSPENDED DONE FAILED POWEROFF UNDEPLOYED}

template = File.read("template_warn.txt")


client = Client.new(nil, ENDPOINT)

vm_pool = VirtualMachinePool.new(client, -1)

rc = vm_pool.info_all
if OpenNebula.is_error?(rc)
  puts rc.message
  exit -1
end

userStats = Array.new

vm_pool.each do |vm|
  uid = vm['UID'].to_i
#  puts "Virtual Machine\t#{vm.id}\t#{uid}(#{vm['UNAME']})\t#{vm.name}\t#{vm['TEMPLATE/CPU']}\t#{vm['TEMPLATE/VCPU']}\t#{vm['TEMPLATE/CONTEXT/PUBLIC_IP']}\t#{vm['STATE']}"
  puts "#{vm.id}\t#{vm['TEMPLATE']}"
end

exit 0

