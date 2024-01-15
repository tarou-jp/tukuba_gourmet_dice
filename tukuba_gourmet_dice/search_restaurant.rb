#!/usr/bin/env ruby
# encording: utf-8
require "cgi"
require 'erb'
require "sqlite3"
require 'cgi/session'

cgi = CGI.new
cookies = cgi.cookies
print cgi.header("content-type: text/html; charset=utf-8")

begin

posted_restaurand_name = cgi['posted_restauranted_name']

session_id = cookies['my_ruby_cookie'][0]
login_status = "login"
genre = ['定食','麺類','居酒屋','ファミレス','エスニック']
genre_tag = [0,1,2,3,4]

if !session_id.nil? && !session_id.empty?
    session = CGI::Session.new(cgi, "session_key" => "my_ruby_session", "session_id" => session_id)
    if !session['username'].nil? && !session['username'].empty?
        login_status = "logout"
    end
    session.close
end

db = SQLite3::Database.new("s2210573.db")
db.results_as_hash = true

restaurants = db.execute("SELECT * FROM restaurants").map do |restaurant|
    business_hours_res = {}
    business_hours = db.execute("SELECT * FROM business_hours WHERE restaurant_id = ?", restaurant['id'])
    business_hours.each do |business_hour|
        if business_hours_res.key?(business_hour['open_time']+"~"+business_hour['close_time'])
            business_hours_res[business_hour['open_time']+"~"+business_hour['close_time']] << business_hour['day_of_week']
        else
            business_hours_res[business_hour['open_time']+"~"+business_hour['close_time']] = [business_hour['day_of_week']]
        end
    end
    if login_status == "logout"
        user_info = db.get_first_row("SELECT visit_count, score FROM visit WHERE restaurant_id = ? AND user_id = ?", restaurant['id'], session['user_id'])
        score = user_info&.fetch('score', 2)
        visit_count = user_info&.fetch('visit_count', 0)
    end        
    score ||= 2
    visit_count ||= 0
    restaurant.merge('business_hours' => business_hours_res,'score' => score ,'visit_count' => visit_count)
end

db.close

html_template = <<-HTML
            <% restaurants.each do |restaurant| %>

            <li class="restaurant-item">
                <div class="restaurant-box">
                    <div class="left-container">
                        <div class="main-image">
                            <img src="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/images/<%= restaurant['image_path'] %>/0.jpg" >
                        </div> 
                        <div class="gourmet-image-group">
                        <% for count in 1..restaurant['image_count'] %>
                            <img src="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/images/<%= restaurant['image_path'] %>/<%= count %>.jpg">
                        <% end %>
                        </div>
                    </div>    
                    <div class="right-container">
                    <h1><%= restaurant['name'] %></h1>
                        <div class="about-restaurant">
                            <div class="score">
                                <h4>評価:
                                    <span class="star5_rating" data-rate="<%= restaurant['score'] %>" ></span>
                                </h4>
                            </div>
                            <div class="visit_count">
                            <% if login_status == "logout" %>
                                <h4>訪問回数:
                                    <span><%= restaurant['visit_count'] %></span>
                                </h4>
                            <% end %>
                            </div>
                            <div class="genre">
                                <h4>ジャンル:</h4>
                                <label><span><%= genre[restaurant['genre_id'].to_i] %></span></label>
                                <input type="hidden" value="<%= genre_tag[restaurant['genre_id'].to_i] %>" class='hidden-restaurant-genre'> 
                            </div>
                            <div class="price">
                                <h4>
                                    価格帯:
                                </h4>
                                <div class="price-range">
                                    <span class="min-price">¥<%= restaurant['min_price'] %></span>~
                                    <span class="max-price">¥<%= restaurant['max_price'] %></span>
                                </div>
                            </div>
                            <% if login_status == "logout" %>
                            <button class="update-button" onclick="updatePopup(<%= restaurant['id'] %>)">更新</button>
                            <% end %>
                        </div>
                        <div class="business-day-hour">
                            <table class="time-table">
                                <tbody>
                                    <tr>
                                    <th></th>
                                    <th>月</th>
                                    <th>火</th>
                                    <th>水</th>
                                    <th>木</th>
                                    <th>金</th>
                                    <th class="sat">土</th>
                                    <th class="sun">日</th>
                                    </tr>
                                    <tr>
                                    <% restaurant['business_hours'].each do |key,value| %>
                                        <td class="time"><%= key %> </td>
                                        <td><%= (value.include?('Monday') ? '●' : '×') %></td>
                                        <td><%= (value.include?('Tuesday') ? '●' : '×') %></td><!-- 火 -->
                                        <td><%= (value.include?('Wendnesday') ? '●' : '×') %></td><!-- 水 -->
                                        <td><%= (value.include?('Thursday') ? '●' : '×') %></td><!-- 木 -->
                                        <td><%= (value.include?('Friday') ? '●' : '×') %></td><!-- 金 -->
                                        <td><%= (value.include?('Saturday') ? '●' : '×') %></td><!-- 土 -->
                                        <td><%= (value.include?('Sunday') ? '●' : '×') %></td><!-- 日 -->
                                    </tr>
                                    <% end %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </li>
        <% end %>
