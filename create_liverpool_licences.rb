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
    opts.banner = "Usage: create_liverpool_licences.rb [options]"

    opts.on("-i", "--instance [INSTANCE]","www, test, demo or dev") do |i|
        options[:instance] = i
    end
    
    opts.on("-l", "--licencefile [LICFILE]","Location of the licences file") do |l|
        options[:licfile] = l
    end

    opts.on("-j", "--institution [INSTITUTION]","Institution Shortcode") do |j|
        options[:institution] = j
    end    

    opts.on("-p", "--password [PASSWORD]","Password") do |p|
        options[:password] = p
    end

    opts.on("-u", "--username [USERNAME]","Username") do |u|
        options[:username] = u
    end

    opts.on("-t", "--template [TEMPLATE]","Template licence to use") do |t|
        options[:template] = t
    end

    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end
end.parse!



licfile = options[:licfile]
template = options[:template]
shortcode = options[:institution]

kb = Kb.new(options[:instance],options[:username],options[:password])
kb.login
#Check institution dashboard accessible to this login before proceeding
if(!kb.checkInstitution(shortcode))
    puts shortcode + ": dashboard was not available. Check shortcode and membership before proceeding"
    puts "Not proceeding"
    exit
else
    kb.org = shortcode.strip.gsub(" ","_")
end



properties = Array.new()
properties = [{"col"=>false,"notes"=>"authorised_users","name"=>"Authorised Users","type"=>"stringValue"},
                {"col"=>"apc_offset_offer","notes"=>"aoo_notes","name"=>"APC/Offsetting Offer","type"=>"refValue"},
                {"col"=>"alumni_access","notes"=>"aa_notes","name"=>"Alumni Access","type"=>"refValue"},
                {"col"=>"concurrent_access","notes"=>"ca_notes","name"=>"Concurrent Access","type"=>"refValue"},
                {"col"=>"concurrent_users","notes"=>"cu_notes","name"=>"Concurrent Users","type"=>"intValue"},
                {"col"=>"enterprise_access","notes"=>"ea_notes","name"=>"Enterprise Access","type"=>"refValue"},
                {"col"=>"ill_electronic","notes"=>"ie_notes","name"=>"ILL - Electronic","type"=>"refValue"},
                {"col"=>"ill_print","notes"=>"ip_notes","name"=>"ILL - Print","type"=>"refValue"},
                {"col"=>"coursepack","notes"=>"c_notes","name"=>"Include In Coursepacks","type"=>"refValue"},
                {"col"=>"vle","notes"=>"v_notes","name"=>"Include in VLE","type"=>"refValue"},
                {"col"=>"multi_site_access","notes"=>"msa_notes","name"=>"Multi Site Access","type"=>"refValue"},
                {"col"=>"notice_period","notes"=>"np_notes","name"=>"Notice Period","type"=>"stringValue"},
                {"col"=>"partner_access","notes"=>"pa_notes","name"=>"Partners Access","type"=>"refValue"},
                {"col"=>"post_cancellation_access","notes"=>"pca_notes","name"=>"Post Cancellation Access Entitlement","type"=>"refValue"},
                {"col"=>"remote_access","notes"=>"ra_notes","name"=>"Remote Access","type"=>"refValue"},
                {"col"=>"walk_in_access","notes"=>"wia_notes","name"=>"Walk In Access","type"=>"refValue"},
                {"col"=>"tdm","notes"=>"tdm_notes","name"=>"Text and Data Mining","type"=>"stringValue"}
            ]
if(options[:instance] == "demo")
    refdata = {"yes"=>66,"no"=>67,"other"=>68,"specified"=>303,"notapplicable"=>87,"unknown"=>302,"notspecified"=>304,"nolimit"=>305}
elsif(options[:instance] == "test")
    #puts "Refdata values not set, exiting"
    #exit
    refdata = {"yes"=>66,"no"=>67,"other"=>68,"specified"=>303,"notapplicable"=>87,"unknown"=>302,"notspecified"=>304,"nolimit"=>305}
elsif(options[:instance] == "kbplus")
    refdata = {"yes"=>66,"no"=>67,"other"=>68,"specified"=>303,"notapplicable"=>87,"unknown"=>302,"notspecified"=>304,"nolimit"=>305}
end
CSV.open('lics-created-kbplus.csv', 'w') do |writer|
    CSV.foreach(licfile, :headers => true, :header_converters => :symbol) do |row|

    if (row[:resource_name])
            newlic = kb.copyLicence(shortcode,template)
            lic_id = /\/(\d*)\?/.match(newlic)[1]
            kb.updateLicenceref(lic_id,row[:resource_name].to_s)
            if(row[:order_ref].to_s.length>0)
                kb.updateLicenseeref(lic_id,row[:order_ref])
            end
            if(row[:start_date].to_s.length>0)
                kb.updateLicencestartdate(lic_id,row[:start_date])
            end

            if(row[:end_date].to_s.length>0)
                kb.updateLicenceenddate(lic_id,row[:end_date])
            end
            if(row[:additional_name].to_s.length>0)
                kb.addLicencenote(lic_id,row[:additional_name])
            end
            #if(row[:licence_notes].to_s.length>0)
            #    kb.addLicencenote(lic_id,row[:licence_notes])
            #end
            if(row[:licensor_id].to_s.length>0)
                kb.addLicenceorg(lic_id,row[:licensor_id],"9")
            end
            kb.setLicencecategoryContent(lic_id)

            properties.each do |p|
                property_name = p["name"]
                value_header = p["col"]
                notes_header = p["notes"]
                value_type = p["type"]
                #Retrieve the property ID by searching the HTML
                #Don't want to do this if the property and note are null
                property_id = kb.getLicencepropertyID(lic_id,property_name)
                if(value_header)
                    property_raw_value = row[value_header.to_sym].to_s.downcase
                    if(value_type=="refValue" && property_raw_value.to_s.length()>0)
                        property_value = refdata[property_raw_value]
                    else
                        property_value = property_raw_value
                    end
                    if(property_value.to_s.length()>0)
                        if(value_type=="stringValue")
                            kb.updateLicencepropertystringvalue(property_id,property_value)
                        elsif(value_type=="refValue")
                            kb.updateLicencepropertyrefvalue(property_id,property_value)
                        elsif(value_type=="intValue")
                            kb.updateLicencepropertyintvalue(property_id,property_value)
                        end
                    end
                end
                #Now set notes
                #Only set if there is a value in the cell -  check not blank
                if(notes_header)
                    property_note = row[notes_header.to_sym]
                    if(property_note.to_s.length()>0)
                        kb.updateLicencepropertynote(property_id,property_note)
                    end
                end

            end
            writer << (row<<[lic_id.to_s])
    	end
    end
end

