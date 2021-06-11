---
title: ubuntu开启启动项
date: 2021-06-11 11:09:33
tags:
- Linux
---

`linux`开机启动有好几种方式，先记录用到过的：

### clash.service

编写`myService.service`文件：

```shell
[Unit]
Description=Clash daemon, A rule-based proxy in Go.
After=network.target

[Service]
Type=simple
Restart=always
ExecStart=/XXX/XXX/XXX -d /XXX/XXX

[Install]
WantedBy=multi-user.target
```

这个文件写好后，放到`/etc/systemd/system/`下，`systemctl start/enable myService`即可启动/开机启动该服务了。

配置文件中的含义如下：

```shell
Description：运行软件描述
Documentation：软件的文档
After：因为软件的启动通常依赖于其他软件，这里是指定在哪个服务被启动之后再启动，设置优先级
Wants：弱依赖于某个服务，目标服务的运行状态可以影响到本软件但不会决定本软件运行状态
Requires：强依赖某个服务，目标服务的状态可以决定本软件运行。
ExecStart：执行命令
ExecStop：停止执行命令
ExecReload：重启时的命令
Type：软件运行方式，默认为simple
WantedBy：这里相当于设置软件，选择运行在linux的哪个运行级别，只是在systemd中不在有运行级别概念，但是这里权当这么理解。  
```



