---
layout: post
title: 将PIL的Image类型转化为pygtk的Image类型
date: 2012-04-14 11:44:02 +0000
comments: true
post_id: 83718
permalink: /archives/83718.html
categories: ["Python栏目"]
tags: ["gtk", "python"]
---

Python代码如下：

``` python
# PIL的Image类型转化为gtk的Image类型
import gtk
import StringIO

f = StringIO.StringIO()
#im为PIL的Image类型
im.save(f, "ppm")
contents = f.getvalue()
f.close()
loader = gtk.gdk.PixbufLoader("pnm")
loader.write(contents, len(contents))
pixbuf = loader.get_pixbuf()
loader.close()
i = gtk.Image()
i.set_from_pixbuf(pixbuf)
```
