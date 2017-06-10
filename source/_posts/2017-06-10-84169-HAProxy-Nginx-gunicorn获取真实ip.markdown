---
layout: 'post'
title: 'HAProxy+Nginx+gunicorn获取真实ip'
date: '2017-06-10T14:31:24.730Z'
comments: true
post_id: '84169'
permalink: '/archives/84169.html'
categories: ['Python栏目']
tags: ['python']
---

之前在部署在 nginx + uwsgi 应用时都是通过如下方法来获取真实的客户端ip的：

```
    upstream app_server {
        server unix:///tmp/gunicorn.sock fail_timeout=0;
    }

    server {
        listen       80;
        server_name  localhost;
        location / {
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
            proxy_redirect off;

            proxy_pass   http://app_server;
        }
    }
```

这样在 uwsgi 的应用程序中只需要读取 http headers 中的 X-Forwarded-For 字段即可。

但是最近由于运维架构的是采用 haproxy + nginx + uwsgi 是形式，导致了在 uwsgi 应用程序中获取到的 ip 都是 haproxy 的。
为了要获取到真实的ip地址，需要由 haproxy 将 ip 传给 nginx，再由 nginx 传给 uwsgi。
在网上搜索了半天 haproxy 的相关配置，感觉太复杂了。因此还是决定从 nginx 入手。

经过实验将 nginx 的配置改为如下即可：

```
            proxy_set_header X-Forwarded-For $http_x_forwarded_for;
            proxy_set_header Host $http_host;
            proxy_redirect off;
```
