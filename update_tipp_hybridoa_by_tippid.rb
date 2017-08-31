#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'optparse'
require 'CSV'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: update_tipp_hybridoa_by_tippid.rb [options]"

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

CSV.foreach(tipps, :headers => true, :header_converters => :symbol) do |row|
    tipp_id = row[:tipp_id]
    hybrid_oa_status = row[:hybrid_oa_status]
    if(tipp_id.is_a?(String))
        begin
            kb.updateTIPPHybridOA(tipp_id,hybrid_oa_status)
            puts "kbplus/tipp/show/" + tipp_id
        rescue
            puts "kbplus/tipp/show/" + tipp_id + "\tFAILED"
        end
    end
end
