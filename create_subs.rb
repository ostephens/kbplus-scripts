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
    
    opts.on("-s", "--subsfile [SUBSFILE]","Location of the subscriptions file") do |s|
        options[:subsfile] = s
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

subsfile = options[:subsfile]
puts "Processing " + subsfile + " ..."

subs = CSV.read(subsfile, :headers => true, :header_converters => :symbol)
orgs = subs[:institutionname].uniq
proceed = true

orgs.each do |inst|
    inst = inst.strip.gsub(" ","_")
    if(!kb.checkInstitution(inst))
        puts inst + ": dashboard was not available. Check shortcode and membership before proceeding"
        proceed = false
    end
end
if(!proceed)
    puts "Not proceeding"
    exit
else
    puts "Proceeding ..."
end

CSV.open('subs-created.csv', 'w') do |writer|
    orgs.each do |inst|
        puts "STARTING: " + inst
        CSV.foreach(subsfile, :headers => true, :header_converters => :symbol) do |row|
            if (row[:institutionname] == inst)
                kb.org = inst.strip.gsub(" ","_")
                sdate = row[:subscriptionstart]
                edate = row[:subscriptionexpiry]
                name = row[:resourcename]
                ref = row[:subscriptionid]
                #ref = SecureRandom.uuid
                sub_url = kb.createSubscription(name,ref,sdate,edate)
                writer << ([sub_url] + row.fields)
            end
        end
        puts "END OF INSTITUTION"
    end
end