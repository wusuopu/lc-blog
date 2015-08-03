---
layout: post
title: "unicorn是如何与nginx通讯的——介绍ruby中的unix socket"
date: 2015-08-03 08:01:52 +0000
comments: true
post_id: 84146
permalink: /archives/84146.html
categories: ["Ruby栏目"]
tags: ["Ruby", "翻译"]
---

Ruby 应用服务典型地是与一个 web 服务一同使用的，如 nginx。当用户请求你的 Rails 应用中的页面时，nginx 将请求指派给应用服务。
然而这个过程是如何完成的呢？nginx 与 unicorn 是如何通讯的呢？

最有效的一种选择是使用 unix 套接字(sockets)。让我们来看看它们是如何工作的！
在这篇文章中我们将从一个基本的套接字(sockets)开始，最后将创建一个使用 nginx 代理的简单应用服务。

![socket](/wp-content/uploads/2015/07/socket.png)

*套接字(sockets)允许进程之间通过对一个文件读或者写进行相互通讯。*
*在这个例子中 Unicorn 创建 socket 并监听它的连接。然后 Nginx 就可以连接到这个 socket 并与 Unicorn 通讯了。*


## 什么是 unix socket？

Unix socket 使得一个进程通过类似文件的方式与另一个进程进行通讯。它是 IPC(Interprocess Communication) 的一种。

