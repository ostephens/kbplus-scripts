#!/usr/bin/env  rvm default do ruby
require 'oai'
client = OAI::Client.new 'http://gokb.kuali.org/gokb/oai/titles', :headers => { "From" => "owen@ostephens.com" }
response = client.list_records
# Get the first page of records
#response.each do |record| 
#  puts record.metadata
#end
# Get the second page of records
#response = client.list_records(:resumption_token => response.resumption_token)
#response.each do |record|
#  puts record.metadata
#end
# Get all pages together (may take a *very* long time to complete)
client.list_records.full.each do |record|
  puts record.metadata
end