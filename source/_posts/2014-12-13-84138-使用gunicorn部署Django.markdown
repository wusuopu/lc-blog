---
layout: post
title: "使用gunicorn部署Django"
date: 2014-12-13 13:03:27 +0000
comments: true
post_id: 84138
permalink: /archives/84138.html
categories: ["web开发", "python栏目"]
tags: ["Django", "python"]
---

[Gunicorn](http://gunicorn.org/) 是 Python的 一个 WSGI HTTP服务器，根据它的介绍说是它来自于 Ruby 的 Unicorn。可以方便的部署 Python 的 Web 程序，而且本身支持多种 Python 的框架，如 Django、Paster等。

通过介绍来看貌似很不错的样子，只可惜我现在不玩 Python 了，于是就简单体验一下。

## 简单应用
首先是安装，这个可以直接使用 `pip` 来完成：

```
$ pip install gunicorn
```

然后再根据官方文档的介绍部署一个简单的例子试试：

```
$ cd examples
$ cat test.py
# -*- coding: utf-8 -
#
# This file is part of gunicorn released under the MIT license.
# See the NOTICE for more information.

def app(environ, start_response):
    """Simplest possible application object"""
    data = 'Hello, World!\n'
    status = '200 OK'
    response_headers = [
        ('Content-type','text/plain'),
        ('Content-Length', str(len(data)))
    ]
    start_response(status, response_headers)
    return iter([data])

$ gunicorn -b 0.0.0.0:8000 --workers=2 test:app
```

好的，现在程序运行起来了，可以访问 http://localhost:8000 看下效果。


gunicorn 也可以通过配置文件来设置一些内容， 一个配置文件是一个 python 脚本，格式类似 `.ini` 。通过 `-c` 参数指定要使用的配置文件。如：

```
# config.ini
bind = ["0.0.0.0:8000", "unix:///tmp/gunicorn.sock"]
workers = 3 
```

gunicorn 还能与 Django 和 Paster 应用集成：

```
$ gunicorn --env DJANGO_SETTINGS_MODULE=myproject.settings myproject.wsgi:application
$ gunicorn --paste development.ini -b :8080 --chdir /path/to/project
```


## 与 Nginx 部署
gunicorn 本身也是一个 WSGI 应用，可以与 Nginx 一同使用。
以下是 Nginx + Gunicorn 部署 Django 的事例， Nginx 配置如下：

```
# nginx.conf
http {
    include mime.types;
    default_type application/octet-stream;
    access_log /tmp/nginx.access.log combined;
    sendfile on;

    upstream app_server {
        server unix:/tmp/gunicorn.sock fail_timeout=0;
        # For a TCP configuration:
        # server 192.168.0.7:8000 fail_timeout=0;
    }

    server {
        listen 80 default;
        client_max_body_size 4G;
        server_name _;

        keepalive_timeout 5;

        # path for static files
        root /path/to/app/current/public;

        location / {
            # checks for static file, if not found proxy to app
            try_files $uri @proxy_to_app;
        }

        location @proxy_to_app {
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
            proxy_redirect off;

            proxy_pass   http://app_server;
        }

        error_page 500 502 503 504 /500.html;
        location = /500.html {
            root /path/to/app/current/public;
        }
    }
}
```

Gunicorn 的配置文件：

```
# gunicorn.ini
import os

bind = ["0.0.0.0:8000", "unix:///tmp/gunicorn.sock"]
workers = 3
chdir = os.path.dirname(os.path.realpath(__file__))
raw_env = ["DJANGO_SETTINGS_MODULE=app.settings"]
accesslog = "/tmp/gunicorn-access.log"
errorlog = "/tmp/gunicorn.log"
daemon = True
pidfile = "/tmp/gunicorn.pid"
```

运行：

```
$ gunicorn -c gunicorn.ini webui.wsgi:application
$ service nginx start
```

## 其他内容
与 WSGI 应用一样，如果之后配置有改动可以向 gunicorn 服务进程发送 `HUP` 信号让其重新加载配置：

```
$ kill -s HUP <pid>
```

