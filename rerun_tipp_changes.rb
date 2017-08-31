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

changes = options[:sourcefile]
CSV.open(options[:outputfile].to_s, 'w') do |csv_write|
    CSV.foreach(changes, :headers => true, :header_converters => :symbol) do |row|
        tipp_id = row[:persisted_object_id]
        property = row[:property_name]
        begin
            case property
            when "accessEndDate"
                kb.updateTIPPaccessEnd(tipp_id,row[:old_value])
            when "accessStartDate"
                kb.updateTIPPaccessStart(tipp_id,row[:old_value])
            when "coverageDepth"
                kb.updateTIPPcoverageDepth(tipp_id,row[:old_value])
            when "coverageNote"
                kb.updateTIPPcoverageNote(tipp_id,row[:old_value])
            when "endDate"
                kb.updateTIPPendDate(tipp_id,row[:old_value])
            when "endIssue"
                kb.updateTIPPendIssue(tipp_id,row[:old_value])
            when "endVolume"
                kb.updateTIPPendVolume(tipp_id,row[:old_value])
            when "hybridOA"
                puts "hybridOA: no re-run"
            when "startDate"
                kb.updateTIPPstartDate(tipp_id,row[:old_value])
            when "startIssue"
                kb.updateTIPPstartIssue(tipp_id,row[:old_value])
            when "startVolume"
                kb.updateTIPPstartVolume(tipp_id,row[:old_value])
            when "status"
                kb.updateTIPPstatus(tipp_id,"29")
            else
                puts "Unknown Property: "+property.to_s
            end
            csv_write << [tipp_id,property,row[:old_value],"old"]
        rescue
            puts "Failed: "+tipp_id+","+property
        end
    end
    CSV.foreach(changes, :headers => true, :header_converters => :symbol) do |row|
        tipp_id = row[:persisted_object_id]
        property = row[:property_name]
        begin
            case property
            when "accessEndDate"
                kb.updateTIPPaccessEnd(tipp_id,row[:new_value])
            when "accessStartDate"
                kb.updateTIPPaccessStart(tipp_id,row[:new_value])
            when "coverageDepth"
                kb.updateTIPPcoverageDepth(tipp_id,row[:new_value])
            when "coverageNote"
                kb.updateTIPPcoverageNote(tipp_id,row[:new_value])
            when "endDate"
                kb.updateTIPPendDate(tipp_id,row[:new_value])
            when "endIssue"
                kb.updateTIPPendIssue(tipp_id,row[:new_value])
            when "endVolume"
                kb.updateTIPPendVolume(tipp_id,row[:new_value])
            when "hybridOA"
                puts "hybridOA: no re-run"
            when "startDate"
                kb.updateTIPPstartDate(tipp_id,row[:new_value])
            when "startIssue"
                kb.updateTIPPstartIssue(tipp_id,row[:new_value])
            when "startVolume"
                kb.updateTIPPstartVolume(tipp_id,row[:new_value])
            when "status"
                if(row[:new_value]=="Deleted")
                    nv = "113"
                elsif(row[:new_value]=="Transferred")
                    nv = "30"
                else
                    nv = "28"
                end
                kb.updateTIPPstatus(tipp_id,nv)
            else
                puts "Unknown Property: "+property.to_s
            end
            csv_write << [tipp_id,property,row[:new_value],"new"]
        rescue
            puts "Failed: "+tipp_id+","+property
        end
    end
end