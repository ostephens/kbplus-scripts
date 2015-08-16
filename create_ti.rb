#!/usr/bin/env  rvm default do ruby
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
    opts.banner = "Usage: create_ti.rb [options]"

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

titles = options[:sourcefile]

CSV.open(options[:outputfile].to_s, 'w') do |csv_write|
    CSV.foreach(titles, :headers => true, :header_converters => :symbol) do |row|
        ti_title = row[:publication_title]
        if(kb.proposeTI(ti_title))
            ti_uri = kb.createTI(ti_title)
            csv_write << row.push(ti_title,ti_uri)
        else
            csv_write << row.push(ti_title,"Potential matching titles already exist. Please check by hand")
        end
    end
end
