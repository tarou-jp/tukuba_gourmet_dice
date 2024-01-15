#!/usr/bin/env ruby
# encoding: utf-8
require 'cgi'
require 'cgi/session'

cgi = CGI.new

begin
  
cookies = cgi.cookies
session_id = cookies['my_ruby_cookie'][0]
  
if !session_id.nil? && !session_id.empty?
  session = CGI::Session.new(cgi, "session_key" => "my_ruby_session", "session_id" => session_id)
  session.delete
end

cookie_new = CGI::Cookie.new('name' => 'my_ruby_cookie', "charset" => "utf-8",  'value' => '')

referrer = ENV['HTTP_REFERER'] || "https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/index.rb"
redirect_url = referrer || "https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/index.rb" 

print cgi.header('status' => '302 Found', 'Location' => redirect_url, 'cookie' => cookie_new)

rescue  => e
  puts "#{e.message}"
end
