---
layout: post
title: netbeans for linux乱码解决方法
data: 2009-05-28 07:11:36 +0000
comments: true
post_id: 16989
permalink: /archives/16989.html
categories: ["Linux栏目"]
tags: ["Linux", "电脑技巧"]
---

netneans for linux下载 http://www.netbeans.org/downloads/index.html

在有的人电脑中可能中文版无法正常显示，而是显示一个个的小方块。

解决方法：将/usr/share/fonts/zh_CN/TrueType目录下的文件全都复制到jkdhome/jre/lib/fonts/fallback

如我的jkdhome为/usr/java/jdk1.6.0，于是以上目录就是/usr/java/jdk1.6.0/jre/lib/fonts/fallback

如果fallback目录不存在则自己创建。
netbeans安装，输入命令：

[root@localhost soft]# sh netbeans-6.5-ml-linux-cn.sh

正在配置安装程序...

正在搜索系统上的 JVM...

正在解压缩安装数据...

正在运行安装程序向导...

弹出安装界面后按照提示安装即可。