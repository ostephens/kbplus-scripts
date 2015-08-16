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
    opts.banner = "Usage: process_package_download.rb [options]"

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

CSV.open(options[:outputfile].to_s, 'w') do |csv_write|
	Dir.glob(sourcedir) do |path|
		file = File.new(path)
        puts path
		CSV.foreach(file, :headers => true, :header_converters => :symbol) do |row|
    		csv_write << ([row,path])
        end
	end
end