#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'optparse'
require 'CSV'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: add_org_id.rb [options]"

    opts.on("-i", "--instance [INSTANCE]","www, test, demo or dev") do |i|
        options[:instance] = i
    end

    opts.on("-p", "--password [PASSWORD]","Password") do |p|
        options[:password] = p
    end

    opts.on("-u", "--username [USERNAME]","Username") do |u|
        options[:username] = u
    end

    opts.on("-s", "--sourcefile [SOURCEFILE]", "Source file") do |s|
        options[:sourcefile] = s
    end

    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end
end.parse!

kb = Kb.new(options[:instance],options[:username],options[:password])
kb.login

orgdetails = options[:sourcefile]

CSV.foreach(orgdetails, :headers => true, :header_converters => :symbol) do |row|
    if (row[:org_id])
        if(kb.checkId(row[:jisc_id]))
            puts "Adding ID: " + row[:jisc_id].to_s + " to " + row[:org_id].to_s
            kb.addOrgid(row[:org_id],row[:jisc_id])
        else
            puts row[:jisc_id].to_s + " already exists as an ID in KB+"
        end
    end
end

