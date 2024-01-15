#!/usr/bin/env ruby
# encoding: utf-8

ENV['GEM_HOME'] = '/home/s2210573/.local/share/gem/ruby3.1.0'
require 'rubygems'
require 'bcrypt'
require 'cgi'
require 'cgi/session'
require 'sqlite3'

cgi = CGI.new

def contains_html_tags?(string)
  /<[^>]+>/.match?(string)
end

def valid_password?(input_password, hashed_password)
  BCrypt::Password.new(hashed_password) == input_password
end

begin
username = cgi.params['username'][0]
password = cgi.params['password'][0]

if username.nil? || username.empty? || password.nil? || password.empty?
  raise "名前とパスワードが入力されていません。"
elsif contains_html_tags?(username) || contains_html_tags?(password)
  raise "入力にHTMLタグが含まれています。"
else
  db = SQLite3::Database.new("s2210573.db")
  db.results_as_hash = true
  user = db.get_first_row("SELECT id ,pass FROM users WHERE username = ?", [username])
  user_id = user['id']
  db.close

  if user && valid_password?(password, user['pass'])
    session = CGI::Session.new(cgi, 'new_session' => true, 'session_key' => 'my_ruby_session')
    session['username'] = username
    session['user_id'] = user_id
    
    cookie_new = CGI::Cookie.new('name' => 'my_ruby_cookie', "charset" => "utf-8", 'value' => session.session_id)
    session.close
    
    print cgi.header("status" => "REDIRECT", "Location" => "https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/index.rb", 'cookie' => cookie_new)
  else
    raise "ユーザー名またはパスワードが間違っています。"
  end

end

rescue => e
  error_message = CGI.escape(e.message)
  print cgi.header("Status" => "302 Found", "Location" => "https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/signin.rb?error=#{error_message}")
end