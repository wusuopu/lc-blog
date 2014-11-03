---
layout: post
title: python cgi教程1——Hello World
data: 2013-12-06 13:26:30 +0000
comments: true
post_id: 83979
permalink: /archives/83979.html
categories: ["Web开发"]
tags: ["python", "Web开发"]
---

<h2>简介</h2>
<p>CGI(Common Gateway Interface)，通用网关接口的简称。它是客户端和服务器程序进行数据传输的一种标准。</p>
<p>一个CGI程序可以使用任何语言编写，通常它是放在Web服务器（如Apache）目录下的cgi-bin目录里。</p>
<h2>实例</h2>
<p>接下来看一个简单的例子。</p>

``` python
#!/usr/bin/env python
print "Content-Type: text/html"
print
print """\
<html>
<body>
<h2>Hello World!</h2>
</body>
</html>
"""
```

<p>脚本程序的第一行指定了python解释器的路径。在你系统中它也可能为：</p>

``` python
#!/usr/bin/python
#!/usr/bin/python2
#!c:\Python26\python.exe
#!c:\Python27\python.exe
```

``` python
print "Content-Type: text/html"
print
```

<p>脚本必须输出一个HTTP的头，它由一条或者多条消息构成，然后再一个空行。空行是必需的，它意味着头的结束。<br>
这里我们想要把输出作为HTML解释，因此指定Content-Type为 text/html。</p>
<p>这里也可以写成：</p>

``` python
print "Content-Type: text/html\n"
```

<p>保存以上脚本，并添加执行权限。然后在浏览器中访问执行该脚本，应该可以看到"Hello World"这几个字。</p>
