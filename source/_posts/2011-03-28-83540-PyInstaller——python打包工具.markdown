---
layout: post
title: PyInstaller——python打包工具
date: 2011-03-28 14:44:52 +0000
comments: true
post_id: 83540
permalink: /archives/83540.html
categories: ["Python栏目"]
tags: ["python"]
---

前一篇文章介绍了使用py2exe将python转换成exe格式。由于py2exe只能在windows下使用，今天又介绍另一个python的打包工具——PyInstaller。PyInstaller可以在<span>Windows, Linux,  Mac OS X下运行。</span>

<strong>使用方法</strong>

1、下载安装  
下载地址：http://www.pyinstaller.org/  
对于windows系统可以直接用安装包安装。对于Linux系统 ，下载后解压并进入解压目录执行如下命令：  
<em> cd source/linux  
python ./Make.py  
make</em>

安装之后请运行PyInstaller目录下的Configure.py脚本进行配置。

2、使用  
执行如下命令进行打包：  
<em>python PyInstaller目录/Makespec.py [--onefile] </em><em>你的程序目录</em><em>/yourscript.py</em>  
<em>python PyInstaller目录/Build.py 你的程序目录/yourscript.spec</em>

如偶的PyInstaller目录为$HOME/PyInstaller，偶的程序目录为$HOME/python，则执行命令：  
<em> python $HOME/PyInstaller/Makespec.py [--onefile] $HOME/python/yourscript.py  
python $HOME/PyInstaller/Build.py $HOME/python/yourscript.spec</em>

如果要打包为一个文件则加上--onefile参数，否则别加。如果没有错误则在$HOME/python/dist目录下生成yourscript二进制文件。
