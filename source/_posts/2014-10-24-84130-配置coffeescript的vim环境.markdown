---
layout: post
title: 配置coffeescript的vim环境
data: 2014-10-24 13:42:10 +0000
comments: true
post_id: 84130
permalink: /archives/84130.html
categories: ["资源分享"]
tags: ["vim"]
---

<p>coffeescript是构建在javascript基础上一门语言，它在运行时会编译在javascript。下面介绍vim用来开发coffeescript的两个插件。</p>
<p>首先是语法高亮支持： https://github.com/kchmck/vim-coffee-script</p>
<p>其次是snippets支持： https://github.com/carlosvillu/coffeScript-VIM-Snippets
这个需要先安装 snipMate 插件。</p>
<p>如果也是用的 vundle 进行插件管理的话，可以直接在 .vimrc 配置中添加如下内容即可：</p>
<pre><code>Bundle 'kchmck/vim-coffee-script'
Bundle 'carlosvillu/coffeScript-VIM-Snippets'

au BufNewFile,BufRead *.coffee set ft=coffee
</code></pre>
