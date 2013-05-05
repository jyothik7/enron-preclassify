require 'rubygems'
require 'mail'

s1=""
Dir.glob("/Users/jyothi/Documents/EDiscovery/RUBY/ExtraCredit/emls/*.eml") do |my_file|
  #puts "working on: #{my_file}"

  mail = Mail.read("#{my_file}")
  # Create a new file and write to it  
  File.open('/Users/jyothi/Documents/EDiscovery/RUBY/ExtraCredit/Emailbody.txt', 'w') do |f2|  
  # use "\n" for two lines of text 
  s1 +=  "\n#{mail.subject}"
  f2.puts s1  
end 
#p mail.subject
end
