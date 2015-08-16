#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'CSV'
require 'json'
require 'open-uri'
require 'optparse'
require 'uri'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: soft_delete_tipp.rb [options]"

    opts.on("-i", "--instance [INSTANCE]","www, test, demo or dev") do |i|
        options[:instance] = i
    end
    
    opts.on("-t", "--tippfile [TIPPFILE]","Location of the tipp file") do |t|
        options[:tippfile] = t
    end

    opts.on("-p", "--password [PASSWORD]","Password") do |p|
        options[:password] = p
    end

    opts.on("-u", "--username [USERNAME]","Username") do |u|
        options[:username] = u
    end

    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end
end.parse!

kb = Kb.new(options[:instance],options[:username],options[:password])
kb.login

tippfile = options[:tippfile]
CSV.foreach(tippfile, :headers => true, :header_converters => :symbol) do |row|
	if (row[:tippid])
		tipp_id = row[:tippid]
	else
		next
	end
	kb.softdeleteTipp(tipp_id)
end