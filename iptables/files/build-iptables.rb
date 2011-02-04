#!/usr/bin/env ruby

Dir["/etc/iptables.d/*"].each do |tablepath|
  table = File.basename(tablepath)
  rules = Dir["#{tablepath}/*"].collect { |path| File.basename(path) }

  if rules.length > 0
    puts "*#{table}"   # like '*filter'
    rules.sort { |a,b| a.to_i <=> b.to_i }.each do |rule|
      puts File.new("#{tablepath}/#{rule}").read()
    end
    puts "COMMIT"
  end

end
