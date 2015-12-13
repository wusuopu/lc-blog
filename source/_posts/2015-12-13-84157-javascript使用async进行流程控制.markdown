---
layout: post
title: "javascript使用async进行流程控制"
date: 2015-12-13 13:39:26 +0000
comments: true
post_id: 84157
permalink: /archives/84157.html
categories: ["前端相关"]
tags: ["js"]
---

## 前言
突然发现博客好久没有更新了，主要是因为最近这几个月比较忙。之前由 Python 转向了 Ruby，现在又由后端转向了前端。
这几个月接触的内容略有点多，信息量有点大，主要都是 js 相关的。准备之后抽时间将这些知识整理整理，沉淀沉淀。

## Async
由于 js 是异步的，之前在使用 loopback 进行 server 端开发时，很容易就出现了比较深层次的回调嵌套。
[async.js](https://github.com/caolan/async)是 js 的一个工具，可以用来方便的控制 js 中的异步流程的，类似的库还有 Promise、RxJS 等。
最初它是设计用于 nodejs 的，不过在浏览器端也可以使用。

### 安装
安装方法很简单，直接使用 npm 即可： `npm install async` 。

### 使用方法
首先是加载 async 库，在 server 端使用 `var async = require('async');`，
在浏览器端直接引用即可： `<script type="text/javascript" src="async.js"></script>`。

async 提供一些集合操作方法和流程控制方法，我比较常用的是：`each`、`map`、`series`、`waterfall` 这些方法。
其中 `each`、`map` 方法与 `lodash` 的类似，可以用来遍历某个集合并执行一些操作。

`each` 方法定义如下：

```javascript
async.each(collection, iterator, [callback])
```

该方法会对 `collection` 每个元素都调用 `iterator` 操作， `iterator` 函数原型为： `iterator(item, callback)`。
当 `collection` 中的所有元素遍历完成或者执行 `iterator` 时发生错误就会调用 `callback` 回调，原型为： `callback(err)`。

`each` 方法只是对每个元素进行操作，如果还需要获取操作的结果，那么可以使用 `map` 方法。定义如下：

```javascript
async.map(collection, iterator, [callback])
```

`map` 与 `each` 类似，只是 `callback` 定义为： `callback(err, results)`。
`results` 为 `iterator` 操作的结果集合。

如下是一个例子，一次读取多个文件的内容：

```javascript
async.map(['file1','file2','file3'], fs.readFile, function(err, results){
    // doSomething();
});
```

`series` 与 `map` 类似，不过 `series` 是遍历一个方法合集并挨个执行，然后返回结果：

```javascript
async.series(tasks, [callback])
```

如：

```javascript
async.series([
  function fun1(callback){
    callback(null, 'one');
  },
  function fun2(callback){
    callback(null, 'two');
  }
],
function(err, results){
  // doSomething();
});
```

注意，以上这些方法各个任务的完成时间顺序是不确定的。如果有一些操作是需要按照先后顺序执行，可以使用 `waterfall`。

```javascript
async.waterfall(tasks, [callback])
```

例如在 `loopback` 的一个 `controller` 中，提供修改用户密码的功能。原始写法如下：

```javascript
router.post('/user/password', function(req, res) {
  User.findById(req.body.id, function(err, user){
    if (err) doSomething();
    user.password = req.body.password;
    user.save(function(err){
      if (err) doSomething();
      res.status(200).end();
    });
  });
});
```

上面的例子功能还比较简单，回调层级不是很深。不过如果使用 `waterfall` 来控制就更为简单：

```javascript
router.post('/user/password', function(req, res) {
  async.waterfall([
    function(callback){
      User.findById(req.body.id, callback);
    },
    function(user, callback){
      user.password = req.body.password;
      user.save(callback);
    }
  ], function(err){
    if (err) doSomething();
    res.status(200).end();
  });
});
```

