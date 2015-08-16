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

    opts.on("-s", "--sourcefile [SOURCEFILE]", "Source file") do |s|
        options[:sourcefile] = s
    end

    opts.on("-o", "--outputfile OUTPUTFILE", "Output File") do |o|
        options[:outputfile] = o
    end

    opts.on("-q", "--organisation ORGANISATION", "Organisation") do |q|
        options[:organisation] = q
    end

    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end
end.parse!

swets = options[:sourcefile]
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



CSV.foreach(swets, :headers => true, :header_converters => :symbol) do |row|
    s_number = row[:subscription_number]
    if (subscriptions[s_number] == nil)
        #no subscription in the array yet, create it
        s = KbSubscription.new()
        s.sidentifier = s_number
        s.name = row[:kb_subscription_name].to_s + " (SWETS)"
        # Use the period charge from date as the subscription start date as per Oxford spec
        begin
            s.sdate = Date.parse(row[:period_charged_from]).to_s
        rescue
            s.sdate = "2014-01-01"
        end
        # Use the period charge to date as the subscription end date as per Oxford spec
        begin
            s.edate = Date.parse(row[:period_charged_to]).to_s
        rescue
            s.edate = "2014-12-31"
        end
        subscriptions[s.sidentifier] = s
    end
    i = IE.new()
    # for each line with this sub id
    # check we have a package - if not, no IEs
    if(row[:kb_master_package_id])
        # make sure the package will be linked so we can create the IE successfully
        subscriptions[s_number].addPackage(row[:kb_master_package_id])
        if (row[:kb_tipp_id])
            i.tipp_id = row[:kb_tipp_id]
            i.ti_id = row[:kb_ti_id]
            # Use the subscription access start date in the spreadsheet and leave the end date blank as per Oxford spec
            begin
                i.sdate = Date.parse(row[:subscription_access__start_date]).to_s
            rescue
                #no start date to be set
            end
            subscriptions[s_number].ies.push(i)
        else
            #No IE to add
        end
    end
end

kb = Kb.new(options[:instance],options[:username],options[:password])
kb.login
kb.org = options[:organisation]

CSV.open(options[:outputfile].to_s, 'w') do |csv_write|
    subscriptions.each do |key,subscription|
        #Create the subscription
        sub_url = kb.createSubscription(subscription.name,subscription.sidentifier,subscription.sdate,subscription.edate)
        #store the URL and the ID
        subscription.url = sub_url
        subscription.id = sub_url.split("/").last
        subscription.packages.each do |package|
            if(subscription.id)
                begin
                    kb.linkPackage(subscription.id,package.to_s,"Without")
                rescue
                    puts "Could not link " + package.to_s + " to subscription " + subscription.id
                end
            end
        end
        #NEED TO ADD THE IEs USING TIPP ID
        subscription.ies.each do |ie|
            if(ie.tipp_id && subscription.id)
                begin
                    kb.addIE(subscription.id,ie.tipp_id)
                rescue
                    puts "Could not create an IE for " + ie.tipp_id + " on subscription " + subscription.id
                end
            end
        end
        csv_write << ([subscription.id,subscription.url,subscription.name,subscription.sidentifier,subscription.sdate,subscription.edate])
        # subscription.printIEs
    end
end
