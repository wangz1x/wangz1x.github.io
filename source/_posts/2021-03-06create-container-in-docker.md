---
title: Create container in docker
date: 2021-03-06 16:40:00
tags: 
- docker
---

## ftp服务，但是只能宿主机访问，我其他机子用的chrome无法访问

```shell
docker run -d \
-p 20:20 -p 21:21 -p 21000-21200 \
-v /home/docker/ftp:/home/vsftpd \
-e FTP_USER=ftp1103 -e FTP_PASS=1103ftp \
-e PASV_ADDRESS=XXX.XXX.XXX.XXX \
-e PASV_MIN_PORT=21000 \
-e PASV_MAX_PORT=21200 \
--name ftp-1 \
fauria/vsftpd:latest
```

## tomcat

容器中的 WorkingDir为 `/usr/local/tomcat`

```shell
docker run -d \
-p 8081:8080 \
-v /home/docker/tomcat:/var/tomcat \
--name tomcat-1 \
tomcat:8.5.64-jdk8-adoptopenjdk-hotspot
```

## redis

```shell
docker run -d \
-p 6379:6379 \
-v /home/docker/redis/:/var/redis \
--name redis-1 \
redis:latest
```

指定配置文件时，后边加上 `redis-server /xxx/redis.conf`，要注意容器内redis的版本和指定的配置文件的版本，不对应的话可能会报错，`line XXX, bad directive or wrong number of arguments`

## mysql

```shell
docker run -d \
-p 3306:3306 \
-v /home/docker/mysql/:/var/mysql \
-e MYSQL_ROOT_PASSWORD=XXXX \
--name mysql-1 \
mysql:5.7
```

## Zookeeper

```shell
docker run --name zookeeper-2 --restart always -d -e "ZOO_MY_ID=2" -e ZOO_SERVERS="server.1=172.17.0.4:2888:3888;2181 server.2=172.17.0.5:2888:3888;2181 server.3=172.17.0.6:2888:3888;2181" zookeeper
```

某些容器中的配置项可以通过 `-e` 来改写，如果修改的配置不多的话，这样比较方便，避免了创建文件进行映射等操作。


## 网络

由于电脑经常死机, 重启后`docker`中的容器也可能会重启`(--restart always)`, 此时各个容器启动顺序不确定, 则其按顺序分配到的`ip`也可能会和之前不同.

那我配置的`zookeeper`假集群就没法用了(因为创建这些`zookeeper`实例时需要指定各台机器的`ip`). 

查了一下，发现可以为容器指定固定的ip, 下面记录下步骤:

1. 创建自己的`docker`网络

```shell
docker network create --subnet=172.18.0.0/16 mybridge

# 若使用默认的bridge，则会出现:
docker: Error response from daemon: user specified IP address is supported on user defined networks only.
```

2. 创建新的容器

```shell
docker run -d --restart always --net mybridge --ip 172.18.0.2 \
-p 6379:6379 \
-v /home/docker/redis/:/var/redis \
--name redis-1 \
redis:latest
ba55ec0fad37ccf9ed42c47871e0d79b7e6fb12a10fa08786e660caa809d1b75
```