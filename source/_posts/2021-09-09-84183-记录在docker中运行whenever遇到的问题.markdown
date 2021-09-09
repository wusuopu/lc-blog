---
layout: 'post'
title: '记录在docker中运行whenever遇到的问题'
date: '2021-09-09T02:12:48.610Z'
comments: true
post_id: '84183'
permalink: '/archives/84183.html'
categories: ["编程开发"]
tags: ["ruby", "docker"]
---

最近在将一个 rails 的项目移到 docker 方式来部署。这个项目有用到了 whenever 来执行定时任务，这里记录一下在迁移过程中遇到的一些问题。

因为 whenever 是使用系统的 cron 来实现的定时任务，所以直接就在 docker image 内安装一个 cron 即可： `apt-get install -y cron` 。
然后尝试执行命令： `whenever -i; crontab -l` 看看定时任务都有设置正确。最后在容器启动的时候使用命令 `service cron start` 一并将 cron 也启动。

至此感觉事情很简单，一切都很顺利。然而过了两天客户反馈说是这两天的定时任务都没有执行。
定时任务没执行，那就是 cron 有问题。现在来开始排查问题。

先再安装 syslog： `apt-get install -y rsyslog`，将 cron 的日志保存下来，方便查找错误。
然后往 crontab 中随便添加一条任务，每分钟执行一次命令： `date >> /tmp/date.log`。

结果1分钟之后 cron 的日志显示有报如下错误：
```
FAILED to open PAM security session (Cannot make/remove an entry for the specified session)
```

经过搜索知道在 docker 内是没有 session 的，所以 PAM set_loginuid 会失败。需要将 `set_loginuid` 这行注释掉：
```
sed -i '/^session\s\+required\s\+pam_loginuid.so/c\#session required pam_loginuid.so' /etc/pam.d/cron
```

重启 cron 之后，`date >> /tmp/date.log` 定时任务也有正常执行了。

到此感觉问题应该是解决了。然而又过了一天客户还是说定时任务没有执行。
看来还是存在问题的，还得接着排查。

whenever 的任务是定时执行一些 rake 任务，然而执行的结果没有任何的日志。
于是我就新添加了一条 crontab 任务，将 rake 命令的 stdout 和 stderr 重定向到日志文件中。
然后就发现其实是因为在执行 rake 命令时提示 rake 命令不存在，从而导致执行失败的。
看来就因为 PATH 环境变量的问题。

在启动 container 时是有设置了一些环境变量的，然而 cron 这个进程并没有继承这些变量。
所以现在就需要手动为 cron 再配置环境变量。在启动 cron 之前先执行命令：
```
rm /etc/environment
for variable_value in $(cat /proc/1/environ | sed 's/\x00/\n/g'); do
  echo $variable_value >> /etc/environment
done
```

现在再测试一切就正常了。
至此问题终于是解决了，于是就记录一下方便以后查阅。
