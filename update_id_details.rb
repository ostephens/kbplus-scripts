#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'optparse'
require 'CSV'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: update_tipp_url.rb [options]"

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

    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end
end.parse!

kb = Kb.new(options[:instance],options[:username],options[:password])
kb.login

ids = options[:sourcefile]

CSV.foreach(ids, :headers => true, :header_converters => :symbol) do |row|
    id_id = row[:id_id].to_s
    id_value = row[:id_value].to_s
    id_ns_fk = row[:corrected_id_ns_fk].to_s
    begin
        kb.updateID(id_id,id_value,id_ns_fk)
        puts "/identifier/show/" + id_id.to_s + "\t" +id_value+ "\t" +id_ns_fk
    rescue
        puts "/identifier/show/" + id_id.to_s + "\tFAILED"
    end
end
