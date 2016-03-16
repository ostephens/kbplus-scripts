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

    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end
end.parse!

kb = Kb.new(options[:instance],options[:username],options[:password])
kb.login

titles = options[:sourcefile]

CSV.foreach(titles, :headers => true, :header_converters => :symbol) do |row|
    sdate = ""
    svol = ""
    siss = ""
    sdate = row[:date_first_issue_online]
    svol = row[:num_first_vol_online]
    siss = row[:num_first_issue_online]
    if(sdate.to_s.length === 0 || sdate === "NULL")
        sdate = ""
    end
    if(svol.to_s.length === 0 || svol === "NULL")
        svol = ""
    end
    if(siss.to_s.length === 0 || siss === "NULL")
        siss = ""
    end
    tipp_id = row[:tipp_id]
    if(tipp_id.is_a?(String))
        kb.updateTIPPstart(tipp_id,sdate,svol,siss)
        puts "kbplus/tipp/show/" + tipp_id
    end
end