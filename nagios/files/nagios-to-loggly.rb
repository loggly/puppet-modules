#!/usr/bin/env ruby
require "rubygems"
require "eventmachine-tail"
require "em-http-request"
require "optparse"
require "json"

def main(args)
  url = nil
  
  opts = OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options]"

    opts.on("-u URL", "--url URL",
            "(required) The input key for the http input you configured on loggly") do |x|
      url = x
    end # -i / --input-key
  end # OptionParser.new

  opts.parse!(args)

  if !url
    $stderr.puts opts.banner
    $stderr.puts "No url specified (-u flag missing)"
    return 1
  end

  data = ENV.to_hash.reject { |k,value| k !~ /^NAGIOS_/ }.to_json

  EventMachine.run do
    http = EventMachine::HttpRequest.new(url)

    p :data => data
    req = http.post :body => data

    start = Time.now
    req.callback do
      # TODO(sissel): Parse the json response and report errors, if any.
      duration = Time.now - start
      puts "(#{duration} secs) #{req.response}"
      EventMachine::stop_event_loop
    end # req.callback
    req.errback do
      $stderr.puts "Error while sending '#{line}' to '#{url}' {#{req}}"
    end # req.errback
  end # EventMachine.run
end # def main

main(ARGV)
