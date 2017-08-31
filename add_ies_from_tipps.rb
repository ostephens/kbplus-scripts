#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'optparse'
require 'CSV'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: add_ies_from_tipps.rb [options]"

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

    opts.on("-t", "--subscription [SUBSCRIPTION]", "Subscription") do |t|    
        options[:subscription] = t
    end
    
    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end
    
end.parse!

kb = Kb.new(options[:instance],options[:username],options[:password])
kb.login

tipps = options[:sourcefile]
subscription_id = options[:subscription]

CSV.foreach(tipps, :headers => true, :header_converters => :symbol) do |row|
    if(row[:tipp_id])
        begin
            kb.addIE(subscription_id,row[:tipp_id])
        rescue
            puts "Could not create an IE for " + row[:tipp_id] + " on subscription " + subscription_id
        end
    end
end