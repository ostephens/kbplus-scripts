#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'optparse'
require 'CSV'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: update_news_tipp_all_by_tippid.rb [options]"

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

    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end
end.parse!

kb = Kb.new(options[:instance],options[:username],options[:password])
kb.login

tipps = options[:sourcefile]

CSV.open(options[:outputfile].to_s, 'w') do |csv_write|
    CSV.foreach(tipps, :headers => true, :header_converters => :symbol) do |row|
        sdate = ""
        svol = ""
        siss = ""
        sdate = row[:tipp_start_date]
        if(sdate.to_s.length === 0 || sdate === "NULL")
            sdate = ""
        end
        if(svol.to_s.length === 0 || svol === "NULL")
            svol = ""
        end
        if(siss.to_s.length === 0 || siss === "NULL")
            siss = ""
        end
        edate = ""
        evol = ""
        eiss = ""
        edate = row[:tipp_end_date]
        if(edate.to_s.length === 0 || edate === "NULL")
            edate = ""
        end
        if(evol.to_s.length === 0 || evol === "NULL")
            evol = ""
        end
        if(eiss.to_s.length === 0 || eiss === "NULL")
            eiss = ""
        end
        coverage = "fulltext"
        coveragenote = ""   
        coveragenote = row[:tipp_coverage_note]
        hosturl = row[:tipp_host_platform_url]
        tipp_id = row[:new_tipp_id]
        puts "TIPP: " + tipp_id.to_s
        if(tipp_id.is_a?(String))
            kb.updateTIPPend(tipp_id,edate,evol,eiss)
            kb.updateTIPPstart(tipp_id,sdate,svol,siss)
            kb.updateTIPPcoverage(tipp_id,coverage,coveragenote)
            kb.updateTIPPhosturl(tipp_id,hosturl)
            tipp_url = "kbplus/tipp/show/" + tipp_id.to_s
            csv_write << [tipp_url,sdate,edate,coveragenote,hosturl]
            puts tipp_url
        end
    end
end