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
cookies = cgi.cookies
session_id = cookies['my_ruby_cookie'][0]
players = [0]

begin

if !session_id.nil? && !session_id.empty?
  session = CGI::Session.new(cgi, "session_key" => "my_ruby_session", "session_id" => session_id)
  if !session['username'].nil? && !session['username'].empty?
      players << session["username"]
  end
  if !session['friendArray'].nil? && !session['friendArray'].empty?
      has_friend_info = true
      session['friendArray'] ||= []
      session['friendArray'].each do |friend_name|
        players << friend_name
      end
      session.close
  end
end

def calculate_travel_time(origin_lat, origin_lng, destination_lat, destination_lng, mode)
  api_key = '-------伏字-------'
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
time_required = cgi['time-required']
origin_lat = cgi['latitude']
origin_lng = cgi['longitude']

current_time = Time.now
current_day = current_time.strftime("%A")
current_time_str = current_time.strftime("%H:%M")

one_hour_later = current_time + (60 * 60)
one_hour_later_day = one_hour_later.strftime("%A")
one_hour_later_time_str = one_hour_later.strftime("%H:%M")

db = SQLite3::Database.new("s2210573.db")
db.results_as_hash = true

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
    AND (
        (bh.day_of_week = ? AND bh.open_time <= ? AND bh.close_time >= ?)
        OR
        (bh.day_of_week = ? AND bh.open_time <= '00:00' AND bh.close_time >= ?)
    )
SQL
  

result = db.execute(query, price_range, *genres, current_day, current_time_str, '23:59', one_hour_later_day, one_hour_later_time_str)
if !result.nil? && !result.empty?
  valid_restaurants = []
  dest_latitude = result[0]['latitude']
  dest_longitude = result[0]['longitude']

  result.each do |restaurant|
    duration_res = calculate_travel_time(origin_lat, origin_lng, dest_latitude, dest_longitude, transportation)
    if duration_res <= time_required.to_i*60
      players.each do |player|
        row = {}
        visit = db.get_first_row("SELECT restaurant_id ,visit_count ,score  FROM visit WHERE user_id = ? AND restaurant_id = ?", [player, restaurant['id']])    
        if visit
          row['visit_count'] = visit['visit_count'] || 0
          row['score'] = visit['score'] || 3
        else
          row['visit_count'] = 0
          row['score'] = 3
        end
        row['restaurant_id'] = restaurant['id']
        row['restaurant_name'] = restaurant['name']
        valid_restaurants << row
      end
      db.close 
  end

  if valid_restaurants.length == 0
    raise "条件に一致するレストランが見つかりませんでした。"
  else 
    weighted_restaurants = valid_restaurants.map do |restaurant|
        score_weight = 2 * restaurant['score'] 
        visit_weight = restaurant['visit_count'] > 0 ? (1.0 / restaurant['visit_count']) : 1  
        total_weight = score_weight + visit_weight
        { 
          restaurant_id: restaurant['restaurant_id'], 
          weight: total_weight,
          restaurant_name: restaurant["restaurant_name"]
        }
    end

    total_weight_sum = weighted_restaurants.sum { |r| r[:weight] }
    random_pick = rand() * total_weight_sum
    selected_restaurant = nil
    cumulative_weight = 0.0

    weighted_restaurants.each do |restaurant|
      cumulative_weight += restaurant[:weight]
      if random_pick <= cumulative_weight
          selected_restaurant = restaurant
      end
      end
    end

    print cgi.header("Status" => "302 Found", "Location" => "https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/search_restaurant.rb?posted_restauranted_name=#{selected_restaurant[:restaurant_name]}")

  end
else
  raise "条件に一致するレストランが見つかりませんでした。"
end

raise "予期せぬエラーが発生しました。"

rescue => e
  print cgi.header("Status" => "302 Found", "Location" => "https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/gourmet_dice.rb?error=#{e}")
end
