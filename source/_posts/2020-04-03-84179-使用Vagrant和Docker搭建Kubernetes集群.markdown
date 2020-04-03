---
layout: 'post'
title: '使用Vagrant和Docker搭建Kubernetes集群'
date: '2020-04-03T04:28:20.946Z'
comments: true
post_id: '84179'
permalink: '/archives/84179.html'
categories: ["Linux栏目"]
tags: ["Docker", "k8s"]
---

在之前的文章[《使用Vagrant在Ubuntu系统上搭建Kubernetes集群》](/archives/84177.html)介绍了使用 Vagrant 在 VirtualBox 中安装 Ubuntu 系统搭建 Kubernetes 集群。
因为 Vagrant 是支持 Docker 的，所以这篇文章就来尝试不再使用 VirtualBox 了，而是直接使用 Docker 来搭建 Kubernetes 集群。

## 安装依赖
需要先安装以下程序：

  * Vagrant
  * Docker
  * Kubectl

## 运行集群
因为是在本地学习 k8s，因此为了方便我就使用 Rancher 的 k3s 来进行安装。
下载 Vagrant 配置文件： https://github.com/wusuopu/kubernetes-vagrant-alpine

然后执行命令：
```
vagrant up --no-parallel --provision
```

这里启动 k3s 服务，并将 master node 的 /etc/rancher/k3s/k3s.yaml 文件内容复制到 host 系统上来，这样就可以直接在 host 系统中用 kubectl 来操作集群。

```
-> % k get node -o wide
NAME        STATUS   ROLES    AGE   VERSION        INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
alpine-02   Ready    <none>   59m   v1.17.4-k3s1   172.17.0.3    <none>        Alpine Linux v3.11   4.9.184-linuxkit   docker://19.3.8
alpine-01   Ready    master   59m   v1.17.4-k3s1   172.17.0.2    <none>        Alpine Linux v3.11   4.9.184-linuxkit   docker://19.3.8
alpine-03   Ready    <none>   58m   v1.17.4-k3s1   172.17.0.4    <none>        Alpine Linux v3.11   4.9.184-linuxkit   docker://19.3.8

```

这里集群的各个 node 都是一个 docker container。
```
-> % docker ps
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS                                                           NAMES
a91d13e2cca0        wusuopu/vagrant:k3s-alpine   "dockerd-entrypoint.…"   About an hour ago   Up 35 minutes       2375-2376/tcp, 6443/tcp, 127.0.0.1:2201->22/tcp                 kubernetes-vagrant-alpine_alpine-03_1585887389
cce93873b666        wusuopu/vagrant:k3s-alpine   "dockerd-entrypoint.…"   About an hour ago   Up 35 minutes       2375-2376/tcp, 6443/tcp, 127.0.0.1:2200->22/tcp                 kubernetes-vagrant-alpine_alpine-02_1585887382
d4844843ca3e        wusuopu/vagrant:k3s-alpine   "dockerd-entrypoint.…"   About an hour ago   Up 36 minutes       2375-2376/tcp, 0.0.0.0:6443->6443/tcp, 127.0.0.1:2222->22/tcp   kubernetes-vagrant-alpine_alpine-01_1585887365
```
