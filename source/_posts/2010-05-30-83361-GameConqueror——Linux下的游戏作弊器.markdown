---
layout: post
title: GameConqueror——Linux下的游戏作弊器
data: 2010-05-30 13:01:24 +0000
comments: true
post_id: 83361
permalink: /archives/83361.html
categories: ["资源分享"]
tags: ["Linux", "游戏"]
---

<p style="margin-bottom: 0cm">GameConqueror <span style="font-family: DejaVu Sans">是一款 </span>Linux <span style="font-family: DejaVu Sans">游戏修改工具，用 </span>PyGTK <span style="font-family: DejaVu Sans">写成，以 </span>scanmem <span style="font-family: DejaVu Sans">作为后端。</span></p>
<p style="margin-bottom: 0cm"><span style="font-family: DejaVu Sans">现在已经实现了基本的搜索功能，支持不同的数据类型和搜索类型。</span></p>
<p style="margin-bottom: 0cm"><span style="font-family: DejaVu Sans">数据类型：</span></p>
<p style="margin-bottom: 0cm"><span style="font-family: DejaVu Sans">不同长度的类型：</span>int{8/16/32/64}<span style="font-family: DejaVu Sans">、</span>float{32/64}</p>
<p style="margin-bottom: 0cm"><span style="font-family: DejaVu Sans">未知长度的类型：</span>int<span style="font-family: DejaVu Sans">、</span>float</p>
<p style="margin-bottom: 0cm"><span style="font-family: DejaVu Sans">未知类型：</span>number</p>
<p style="margin-bottom: 0cm"><span style="font-family: DejaVu Sans">字节串和字符串：</span>bytearray<span style="font-family: DejaVu Sans">、</span>string</p>
<p style="margin-bottom: 0cm"><span style="font-family: DejaVu Sans">搜索类型：相等、大于、小于、变化、未变、增大、减少</span></p>
<p style="margin-bottom: 0cm"></p>
<p style="margin-bottom: 0cm"></p>
<p style="margin-bottom: 0cm"><span style="font-family: DejaVu Sans">运行需要 </span>Python <span style="font-family: DejaVu Sans">和 </span>Python-GTK2<span style="font-family: DejaVu Sans">，编译需要 </span>libreadline<span style="font-family: DejaVu Sans">。</span></p>
<p style="margin-bottom: 0cm"><span style="font-family: DejaVu Sans">安装带图形界面的编译</span>:</p>

<p style="margin-bottom: 0cm">./configure --enable-gui &amp;&amp; make
sudo make install
<p style="margin-bottom: 0cm"></p>
<p style="margin-bottom: 0cm"><span style="font-family: DejaVu Sans">安装不带图形界面的</span><span style="font-family: DejaVu Sans">编译</span>:</p>

<p style="margin-bottom: 0cm">./configure &amp;&amp; make
sudo make install
<p style="margin-bottom: 0cm"></p>
<p style="margin-bottom: 0cm"><span style="font-family: DejaVu Sans">安装完后在终端运行 </span>gameconqueror<span style="font-family: DejaVu Sans">，启动界面方式；运行 </span>scanmem<span style="font-family: DejaVu Sans">，启动命令行方式。还有不懂的自己看帮助。</span></p>
<p style="margin-bottom: 0cm"></p>
<p style="margin-bottom: 0cm"><span style="font-family: DejaVu Sans">主页：</span>http://code.google.com/p/scanmem/</p>
