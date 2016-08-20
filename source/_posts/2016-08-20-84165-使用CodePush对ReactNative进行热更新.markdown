---
layout: post
title: "使用CodePush对ReactNative进行热更新"
date: 2016-08-20 08:15:34 +0000
comments: true
post_id: 84165
permalink: /archives/84165.html
categories: ["编程开发"]
tags: ["react"]
---

[CodePush](http://microsoft.github.io/code-push/)是微软提供的可用于对 Cordova 和 ReactNative 进行代码热更新的库。
在其官方的文档中已经写得很详细了，按照其说明来配置即可。我这里只是对在使用过程中遇到的一些坑作为总结。

## 创建应用
首先注册一个账号并创建一个 CodePush 的应用：

```
npm install -g code-push-cli
code-push register
code-push app add <appName>
```


## 安装配置CodePush
按照说明 https://github.com/Microsoft/react-native-code-push#getting-started，使用 rnpm 进行安装即可：

```
npm install --save react-native-code-push
rnpm link react-native-code-push
```

安装完成之后还需要再进行一些配置，对于 iOS 需要将 `AppDelegate.m` 文件中的 `jsCodeLocation` 修改为： `jsCodeLocation = [CodePush bundleURL];`。
同时再在 `Info.plist` 文件中添加一项 `CodePushDeploymentKey`，其值为 CodePush 应用的 Deployment Key。

对于 android 需要在 `MainActivity` 类的 `getPackages` 方法中设置 Deployment Key。同时根据 ReactNative 的版本不同而使用不同的方法来设置 `getJSBundleFile`，
参考： `https://github.com/Microsoft/react-native-code-push#android-setup`。


## 程序更新
在安装、配置完成之后，即可以使用CodePush进行程序的更新操作了。
根据官方的说明只需要调用 `CodePush.sync()` 即可完成自动更新操作。
我针对自己的情况再进行封装了一下：

```
function syncCodePush() {
  NetInfo.fetch().done(
    (reach) => {
      // 检查网络环境
      if (_.includes(['wifi', 'WIFI', 'VPN'], reach)) {
        CodePush.sync().done(
          () => {
            // 检查更新成功
          },
          (err) => {
            // 更新失败
          }
        );
      }
    }
  );
}
```

以上函数是保证只有在wifi的网络环境下才进行更新操作，同时由于 `CodePush.sync()` 返回的是一个 `Promise` 对象，
在这里我就遇到了由于网络异常而下载出错，从而导致 app 崩溃。因此需要处理 `reject` 的情况。

有时在程序更新之后的首次运行时可能会需要作一些迁移的操作，这里可以使用 `getUpdateMetadata` 来检查程序是不是首次运行。

```
Codepush.getUpdateMetadata().then(
  (update) => {
    if (update && update.isFirstRun) {
      // 首次运行执行一些操作
    }
  }
).done( callback );
```

## 发布更新
在 app 发布安装包发布出去之后，已经有用户下载安装了。此时如果再有 js 代码更新或者图片文件的改动的话，可以使用 CodePush 进行发布。
进入 ReactNative 的项目根目录，使用 code-push 命令进行发布更新。例如：

```
code-push release-react DemoApp ios -m -d Staging --des "更新描述" -t "~2.0.0"
```

以上命令是发布一个紧急更新到 Staging ，只有 ios appp 的版本为 2.0~3.0 的才会下载该更新包。
由于是紧急更新，app在下载安装完成之后会自动重启应用该更新包。否则的话就需要用户下次手动启动app时该更新包才会生效。

在 CodePush 中针对 ios 和 android 可以共用一个应用，只是我个人感觉这样在管理 deployment history 时不太方便。
因此我通常会创建两个应用，例如： DemoApp-iOS、DemoApp-Android 这样的。

需要注意的是，由于 CodePush 的 server 是在国外，因此下载的速度会比较慢。

最后我自己使用 Electron + Vue.js 开发了一个 CodePush 的简易管理工具，https://github.com/wusuopu/code-push-gui 。
可以对 CodePush 的 app 跟 deployment 进行简单的管理。
