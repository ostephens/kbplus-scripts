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
    opts.banner = "Usage: create_orgs.rb [options]"

    opts.on("-i", "--instance [INSTANCE]","www, test, demo or dev") do |i|
        options[:instance] = i
    end
    
    opts.on("-o", "--orgfile [ORGFILE]","Location of the organisations file") do |o|
        options[:orgfile] = o
    end

    opts.on("-p", "--password [PASSWORD]","Password") do |p|
        options[:password] = p
    end

    opts.on("-s", "--sector [SECTOR]","Specify default sector for orgs in file") do |s|
        options[:sector] = s
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

orgfile = options[:orgfile]
sector = options[:sector]
puts orgfile
CSV.foreach(orgfile, :headers => true, :header_converters => :symbol) do |row|
	if (row[:name])
		org_name = row[:name]
	else
		next
	end
	if (row[:sector])
		sector = row[:sector]
	end
	kb.createOrganisation(org_name,sector)
end