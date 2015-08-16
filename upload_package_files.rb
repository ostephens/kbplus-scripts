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
    opts.banner = "Usage: process_swets_file.rb [options]"

    opts.on("-i", "--instance [INSTANCE]","www, test, demo or dev") do |i|
        options[:instance] = i
    end

    opts.on("-p", "--password [PASSWORD]","Password") do |p|
        options[:password] = p
    end

    opts.on("-u", "--username [USERNAME]","Username") do |u|
        options[:username] = u
    end

    opts.on("-s", "--sourcedir [SOURCEDIR]", "Source Directory") do |s|
        options[:sourcedir] = s
    end

    opts.on("-o", "--outputfile OUTPUTFILE", "Output File") do |o|
        options[:outputfile] = o
    end

    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end
end.parse!

sourcedir = options[:sourcedir]

if (sourcedir[-1,1] != '/')
    sourcedir = sourcedir + "/"
end
sourcedir = sourcedir + "*.csv"

kb = Kb.new(options[:instance],options[:username],options[:password])
kb.login
CSV.open(options[:outputfile].to_s, 'w') do |csv_write|
	Dir.glob(sourcedir) do |path|
		file = File.new(path)
		result = kb.uploadPackage(file)
		csv_write << ([path,result.to_s])
	end
end