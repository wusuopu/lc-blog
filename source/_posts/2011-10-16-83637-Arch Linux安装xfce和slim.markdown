---
layout: post
title: Arch Linux安装xfce和slim
data: 2011-10-16 12:24:20 +0000
comments: true
post_id: 83637
permalink: /archives/83637.html
categories: ["Linux栏目"]
tags: ["Arch", "Linux"]
---

这几天终于把Arch Linux + Xfce + slim配置好了，做个笔记备忘。
<h1>安装Xfce</h1>
https://wiki.archlinux.org/index.php/Xfce_(简体中文)

<strong>安装准备</strong>

请在安装与使用xfce前确认已经安装有xorg以及hal。

`# pacman -S xorg hal`

默认安装的archlinux是不包含xorg以及hal的。如果不安装两者，将造成xfce无法启动。HAL 已经被诸如udev,udisks,upower这些程序替代 。

<strong>安装XFCE系统(Xfce 4.8)</strong>

`# pacman -S xfce4 xfce4-goodies`  
`# pacman -S $(pacman -Sgq xfce4-goodies | grep -v xfce4-xfapplet-plugin)`

默认安装的xfce4，首次启动出现的小提示窗口里面是没有任何东西的。如果你想看到刚启动时候的技巧和小提示，那么就需要安装fortune-mod

`# pacman -S fortune-mod`

安装好xfce4之后可能会发现xfce4-mixer通过ALSA并不能控制音量，需要安装gstreamer0.10-base-plugins：

`# pacman -S gstreamer0.10-base-plugins`

对于笔记本用户，Xfce4-mixer如果不能同时控制外放与耳机，请尝试安装全部Plugins：

`# pacman -S gstreamer0.10-plugins`

<strong>安装和配置Daemons</strong>

<strong>安装dbus：</strong>

`# pacman -S dbus`

需要在开机的时候自动运行，应该将dbus添加到/etc/rc.conf文件中的DAEMONS：
DAEMONS=(syslog-ng dbus network crond)

如果不想重启开始dbus服务： `# /etc/rc.d/dbus start`

安装gamin (fam已经是过时的东西)，它会在后台自动运行检查文件改动反应给桌面，并且不需要添加到Daemons。

`# pacman -S gamin`

<h1>运行XFCE</h1>

<strong>手动启动</strong>

你只需要运行： `$ startxfce4`

从终端启动，例如使用xinit/startx 需要配置Xinitrc (简体中文)。
如果还没有~/.xinitrc 文件，系统里有一份实例文件供参考：`$ cp /etc/skel/.xinitrc ~/.xinitrc`

在最后添加（因为权限的问题推荐在启动xfce之前添加ck-launch-session dbus-launch启）：
<em>exec ck-launch-session dbus-launch --exit-with-session startxfce4</em>

<strong>在XFCE中关机和重启</strong>

在/etc/sudoers文件末尾添加如下一行：
<em>%users ALL=(root) NOPASSWD: /usr/lib/xfce4/session/xfsm-shutdown-helper</em>

`# gpasswd -a 你的用户名 users`

<strong>声音</strong>  
<strong>安装ALSA</strong>
https://wiki.archlinux.org/index.php/Advanced_Linux_Sound_Architecture_(简体中文)

要求有本地化的ALSA程序和管理

`# pacman -S alsa-lib alsa-utils`  
`# pacman -S alsa-oss`

所有ALSA程序都很可能需要依赖alsa-lib。

<strong>使用ALSA驱动如何让xfce4-mixer来控制音量</strong>

新版的xfce4-mixer使用了gstreamer作为后端，这样就不用直接与驱动交流，更加统一。与驱动打交道的工作交给了gstreamer。因此如果你xfce4-mixer无法正常工作，就需要配置好gstreamer。首先当然你得安装xfce4-mixer。

`pacman -S xfce4-mixer gstreamer0.10-base-plugins`

你需要至少安装gstreamer0.10-good-plugins,考虑安装gstreamer0.10-bad-plugins

`pacman -S gstreamer0.10-good-plugins gstreamer0.10-bad-plugins`

然后删除面板上的mixer插件，然后重新添加一次，或者先登出然后再登录一次，对gstreamer做更改后必须这样做才能让操作生效。

<h1>安装SLiM</h1>
https://wiki.archlinux.org/index.php/SLiM_(简体中文)

<strong>介绍</strong>

SLiM是Simple Login Manager（简单登录管理器）的缩写。SLiM是简单、轻量级和容易配置的，相对较易在低端和高端的系统中使用。对于那些希望寻找一个不依赖于GNOME或者KDE，可以在Xfce、Openbox、Fluxbox等环境下使用的登录管理器的人来说，SLiM也是非常合适的。

<strong>安装</strong>

可以在extra软件仓库中找到SLiM： `# pacman -S slim`

同时还可以安装主题包： `# pacman -S slim-themes archlinux-themes-slim`

<strong>配置</strong>

启用SLiM

单用户环境  
要将SLiM配置为加载某个特定的环境，只需编辑~/.xinitrc如下：  
将[session-command]替换为适当的会话命令。例如：  
要启动Xfce:  
<em>exec ck-launch-session dbus-launch --exit-with-session startxfce4</em>

打开 /etc/rc.conf。  
`# vi /etc/rc.conf`

添加一个服务slim  
<em>DAEMONS=(syslogd klogd !pcmcia network netfs crond slim)</em>

修改默认运行等级  
1. 切换用户到root.  
$ su  
2. 编辑/etc/inittab：  
`# vi /etc/inittab`  
3. 找到如下这一行：  
id:3:initdefault:  
4. 为了启动X11需要把'3'修改成'5'：  
id:5:initdefault:  
5. 保存此文件并退出编辑器，下次启动时你选择的显示管理器就会运行了。  

这样就差不多了，细节上的以后再慢慢琢磨。