HTML

erb = ERB.new(html_template)
html_content = erb.result_with_hash(restaurants: restaurants)

print <<EOF

<html lang="ja">
<head>
  <meta charset="utf-8">
    <title>ランディングページ</title>
    <link rel="stylesheet" type="text/css" href="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/css/header.css">
    <link rel="stylesheet" type="text/css" href="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/css/search_restaurant.css">
</head>

<body>

<header class="header">
<h1 class="main-header">
    <a href="/" rel="home">
        <img src="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/images/Logo.png">
    </a>
</h1>
<a class="login-button" href="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/#{login_status}.rb">
    <img src="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/images/#{login_status}.png">
</a>
<button class="menu-toggle">
    <div class="menu-toggle-open">
        <div class="bar"></div>
        <div class="bar"></div>
        <div class="bar"></div>
    </div>
    <div class="menu-toggle-close">
        <div class="bar"></div>
        <div class="bar"></div>
    </div>
</button>

<nav class="site-header__menu">
    <ul class="menu-list">
        <li>
            <a class="menu-list__item" href="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/index.rb">
                <div class="ja">
                    <span class="palt">ト</span>ップ
                </div>
                <div class="en">TOP</div>
            </a>
            <div class="menu-list-img">
                <img src="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/images/arrow.png">
            </div>
        </li>
    </ul>
    <ul class="menu-list">
        <li>
            <a class="menu-list__item" href="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/login.rb">
                <div class="ja">
                    <span class="palt">ロ</span>グイン
                </div>
                <div class="en">LOGIN</div>
            </a>
            <div class="menu-list-img">
                <img src="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/images/arrow.png">
            </div>
        </li>
    </ul>
    <ul class="menu-list">
        <li>
            <a class="menu-list__item" href="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/gourmet_dice.rb">
                <div class="ja">
                    <span class="palt">グ</span>ルメダイス
                </div>
                <div class="en">GOURMET DICE</div>
            </a>
            <div class="menu-list-img">
                <img src="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/images/arrow.png">
            </div>
        </li>
    </ul>
    <ul class="menu-list">
        <li>
            <a class="menu-list__item" href="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/search_restaurant.rb">
                <div class="ja">
                    <span class="palt">レ</span>ストラン検索
                </div>
                <div class="en">SEARCH RESTAURANT</div>
            </a>
            <div class="menu-list-img">
                <img src="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/images/arrow.png">
            </div>
        </li>
    </ul>
</nav>

</header>

<div class="overlay"></div>

