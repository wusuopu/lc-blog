---
layout: post
title: python cgi教程5——Cookie
data: 2013-12-07 08:49:31 +0000
comments: true
post_id: 83998
permalink: /archives/83998.html
categories: ["Web开发"]
tags: ["python", "Web开发"]
---

<h2>设置Cookie</h2>
<p>有两个与cookie相关的操作，设置cookie和读取cookie。</p>
<p>以下例子展示了cookie的设置。</p>

```python
#!/usr/bin/env python
import time

# This is the message that contains the cookie
# and will be sent in the HTTP header to the client
print 'Set-Cookie: lastvisit=' + str(time.time());

# To save one line of code
# we replaced the print command with a '\n'
print 'Content-Type: text/html\n'
# End of HTTP header

print '<html><body>'
print 'Server time is', time.asctime(time.localtime())
print '</body></html>'
```

<p>这是在数据头中使用<em>Set-Cookie</em>进行的操作。</p>
<h2>检索Cookie</h2>
<p>浏览器返回来的cookie存放于os.environ字典中，对应的字段名为'HTTP_COOKIE'。以下是一个例子：</p>

```python
#!/usr/bin/env python
import Cookie, os, time

cookie = Cookie.SimpleCookie()
cookie['lastvisit'] = str(time.time())

print cookie
print 'Content-Type: text/html\n'

print '<html><body>'
print '<p>Server time is', time.asctime(time.localtime()), '</p>'

# The returned cookie is available in the os.environ dictionary
cookie_string = os.environ.get('HTTP_COOKIE')

# The first time the page is run there will be no cookies
if not cookie_string:
   print '<p>First visit or cookies disabled</p>'

else: # Run the page twice to retrieve the cookie
   print '<p>The returned cookie string was "' + cookie_string + '"</p>'

   # load() parses the cookie string
   cookie.load(cookie_string)
   # Use the value attribute of the cookie to get it
   lastvisit = float(cookie['lastvisit'].value)
   
   print '<p>Your last visit was at',
   print time.asctime(time.localtime(lastvisit)), '</p>'

print '</body></html>'
```

<p>使用SimpleCookie对象的load()方法对字符串进行解析。</p>
