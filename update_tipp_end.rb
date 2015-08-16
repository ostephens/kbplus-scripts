#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'optparse'
require 'CSV'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: rename_packages.rb [options]"

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

    opts.on("-q", "--packageid [PACKAGEID]", "Package ID") do |q|
        options[:packageid] = [q]
    end

    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end
end.parse!

kb = Kb.new(options[:instance],options[:username],options[:password])
kb.login

titles = options[:sourcefile]
packageid = options[:packageid]

CSV.foreach(titles, :headers => true, :header_converters => :symbol) do |row|
    edate = ""
    evol = ""
    eiss = ""
    edate = row[:date_last_issue_online]
    evol = row[:num_last_vol_online]
    eiss = row[:num_last_issue_online]
    if(edate.to_s.length === 0 || edate === "NULL")
        edate = ""
    end
    if(evol.to_s.length === 0 || evol === "NULL")
        evol = ""
    end
    if(eiss.to_s.length === 0 || eiss === "NULL")
        eiss = ""
    end
    tipp_id = kb.getTIPPfromTI(row[:ti_id],packageid)
    if(tipp_id.is_a?(String))
        kb.updateTIPPend(tipp_id,edate,evol,eiss)
        puts "kbplus/tipp/show/" + tipp_id + "," + edate + "," + evol + "," + eiss
    end
end