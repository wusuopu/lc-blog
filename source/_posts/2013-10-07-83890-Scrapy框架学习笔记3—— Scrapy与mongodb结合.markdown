---
layout: post
title: Scrapy框架学习笔记3—— Scrapy与mongodb结合
data: 2013-10-07 09:14:00 +0000
comments: true
post_id: 83890
permalink: /archives/83890.html
categories: ["Python栏目"]
tags: ["mongodb", "python", "Scrapy"]
---

创建一个新的Item Pipeline，并将其添加到settings.py的ITEM_PIPELINES列表中。  
在process_item方法中将item的数据保存到mongodb中。  
scrapy的Item与dict相似，而mongodb中的数据是心bson格式保存的。因此Item的数据应该可以直接存储到mongodb中而几乎不用做额外的处理。

``` python
class MyMongoDBPipeline(object):
    def __init__(self, mongodb_server, mongodb_port, mongodb_db, mongodb_collection):
        connection = pymongo.Connection(mongodb_server, mongodb_port)
        self.mongodb_db = mongodb_db
        self.db = connection[mongodb_db]
        self.mongodb_collection = mongodb_collection
        self.collection = self.db[mongodb_collection]

    @classmethod
    def from_crawler(cls, crawler):
        # 连接mongodb
        return cls('localhost', 27017, 'scrapy', 'items')

    def process_item(self, item, spider):
        result = self.collection.insert(dict(item))
        log.msg("Item %s wrote to MongoDB database %s/%s" % (result, self.mongodb_db, self.mongodb_collection),
                level=log.DEBUG, spider=spider)
        return item
```
