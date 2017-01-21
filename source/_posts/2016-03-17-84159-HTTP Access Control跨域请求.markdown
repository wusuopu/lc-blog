---
layout: post
title: "HTTP Access Control跨域请求"
date: 2016-03-17 08:35:12 +0000
comments: true
post_id: 84159
permalink: /archives/84159.html
categories: ["Web开发"]
tags: ["ajax"]
---

最近在使用 Ajax api 请求时遇到了跨域的问题，现在问题解决了顺便做个笔记。  

场景：现在主站域名为 example.org ，需要通过 ajax 请求 hello-world.example 上的资源。

## Access-Control-Allow-Origin

如果请求时遇到如下错误：  
`No 'Access-Control-Allow-Origin' header is present on the requested resource. Origin 'http://example.org' is therefore not allowed access.`

则需要在 hello-world.example 的 server 端 Response Headers 中设置 `Access-Control-Allow-Origin` 字段。其值根据情况设置为 `http://example.org` 或者 `https://example.org` 。

## Access-Control-Allow-Methods

一般情况下只允许 GET 和 POST 请求，对于 RESTful 的 api 可能会有其他类型的请求。例如：

```
$.ajax({
  url: 'http://hello-world.example/sessions/me.json',
  method: 'DELETE',
  dataType: 'json'
});
```

这时如果出现方法不被允许，则需要在 server 端 Response Headers 中设置 `Access-Control-Allow-Methods` 字段。如： `Access-Control-Allow-Methods: GET, POST, DELETE` 。


## Access-Control-Allow-Credentials

当在 hello-world.example 站点登录之后，浏览器会保存对应的 Cookies ，但是在 example.org 站点中使用 ajax 时发现 hello-world.example 的 Cookies 并没有附加到 Request Headers 中。

此时就需要设置 XMLHttpRequest 的 `withCredentials` 属性，例如：

```
$.ajax({
  url: 'http://hello-world.example/session/me.json',
  method: 'GET',
  dataType: 'json',
  xhrFields: {
      withCredentials: true
  }
});
```

同时在 server 端 Response Headers 中设置 `Access-Control-Allow-Credentials` 字段。说明允许通过跨域修改 Cookies 。如： `Access-Control-Allow-Credentials: true`


以上是常用的几个字段，更多设置参考手册： https://www.w3.org/TR/access-control/

