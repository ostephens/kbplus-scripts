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
    opts.banner = "Usage: create_orgs.rb [options]"

    opts.on("-i", "--instance [INSTANCE]","www, test, demo or dev") do |i|
        options[:instance] = i
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

count = 1
while (count<2)
    ti_id = count.to_s
    ti_title = kb.getTiTitle(ti_id)
    kb.updateTiTitle(ti_id,ti_title+".")
    kb.updateTiTitle(ti_id,ti_title)
    puts kb.base_url + "/titleDetails/edit/" + ti_id
    puts ti_title
    count += 1
end