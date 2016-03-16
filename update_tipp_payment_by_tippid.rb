#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'optparse'
require 'CSV'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: update_tipp_url.rb [options]"

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
    payment = row[:tipp_payment_rv_fk]
    tipp_id = row[:tipp_id]
    if(tipp_id.is_a?(String))
        if(payment == "236")
            begin
                kb.makeTIPPOA(tipp_id)
                puts "kbplus/tipp/show/" + tipp_id + "\tOA"
            rescue
                puts "kbplus/tipp/show/" + tipp_id + "\tFAILED"
            end
        elsif (payment == "238")
            begin
                kb.makeTIPPUncharged(tipp_id)
                puts "kbplus/tipp/show/" + tipp_id + "\tUncharged"
            rescue
                puts "kbplus/tipp/show/" + tipp_id + "\tFAILED"
            end
        end
    end
end
