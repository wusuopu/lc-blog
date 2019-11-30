---
layout: 'post'
title: '使用Vagrant在Ubuntu系统上搭建Kubernetes集群'
date: '2019-11-30T07:37:50.127Z'
comments: true
post_id: '84177'
permalink: '/archives/84177.html'
categories: ["Linux栏目"]
tags: ["Docker", "k8s"]
---

## 安装依赖

### Vagrant

目前 Vagrant (https://www.vagrantup.com/downloads.html) 最新为 v2.2.6，Kubernetes 为 v1.16

### Kubectl

下载最新版的 kubectl:

```
`curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl`
```

### VirtualBox

需要下载 Vagrant 所兼容的版本(https://www.vagrantup.com/docs/virtualbox/)。我是直接用 apt-get 安装 5.2 的版本。

```
apt-get install virtual virtualbox-guest-additions-iso
```

## 运行 ubuntu 单实例

创建 Vagrantfile 配置文件，这里在 virtualbox 内运行的是 Ubuntu 18.04。

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

$num_instances = 1
$instance_name_prefix = "ubuntu"
$vm_gui = false
$vm_memory = 1024
$vm_cpus = 1
$vb_cpuexecutioncap = 100
ip_prefix = '172.17.8.'

Vagrant.configure(2) do |config|
  (1..$num_instances).each do |i|
    config.vm.define vm_name = "%s-%02d" % [$instance_name_prefix, i] do |node|
      node.vm.box = 'ubuntu/bionic64'
      node.vm.box_version = "20191125.0.0"
      node.vm.box_check_update = false
      node.vm.hostname = vm_name
      node.vm.synced_folder '.', '/vagrant', type: 'virtualbox'

      ip = "#{ip_prefix}#{i+100}"
      node.vm.network 'private_network', ip: ip
      node.vm.provider :virtualbox do |vb|
        vb.gui = $vm_gui
        vb.memory = $vm_memory
        vb.cpus = $vm_cpus
        vb.customize ["modifyvm", :id, "--cpuexecutioncap", "#{$vb_cpuexecutioncap}"]
      end
    end
  end
end
```

接着启动 ubuntu

```
vagrant up
```

登录 ubuntu 实例

```
vagrant ssh
```

至此 ubuntu 就是运行起来了。然后却只有一个 实例，但是在实际应用中可能是多个实例组成的集群。

## 运行 ubuntu 多实例

先停止刚刚的实例

```
vagrant halt
```

然后修改 Vagrantfile 文件，将 $num_instances 变量改为3。这里我就启动3个实例来组成集群。
接着启动这3个实例

```
vagrant up
```

查看实例状态

```
-> % vagrant status
Current machine states:

ubuntu-01                 running (virtualbox)
ubuntu-02                 running (virtualbox)
ubuntu-03                 running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

然后登录到其中的某个实例

```
vagrant ssh ubuntu-02
```

## 安装 Kubernetes

目前的3个 ubuntu 实例如下：

```
172.17.8.101 (ubuntu-01)    master
172.17.8.102 (ubuntu-02)    worker1
172.17.8.103 (ubuntu-03)    worker2
```

因为是在本地学习 k8s，因此为了方便我就使用 Rancher 的 k3s 来进行安装。
先分别在各个实例中安装 docker，参考： https://docs.docker.com/install/linux/docker-ce/ubuntu/

先安装  master node

```
vagrant ssh ubuntu-01
curl -sfL https://get.k3s.io | sh -
```

接着分别进入另外两个实例内安装 worker node，其中 K3S_TOKEN 的值来自 /var/lib/rancher/k3s/server/node-token 文件。

```
vagrant ssh ubuntu-02
curl -sfL https://get.k3s.io | K3S_URL=https://172.17.8.101:6443 K3S_TOKEN=XXX sh -
```

最后可以将 master node 的 /etc/rancher/k3s/k3s.yaml 文件内容复制到 host 系统上来，这样就可以直接在 host 系统中用 kubectl 来操作集群。

```
-> % k get nodes -o wide
NAME        STATUS   ROLES    AGE     VERSION         INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
ubuntu-03   Ready    <none>   4m57s   v1.16.3-k3s.2   172.17.8.103   <none>        Ubuntu 18.04.3 LTS   4.15.0-70-generic   docker://19.3.5
ubuntu-02   Ready    <none>   7m25s   v1.16.3-k3s.2   172.17.8.102   <none>        Ubuntu 18.04.3 LTS   4.15.0-70-generic   docker://19.3.5
ubuntu-01   Ready    master   8m5s    v1.16.3-k3s.2   172.17.8.101   <none>        Ubuntu 18.04.3 LTS   4.15.0-70-generic   docker://19.3.5
```


当前安装的 k3s 是 v1.0.0，k8s 是 v1.16.3

最后我将完整的配置已经上传到 github 上了。大家有需要可以直接执行如下命令即可：

```
git clone https://github.com/wusuopu/kubernetes-vagrant-ubuntu
cd kubernetes-vagrant-ubuntu
vagrant up
```
