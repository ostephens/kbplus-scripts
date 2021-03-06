#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'optparse'
require 'CSV'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: rename_packages.rb [options]"

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

    opts.on("-q", "--packageid [PACKAGEID]", "Package ID") do |q|
        options[:packageid] = [q]
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

titles = options[:sourcefile]
packageid = options[:packageid]
CSV.open(options[:outputfile].to_s, 'w') do |csv_write|
    CSV.foreach(titles, :headers => true, :header_converters => :symbol) do |row|
        warning = ""
        sdate = ""
        svol = ""
        siss = ""
        sdate = row[:date_first_issue_online]
        svol = row[:num_first_vol_online]
        siss = row[:num_first_issue_online]
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
        edate = row[:date_last_issue_online]
        evol = row[:num_last_vol_online]
        eiss = row[:num_last_issue_online]
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
        coverage = row[:coverage_depth]
        coveragenote = row[:coverage_notes]
        hosturl = row[:platform_host_url]
        if(hosturl.to_s.length === 0 || hosturl === "NULL")
            eiss = ""
        end
        tipp_id = row[:tipp_id]
        puts "TI: " + row[:ti_id].to_s
        tipp_id = kb.getTIPPfromTI(row[:ti_id],packageid)
        sleep 0.5
        puts "TIPP: " + tipp_id.to_s
        if(hosturl.to_s.length === 0 || hosturl === "NULL")
            warning = "NO HOST URL"
        end
        if(tipp_id.is_a?(String))
            kb.updateTIPPend(tipp_id,edate,evol,eiss)
            sleep 0.2
            kb.updateTIPPstart(tipp_id,sdate,svol,siss)
            sleep 0.2
            kb.updateTIPPcoverage(tipp_id,"fulltext",coveragenote)
            sleep 0.2
            kb.updateTIPPhosturl(tipp_id,hosturl)
            sleep 0.2
            tipp_url = "kbplus/tipp/show/" + tipp_id.to_s
            csv_write << [row[:ti_id],tipp_url,sdate,svol,siss,edate,evol,eiss,coveragenote,warning]
            puts row[:ti_id] + "," + tipp_url
        end
    end
end