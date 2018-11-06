---
layout: post
title: "GRUB Error 28: Selected item cannot fit into memory 解决方法"
date: 2011-02-23 12:37:57 +0000
comments: true
post_id: 83529
permalink: /archives/83529.html
categories: ["教程"]
tags: ["grub"]
---

今天偶用wubi安装ubuntu10.10时，重启选择安装项却提示：

    “Error:the initrd is too big!
    
    Press any key to continue”

然后再怎么也进不去了，这种情况以前没有遇到过。既然ubuntu装不了就改装Qomo Linux吧，于是下了镜像文件选择硬盘安装。可是重启选择安装项却提示：

    “GRUB Error 28: Selected item cannot fit into memory”

然后也进不去了，然后偶就彻底无语了。根据提示的字面意思好像是内存不够，偶这台式机是前几年买的，512的内存。而到网上查了，这两个Linux要求的最低配置是300多内存就行了，所以偶这不可以是配置不行。然后又到网上查了解决办法，只需要改下BIOS设置即可。具体方法如下：

开机进入BIOS设置－&gt;进入advanced chipset features的设置-&gt;将“memory Hole At 15M-16M”设置成[Disable]，问题解决！

（注：部分机型可能会将chipset选项隐藏，如果找不到的话，按Ctrl+F1即可显示。）
