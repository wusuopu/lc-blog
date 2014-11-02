---
layout: post
title: NERD_commenter——VIM批量注释与反注释插件
data: 2011-08-05 13:26:02 +0000
comments: true
post_id: 83568
permalink: /archives/83568.html
categories: ["开源软件"]
tags: ["vim"]
---

这是对程序员非常实用的一款插件，支持多种语言的补全，还支持单行注释，批量注释，等各种命令映射。

使用方法，先下载该插件：http://www.vim.org/scripts/script.php?script_id=1218

将NERD_commenter.vim文件放到~/.vim/plugin目录下，将NERD_commenter.txt文件放到~/.vim/doc目录下。

然后使用&lt;leader&gt;cc快捷键进行注释选中的行，&lt;leader&gt;cu进行反注释。

其中&lt;leader&gt;是键盘映射，默认情况下是反斜杆“”，则上述快捷键分别为：cc和cu。你可以使用命令自定义，例如命令:let mapleader=","将&lt;leader&gt;定义为","键。

还有不懂的使用:help NERDCommenter命令查看帮助。
