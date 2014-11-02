---
layout: post
title: OpenOffice linux办公软件安装
data: 2009-05-28 07:10:12 +0000
comments: true
post_id: 16987
permalink: /archives/16987.html
categories: ["Linux栏目"]
tags: ["Linux", "电脑技巧"]
---

首先吧源文件拷到linux 格式的磁盘格式下,在windows下解压容易出错。如果没有可到官网下载。

中文简体版：<a href="http://ftp5.gwdg.de/pub/openoffice/extended/3.1.0rc1/OOo_3.1.0rc1_20090402_LinuxIntel_install_zh-CN.tar.gz">http://ftp5.gwdg.de/pub/openoffice/extended/3.1.0rc1/OOo_3.1.0rc1_20090402_LinuxIntel_install_zh-CN.tar.gz</a>

中文简体版（含JRE）：<a href="http://ftp5.gwdg.de/pub/openoffice/extended/3.1.0rc1/OOo_3.1.0rc1_20090402_LinuxIntel_install_wJRE_zh-CN.tar.gz">http://ftp5.gwdg.de/pub/openoffice/extended/3.1.0rc1/OOo_3.1.0rc1_20090402_LinuxIntel_install_wJRE_zh-CN.tar.gz</a>

然后执行下面的命令解压

[root@localhost tmp]# tar -xzvf OOo_3.1.0rc1_20090402_LinuxIntel_install_wJRE_zh-CN.tar.gz

进入 下面的目录:

[root@localhost tmp]# cd OOo_3.1.0rc1_20090402_LinuxIntel_install_wJRE_zh-CN

进入安装包目录

[root@localhost OOo_3.1.0rc1_20090402_LinuxIntel_install_wJRE_zh-CN]# cd RPMS

[root@localhost RPMS]# ls

里面是一大堆的r p m 文件.这些文件要同时执行,不能单独执行.

[root@localhost RPMS]# rpm -ivh o*.rpm

等待安装结果,这里需要Java Runtime Environment支持.如果事先没安装的这里会提示错误.

最后执行下面命令

[root@localhost RPMS]# cd desk*

[root@localhost desktop-integration]# rpm -ivh openoffice.org3.0-redhat-menus-3.0-9354.noarch.rpm

等待安装结束.

之后就可以在应用程序菜单中找到了。
