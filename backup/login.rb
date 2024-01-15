#!/usr/bin/env ruby
# encording: utf-8

require "cgi"

cgi = CGI.new
print cgi.header("content-type: text/html; charset=utf-8")

begin

print <<EOF
<html lang="ja">
<head>
  <meta charset="utf-8">
    <title>ログイングページ</title>
    <link rel="stylesheet" type="text/css" href="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/css/header.css">
    <link rel="stylesheet" type="text/css" href="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/css/login.css">
</head>
<body>


<header class="header">
<h1 class="main-header">
    <a href="/" rel="home">
        <img src="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/public/images/Logo.png">
    </a>
</h1>
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

    <div class="login-page">
        <div class="form">
            <h1>ログイン</h1>
            <form class="login-form"  id="loginForm" method="post" action="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/login_check.rb">
                <input type="text" placeholder="username" id="username" name="username" autocomplete="username">
                <input type="password" placeholder="password" id="password" name="password" autocomplete="current-password">
                <button type="submit">ログイン</button>
                <p class="message">アカウントをお持ちでない方<a href="https://cgi.u.tsukuba.ac.jp/~s2210573/local_only/wp/signin.rb">Create an account</a></p>
            </form>
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

    var loginForm = document.getElementById('loginForm');
    
    loginForm.addEventListener('submit', function (event) {
        var username = document.getElementById('username').value;
        var password = document.getElementById('password').value;

        if (!username || !password) {
            alert('ユーザー名とパスワードの両方を入力してください。');
            event.preventDefault(); 
        }
    });
    
    var queryParams = new URLSearchParams(window.location.search);
    if (queryParams.has('error')) {
      var errorMessage = queryParams.get('error');
      alert(decodeURIComponent(errorMessage));
    }

});

</script>
</html>

EOF

rescue => e
    print "<html lang='ja'> <head><meta charset='utf-8'><body><p>エラーが発生しました。後ほど再度お試しください。</p><p>#{e.message}</p></body></html>"
end