#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'CSV'
require 'date'
require 'open-uri'
require 'optparse'
require 'uri'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: create_subs.rb [options]"

    opts.on("-i", "--instance [INSTANCE]","www, test, demo or dev") do |i|
        options[:instance] = i
    end
    
    opts.on("-o", "--orgsfile [ORGSFILE]","Location of the Organizations file") do |s|
        options[:orgsfile] = s
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

#Need to check access to http://test.kbplus.ac.uk/kbplus/myInstitutions/{#org}/dashboard is OK
#Get all Org values: 
# subs = CSV.read(subsfile, :headers => true, :header_converters => :symbol)
# subs[:institutionname] is an array of names - unique then check each one
# throw error on any that don't give a 200
# then process file using institutionname to set org

orgsfile = options[:orgsfile]
puts "Processing " + orgsfile + " ..."

orgslist = CSV.read(orgsfile, :headers => true, :header_converters => :symbol)
orgs = orgslist[:institutionname].uniq
proceed = true

orgs.each do |inst|
    inst = inst.strip.gsub(" ","_")
    if(!kb.checkInstitution(inst))
        puts inst + ": dashboard was not available. Check shortcode and membership before proceeding"
        proceed = false
    end
end