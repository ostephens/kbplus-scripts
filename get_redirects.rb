#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require 'optparse'
require 'CSV'
require 'net/http'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: get_redirects.rb [options]"

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
CSV.open(options[:outputfile].to_s, 'w') do |csv_write|
	CSV.foreach(options[:sourcefile], :headers => true, :header_converters => :symbol) do |row|
	    url = URI.parse(row[:url])
	    http = Net::HTTP.new(url.host, url.port)
	    if(http)
	        response = http.request_head(url)
	        puts row[:url]
	        if(response.code==="301")
	        	http.request_head(url)
	        end
	        if(response.code==="302")
	        	csv_write << ([row,response["Location"]])
		    elsif (response.code==="200")
		    	csv_write << ([row,url])
		    end
	    end
	end
end