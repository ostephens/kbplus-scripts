#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'optparse'
require 'CSV'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: accept_all_changes.rb [options]"

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

kb = Kb.new(options[:instance],options[:username],options[:password])
kb.login

subscriptions = options[:sourcefile]
CSV.open(options[:outputfile].to_s, 'w') do |csv_write|
    CSV.foreach(subscriptions, :headers => true, :header_converters => :symbol) do |row|
        
        sub_id = row[:sub_id]
        if(sub_id.is_a?(String))
            if(kb.checkforPendingchanges(sub_id))
                kb.acceptAll(sub_id)
                message = options[:instance] + "/subscriptionDetails/index/" + sub_id
            else
                message = "No pending changes for " + options[:instance] + "/subscriptionDetails/index/" + sub_id
            end
            csv_write << ([message])
        end
    end
end