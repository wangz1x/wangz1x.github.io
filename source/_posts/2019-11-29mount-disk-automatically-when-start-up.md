---
title: Mount disk automatically when start up
date: 2019-11-29 20:54:50
tags:
- linux
---

其实不用手动操作，`deepin`也会自动挂载磁盘，只不过它的路径看起来太长了。

<!--more-->

主要分为3步:

1. 创建挂载点

说白了就是从哪个路径访问到你的磁盘，这里边也有大学问，我不懂

2. 查看磁盘的UUID

可以使用命令`blkid`，或者是`lsblk --fs`
![haha](fig1.jpg)

![xixi](fig2.jpg)

3. 编辑文件

`/etc/fstab`这个文件应该就是控制系统启动时所加载的磁盘，仿照上边规范的写法，加上自定的加载磁盘就好。
![heihei](fig3.jpg)