<div class="third-content">
<div class="search-section">
    <div class="search-form-wrapper">
        <form class="search-form" onsubmit="return checkForm(event)">
            <div class="form-item-title">
                <h3>飲食店名:</h3>
            </div>
            <p><input type="text" id="restaurant-name" name="restaurant-name" value="#{posted_restaurand_name}"></p>
            <div class="form-item-title">
                <h3>ジャンル:</h3>
            </div>
            <div class="genre-section">
                <label><input type="checkbox" name="genre" value=0 id="genre-form"><span>定食</span></label>
                <label><input type="checkbox" name="genre" value=1 id="genre-form"><span>麺類</span></label>
                <label><input type="checkbox" name="genre" value=2 id="genre-form"><span>居酒屋</span></label>
                <label><input type="checkbox" name="genre" value=3 id="genre-form"><span>ファミレス</span></label>
                <label><input type="checkbox" name="genre" value=4 id="genre-form"><span>エスニック</span></label>
            </div>

            <div class="form-item-title">
                <h3>価格帯:</h3>
            </div>
            <select id="price-range" name="price-range">
                <option value="800">~800</option>
                <option value="1200">~1200</option>
                <option value="1600">~1600</option>
                <option value="2000">~2000</option>
                <option value="100000">BF</option>
            </select>
            <br>

            <div class="form-item-title">
                <h3>移動手段:</h3>
            </div>
            <select id="transportation" name="transportation">
                <option value="walking">徒歩</option>
                <option value="bicycling">自転車</option>
                <option value="driving">車</option>
                <option value="transit">公共機関</option>
            </select>
            <br>

            <div class="form-item-title">
                <h3>所要時間:</h3>
            </div>
            <select id="time-required" name="time-required">
                <option value="10">~10</option>
                <option value="20">~20</option>
                <option value="30">~30</option>
                <option value="60">~60</option>
                <option value="1000000">BF</option>
            </select>
            <br>
            <input type="hidden" id="latitude" name="latitude">
            <input type="hidden" id="longitude" name="longitude">

            <button type="submit" id="submit" class="dice-button">検索</button>
        </form>
    </div>
</div>
<div class="search-result-section">
    <h1>検索結果</h1>
    <div class="search-result-items">
        <ul>
        #{html_content}
    </div>
</div>
</div>

<div id="popupForm" class="popup-overlay">
    <div class="popup-content">
        <button type="button" id="closePopup" class="close-btn">&#10005;</button> <!-- Cross Mark -->
        <h2>ユーザー情報更新</h2>
        <form method="get" action="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/visit_update.rb">
            <label for="username">評価:</label>
            <select id="score_update" name="score_update">
                <option value="0.5">0.5</option>
                <option value="1">1</option>
                <option value="1.5">1.5</option>
                <option value="2">2</option>
                <option value="2.5">2.5</option>
                <option value="3">3</option>
                <option value="3.5">3.5</option>
                <option value="4">4</option>
                <option value="4.5">4.5</option>
                <option value="5">5</option>
            </select><br>
            <label for="username">訪問回数:</label>
            <input type="hidden" id="restaurant_id_update" name="restaurant_id_update">
            <input type="number" min="0" id="visit_count_update" name="visit_count_update" value="0" ><br>
            <button type="submit" id="update-submit">更新</button>
        </form>
    </div>
</div>

<script>

window.onload = function(){
    var inputElement = document.getElementById("restaurant-name");

    var event = new Event('input', {
        bubbles: true,
        cancelable: true,
    });
    inputElement.dispatchEvent(event);
}

