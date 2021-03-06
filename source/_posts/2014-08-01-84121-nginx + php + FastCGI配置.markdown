---
layout: post
title: nginx + php + FastCGI配置
date: 2014-08-01 13:38:39 +0000
comments: true
post_id: 84121
permalink: /archives/84121.html
categories: ["Web开发"]
tags: ["nginx", "php"]
---

<p>最近在弄PHP，于是乎把配置过程作一个笔记以免忘了。</p>
<h2>PHP安装、配置</h2>
<p>我是通过源代码编译的形式进行安装的，基本步骤如下：</p>
<pre><code>$ tar xf php-5.5.12.tar.bz2
$ cd php-5.5.12
$ './configure'  '--prefix=/opt/myphp' '--with-mysql' '--enable-safe-mode' '--enable-ftp' '--enable-zip' '--with-jpeg-dir' '--with-bz2' '--with-png-dir' '--with-freetype-dir' '--with-iconv' '--with-libxml-dir' '--with-xmlrpc' '--with-zlib-dir' '--with-gd' '--enable-gd-native-ttf' '--with-curl' '--with-gettext' '--with-pear' '--enable-fpm' '--enable-fastcgi' '--with-ncurses' '--with-mcrypt' '--with-mhash' '--with-openssl' '--with-pcre-dir' '--enable-pdo' '--enable-phar' '--enable-json' '--enable-mbstring' '--with-pdo-mysql' '--with-pdo-sqlite' '--with-readline' '--enable-bcmath'
$ make
$ sudo make install
</code></pre>

<p>安装完成之后进入安装目录修改配置文件 lib/php.ini (没有则创建)，添加时区设置：</p>
<pre><code>date.timezone=Asia/Shanghai
</code></pre>

<p>然后运行PHP的FastCGI服务：</p>
<pre><code>./bin/php-cgi -b 9000
</code></pre>

<h2>nginx配置</h2>
<p>nginx可以直接从仓库进行安装：</p>
<pre><code>sudo pacman -S nginx
</code></pre>

<p>或者：</p>
<pre><code>sudo apt-get install nginx
</code></pre>

<p>安装完成之后修改配置，添加一条新的虚拟主机：</p>
<pre><code>server {
    listen 8000;
    server_name localhost;

    root /var/www;

    location / {
        index index.php;
    }

    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;  
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include        fastcgi_params;
        fastcgi_param  SCRIPT_FILENAME  /var/www/$fastcgi_script_name;
    }

}
</code></pre>

<p>然后再创建文件 /var/www/index.php</p>
<pre><code>&lt;?php
  phpinfo();
?&gt;
</code></pre>

<p>现在通过浏览器访问 http://127.0.0.1:8000/ 应该就可以看到效果了。</p>
