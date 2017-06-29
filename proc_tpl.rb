#!/usr/bin/ruby

require 'nokogiri'
require 'pp'

roottag = 'VM'
#roottag = 'VMTEMPLATE'

xml = File.read(ARGV[0])

template = Nokogiri::XML(xml)

#line << "id;low_id;user;disk_format;white_tcp;black_tcp;white_udp;black_udp;files_ds;raw_type;onegate_http\n"

line = String.new
found = false

id = template.at_xpath("//#{roottag}/ID").content
line << id + ";"

if roottag == 'VM' and id.to_i <= 20000
  line << "1;"
else
  line << "0;"
end


line << template.at_xpath("//#{roottag}/UNAME").content + ";"

#format
fmt = template.at_xpath("//VMTEMPLATE/TEMPLATE/DISK/FORMAT")
unless fmt.nil?
  line << fmt.content
  found = true
end
line << ";"


#WHITE_PORTS_TCP
wptcp = template.at_xpath("//#{roottag}/TEMPLATE/NIC/WHITE_PORTS_TCP")
unless wptcp.nil?
  line << wptcp.content
  found = true
end
line << ";"

#BLACK_PORTS_TCP
bptcp = template.at_xpath("//#{roottag}/TEMPLATE/NIC/BLACK_PORTS_TCP")
unless bptcp.nil?
  line << bptcp.content
  found = true
end
line << ";"

#WHITE_PORTS_UDP
wpudp = template.at_xpath("//#{roottag}/TEMPLATE/NIC/WHITE_PORTS_UDP")
unless wpudp.nil?
  line << wpudp.content
  found = true
end
line << ";"

#BLACK_PORTS_UDP
bpudp = template.at_xpath("//#{roottag}/TEMPLATE/NIC/BLACK_PORTS_UDP")
unless bpudp.nil?
  line << bpudp.content
  found = true
end
line << ";"

#FILES_DS
ds = template.at_xpath("//#{roottag}/TEMPLATE/CONTEXT/FILES_DS")
unless ds.nil?
  line << ds.content
  found = true
end
line << ";"

#RAW/TYPE
raw = template.at_xpath("//#{roottag}/TEMPLATE/RAW/TYPE")
unless raw.nil?
  if raw.content == "xen"
    line << raw.content
    found = true
  end
end
line << ";"

#RAW/TYPE
raw = template.at_xpath("//#{roottag}/TEMPLATE/CONTEXT/ONEGATE_URL")
unless raw.nil?
  if raw.content.start_with?("http://")
    line << raw.content
    found = true
  end
end



puts line if found


#VMTEMPLATE/TEMPLATE/DISK/FORMAT|VMTEMPLATE/TEMPLATE/NIC/WHITE_PORTS_TCP|VMTEMPLATE/TEMPLATE/NIC/BLACK_PORTS_TCP|VMTEMPLATE/TEMPLATE/NIC/WHITE_PORTS_UDP|VMTEMPLATE/TEMPLATE/NIC/BLACK_PORTS_UDP|VMTEMPLATE/TEMPLATE/CONTEXT/FILES_DS|VMTEMPLATE/TEMPLATE[contains(RAW/TYPE, 'xen')]|VMTEMPLATE/TEMPLATE[contains(CONTEXT/ONEGATE_URL, 'http://')]|| 

