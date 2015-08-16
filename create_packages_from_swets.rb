#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require './lib/KbPackage'
require './lib/TIPP'
require 'CSV'
require 'json'
require 'open-uri'
require 'optparse'
require 'uri'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: process_swets_file.rb [options]"

    opts.on("-i", "--instance [INSTANCE]","www, test, demo or dev") do |i|
        options[:instance] = i
    end

    opts.on("-s", "--sourcefile [SOURCEFILE]", "Source file") do |s|
        options[:sourcefile] = s
    end

    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end
end.parse!

swets = options[:sourcefile]
#
#
# Need to create a 'Package' object, which can have an array of TIPPs in it
# Store those package objects in a keyed hash
packages = Hash.new()

#    If they have no pkg_id, ti_id or tipp_id then 

CSV.foreach(swets, :headers => true, :header_converters => :symbol) do |row|
    #Ignore lines without ISSNs for now
    if(!row[:issn] || row[:issn] == "NULL") 
        next
    end

    if (row[:kb_master_package_id] && row[:kb_master_package_id] != "NULL")
        p_name = row[:kb_package_name]
        p_pidentifier = row[:kb_package_import_id]
        p_provider = row[:kb_content_provider]
        p_id = row[:kb_master_package_id]
        p_sdate = row[:kb_package_start]
        p_edate = row[:kb_package_end]
    else
        p_name = row[:supplier_name] + ":Master"
        p_pidentifier = "Master"
        p_provider = row[:supplier_name]
        p_id = ""
        p_sdate = "01/01/2014"
        p_edate = "31/12/2100"
    end
    if (packages[p_name] == nil)
        p = KbPackage.new()
        p.name = p_name
        p.pidentifier = p_pidentifier
        p.provider = p_provider
        p.id = p_id
        p.sdate = p_sdate
        p.edate = p_edate
        packages[p.name] = p
    end
    t = TIPP.new()
    if (row[:kb_ti_id])
        #If there is a TIPP ID add this as well - then we can test on output whether this tipp needs creating
        t.title = row[:kb_title]
        t.pissn = row[:kb_issn]
        t.eissn = row[:kb_eissn]
    else
        t.title = row[:corrected_title]
        if(row[:pissn])
            t.pissn = row[:pissn]
        end
        if(row[:eissn])
            t.eissn = row[:eissn]
        end
        if(!row[:eissn] && !row[:pissn])
            t.pissn = row[:issn]
        end
    end
    if (row[:kb_platform])
        t.platform_host_name = row[:kb_platform]
    else
        t.platform_host_name = row[:supplier_name]
    end
    if (row[:kb_tipp_id])
        t.id = row[:kb_tipp_id]
    else
        t.platform_host_url = "http://"+options[:instance]+".kbplus.ac.uk/kbplus/noHostPlatformUrl"
    end
    t.coverage_depth = "fulltext"
        
    packages[p_name].tipps.push(t)
end

packages.each do |key,package|
    if (package.idlessTIPPcount==0)
        next
    end
    package.kbplusimpCSV("./swets/"+options[:instance]+"/" + package.name.gsub(/[:\/]/,"_") + ".csv")
end


