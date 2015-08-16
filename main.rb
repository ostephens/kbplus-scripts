#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'CSV'
require 'json'
require 'open-uri'

kbplusuri = "http://"+ARGV[0]+".kbplus.ac.uk/kbplus/"
downloadscsv = kbplusuri + "publicExport/idx?format=csv"
downloadsjson = kbplusuri + "publicExport/idx?format=json"
downloadscsvcontent = open(downloadscsv)
downloadjsoncontent = open(downloadsjson)

kb = Kb.new(ARGV[0],ARGV[1],ARGV[2])
kb.login

package_json = JSON.parse(File.read(downloadjsoncontent))

package_json["packages"].each do |p|
	package_name = p["name"].chomp
	puts kb.packageCheck(package_name) + "," + package_name + "," + kbplusuri + "packageDetails/show/" + p["identifier"].to_s
end

#CSV.parse(downloadscsvcontent, :headers => true, :header_converters => :symbol) do |row|
#	if (row[:name])
#		package_name = row[:name]
#		puts package_name + "," + kb.packageCheck(package_name)
#	end
#end
