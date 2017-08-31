#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'optparse'
require 'CSV'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: update_tipp_selective.rb [options]"

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
        edate = ""
        evol = ""
        eiss = ""
        coverage = "fulltext"
        coveragenote = ""
        sdate = row[:date_first_issue_online]
        svol = row[:num_first_vol_online]
        siss = row[:num_first_issue_online]
        edate = row[:date_last_issue_online]
        evol = row[:num_last_vol_online]
        eiss = row[:num_last_issue_online]
        #coverage = row[:coverage_depth]
        coveragenote = row[:coverage_notes]
        #hosturl = row[:platform_host_url]
        puts "TI: " + row[:ti_id].to_s
        tipp_id = kb.getTIPPfromTI(row[:ti_id],packageid)
        puts "TIPP: " + tipp_id.to_s
        if(tipp_id.is_a?(String))
            if(sdate.to_s.length > 0 && sdate.to_s != "NULL")
                kb.updateTIPPstartDate(tipp_id,sdate)
            elsif(sdate.to_s === "NULL")
                kb.updateTIPPstartDate(tipp_id,"")
            end
            if(svol.to_s.length > 0 && svol.to_s != "NULL")
                kb.updateTIPPstartVolume(tipp_id,svol)
            elsif(svol.to_s === "NULL")
                kb.updateTIPPstartVolume(tipp_id,"")
            end
            if(siss.to_s.length > 0 && siss.to_s != "NULL")
                kb.updateTIPPstartIssue(tipp_id,siss)
            elsif(siss.to_s === "NULL")
                kb.updateTIPPstartIssue(tipp_id,"")
            end
            if(edate.to_s.length > 0 && edate.to_s != "NULL")
                kb.updateTIPPendDate(tipp_id,edate)
            elsif(edate.to_s === "NULL")
                kb.updateTIPPendDate(tipp_id,"")
            end
            if(evol.to_s.length > 0 && evol.to_s != "NULL")
                kb.updateTIPPendVolume(tipp_id,evol)
            elsif(evol.to_s === "NULL")
                kb.updateTIPPendVolume(tipp_id,"")
            end
            if(eiss.to_s.length > 0 && eiss.to_s != "NULL")
                kb.updateTIPPendIssue(tipp_id,eiss)
            elsif(eiss.to_s === "NULL")
                kb.updateTIPPendIssue(tipp_id,"")
            end
            if(coveragenote.to_s.length > 0 && coveragenote.to_s != "NULL")
                kb.updateTIPPcoverage(tipp_id,"fulltext",coveragenote)
            elsif(coveragenote.to_s === "NULL")
                kb.updateTIPPcoverage(tipp_id,"fulltext","")
            end
            tipp_url = "kbplus/tipp/show/" + tipp_id.to_s
            csv_write << [row[:ti_id],tipp_url,sdate,svol,siss,edate,evol,eiss,coveragenote,warning]
            puts row[:ti_id] + "," + tipp_url
        end
    end
end