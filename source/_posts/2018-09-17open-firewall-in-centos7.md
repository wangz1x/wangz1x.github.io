---
title: Centos7开放防火墙端口
date: 2018-09-17 18:56:36
tags:
- firewall
- linux
---

Centos7之前一般是用`iptables`管理防火墙相关内容的，一般用到的就是开放一个端口供我们的应用使用，其命令如下:
`iptables -I INPUT -p tcp --dport 11111 -j ACCEPT`

<!--more-->

添加端口:
![enter description here](https://image.zero22.top/firewall/iptables1.png)

删除端口:
![enter description here](https://image.zero22.top/firewall/iptables2.png)

Centos7一般新增了`firewall-cmd`，用来管理防火墙
首先开启
`systemctl start firewalld`

查看状态
`firewall-cmd --state`

添加端口
`firewall-cmd --add-port=11111/tcp --zone=public --permanent`

查看端口
`firewall-cmd --list-ports`

![enter description here](https://image.zero22.top/firewall/firewall-cmd1.png)

添加端口后一般是用 `firewall-cmd --reload`来更新使其生效

`firewall`中的`zone`，不知道和`iptables`中的`chain`有没有关系，用`firewall-cmd`添加的端口在`iptables -L -n`中也可以看到(好像是废话- -)
![enter description here](https://image.zero22.top/firewall/firewall-cmd2.png)

删除端口
`firewall-cmd --remove-port=11111/tcp`

基本的使用over.