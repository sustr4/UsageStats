#!/usr/bin/ruby

require 'nokogiri'
require 'pp'
require 'date'

roottag = 'VMS'

#flags = [ "cutyear" ]
flags = [  ]

#collapse_groups = [ ]
collapse_groups = [ "oneadmin", "fedcloud.egi.eu", "kypo", "mycroftmind", "peachnote.com", "enmr.eu", "perun", "sdi4apps", "cerit-sc", "cloud-devel", "portals-admins", "bioconductor", "vo.nextgeoss.eu", "chipster.csc.fi", "eo-poc-nuvla", "secant-service", "bioconductor-teachers", "irys-vuvl", "gputest.metacentrum.cz", "a2", "training.egi.eu", "vo.elixir-europe.org", "sdn-mu", "appdb-general", "rt", "dexlandia", "ops", "cloud-service-users", "demo.fedcloud.egi.eu" ]

#separate_users = [ ]
separate_users = [ "cerit-sc-admin" ]

nebulenko = {
  'dukan' => {
    0 => 2 },
  'duilin' => {
    0 => 2 },
  'warg' => {
    0 => 1,
    1498089600 => 2  # 22. 6. 2017
  }
}

xml = File.read(ARGV[0])

year = ARGV[1].nil? ? 2017 : ARGV[1].to_i
ystart = DateTime.parse("#{year}-01-01T00:00:00+01:00").to_time.to_i
yend = DateTime.parse("#{year+1}-01-01T00:00:00+01:00").to_time.to_i

all = Nokogiri::XML(xml)


puts "\"id\",\"cluster\",\"cloud\",\"user\",\"group\",\"VM Start\",\"VM End\",\"Segment Start\",\"Segment End\",\"CPU\",\"real CPU\",\"vCPU\",\"Lifetime (s)\",\"Lifetime (hrs)\",\"Lifetime (weeks)\",\"Record life (weeks)\",\"CPU Hours\",\"< 1 hr\",\"< 1 day\",\"< 1 week\",\"< 1 month\",\"> 1 month\",\"Histogram tag\""

all.xpath("//#{roottag}/VM").each do |template|

  id = template.at_xpath("./ID").content
  if template.at_xpath("./USER_TEMPLATE/USER_IDENTITY").nil? then
    user = template.at_xpath("./UNAME").content
  else
    user = template.at_xpath("./USER_TEMPLATE/USER_IDENTITY").content
  end

  group = template.at_xpath("./GNAME").content

  if separate_users.include? user then
    group = "Also in #{group}"
  end

  if collapse_groups.include? group then
    user = "All members combined"
  end

  cpu = template.at_xpath("./TEMPLATE/CPU").nil? ? 0 : template.at_xpath("./TEMPLATE/CPU").content.to_f
  real_cpu = cpu
  vcpu = template.at_xpath("./TEMPLATE/VCPU").nil? ? cpu : template.at_xpath("./TEMPLATE/VCPU").content.to_f
  vmstime = template.at_xpath("./STIME").content.to_i
  vmetime = template.at_xpath("./ETIME").content.to_i

  template.xpath("./HISTORY_RECORDS/HISTORY").each do |hist|

    cluster = hist.at_xpath("./HOSTNAME").content.gsub(/[0-9.].*/, "")

    if cluster == "warg" then
      cloud = "FedCloud"
    elsif ["dukan", "minos", "duilin", "gorbag"].include? cluster then
      cloud = "MetaCloud"
    else
      cloud = "Cerit"
    end

    stime = hist.at_xpath("./STIME").content.to_i
    etime = hist.at_xpath("./ETIME").content.to_i

    if stime == 0 then
      stime = vmstime
    end

    if flags.include? "cutyear" then
      etime = yend if (etime == 0)
      etime = yend if (etime > yend)
      stime = ystart if (stime < ystart)
      etime = ystart if (etime < ystart)
      stime = yend if (stime > yend)
    else
      etime = Time.now.to_i if (etime == 0)
    end

    if vmetime == 0 then
      vmetime = Time.now.to_i
    end

    duration = etime-stime
    if duration < 3600 then
      duraflag = "1,0,0,0,0,\"< 1 hour\""
    elsif duration < 86400 then
      duraflag = "0,1,0,0,0,\"< 1 day\""
    elsif duration < 604800 then
      duraflag = "0,0,1,0,0,\"< 1 week\""
    elsif duration < 2592000 then
      duraflag = "0,0,0,1,0,\"< 1 month\""
    else
      duraflag = "0,0,0,0,1,\"> 1 month\""
    end

    if nebulenko.has_key?(cluster) then
      nebulenko[cluster].each do | start, factor | 
        puts "Comparing #{stime} > #{start}"
        if stime > start then
          real_cpu = cpu * factor
        end
      end
    end

    if stime != etime then
      puts "#{id},#{cluster},#{cloud},\"#{user}\",\"#{group}\",#{Time.at(vmstime)},#{Time.at(vmetime)},#{Time.at(stime)},#{Time.at(etime)},#{cpu},#{real_cpu},#{vcpu},#{duration},#{'%.2f' % (duration/3600.0)},#{(duration/604800).round},#{((vmetime-vmstime)/604800.0).round},#{'%.2f' % (cpu*(duration/3600.0))},#{duraflag}"
    end
  end
end



