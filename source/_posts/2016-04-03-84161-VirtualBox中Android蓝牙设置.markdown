---
layout: post
title: "Mac OS中VirtualBox的Android蓝牙设置"
date: 2016-04-03 03:05:11 +0000
comments: true
post_id: 84161
permalink: /archives/84161.html
categories: ["编程开发"]
tags: ["Android"]
---

在做手机开发时，由于没有 Android 设备，只得在模拟器中进行测试。然而在模拟器却没法访问本机的蓝牙设备，这对于要做蓝牙开发来说很不方便。

经过各种搜索终于找到了一个解决方案。首先需要以下工具：

  * Mac OS系统
  * VirtualBox (https://www.virtualbox.org/)
  * Android x86 (https://sourceforge.net/projects/android-x86/)

1.禁用系统的蓝牙服务：

```
$ sudo launchctl unload /System/Library/LaunchDaemons/com.apple.blued.plist
# 对于 Mountain Lion 系统执行如下命令：
$ sudo kextunload -b com.apple.iokit.IOBluetoothSerialManager
$ sudo kextunload -b com.apple.iokit.BroadcomBluetoothHCIControllerUSBTransport
# 对于 Snow Leopard 系统执行如下命令：
$ sudo kextunload -b com.apple.driver.BroadcomUSBBluetoothHCIController
$ sudo kextunload -b com.apple.driver.AppleUSBBluetoothHCIController
```

2.运行 VirtualBox

设置启用 USB 控制器，添加蓝牙设备，如图：

![](/wp-content/uploads/2016/04/03/virtualbox-android-bluetooth.png)

然后运行 android 系统即可。

3.在退出 VirtualBox 之后，重新启用系统的蓝牙服务：

```
$ sudo launchctl load /System/Library/LaunchDaemons/com.apple.blued.plist
# 对于 Mountain Lion 系统执行如下命令：
$ sudo kextload -b com.apple.iokit.IOBluetoothSerialManager
$ sudo kextload -b com.apple.iokit.BroadcomBluetoothHCIControllerUSBTransport
# 对于 Snow Leopard 系统执行如下命令：
$ sudo kextload -b com.apple.driver.BroadcomUSBBluetoothHCIController
$ sudo kextload -b com.apple.driver.AppleUSBBluetoothHCIController 
```


参考：  
https://www.virtualbox.org/ticket/2372#comment:17
