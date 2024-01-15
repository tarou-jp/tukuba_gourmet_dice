#!/usr/bin/env ruby
# encoding: utf-8

ENV['GEM_HOME'] = '/home/s2210573/.local/share/gem/ruby3.1.0'
require 'rubygems'
require 'cgi'
require 'cgi/session'
require 'sqlite3'
require 'bcrypt'
require 'json'

def contains_html_tags?(string)
  /<[^>]+>/.match?(string)
end

def valid_password?(input_password, hashed_password)
  BCrypt::Password.new(hashed_password) == input_password
end

cgi = CGI.new

begin

cookies = cgi.cookies
username = cgi['username']
password = cgi['password']
login_status = cgi['login_status']
has_friend_info = cgi['has_friend_info']

session_id = cookies['my_ruby_cookie'][0]

raise "名前とパスワードが入力されていません。" if (!username.nil? && username.empty?) || (!password.nil? && password.empty?)
raise "入力にHTMLタグが含まれています。" if contains_html_tags?(username) || contains_html_tags?(password)

db = SQLite3::Database.new("s2210573.db")
db.results_as_hash = true
user = db.get_first_row("SELECT username, id, pass FROM users WHERE username = ?", [username])

if user && valid_password?(password, user['pass'])
  if login_status == "logout" || (has_friend_info == true)
    session = CGI::Session.new(cgi, "session_key" => "my_ruby_session", "session_id" => session_id)
    if !session['username'].nil? && !session['username'].empty? && session['username'] == user['username']
      raise "既に追加済みです"
    end 
  else
    session = CGI::Session.new(cgi, 'new_session' => true, 'session_key' => 'my_ruby_session')
    cookie_new = CGI::Cookie.new('name' => 'my_ruby_cookie', 'value' => session.session_id)
  end
  

  session['friendArray'] ||= []
  if session['friendArray'].include?(user['username']) 
      raise "既に追加済みです。"
  else
      session['friendArray'] << user['username']
  end
  session.close

  response = { success: true, message: "処理が完了しました。", username: user['username'] }
else
  raise "ユーザー名またはパスワードが間違っています。"
end


rescue => e
  response = { success: false, message: e.message }
end

if !cookie_new.nil? && !cookie_new.empty?
    puts cgi.header("content-type" => "application/json",'cookie' => cookie_new)
else;
  puts cgi.header("content-type" => "application/json")
end
puts response.to_json