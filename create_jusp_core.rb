#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'optparse'
require 'open-uri'
require 'CSV'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: create_jusp_core.rb [options]"

    opts.on("-i", "--instance [INSTANCE]","www, test, demo or dev") do |i|
        options[:instance] = i
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
current = DateTime.now

puts kb.fetchAlltips

CSV.open('all-core-info.csv', 'w') do |writer|
    writer <<(["JUSP Institution ID","JUSP Title ID","JUSP Provider"," Core Dates"])
    CSV.new(kb.fetchAlltips, encoding: "utf-8", :headers => true, :header_converters => :symbol).each do |row|
        if(row[:jusp_provider]=="")
            next
        end
        core = false
        row[:_core_dates].split(",").each do |range|
            if(range.split(":")[1].strip == "")
                core = true
                break
            end
            sdate = DateTime.parse(range.split(":")[0].strip)
            edate = DateTime.parse(range.split(":")[1].strip)
            if(current>sdate && current <edate)
                core = true
                break
            end
        end
        if(core==true)
            writer << (row)
        end
    end
end