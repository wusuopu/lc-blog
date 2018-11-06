---
layout: post
title: Scrapy框架学习笔记2—— Scrapy与Django结合
date: 2013-10-07 09:04:40 +0000
comments: true
post_id: 83887
permalink: /archives/83887.html
categories: ["Python栏目"]
tags: ["Django", "python", "Scrapy"]
---

前面也介绍过了Scrapy与Django的设计思想非常相似，因此这个两个结合也是比较容易的。  
以下方法在Scrapy 0.18与Django 1.5下面测试是可以用的。

<h3>1.首先设置Django的运行环境</h3>
在settings.py中添加如下代码：

``` python
def setup_django_environment(path):
    import imp, os, sys
    from django.core.management import setup_environ
    m = imp.load_module('settings', *imp.find_module('settings', [path]))
    setup_environ(m)
    sys.path.append(os.path.abspath(os.path.join(path, os.path.pardir)))

setup_django_environment("/django/project/path")
```

注意：如果你的Django项目是用的sqlite数据库的话，那就需要设置为绝对路径，不能使用相对路径。


<h3>2.创建django item</h3>
首先在Django项目代码中创建一个Django的model，例如:

``` python
from django.db import models
class ScrapyModel(models.Model):
    title = models.CharField(max_length=200)
    link = models.CharField(max_length=200)
    desc = models.TextField()
```

然后在Scrapy项目中创建一个新的Item，只不过这次我们不再是继承自scrapy.item.Item，而是scrapy.contrib.djangoitem.DjangoItem:

``` python
class Test1DjItem(DjangoItem):
    django_model = ScrapyModel
```

用法与原来的Item相同，只是最后要执行一个save函数来调用django的save方法将数据存入数据库。
