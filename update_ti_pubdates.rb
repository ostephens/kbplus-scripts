#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'CSV'
require 'json'
require 'open-uri'
require 'optparse'
require 'uri'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: update_ti_pubdates.rb [options]"

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
        ti_id = row[:ti_id]
        from_date = row[:published_from_date]
        to_date = row[:published_to_date]
        if(from_date.to_s.length > 0)
            kb.updateTiPublishedFrom(ti_id,from_date)
        end
        if(to_date.to_s.length > 0)
            kb.updateTiPublishedTo(ti_id,to_date)
        end

        message = "Updated dates for http://www.kbplus.ac.uk/" + options[:instance] + "/titleDetails/show/" + ti_id

        csv_write << ([message])
    end
end