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
    opts.banner = "Usage: delete_licence_property.rb [options]"

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

    opts.on("-r", "--property [PROPERTY]","Licence Property to delete") do |r|
        options[:property] = r
    end

    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end
end.parse!

licfile = options[:licfile]
property_name = options[:property]

kb = Kb.new(options[:instance],options[:username],options[:password])
kb.login

CSV.foreach(licfile, :headers => true, :header_converters => :symbol) do |row|
    lic_id = row[:lic_id].to_s
    property_id = kb.getLicencepropertyID(lic_id,property_name)
    if(property_id)
        kb.deleteLicenceproperty(lic_id,property_id)
        puts "Deleted property: '" + property_name.to_s + "' from " + lic_id.to_s
    else
        puts "No such property: '" + property_name.to_s + "' from " + lic_id.to_s
    end
end