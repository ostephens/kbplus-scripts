#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require './lib/kb'
require 'optparse'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: edit_package_name.rb [options]"

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

package_json = kb.getpublicPackages
count = 0
package_json["packages"].each do |p|
	package_name = p["name"].chomp
	puts "Checking ... " +package_name + "\t" + p["identifier"].to_s
	if (kb.checkPackage(package_name) == "Not Indexed" && count < 100)
		if (p["identifier"])
			kb.updatePackagename(p["identifier"],package_name+".")
			kb.updatePackagename(p["identifier"],package_name)
			puts "packageDetails/show/" + p["identifier"].to_s + "\t" + package_name
			count += 1
		end
    end
	if (count >= 100)
        puts "Reached max checks, waiting 10 minutes"
        count = 0
        sleep(600)
    end
end


