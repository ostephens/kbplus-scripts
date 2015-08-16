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
    opts.banner = "Usage: join.rb [options]"

    opts.on("-i", "--instance [INSTANCE]","www, test, demo or dev") do |i|
        options[:instance] = i
    end
    
    opts.on("-o", "--orgfile [ORGFILE]","Location of the organisations file") do |o|
        options[:orgfile] = o
    end

    opts.on("-p", "--password [PASSWORD]","Password") do |p|
        options[:password] = p
    end

    opts.on("-u", "--username [USERNAME]","Username") do |u|
        options[:username] = u
    end

    opts.on("-d", "--displayname [DISPLAYNAME]","Display name in KB+") do |d|
        options[:displayname] = d
    end

    opts.on("-r", "--role [ROLE]","User role: 5 = Institutional editor, 6 = Read only") do |r|
        options[:role] = r
    end

    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end
end.parse!

kb = Kb.new(options[:instance],options[:username],options[:password])
kb.loginJisc

orgfile = options[:orgfile]

CSV.foreach(orgfile, :headers => true, :header_converters => :symbol) do |row|
	if (row[:org_id])
		kb.joinOrg(row[:org_id],options[:role])
		#kb.approveAffiliation(options[:displayname])
		puts "Joined: " + row[:org_name]
	else
		next
	end
end