#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require './lib/KbSubscription'
require './lib/IE'
require 'CSV'
require 'json'
require 'open-uri'
require 'optparse'
require 'uri'
require 'date'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: create_subscriptions_finance_testing.rb [options]"

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

    opts.on("-q", "--organisation ORGANISATION", "Organisation") do |q|
        options[:organisation] = q
    end

    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end
end.parse!

finance = options[:sourcefile]
#
#
# Need to create a 'Subscription' object, which can have an array of IEs in it
# Store those subscriptions objects in a keyed hash
subscriptions = Hash.new()

# Then need to add each package that needs linking to the sub (going to be 1 generally)
# Add all the relevant IEs to the subscription - basically the TIPP ID and any other things
# Then link the packages
# Then add the IEs using the TIPP IDs
# Then update the IEs with other info if necessary


kb = Kb.new(options[:instance],options[:username],options[:password])
kb.login
kb.org = options[:organisation]

CSV.foreach(finance, :headers => true, :header_converters => :symbol) do |row|
    puts row[:subscriptionid].to_s
    s_jcid = "JC:"+row[:subscriptionid].to_s
    s_name = row[:subscriptionid].to_s
    s_url = kb.createSubscription(s_name,s_jcid,"2017-01-01","2017-12-31")
    s_id = s_url.split("/").last

    if(kb.checkId(s_jcid))
        puts "Adding ID: " + s_jcid + " to " + s_id
        kb.addSubscriptionid(s_id,s_jcid)
    else
        puts s_jcid.to_s + " already exists as an ID in KB+"
    end
end
