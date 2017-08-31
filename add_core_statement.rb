#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'optparse'
require 'CSV'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: add_core_statement.rb [options]"

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

tips = options[:sourcefile]

CSV.foreach(tips, :headers => true, :header_converters => :symbol) do |row|
    if(row[:tip_id])
        corestart = ""
        coreend = ""
        corestart = row[:core_start]
        coreend = row[:core_end]
        if(kb.addCore(row[:tip_id].to_s,corestart.to_s,coreend.to_s))
            puts "Done: " + row[:tip_id].to_s
        else
            puts "Issue adding Core dates to: " + row[:tip_id].to_s
        end
    else
        puts "No tip id"
    end
end