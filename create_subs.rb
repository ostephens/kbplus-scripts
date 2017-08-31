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
    puts "Checking: " + inst
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

#Set 'child' refvalue
if(options[:instance]=='test')
    refval = '108'
elsif(options[:instance]=='kbplus')
    refval = '108'
elsif(options[:instance]=='demo')
    refval = '108'
else
    refval = false
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
                child = row[:childstatus]
                #ref = SecureRandom.uuid
                sub_url = kb.createSubscription(name,ref,sdate,edate)
                subid = sub_url.split("/")[-1] #need to extract sub id from url
                if(child == "yes" && refval)
                    kb.makeChildsub(subid,refval)
                end

                sub_identifier_ns = "jc"
                sub_identifier = ref
                sub_id = subid
                add_id = sub_identifier_ns.to_s+":"+sub_identifier.to_s

                if(kb.checkId(add_id))
                    msg = "Adding ID: " + add_id.to_s + " to " + sub_id.to_s
                    kb.addSubscriptionid(sub_id,add_id)
                else
                    msg = add_id.to_s + " already exists as an ID in KB+"
                end
                puts msg

                writer << ([sub_url] + row.fields)
            end
        end
        puts "END OF INSTITUTION"
    end
end
