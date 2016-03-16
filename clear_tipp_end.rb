#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'optparse'
require 'CSV'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: clear_tipp_end.rb [options]"

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

tipps = options[:sourcefile]
packageid = options[:packageid]

CSV.foreach(tipps, :headers => true, :header_converters => :symbol) do |row|
    edate = ""
    evol = ""
    eiss = ""
    tipp_id = row[:tipp_id]
    if(tipp_id.is_a?(String))
        kb.updateTIPPend(tipp_id,edate,evol,eiss)
        puts "kbplus/tipp/show/" + tipp_id + "," + edate + "," + evol + "," + eiss
    end
end