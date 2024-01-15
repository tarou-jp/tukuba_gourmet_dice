#!/usr/bin/env ruby
# encoding: utf-8

require 'cgi'
require 'cgi/session'
require 'sqlite3'

cgi = CGI.new
cookies = cgi.cookies

session_id = cookies['my_ruby_cookie'][0]

begin 

if !session_id.nil? && !session_id.empty?
    session = CGI::Session.new(cgi, "session_key" => "my_ruby_session", "session_id" => session_id)
else 
    raise "セッションIDが取得できませんでした。"
end

score = cgi.params['score_update'][0]
visit_count = cgi.params['visit_count_update'][0].to_i
restaurant_id = cgi.params['restaurant_id_update'][0]
user_id = session['user_id']

db = SQLite3::Database.new("s2210573.db")
result = db.execute("SELECT 1 FROM visit WHERE restaurant_id = ? AND user_id = ?", [restaurant_id, user_id])

if result.any?
  db.execute("UPDATE visit SET  visit_count = ?,score = ? WHERE restaurant_id = ? AND user_id = ?", [visit_count, score,restaurant_id, user_id])
else
  db.execute("INSERT INTO visit (score, visit_count, restaurant_id, user_id) VALUES (?, ?, ?, ?)", [score, visit_count, restaurant_id, user_id])
end
db.close

print cgi.header("status" => "REDIRECT", "Location" => "https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/search_restaurant.rb")

rescue => e
    print cgi.header("content-type: text/html; charset=utf-8")
    print "<html lang='ja'> <head><meta charset='utf-8'><body><p>エラーが発生しました。後ほど再度お試しください。</p><p>#{e.message}</p></body></html>"
end