要使得可以通过 socket 访问进程，首先需要创建一个 socket 并作为一个文件保存在磁盘中。
然后监听这个 socket 的连入连接。当接收到一个连接时，就可以使用[标准 IO 方法](http://ruby-doc.org/core-2.2.2/IO.html#method-i-readline)进行读写数据。

Ruby 通过以下一组类提供了 unix socket 所需的所有内容：

- UNIXServer - 创建 socket 并保存到磁盘中，并且让你可以监听新连接。
- UNIXSocket - 打开已存在的套接字(sockets)。

**注意：**还存在着其它类型的 socket，最突出的是 TCP socket。不过这篇文章只处理 unix socket。那么它们之间的区别是什么呢？unix  socket 具有文件名。


## 最简单的 Socket

我们接下来看两个小程序。

第一个是服务端，它创建一个 `UnixServer` 实例，然后使用 `server.accept` 等待连接。当收到连接后则相互问候。

需要说明一下，`accept` 和 `readline` 方法都会阻塞程序的执行，直到收到内容。

```ruby
require "socket"
 
server = UNIXServer.new('/tmp/simple.sock')
 
puts "==== Waiting for connection"
socket = server.accept
 
puts "==== Got Request:"
puts socket.readline
 
puts "==== Sending Response"
socket.write("I read you loud and clear, good buddy!")
 
socket.close
```

这里我们有了服务端，现在还需要客户端。

在下面这个例子中，我们打开由服务端创建的 socket，然后使用普通的 IO 方法进行发送和接收问候。

```ruby
require "socket"
 
socket = UNIXSocket.new('/tmp/simple.sock')
 
puts "==== Sending"
socket.write("Hello server, can you hear me?\n")
 
puts "==== Getting Response"
puts socket.readline
 
socket.close
```

演示一下程序，先运行服务端，然后再运行客户端。你可以看到以下结果：

![simple_ruby_socket_example](/wp-content/uploads/2015/07/simple_ruby_socket_example.png)
*简单的 Unix socket 服务端/客户端交互的例子。左边是客户端，右边是服务端。*


## 与 nginx 接合

现在我们知道如何创建一个 unix socket 的服务端了，我们可以很容易地与 nginx 接合。

不相信我？让我们来做一个快速的概念验证吧。我修改上面的代码使其输出从 socket 接收到的所有内容。

```ruby
require "socket"
 
# Create the socket and "save it" to the file system
server = UNIXServer.new('/tmp/socktest.sock')
 
# Wait until for a connection (by nginx)
socket = server.accept
 
# Read everything from the socket
while line = socket.readline
  puts line.inspect
end
 
socket.close
```

现在如果我修改 nginx 配置，将请求转发到 `/tmp/socktest.sock` socket 上。
我就能看到 nginx 发送来的数据了。(别担心，我们稍后会讨论它的配置的)

当我发起一个 web 请求时，nginx 将如下数据发送到我的服务端上：

![request_http](/wp-content/uploads/2015/07/request_http.png)

太酷了！这就是一个包含了额外头信息的 HTTP 请求。现在我们准备来构建一个真正的应用服务。
但是，首先让我们讨论一个 nginx 的配置吧。


## 安装配置 Nginx

如果你还没有安装 nginx 的话，请先安装。对于 OSX 可以 homebrew 简单完成：

```
brew install nginx
```

现在我们配置 nginx 将 localhost:2048 的请求通过名为 `/tmp/socktest.sock` 的 socket 转发到上游服务端。
名字可以是任意的，它仅需要与我们 web 服务的 socket 名字匹配即可。

你可以将其保存至 `/tmp/nginx.conf` 并通过命令 `nginx -c /tmp/nginx.conf` 运行 nginx。

```
# Run nginx as a normal console program, not as a daemon
daemon off;
 
# Log errors to stdout
error_log /dev/stdout info;
 
events {} # Boilerplate
 
http {
 
  # Print the access log to stdout
  access_log /dev/stdout;
 
  # Tell nginx that there's an external server called @app living at our socket
  upstream app {
    server unix:/tmp/socktest.sock fail_timeout=0;
  }
 
  server {
 
    # Accept connections on localhost:2048
    listen 2048;
    server_name localhost;
 
    # Application root
    root /tmp;
 
    # If a path doesn't exist on disk, forward the request to @app
    try_files $uri/index.html $uri @app;
 
    # Set some configuration options on requests forwarded to @app
    location @app {
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $http_host;
      proxy_redirect off;
      proxy_pass http://app;
    }
 
  }
}
```

以非后台模式运行 nginx。当你运行 nginx 时它应该看起来像如下这样：

![nginx_non_daemon](/wp-content/uploads/2015/07/nginx_non_daemon.png)
*Nginx 以非后台模式运行*


## 自定义应用服务

既然我们已经知道了如何将 nginx 与我们程序进行连接，那么我们就来构建一个简单的应用服务。
当 nginx 将请求转发到我们的 socket 时，它是一个标准的 HTTP 请求。
经过一些处理后我可以决定 socket 是否会返回一个有效的 HTTP 响应，它会在浏览器中显示。

下面这个应用接受任何请求并显示时间戳。

```ruby
require "socket"
 
# Connection creates the socket and accepts new connections
class Connection
 
  attr_accessor :path
 
  def initialize(path:)
    @path = path
    File.unlink(path) if File.exists?(path)
  end
 
  def server
    @server ||= UNIXServer.new(@path)
  end
 
  def on_request
    socket = server.accept
    yield(socket)
    socket.close
  end
end
 
 
# AppServer logs incoming requests and renders a view in response
class AppServer
 
  attr_reader :connection
  attr_reader :view
 
  def initialize(connection:, view:)
    @connection = connection
    @view = view
  end
 
  def run
    while true
      connection.on_request do |socket|
        while (line = socket.readline) != "\r\n"
          puts line
        end
        socket.write(view.render)
      end
    end
  end
 
end
 
# TimeView simply provides the HTTP response
class TimeView
  def render
%[HTTP/1.1 200 OK
 
 
The current timestamp is: #{ Time.now.to_i }
 
]
  end
end
 
 
AppServer.new(connection: Connection.new(path: '/tmp/socktest.sock'), view: TimeView.new).run
```

现在运行 nginx 和脚本，然后访问 localhost:2048。请求会发送到我的应用上，然后响应被浏览器渲染。太酷了！

![appserver](/wp-content/uploads/2015/07/appserver.png)
*HTTP 请求信息由我们的应用服务输出到 STDOUT*

以下就是我们的劳动成果。

![timestamp](/wp-content/uploads/2015/07/timestamp.png)
*浏览器中显示服务端返回的时间戳*


原文地址： http://blog.honeybadger.io/how-unicorn-talks-to-nginx-an-introduction-to-unix-sockets-in-ruby/
