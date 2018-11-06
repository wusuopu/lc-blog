---
layout: post
title: python cgi教程6——Session
date: 2013-12-07 12:39:56 +0000
comments: true
post_id: 84001
permalink: /archives/84001.html
categories: ["Web开发"]
tags: ["python", "Web开发"]
---

<p>Session是位于服务器端的Cookie。它保存在服务器上的文件或者数据库中。每条session是由session id(SID)进行标识。</p>
<h2>基于Cookie的SID</h2>
<p>Cookie可以长久胡保存SID，直到Cookie过期。用这种方式更快更安全。但是得客户端的浏览器支持Cookie才行。</p>

```python
#!/usr/bin/env python

import sha, time, Cookie, os

cookie = Cookie.SimpleCookie()
string_cookie = os.environ.get('HTTP_COOKIE')

# If new session
if not string_cookie:
   # The sid will be a hash of the server time
   sid = sha.new(repr(time.time())).hexdigest()
   # Set the sid in the cookie
   cookie['sid'] = sid
   # Will expire in a year
   cookie['sid']['expires'] = 12 * 30 * 24 * 60 * 60
# If already existent session
else:
   cookie.load(string_cookie)
   sid = cookie['sid'].value

print cookie
print 'Content-Type: text/html\n'
print '<html><body>'

if string_cookie:
   print '<p>Already existent session</p>'
else:
   print '<p>New session</p>'

print '<p>SID =', sid, '</p>'
print '</body></html>'
```

<p>我们对服务器的时间进行哈希生成一个唯一的Session ID。</p>
<h2>基于Query String的SID</h2>

    #!/usr/bin/env python
    
    import sha, time, cgi, os
    
    sid = cgi.FieldStorage().getfirst('sid')
    
    if sid: # If session exists
       message = 'Already existent session'
    else: # New session
       # The sid will be a hash of the server time
       sid = sha.new(repr(time.time())).hexdigest()
       message = 'New session'
    
    qs = 'sid=' + sid
    
    print """\
    Content-Type: text/html\n
    <html><body>
    <p>%s</p>
    <p>SID = %s</p>
    <p><a href="./set_sid_qs.py?sid=%s">reload</a></p>
    </body></html>
    """ % (message, sid, sid)

<p>这是将sid直接在url中传递。</p>
<h2>使用隐藏域</h2>

    #!/usr/bin/env python
    
    import sha, time, cgi, os
    
    sid = cgi.FieldStorage().getfirst('sid')
    
    if sid: # If session exists
       message = 'Already existent session'
    else: # New session
       # The sid will be a hash of the server time
       sid = sha.new(repr(time.time())).hexdigest()
       message = 'New session'
    
    qs = 'sid=' + sid
    
    print """\
    Content-Type: text/html\n
    <html><body>
    <p>%s</p>
    <p>SID = %s</p>
    <form method="post">
    <input type="hidden" name=sid value="%s">
    <input type="submit" value="Submit">
    </form>
    </body></html>
    """ % (message, sid, sid)

<p>这是将sid放在表单中作为隐藏字段提交。</p>
<h2>shelve模块</h2>
<p>光有session id是不够的，还需要将内容保存到文件或者数据库中。这里可以使用shelve模块保存到文件。</p>

`session = shelve.open('/tmp/.session/sess_' + sid, writeback=True)`

<p>它打开文件并返回一个类似于字典的对象。</p>

`session['lastvisit'] = repr(time.time())`

<p>设置session的值。</p>

`lastvisit = session.get('lastvisit')`

<p>读取刚刚设置的值。</p>

`session.close()`

<p>最后操作完成之后要记得关闭文件。</p>
<h2>Cookie和Shelve</h2>
<p>接下来用一个例子展示下Cookie和Shelve共同使用。</p>

    #!/usr/bin/env python
    import sha, time, Cookie, os, shelve
    
    cookie = Cookie.SimpleCookie()
    string_cookie = os.environ.get('HTTP_COOKIE')
    
    if not string_cookie:
       sid = sha.new(repr(time.time())).hexdigest()
       cookie['sid'] = sid
       message = 'New session'
    else:
       cookie.load(string_cookie)
       sid = cookie['sid'].value
    cookie['sid']['expires'] = 12 * 30 * 24 * 60 * 60
    
    # The shelve module will persist the session data
    # and expose it as a dictionary
    session_dir = os.environ['DOCUMENT_ROOT'] + '/tmp/.session'
    session = shelve.open(session_dir + '/sess_' + sid, writeback=True)
    
    # Retrieve last visit time from the session
    lastvisit = session.get('lastvisit')
    if lastvisit:
       message = 'Welcome back. Your last visit was at ' + \
          time.asctime(time.gmtime(float(lastvisit)))
    # Save the current time in the session
    session['lastvisit'] = repr(time.time())
    
    print """\
    %s
    Content-Type: text/html\n
    <html><body>
    <p>%s</p>
    <p>SID = %s</p>
    </body></html>
    """ % (cookie, message, sid)
