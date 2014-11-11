---
layout: post
title: "Nginx + uwsgi + Django环境配置"
date: 2014-11-11 13:02:17 +0000
comments: true
post_id: 84135
permalink: /archives/84135.html
categories: ["web开发", "python栏目"]
tags: ["Django", "python"]
---

有段时间没折腾 Django 了，又有点生疏了。最近又部署了一下 Django 的环境，顺便作个笔记以便之后查阅。

首先安装 nginx、uwsgi 以及 uwsgi 的 python 插件。

然后新建一个 uwsgi 的配置文件：

```
[uwsgi]
uid = www-data
chdir = /repo/django-blog
virtualenv = /repo/django-blog/pyenv2.7/    # python虚拟环境，没有可以不设置
env = DJANGO_SETTINGS_MODULE=blog.settings
module = blog.wsgi:application
master = true
plugin = python
pidfile = /tmp/blog-master.pid
socket = /tmp/blog.sock
enable-threads = true
post-buffering=1024000
post-buffering-busize=655360
```

这里我们的 Django 项目代码位于 `/repo/django-blog` ，项目的配置文件为： `blog/settings.py` 。

`virtualenv` 项表明我们使用的是 `virtualenv` 环境，也可以直接系统的 python 环境。不过还是建议使用虚拟环境，以免软件包版本冲突。

`post-buffering` 和 `post-buffering-busize` 这两项设置了 POST 请求时缓冲区的大小，该值可根据自己的情况进行调整。之前遇到过由于缓冲区不足导致返回的内容不完整。

再安装对应的 python 依赖包，然后运行 uwsgi 服务。

接着修改 nginx 的配置：

```
server {
  listen 80;
  server_name localhost;

  client_max_body_size 50m;

  access_log /var/log/nginx/blog-access.log;
  error_log /var/log/nginx/blog-error.log;

  location / {
    uwsgi_pass unix:///tmp/blog.sock;
    include uwsgi_params;
  }

  location /static {
    alias /repo/django-blog/static/;
  }
}
```

这个内容比较简单， `client_max_body_size` 项是用于设置 http 请求的 body 最大大小。如果你的程序中有文件上传的，那么就需要根据自身情况来设置允许上传文件的最大值。

最后再启动 nginx 服务。
