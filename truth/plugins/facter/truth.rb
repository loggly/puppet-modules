require "rubygems"
require "json"
require "csv"

if File.exists?("/var/spool/ec2/meta-data-cache")
  truth_source = "rightscale"
else
  # Default truth source is local.
  truth_source = "local"
end

def safe_hostname(value)
  return value.downcase.gsub(/[^A-Za-z0-9-]/, "")
end

DOMAIN = "example.com"

Facter.add("truth_source") do
  setcode do
    truth_source
  end # setcode
end

begin
  data = JSON.parse(File.open("/etc/truth.json").read)

  # Write truth to csv so extlookup() can use it.
  # This is in response to puppet issue #5212.
  truthcsv_path  = "/opt/loggly/deployment/truth.csv"
  truthcsv_file = File.open(truthcsv_path + ".new", "w")
  truthcsv = CSV::Writer.create(truthcsv_file)

  by_tag = Hash.new { |h,k| h[k] = Array.new() }
  data["servers"].each do |name, settings|
    settings["tags"].each do |tag|
      if settings["private_ip_address"]
        by_tag[tag] << settings["private_ip_address"]
      end
    end # settings["tags"].each
  end # data["servers"].each

  myself = data["servers"][data["name"]]
  Facter.add("server_tags") do
    setcode do
      myself["tags"].sort.join(",")
    end # setcode
  end # Facter.add("server_tags")
  truthcsv << [ "truth/server_tags", *myself["tags"] ]

  myself["tags"].each do |tag|
    key, value = tag.split("=")
    if value == nil
      value = "true"
    end
    truthcsv << [ "truth/#{key}", value ]

    Facter.add(key) do
      setcode do
        value
      end
    end
  end # myself["tags"].each

  Facter.add("deployment") do
    setcode do
      data["deployment"]
    end # setcode
  end # Facter.add("deployment")
  truthcsv << [ "truth/deployment", data["deployment"] ]

  Facter.add("deployment_domain") do
    setcode do
      safe_hostname(data["deployment"]) + ".#{DOMAIN}"
    end # setcode
  end # Facter.add("deployment_domain")
  truthcsv << [ "truth/deployment_domain", safe_hostname(data["deployment"]) + ".#{DOMAIN}" ]

  Facter.add("deployment_hostname") do
    setcode do
      begin
        Facter.deployment_domain
      rescue
        Facter.loadfacts()
      end
      "#{safe_hostname(data["name"])}.#{Facter.value("deployment_domain")}"
    end # setcode
  end # Facter.add("deployment_hostname")
  truthcsv << [
    "truth/deployment_hostname", 
    [ safe_hostname(data["name"]), safe_hostname(data["deployment"]), DOMAIN ].join(".")
  ]

  Facter.add("roles_list") do
    setcode do
      by_tag.keys.grep(/^role:/).collect { |tag| tag.split(/[:=]/)[1] }.join(",")
    end
  end
  truthcsv << [ 
    "truth/roles_list", 
    by_tag.keys.grep(/^role:/).collect { |tag| tag.split(/[:=]/)[1] }
  ]

  by_tag.each do |tag, servers|
    next unless tag =~ /^role:/
    role = tag.split(/[:=]/)[1]
    Facter.add("role_#{role}") do
      setcode do
        servers.sort.join(",")
      end # setcode
    end # Facter.add
    truthcsv << [ "truth/role_#{role}", *servers.sort ]
  end # by_tag.each

  truthcsv.close
  truthcsv_file.close
  File.rename(truthcsv_path + ".new", truthcsv_path)
rescue => e
  $stderr.puts "Failed loading /tmp/truth.json, #{e}"
  $stderr.puts "Backtrace"
  $stderr.puts e.backtrace
end
