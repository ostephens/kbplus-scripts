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

titles = options[:sourcefile]
CSV.open(options[:outputfile].to_s, 'w') do |csv_write|
    CSV.foreach(titles, :headers => true, :header_converters => :symbol) do |row|
        ## get all TIPPs for the TI
        tipps = kb.getTIPPsfromTI(row[:ti_id])
        tipps.each do |tipp_id|
            if(tipp_id.is_a?(String))
                #kb.makeTIPPOA(tipp_id)
                tipp_url = "kbplus/tipp/show/" + tipp_id.to_s
                csv_write << [row[:ti_id],tipp_url]
                puts row[:ti_id] + "," + tipp_url
            end
        end
    end
end