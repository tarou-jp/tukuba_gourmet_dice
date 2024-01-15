#!/usr/bin/env ruby
# encording: utf-8
require "cgi"
require "sqlite3"
require 'cgi/session'

cgi = CGI.new
print cgi.header("content-type: text/html; charset=utf-8")

begin

cookies = cgi.cookies
error = cgi.params['error'][0]
session_id = cookies['my_ruby_cookie'][0]

friend_inf = []
login_status = "login"
user_inf = ""
has_friend_info = false

if !session_id.nil? && !session_id.empty?
    session = CGI::Session.new(cgi, "session_key" => "my_ruby_session", "session_id" => session_id)
    if !session['username'].nil? && !session['username'].empty?
        username = session["username"]
        user_inf = "<div class='my-user-form'><div class='add-user-img'><img src='https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/images/Logo.png'></div><div><h4>#{username}</h4></div></div>"
        login_status = "logout"
    end
    if !session['friendArray'].nil? && !session['friendArray'].empty?
        has_friend_info = true
        session['friendArray'] ||= []
        session['friendArray'].each do |friend_username|
            friend_inf << "<div class='friend-user-form'><div class='add-user-img'><img src='https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/images/Logo.png'></div><div><h4>#{friend_username}</h4></div></div>"
        end
    end
    session.close
end

print <<EOF

<html lang="ja">
<head>
  <meta charset="utf-8">
    <title>グルメダイス</title>
    <link rel="stylesheet" type="text/css" href="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/css/header.css">
    <link rel="stylesheet" type="text/css" href="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/css/gourmet_dice.css">
</head>

<body>

<header class="header">
<h1 class="main-header">
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

    <div class="second-content">
        <div class="search-section">
            <div class="search-form-wrapper">
            <form class="search-form" id="search-form" method="post" action="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/gourmet_dice_play.rb" onSubmit="return checkForm()">
                    <div class="form-item-title">
                        <h3>ジャンル:</h3>
                    </div>
                    <div class="genre-section">
                        <label><input type="checkbox" name="genre" value=0><span>定食</span></label>
                        <label><input type="checkbox" name="genre" value=1><span>麺類</span></label>
                        <label><input type="checkbox" name="genre" value=2><span>居酒屋</span></label>
                        <label><input type="checkbox" name="genre" value=3><span>ファミレス</span></label>
                        <label><input type="checkbox" name="genre" value=4><span>エスニック</span></label>
                    </div>

                    <div class="form-item-title">
                        <h3>価格帯:</h3>
                    </div>
                    <select id="price-range" name="price-range">
                        <option value=800>~800</option>
                        <option value=1200>~1200</option>
                        <option value=1600>~1600</option>
                        <option value=2000>~2000</option>
                        <option value=100000>BF</option>
                    </select>
                    </br>

                    <div class="form-item-title">
                        <h3>移動手段:</h3>
                    </div>
                    <select id="transportation" name="transportation">
                        <option value="walking">徒歩</option>
                        <option value="bicycling">自転車</option>
                        <option value="driving">車</option>
                        <option value="transit">公共機関</option>
                    </select>
                    </br>

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
                    </br>
                    <input type="hidden" id="latitude" name="latitude">
                    <input type="hidden" id="longitude" name="longitude">

                    <div class="add-player" id="add-player">
                        <div id="added-players">
                            <div class="form-item-title">
                                <h3>参加ユーザー:</h3>
                            </div>
                            #{user_inf}
                            #{friend_inf.join("\n")}
                            </div>
                        </div>
                        <div type="button" id="add-player-button" class="user-form">
                            <div class="add-user-img">
                                <img src="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/images/Logo.png">
                            </div>
                            <div><h4>ユーザー追加</h4></div>
                        </div>

                    <button ="dice-play" class="dice-button">ダイスを振る</button>
                </form>
            </div>
        </div>
        <div class="map-section">
            <div id="map"></div>
        </div>
    </div>
                    
<div id="popupForm" class="popup-overlay">
    <div class="popup-content">
        <button type="button" id="closePopup" class="close-btn">&#10005;</button> <!-- Cross Mark -->
        <h2>ユーザー追加</h2>
        <form action="/submit_form_path" method="post">
            <label for="username">ユーザー名:</label>
            <input type="text" id="username" name="username"><br>
            <label for="password">パスワード:</label>
            <input type="password" id="password" name="password"><br>
            <button type="button" id="add-player-submit">追加</button>
        </form>
    </div>
</div>



<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCA0t45fvMjTCFbM9hixFDGwrJUrkMZNbs&language=ja"></script>

<script>
var MyLatLng = new google.maps.LatLng(36.08636354495407, 140.1062760207793);
var Options = {
    zoom: 15,
    center: MyLatLng,
    mapId: "bc3c7c9a3b90a2a4"
};

var map = new google.maps.Map(document.getElementById("map"), Options)

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
    
});

var error = "#{error}";
if (error) {
    alert(error);
}

function checkForm(){
    var form = document.getElementById('search-form');
    var checkboxes = form.querySelectorAll('input[type="checkbox"][name="genre"]');
    var isChecked = Array.from(checkboxes).some(checkbox => checkbox.checked);
    if (!isChecked) {
        alert('少なくとも1つのジャンルを選択してください。');
        return false;
    }
    return true;
}

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

document.getElementById('add-player-button').addEventListener('click', function() {
    document.getElementById('popupForm').style.display = 'block';
    document.getElementById('add-player-submit').addEventListener('click', function(e) {
        e.preventDefault();
        var username = document.getElementById('username').value;
        var password = document.getElementById('password').value;
        var add_player_element = document.getElementById('add-player');

        var formData = new FormData();
        formData.append('username', username);
        formData.append('password', password);
        formData.append('login_status', '#{login_status}');
        formData.append('has_friend_info','#{has_friend_info}')
        
        fetch('https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/add_friend.rb', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.success === false) {
                alert(data.message);
            } else {
                document.getElementById('popupForm').style.display = 'none';
                console.log('Success:', data);
                var newHtmlContent = `<div class='friend-user-form'><div class='add-user-img'><img src='https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/images/Logo.png'></div><div><h4>${data['username']}</h4></div></div>`;
                add_player_element.insertAdjacentHTML('beforeend', newHtmlContent);
            }
        })
        .catch(error => console.error('Error:', error));
    });
});

document.getElementById('closePopup').addEventListener('click', function() {
    document.getElementById('popupForm').style.display = 'none';
});

</script>
</html>

EOF

rescue => e
    error_message = CGI.escape(e.message)
    print cgi.header("Status" => "302 Found", "Location" => "https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/signin.rb?error=#{error_message}")
end