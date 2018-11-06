---
layout: post
title: 在vim下使用DoxygenToolkit进行自动注释
date: 2012-09-28 12:26:40 +0000
comments: true
post_id: 83795
permalink: /archives/83795.html
categories: ["开源软件"]
tags: ["vim"]
---

doxygen是一个文档生成器，其工作机制是利用注释中的有效信息来自动生成文档。而DoxygenToolkit是vim下一款能够自动生成doxygen可以识别的注释的插件。  
它会根据配置自动生成注释，主要是license注释、文件注释、函数及类注释。  
下载地址：http://www.vim.org/scripts/script.php?script_id=987

修改.vimrc的配置，加入自己对Doxygen的配置  
let g:DoxygenToolkit_authorName="longchangjin &lt;admin@longchangjin.cn&gt;"  
let g:DoxygenToolkit_briefTag_funcName="yes"  
let g:doxygen_enhanced_color=1  

运行vim 在命令行输入命令即可  
DoxAuthor:将文件名，作者，时间等  
DoxLic:  license注释  
Dox：    函数及类注释  

也可做一个按键映射，就不用每次都输入命令了。

如果想自定义注释信息，可以修改DoxygenToolkit.vim文件。
