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
    opts.banner = "Usage: create_licences.rb [options]"

    opts.on("-i", "--instance [INSTANCE]","www, test, demo or dev") do |i|
        options[:instance] = i
    end
    
    opts.on("-l", "--licencefile [LICFILE]","Location of the licences file") do |l|
        options[:licfile] = l
    end

    opts.on("-p", "--password [PASSWORD]","Password") do |p|
        options[:password] = p
    end

    opts.on("-u", "--username [USERNAME]","Username") do |u|
        options[:username] = u
    end

    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end
end.parse!

kb = Kb.new(options[:instance],options[:username],options[:password])
kb.login

licfile = options[:licfile]
CSV.open('lics-created.csv', 'w') do |writer|
    CSV.foreach(licfile, :headers => true, :header_converters => :symbol) do |row|
    	if (row[:name])
    		lic_name = row[:name]
            newlic = kb.createLicencetemplate(lic_name)
            writer << ([lic_name.to_s,newlic.to_s])
    	end
    end
end

