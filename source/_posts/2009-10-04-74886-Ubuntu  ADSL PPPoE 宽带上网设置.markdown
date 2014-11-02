---
layout: post
title: Ubuntu  ADSL PPPoE 宽带上网设置
data: 2009-10-04 06:49:37 +0000
comments: true
post_id: 74886
permalink: /archives/74886.html
categories: ["Linux栏目"]
tags: ["Linux", "ubuntu"]
---

首先打开你的终端机，并键入以下命令：<strong>sudo pppoeconf </strong>
键入sudo 管理权限的密码

接下来系统会列出你可以使用的网络设备介面，如果没有问题你就回答『是』，或者你想手动设置网卡则按『否』  
接着系统开始检测你的ADSL设备 (猫、IP分享器等等 )  
这里毫无疑问的回答『是』  
到了这里你就可以将你ISP的ID打上  
输入你的密码  
PPPoe拨接后会将DNS的IP告诉你，这里是问你是否要将DNS Server自动加入到设定的文件resolv.conf。所以这里要回答『是』  
注意：如果你在选择 『是』后，没有能够自动获得DNS的IP，可以运行以下命令来自行添加：  
<strong>sudo gedit /etc/resolv.conf </strong>  
在弹出的文本编辑里输入以下代码：  
nameserver XXX.XXX.XXX.XXX  
其中 XXX.XXX.XXX.XXX是DNS的IP，如果你不清楚可以打电话到你的网络提供商询问DNS的IP  
这里说来话长，一般MTU设置都为1500，但是由于通信协定各层级的header的关系，实际传输的封包大小也只有1452。所以这里一定要回答『是』。  

这里问你，开启电脑进入系统时就自动连接网络吗？随你啦  
基本上所有的设置都是缺省值『是』，除非你有特殊的考虑面，否则不要尝试其他的选择。  

接下来有几个命令也顺便了解一下  

想知道现在PPPoe的状况可用 <strong>plog</strong>  
想手动ADSL拨号上网则可用<strong> sudo pon dsl-provider</strong>  
想手动断开ADSL 你可以用 <strong>sudo poff </strong>  

<span style="color: #ff0000">另外偶自己写了一个pppoe设置的脚本，希望对大家有用。下载地址：http://cn.ziddu.com/download/397216/pppoe.gz.html</span>
