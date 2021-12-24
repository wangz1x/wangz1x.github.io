---
title: 在ubuntu中安装无线网卡驱动
date: 2021-12-24 10:19:05
tags:
- ubuntu
- adapter
---

参考链接[ubuntu安装无线网卡驱动（包括离线安装](https://blog.csdn.net/mhlwsk/article/details/52833374)

1. 将iso镜像作为源

挂载iso镜像：
```shell
sudo mount -o loop -t iso9660 xx/ubuntu-xx.iso /media/cdrom/
```

这里可能会提示没有`/media/cdrom`目录，我是手动创建了一个

添加源：
```shell
sudo apt-cdrom -m -d /media/cdrom add
```

编辑源信息：
```shell
sudo gedit /etc/apt/sources.list
```

只保留`deb cdrom xxx`一行，注意先备份，后边有网了再替换回去

更新源：
```shell
sudo apt update
```

2. 从iso源中安装依赖

```shell
sudo apt install dkms
```

3. 安装驱动

首先要下载对应的无线网卡驱动的deb安装包，原作中给出的链接是broadcom的，正好和我匹配，但是链接地址需要修改下，可以从[http://mirrors.kernel.org/ubuntu/pool/restricted/b/bcmwl/](http://mirrors.kernel.org/ubuntu/pool/restricted/b/bcmwl/)这里边找，我选了最新的一个，没想到就能用，不太晓得到底需要哪一个

下载完后拷到ubuntu中，然后安装该包
```shell
sudo dpkg -i bcmwl-xx.deb
```