document.addEventListener('DOMContentLoaded', function () {
    var menuToggle = document.querySelector('.menu-toggle');
    var siteHeaderMenu = document.querySelector('.site-header__menu');
    var overlay = document.querySelector('.overlay');

    menuToggle.addEventListener('click', function () {
        if (siteHeaderMenu.classList.contains('menu-active')) {
            siteHeaderMenu.classList.remove('menu-active');
            menuToggle.classList.remove('menu-active');
            overlay.classList.remove('menu-active');
        } else {
            siteHeaderMenu.classList.add('menu-active');
            menuToggle.classList.add('menu-active');
            overlay.classList.add('menu-active');
        }
    })

    var searchInput = document.querySelector('input[name="restaurant-name"]');
    var restaurantItems = document.querySelectorAll('.restaurant-item');

    searchInput.addEventListener('input', function () {
        var searchText = searchInput.value.toLowerCase();
        var searchTerms = searchText.split('or').map(function(term) {
            return term.trim();
        }).filter(function(term) {
            return term !== '';
        });

        if (searchTerms.length === 0) {
            restaurantItems.forEach(function (item) {
                item.style.display = 'block';
            });
        } else {
            restaurantItems.forEach(function (item) {
                var restaurantName = item.querySelector('.right-container h1').textContent.toLowerCase();
                var anyTermMatches = searchTerms.some(function(term) {
                    return restaurantName.includes(term);
                });

                if (anyTermMatches) {
                    item.style.display = 'block';
                } else {
                    item.style.display = 'none';
                }
            });
        }
    });

    var genreCheckboxes = document.querySelectorAll('input[name="genre"]');
    var restaurantItems = document.querySelectorAll('.restaurant-item');

    function filterByGenre() {
        var selectedGenres = [];

        genreCheckboxes.forEach(function (checkbox) {
            if (checkbox.checked) {
                selectedGenres.push(checkbox.value);
            }
        });

        if (selectedGenres.length === 0) {
            restaurantItems.forEach(function (item) {
                item.style.display = 'block';
            });
        } else {
            restaurantItems.forEach(function (item) {
                var genreTags = item.querySelectorAll('.hidden-restaurant-genre');
                var shouldDisplay = false;

                genreTags.forEach(function (genreTag) {
                    var genre = genreTag.value;
                    if (selectedGenres.includes(genre)) {
                        shouldDisplay = true;
                    }
                });

                if (shouldDisplay) {
                    item.style.display = 'block'; 
                } else {
                    item.style.display = 'none';
                }
            });
        }
    }

    genreCheckboxes.forEach(function (checkbox) {
        checkbox.addEventListener('change', filterByGenre);
    });
});


if ("geolocation" in navigator) {
    navigator.geolocation.getCurrentPosition(function(position) {
        var latitude = position.coords.latitude;
        var longitude = position.coords.longitude;

        document.getElementById('latitude').value = latitude;
        document.getElementById('longitude').value = longitude;

        console.log("Latitude is :", latitude);
        console.log("Longitude is :", longitude);
    }, function(error) {
        console.warn("Error Code = " + error.code + " - " + error.message);
    });
} else {
    console.log("Geolocation is not supported by this browser.");
}

function checkForm(event) {
    var checkboxes = document.querySelectorAll('input[type="checkbox"][name="genre"]');
    var isChecked = false;
    event.preventDefault();

    checkboxes.forEach(function (checkbox) {
        if (checkbox.checked) {
            isChecked = true;
        }
    });

    if (!isChecked) {
        alert('少なくとも1つのジャンルを選択してください。');
        return false;
    } else{
        var formData = new FormData();
        var selectedGenres = [];
        var price_range = document.getElementById('price-range').value;
        var transportation = document.getElementById('transportation').value;
        var time_required = document.getElementById('time-required').value;
        var latitude = document.getElementById('latitude').value;
        var longitude = document.getElementById('longitude').value;

        checkboxes.forEach(function (checkbox) {
            if (checkbox.checked) {
                selectedGenres.push(checkbox.value);
            }
        });

        formData.append('genre', selectedGenres);
        formData.append('price-range', price_range);
        formData.append('transportation', transportation);
        formData.append('time_required',time_required);
        formData.append('latitude', latitude);
        formData.append('longitude', longitude);
        
        fetch('https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/search_restaurant_next.rb', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.success === false) {
                alert(data.message);
            } else {
                console.log('Success:', data);
                var joinedString = data.valid_restaurants.join("or");
                var inputElement = document.getElementById("restaurant-name");
                inputElement.value = joinedString;
        
                var event = new Event('input', {
                    bubbles: true,
                    cancelable: true,
                });
                inputElement.dispatchEvent(event);

                if (joinedString == ""){
                    alert("条件に一致する飲食店が見つかりませんでした。")
                } 
            }
        })
        .catch(error => console.error('Error:', error));
    }

    return true;
}


function updatePopup(restaurant_id) {
    document.getElementById('popupForm').style.display = 'block';
    document.getElementById('restaurant_id_update').value = restaurant_id;
};

document.getElementById('closePopup').addEventListener('click', function() {
    document.getElementById('popupForm').style.display = 'none';
});

</script>
</html>

EOF

rescue => e
    print "<html lang='ja'> <head><meta charset='utf-8'><body><p>エラーが発生しました。後ほど再度お試しください。</p><p>#{e.message}</p></body></html>"
end