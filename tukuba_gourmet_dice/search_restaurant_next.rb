#!/usr/bin/env ruby
# encoding: utf-8
require 'net/http'
require 'uri'
require 'cgi/session'
require 'json'
require 'cgi'
require 'sqlite3'
require 'time'

cgi = CGI.new

begin

def calculate_travel_time(origin_lat, origin_lng, destination_lat, destination_lng, mode)
  api_key = 'AIzaSyCA0t45fvMjTCFbM9hixFDGwrJUrkMZNbs'
  base_url = "https://maps.googleapis.com/maps/api/distancematrix/json"
  origin = "#{origin_lat},#{origin_lng}"
  destination = "#{destination_lat},#{destination_lng}"
  url = "#{base_url}?origins=#{URI.encode_www_form_component(origin)}&destinations=#{URI.encode_www_form_component(destination)}&mode=#{mode}&language=ja&key=#{api_key}"
  uri = URI(url)
  response = Net::HTTP.get(uri)
  data = JSON.parse(response)

  if data["rows"].empty? || data["rows"][0]["elements"][0]["status"] == "ZERO_RESULTS"
    case mode
    when 'bicycling'
      return calculate_travel_time(origin_lat, origin_lng, destination_lat, destination_lng, 'walking') / 3
    when 'transit'
      return calculate_travel_time(origin_lat, origin_lng, destination_lat, destination_lng, 'driving')
    when 'walking'
      return calculate_travel_time(origin_lat, origin_lng, destination_lat, destination_lng, 'driving')
    end
  else
    
    duration = data["rows"][0]["elements"][0]["duration"]["value"]
    return duration
  end
end

genres = cgi.params['genre']
price_range = cgi['price-range'].to_i
transportation = cgi['transportation']
time_required = cgi['time_required']
origin_lat = cgi['latitude']
origin_lng = cgi['longitude']


# データベースに接続
db = SQLite3::Database.new("s2210573.db")
db.results_as_hash = true


  # SQLクエリを準備
query = <<-SQL
SELECT 
    r.id, r.name, r.genre_id, r.latitude, r.longitude, r.min_price, r.max_price, r.image_path
FROM 
    restaurants r
JOIN 
    business_hours bh ON r.id = bh.restaurant_id
WHERE 
    r.min_price <= ?
    AND r.genre_id IN (#{genres.map{'?'}.join(',')})
    GROUP BY 
    r.id
SQL

result = db.execute(query, price_range, *genres)
valid_restaurants = []
if !result.nil? && !result.empty?
  valid_restaurants = []

  if !result.nil?
    result.each do |restaurant|
      dest_latitude = restaurant['latitude']
      dest_longitude = restaurant['longitude']    
      duration_res = calculate_travel_time(origin_lat, origin_lng, dest_latitude, dest_longitude, transportation)
      if !duration_res.nil? && duration_res <= time_required.to_i*60
        valid_restaurants << restaurant['name']
      end
    end
  end
end

db.close 

response = { success: true, message: "処理が完了しました。", 'valid_restaurants': valid_restaurants}

rescue => e
    response = { success: false, message: e.message }
end
  
puts cgi.header("content-type" => "application/json")
puts response.to_json