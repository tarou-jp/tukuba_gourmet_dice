#!/usr/bin/env ruby
# encording: utf-8
require "cgi"
require "sqlite3"
require 'cgi/session'

cgi = CGI.new
cookies = cgi.cookies
session_id = cookies['my_ruby_cookie'][0]
login_status = "login"
rows = []

begin
print cgi.header("content-type: text/html; charset=utf-8")

db = SQLite3::Database.new("s2210573.db")
db.transaction(){
    rows = db.execute("SELECT name, image_path FROM restaurants ORDER BY RANDOM() LIMIT 3")
}

db.close

if !session_id.nil? && !session_id.empty?
    session = CGI::Session.new(cgi, "session_key" => "my_ruby_session", "session_id" => session_id)
    if !session['username'].nil? && !session['username'].empty?
        login_status = "logout"
    end
end

print <<EOF

<html lang="ja">
<head>
  <meta charset="utf-8">
    <title>ランディングページ</title>
    <link rel="stylesheet" type="text/css" href="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/css/header.css">
    <link rel="stylesheet" type="text/css" href="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/css/index.css">
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

    <div class="top-wrapper">
        <div class="top-textarea-wrapper">
            <div class="top-textarea">
                <div class="top-h1">
                    <img class="fit" src="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/images/home.png">
                </div>
                <p class="top-p">
                    本サイトでは、あなたが入力した条件にぴったり合う飲食店を、特別なアルゴリズムで提案します！一度のクリックで、未知の美味しい出会いがあなたを待っています。もしかしたら、やがてすべての飲食店を制覇する日が来るかもしれません！
                </p>
            </div>
        </div>
        <div class="top-slider" id="top-slider">
            <div class="slide" id="slide1">
                <div class="image">
                    <a class="slide-image-target">
                        <img class="fit" src="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/images/#{rows[0][1]}/0.jpg">
                    </a>
                </div>
                <a href="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/search_restaurant.rb?posted_restauranted_name=#{rows[0][0]}" class="shop-link">
                <div class="detail">
                    <div class="shop-name">#{rows[0][0]}</div>
                </div>
                </a>
            </div>
            <div class="slide" id="slide2">
                <div class="image">
                    <a class="slide-image-target">
                        <img class="fit" src="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/images/#{rows[1][1]}/0.jpg">
                    </a>
                </div>
                <a href="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/search_restaurant.rb?posted_restauranted_name=#{rows[1][0]}" class="shop-link">
                <div class="detail">
                    <div class="shop-name">#{rows[1][0]}</div>
                </div>
                </a>
            </div>
            <div class="slide" id="slide3">
                <div class="image">
                    <a class="slide-image-target">
                        <img class="fit" src="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/images/#{rows[2][1]}/0.jpg">
                    </a>
                </div>
                <a href="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/search_restaurant.rb?posted_restauranted_name=#{rows[2][0]}" class="shop-link">
                <div class="detail">
                    <div class="shop-name">#{rows[2][0]}</div>
                </div>
                </a>
            </div>
        </div>
    </div>
      

</body>
<script>

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
    
    var topSlider = document.getElementById("top-slider")
    const slides = [document.getElementById('slide1'), document.getElementById('slide2'), document.getElementById('slide3')];
    var slideIndex = 0;

    function changeSlide() {
        let firstSlide = topSlider.removeChild(slides[0]);
        topSlider.appendChild(firstSlide);
        slides.push(slides.shift());

        requestAnimationFrame(function() {
            slides[0].style.margin = "15% 5% auto auto";
            slides[0].style.zIndex = 6;
            slides[1].style.margin = "13% 3% auto auto";
            slides[1].style.zIndex = 5;
            requestAnimationFrame(function() {
                slides[2].style.margin = "11% 1% auto auto";
                slides[2].style.zIndex = 4;
            });
        });

    }

    setInterval(changeSlide, 4000);
});

</script>
</html>

EOF

rescue => e
    print "<html lang='ja'> <head><meta charset='utf-8'><body><p>エラーが発生しました。後ほど再度お試しください。</p><p>#{e.message}</p></body></html>"
end