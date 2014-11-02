---
layout: post
title: 使用UNetbootin制作Linux USB引导盘
data: 2010-10-12 13:26:04 +0000
comments: true
post_id: 83431
permalink: /archives/83431.html
categories: ["Linux栏目"]
tags: ["Linux", "USB"]
---

首先要你的电脑主板支持usb引导才行。像我的是神舟天运F3000的小本好像有的问题，之前用U盘制作了一个Win PE的的引导盘，结果却不能引导，但是在同学的台式电脑却没问题。还好这次用UNetbootin制作的Linux引导盘可以用。

然后再来介绍一下UNetbootin(Universal Netboot Installer)，它是一种跨平台工具软件（支援Windows和Linux），可以用来建立Live USB 系统，也可以加载各种系统工具，或安装各种Linux操作系统（Linux套件）和其他操作系统，不需使用安装光碟（自动透过网络下载）。支援主流Linux（Linux套件），包含但不只限于，Ubuntu、Fedora、 openSUSE、CentOS、Debian、Linux Mint、Arch Linux、Mandriva、Puppy Linux、Slackware和FreeDOS，FreeBSD以及NetBSD。

最后再来说说制作过程，先运行UNetbootin（Linux下需root权限运行），如果没有Linux的镜像文件就选第一个“Distribution”再选择你想要安装的版本，然后它就会自动下载安装；如果有镜像文件就选第二个“Disk Image”再选择你的镜像文件，最后在下面的“Type”及“Drive”选择你要安装到哪个分区，点“OK”开始安装。

如图：

<img class="alignnone" title="UNetbootin" src="http://sourceforge.net/dbimage.php?id=167328" alt="" width="542" height="397" />
<img class="alignnone" title="UNetbootin" src="http://sourceforge.net/dbimage.php?id=173795" alt="" width="542" height="397" />
<img class="alignnone" title="UNetbootin" src="http://sourceforge.net/dbimage.php?id=173785" alt="" width="542" height="397" />
<img class="alignnone" title="UNetbootin" src="http://sourceforge.net/dbimage.php?id=173797" alt="" width="542" height="397" />
<img class="alignnone" title="UNetbootin" src="http://sourceforge.net/dbimage.php?id=173791" alt="" width="542" height="397" />

下载地址：http://unetbootin.sourceforge.net/
