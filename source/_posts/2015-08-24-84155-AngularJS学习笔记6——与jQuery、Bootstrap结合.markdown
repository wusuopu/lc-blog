---
layout: post
title: "AngularJS学习笔记6——与jQuery、Bootstrap结合"
date: 2015-08-24 02:25:28 +0000
comments: true
post_id: 84155
permalink: /archives/84155.html
categories: ["前端相关"]
tags: ["js", "angular"]
---

## jQuery
如果想要在 angular 内部调用 jQuery 的函数（如 jQuery 的 ajax 功能）比较简单，直接调用 `$.ajax` 即可。  
但是如果想要在 angular 外部调用其函数就稍微麻烦一点，毕竟这也与 angular 的设计理念不符。

```
<div ng-controller="PageController">
  ...
</div>

<script>
  var appModule = angular.module('myApp', []);
  appModule.controller('PageController', ['$scope', '$http', function($scope, $http){
      ...
  }]);
```

例如上个这段代码，如果想要从外部访问 `PageController` 中的某些内容。则可以先获取 `PageController` 的上下文对象($scope)：`angular.element($('[ng-controller="PageController"]')).scope();`  
在外部修改了 `scope` 的某些值时会发现对应的视图并没有更新，这时还需要调用 `scope` 的 `$digest` 方法进行同步，或者直接调用 `$apply` 方法进行操作。

## Bootstrap
之前使用 angularjs 时遇到了 Bootstrap 的控件不能正常使用了，如 dropdown 组件点击了没有效果。  
经过分析发现是 angularjs 将 Bootstrap 的组件的事件给截获了。

好在有 angular-bootstrap 这么一个组件可以将它们整合在一起。

http://angular-ui.github.io/bootstrap/
