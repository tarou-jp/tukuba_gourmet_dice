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

def hash_password(plain_password)
  BCrypt::Password.create(plain_password)
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
  existing_user = db.get_first_row("SELECT id FROM users WHERE username = ?", [username])

  if existing_user
    raise "このユーザー名は既に使用されています。"
  else
    hashed_password = hash_password(password)
    db.execute("INSERT INTO users (username, pass) VALUES (?, ?)", [username, hashed_password])
    user_id = db.last_insert_row_id()
    session = CGI::Session.new(cgi, 'new_session' => true, 'session_key' => 'my_ruby_session')
    session['username'] = username
    session['user_id'] = user_id
    session.close
    db.close
    
    cookie_new = CGI::Cookie.new('name' => 'my_ruby_cookie', 'value' => session.session_id)
    print cgi.header("status" => "REDIRECT", "Location" => "https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/index.rb", 'cookie' => cookie_new)
  end
end

rescue => e
  error_message = CGI.escape(e.message)
  print cgi.header("Status" => "302 Found", "Location" => "https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/signin.rb?error=#{error_message}")
end