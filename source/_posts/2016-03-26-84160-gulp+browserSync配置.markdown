---
layout: post
title: "gulp+browserSync配置"
date: 2016-03-26 06:32:56 +0000
comments: true
post_id: 84160
permalink: /archives/84160.html
categories: ["前端相关"]
tags: ["js", "gulp"]
---

Browsersync  是一个前端调试的利器，它能够让你在页面文件改动之后自动刷新浏览器，从而方便了前端的调试工作。

本文就是对于 Browsersync + Gulp 的配置作个简单的笔记。

1. 首先安装 Browsersync 与 Gulp:

```
$ npm install browser-sync gulp --save-dev
```

2. 在 `gulpfile.js` 中创建新任务：

```
var gulp = require('gulp');
var browserSync = require('browser-sync').create();

var config = {
  baseDir: 'src',
  watchFiles: [ 'src/**/*.html', 'src/assets/css/*.css', 'src/assets/js/*.js' ]
}

gulp.task('serve', function() {
  browserSync.init({
    files: config.watchFiles,
    server: {
      baseDir: config.baseDir
    }
  });
})
```

这里表示以 `src` 目录作为根目录启动 HTTP 服务，并监听 `src` 目录下的所有 `html`、`css` 以及 `js` 类型的文件，当这些文件有改动时 Browsersync 会自动刷新浏览器页面。

如果想配合使用 SASS 之类的，可以参考： https://www.browsersync.io/docs/gulp/


同时为了避免之后每次都要重新配置一遍，于是我自己写了个简单的 `yo` 生成器： https://github.com/wusuopu/my-yeoman-generator

由于这只是我自己 generator，并没有发布到 npm 上，因此只能手动进行安装。各位有兴趣的可以试试。使用方法：

1. 安装 yo 和 bower： `$ npm install -g yo bower`

2. 安装 generator:

```
$ git clone https://github.com/wusuopu/my-yeoman-generator generator-wusuopu
$ cd generator-wusuopu
$ npm link
```

3. 生成项目：

```
$ mkdir webpage
$ cd webpage
$ yo wusuopu:bootstrap3
```

这里 bootstrap3 generator 包含了 bootstrap3、font-awesome、jquery 这些常用的前端库，省得每次都需要重新下载一遍。

