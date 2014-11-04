---
layout: post
title: 制作Linux+DOS+WinPE USB引导盘
data: 2010-10-13 13:01:09 +0000
comments: true
post_id: 83433
permalink: /archives/83433.html
categories: ["Linux栏目"]
tags: ["Linux", "USB"]
---

在我的前一篇文章《使用UNetbootin制作Linux USB引导盘》（ http://www.xefan.com/archives/83431.html ）介绍了使用UNetbootin轻松制作Linux的USB引导盘，不过如果我想换一个版本的Linux的话需要先将原来的文件删除再重新制作，这样感觉比较麻烦。于是就思考能不能同时引导多个Linux呢，通过试验发现可以通过修改syslinux.cfg这个文件来实现。

syslinux.cfg与grub的menu.lst类似，不过又有点不同。反正我是菜鸟也不懂，只要能用就行。有两个方法可以实现引导，一个是使用memdisk，另一个是使用grub。

一、memdisk  
1、添加其它Linux引导项  
以Ubuntu10.04为例，先将镜像文件中casper目录下的vmlinuz和initrd.lz文件提取出来跟镜像文件一起放在U盘的ubuntu10.04文件夹下。然后在syslinux.cfg中添加一个引导项：  
<ul> label Ubuntu 10.04  
menu Ubuntu 10.04  
kernel /ubuntu10.04/vmlinuz boot=casper iso-scan/filename=/ubuntu/ubuntu-10.04-desktop-i386.iso ro quiet splash locale=zh_CN.UTF-8  
append initrd=/ubuntu10.04/initrd.lz</ul>

2、添加DOS、PE引导项  
先将dos.img及memdisk放在dos文件夹下，然后在syslinux.cfg中添加一个引导项：  
<ul> label DOS1.0  
menu DOS1.0  
kernel /dos/memdisk  
initrd /dos/dos.img</ul>

<span style="text-decoration: underline">dos.img下载地址：http://u.115.com/file/f5a0def2a8

memdisk下载地址：http://u.115.com/file/f5f4cb0aa1</span>

PE跟这个类似，只是我在网上只找到WinPE.iso，找不到WinPE.img，故我用的是另一个方法来引导。  
如果镜像文件不是标准的1.44/2.88MB，或者大小超过2880kb，就需要指定磁盘镜像的C/H/S参数(即磁道数/磁头数/每磁道扇区数)。这时我们可以用“grub菜单编辑器”来获取软盘的C/H/S参数。  
<span style="text-decoration: underline">下载地址：http://u.115.com/file/f5510e6f36</span>  

运行grub菜单编辑器，单击界面左边的“获取软盘镜像的C/H/S参数”，选中映像文件，即可看到它的数据。那么它的格式为：  
kernel (hdx,y)/boot/grub/memdisk.gz c=磁道数 h=磁头数 s=每磁道扇区数 floppy  
initrd (hdx,y)/目录/文件名  

二、grub  
先将grub.exe和menu.lst文件放在grub文件夹下，然后在syslinux.cfg中添加一个引导项：  
<ul> label Grub  
menu Grub  
kernel /grub/grub.exe  
append --config-file="configfile /grub/menu.lst"</ul>

再将WinPE.ISO文件放在PE文件夹下，然后修改menu.lst文件，添加以下内容：  
<ul> title WinPE.ISOfallback 1  

find --set-root /PE/WinPE.ISO  

map /PE/WinPE.ISO (0xff) || map --mem /PE/WinPE.ISO (0xff)  

map --hook  

chainloader (0xff)

savedefault --wait=2</ul>

<span style="text-decoration: underline"> WinPE下载地址：http://u.115.com/file/f59f3e483b

grub4dos下载地址：http://u.115.com/file/f52b6269a6</span>

dos及ubuntu10.04也可以通过修改menu.lst来实验引导。

至此，Linux+DOS+PE的引导盘做好了，如果以后还想添加引导项的话可以直接修改这两个文件。
