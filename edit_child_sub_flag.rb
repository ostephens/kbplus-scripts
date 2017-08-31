#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'CSV'
require 'date'
require 'open-uri'
require 'optparse'
require 'uri'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: create_subs.rb [options]"

    opts.on("-i", "--instance [INSTANCE]","www, test, demo or dev") do |i|
        options[:instance] = i
    end
    
    opts.on("-s", "--subsfile [SUBSFILE]","Location of the subscriptions file") do |s|
        options[:subsfile] = s
    end

    opts.on("-p", "--password [PASSWORD]","Password") do |p|
        options[:password] = p
    end

    opts.on("-u", "--username [USERNAME]","Username") do |u|
        options[:username] = u
    end

    opts.on("-c", "--childsubs [CHILDSUBS]","'y' or 'n'") do |c|
        options[:childsubs] = c
    end

    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end
end.parse!

kb = Kb.new(options[:instance],options[:username],options[:password])
kb.login


subsfile = options[:subsfile]


children = options[:childsubs]
if(children=='y')
    if(options[:instance]=='test')
        refval = '108'
    elsif(options[:instance]=='kbplus')
        refval = '108'
    elsif(options[:instance]=='demo')
        refval = '108'
    else
        refval = false
    end
elsif(children=='n')
    if(options[:instance]=='test')
        refval = '109'
    elsif(options[:instance]=='kbplus')
        refval = '109'
    elsif(options[:instance]=='demo')
        refval = '109'
    else
        refval = false
    end
else
    refval = false
end

CSV.foreach(subsfile, :headers => true, :header_converters => :symbol) do |row|
    if(refval)
        subid = row[:sub_id] #need to extract sub id from url
        kb.makeChildsub(subid,refval)
        puts "Updated: "+subid
    end
end