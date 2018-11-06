---
layout: post
title: 使用virtualenv安装多个版本python
date: 2014-01-22 11:01:41 +0000
comments: true
post_id: 84036
permalink: /archives/84036.html
categories: ["Python栏目"]
tags: ["python"]
---

<p>使用virtualenv可以在你的系统中安装多个python环境，它与Ruby的rvm和nodejs的nvm类似。如果你要尝试不同版本的库的话，这个是非常有用的。</p>
<h3>安装</h3>
<p>安装方法很简单，直接执行命令：</p>
<pre><code>$ [sudo] pip install virtualenv
</code></pre>
<p>如果是想到体验最新的非正式版，可以执行命令：</p>
<pre><code>$ [sudo] pip install https://github.com/pypa/virtualenv/tarball/develop
</code></pre>
<h3>使用</h3>
<p>基本使用方法是：</p>
<pre><code>$ virtualenv &lt;DEST_DIR&gt;
</code></pre>
<p>则在 &lt;DEST_DIR&gt; 目录下为 /usr/bin/python 创建一个新的虚拟环境。该环境下对应的python解释器为 &lt;DEST_DIR&gt;/bin/python 。</p>
<p>想要使用刚刚创建的python环境，可以修改 $PATH 环境变量，在开头加上 &lt;DEST_DIR&gt;/bin 。这样就可以直接执行 python 命令运行了，但是这样的话又会造成系统环境中的python无法正常使用了。 或者每次执行命令时输入完整的路径， &lt;DEST_DIR&gt;/bin/python ，但是这样比较麻烦。不过好在刚创建的虚拟环境中有一个 &lt;DEST_DIR&gt;/bin/activate 脚本文件，运行该脚本即可切换到虚拟环境中。</p>
<pre><code>$ source &lt;DEST_DIR&gt;/bin/activate
$ which python
&lt;DEST_DIR&gt;/bin/python
</code></pre>
<p>这样默认的就是使用刚刚创建的虚拟环境中的python了。</p>
<p>官方文档： http://www.virtualenv.org/en/latest/</p>
