---
layout: post
title: 让firefox在线播放用mplayer，而不是totem
date: 2010-09-18 12:58:38 +0000
comments: true
post_id: 83408
permalink: /archives/83408.html
categories: ["Linux栏目"]
tags: ["firefox", "Linux"]
---

我的是Fedora 13系统，FireFox在线播放音频默认用的是totem。我在用firefox播放网页内的wma文件时老是失败，好像是没有解码器，但是我将wma文件下载到本地再用totem播放时却没问题。一直弄了几天也没解决，不知道是什么原因。

最后上网搜索终于找到解决方法，直接换一个播放器，改用mplayer。

步骤如下：  
1、首先删除totem的火狐插件  
<em> yum erase totem-mozplugin</em>

2、安装gecko-mediaplayer  
<em>yum install gecko-mediaplayer</em>
