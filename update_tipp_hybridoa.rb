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
    begin
        tipp_id = kb.getTIPPfromTI(row[:ti_id],packageid)
        puts packageid.to_s + "\t" + row[:ti_id].to_s
    rescue
        puts packageid.to_s + "\t" + row[:ti_id].to_s + "\tFAILED"
    end
    if(tipp_id.is_a?(String))
        hybrid_oa_status = row[:hybrid_oa_status]
        begin
            kb.updateTIPPHybridOA(tipp_id,,hybrid_oa_status)
            puts "kbplus/tipp/show/" + tipp_id
        rescue
            puts "kbplus/tipp/show/" + tipp_id + "\tFAILED"
        end
    end
end
