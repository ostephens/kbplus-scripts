#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'optparse'
require 'CSV'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: update_orgs.rb [options]"

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
    if (row[:kb_id])
        name=false
        address=false
        iprange=false
        sector=false
        if (row[:kb_name] && row[:kb_name].length > 0)
            name = row[:kb_name]
        end
        if (row[:ip_address] && row[:ip_address].length > 0)
            iprange = row[:ip_address]
        end
        kb.updateOrganisation(row[:kb_id],address,iprange,sector,name)
        puts row.to_s
        puts "organisations/show/" + row[:kb_id].to_s
    end
end

