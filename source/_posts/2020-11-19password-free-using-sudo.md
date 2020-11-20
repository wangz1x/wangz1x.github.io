---
title: password free using sudo
date: 2020-11-19 17:38:27
tags:
- linux
---

可能有两种方式，但都是修改一个文件：`/etc/sudoers`

查看这个文件，要求必须使用`visudo`命令修改!!!

### 修改方式一

1. 将当前想体验免密码的用户加到`sudo`用户组里，可以直接编辑`/etc/group`文件，或者使用`usermod -G sudo current_user`

2. 命令`sudo visudo`，将`%sudo  ALL=(ALL:ALL) ALL` -> `%sudo  ALL=(ALL:ALL) NOPASSWD:ALL`

### 修改方式二

命令`sudo visudo`，将在`%sudo  ALL=(ALL:ALL) ALL`行下补充 -> `username  ALL=(ALL) NOPASSWD:ALL`

但是生效好像要重启，暂时先这样

### 额外

`%sudo  ALL=(ALL:ALL) ALL`

对应表示：授权用户组（加%）/用户   在哪个主机登录可进行授权=（切换到哪些用户：切换到哪些组）[是否需要密码]  可授权执行的命令
