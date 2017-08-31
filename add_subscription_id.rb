#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'CSV'
require 'optparse'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: add_subscription_id.rb [options]"

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

    opts.on("-o", "--outputfile OUTPUTFILE", "Output File") do |o|
        options[:outputfile] = o
    end

    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end
end.parse!

subscriptions = options[:sourcefile]

kb = Kb.new(options[:instance],options[:username],options[:password])
kb.login

CSV.open(options[:outputfile].to_s, 'w') do |csv_write|
    CSV.foreach(subscriptions, :headers => true, :header_converters => :symbol) do |row|
        sub_identifier_ns = row[:idns]
        sub_identifier = row[:sub_identifier]
        sub_id = row[:sub_id]

        add_id = sub_identifier_ns.to_s+":"+sub_identifier.to_s

        if(kb.checkId(add_id))
            puts "Adding ID: " + add_id.to_s + " to " + sub_id.to_s
            msg = "Adding ID: " + add_id.to_s + " to " + sub_id.to_s
            kb.addSubscriptionid(sub_id,add_id)
        else
            msg = add_id.to_s + " already exists as an ID in KB+"
        end
        puts msg
        csv_write << ([sub_id,msg])
    end
end
