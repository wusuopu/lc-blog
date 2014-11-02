---
layout: post
title: VirtualBox和VMware镜像文件互转方法详解
data: 2010-09-29 13:56:18 +0000
comments: true
post_id: 83415
permalink: /archives/83415.html
categories: ["Linux栏目"]
tags: ["VirtualBox", "vmware"]
---

VirtualBox和VMware都是功能强大的虚拟机软件，各有其优点，也各有缺点。有时实在是让人难以取舍，不知道该用那个好。下面说说这两个软件分别生成的不同格式的硬盘文件相互转换的方法。

<span style="color: #ff0000"><strong>VMWare转VirtualBox </strong></span>

方法一：  
使用VBoxManage命令

Usage:  
<em>VBoxManage clonehd          &lt;uuid&gt;|&lt;filename&gt;   &lt;outputfile&gt;  
[--format VDI|VMDK|VHD|RAW|&lt;other&gt;]  
[--variant Standard,Fixed,Split2G,Stream,ESX]  
[--type normal|writethrough|immutable|shareable]  
[--remember] [--existing]</em>

例如：  
<em>VBoxManage clonehd 'vmdk文件名' 'vdi文件名' --format VDI</em>

命令执行过程中如出现如下错误：  
ERROR: Cannot register the hard disk '/stor/virtualbox/sv1/sv1-disk1.vdi' with UUID {4e7a0d53-2775-438d-b383-79e69c5cf7f4} because a hard disk '/stor/virtualbox/sv1/sv1-disk1.vdi' with UUID {4e7a0d53-2775-438d-b383-79e69c5cf7f4} already exists in the media registry ('/home/chao/.VirtualBox/VirtualBox.xml')  
Details: code NS_ERROR_INVALID_ARG (0x80070057), component VirtualBox, interface IVirtualBox, callee nsISupports  
Context: "OpenHardDisk(Bstr(szFilenameAbs), AccessMode_ReadWrite, false, Bstr(""), false, Bstr(""), srcDisk.asOutParam())" at line 628 of file VBoxManageDisk.cpp

则需要先将硬盘镜像从虚拟介质管理器中将镜像释放 并删除，然后再执行命令。

最新版本的VirtualBox是可以直接使用VMDK的。

方法二：  
使用Qemu软件，下载地址：http://www.davereyn.co.uk/download.htm（只能在Windows下用）  
先用Qemu转VMDK为RAW格式，再转RAW为VDI格式。详情请自己看软件说明。

<span style="color: #ff0000"><strong>VirtualBox转VMWare</strong></span>

因為VirtualBox的转换方式有问题的关系，所以我們得通过两次转化的方法来进行…

第一次就是先把vdi轉成vmdk

<em>VBoxManage clonehd 'vdi文件名' 'vmdk文件名' --format VMDK</em>

經過漫長的等候  
這裡轉換好之後….  
再來就是第二次的轉換啦…  

<em>vmware-vdiskmanager -r '原vmdk文件' -t X '转换后的vmdk文件'</em>

其中的X可以用  
0 : 做成單一檔案(不預先配置)  
1 : 切成2GB為一個檔案  
2 : 預先配置檔案大小  
3 : 預先配置以2GB為單位的檔案群  
4 : 預先配置成ESX的格式  
來代替

這裡我用的是”1″
