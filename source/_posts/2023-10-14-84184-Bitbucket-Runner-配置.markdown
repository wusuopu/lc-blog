---
layout: post
title: Bitbucket Runner 配置
comments: true
post_id: 84184
permalink: /archives/84184.html
date: 2023-10-14 20:45:42
categories:
tags: ["git"]
---


以前有介绍过 Github Runner 和 Gitlab Runner 的配置，现在再来介绍一下 Bitbucket Runner 的配置。

参考官方文档： https://support.atlassian.com/bitbucket-cloud/docs/runners/

## 添加 Runner
首先禁用 Linux 系统的 swap 功能。若不禁用 swap，在 runner 进行 builder 时会使用 swap 内存，可能会出现内存不足的错误。

```
sudo swapoff -sv
```

编辑 `/etc/sysctl.conf` 添加 `vm.swappiness = 1` 再重启系统。

接着在 Bitbucket 的设置界面添加 Runner，然后执行界面给出的命令。
然后在目标机器上执行命令：

```
docker run-it -d \
  --name bitbucket-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e ACCOUNT_UUID=<accountUuid> \
  -e REPOSITORY_UUID=<repositoryUuid> \
  -e RUNNER_UUID=<runnerUuid> \
  -e OAUTH_CLIENT_ID=<OAuthClientId> \
  -e OAUTH_CLIENT_SECRET=<OAuthClientSecret> \
  wusuopu/bitbucket-pipelines-runner:1.512
```


## 使用 Runner
在 `bitbucket.pipelines.yml` 中的相关步骤配置 `runs-on`，如：
```
pipelines:
  default:
      - step:
          runs-on:
            - self.hosted
            - linux.shell
          script:
```

因为 runner 是以 linux-shell 的方式运行的，所以会有一些限制： https://support.atlassian.com/bitbucket-cloud/docs/set-up-runners-for-linux-shell/

