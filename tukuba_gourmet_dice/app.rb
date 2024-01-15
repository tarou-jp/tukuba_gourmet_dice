#!/usr/bin/env ruby
# encording: utf-8
require 'cgi'
cgi = CGI.new
print cgi.header("text/plain;charset=utf-8")
print Time.now.to_s
