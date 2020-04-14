---
title: install mysql
date: 2020-03-09 11:12:42
tags: mysql
categories: 
---

在`windows`中使用数据库，首先下载，网不好的话可以去[这](https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-8.0/mysql-8.0.17-winx64.msi)

以**管理员**身份到安装目录下的`bin`目录下：

1. `mysqld --initialize --console`

   会生成一个随机密码

2. `mysqld --install`

   安装服务

3. `net start MySQL`

   启动服务

4.  `alter user root@localhost identified by 'new pass'`

   登陆后修改密码

5.  `set global time_zone='+8:00'`

   设置时区

其他的设置可以查下配置文件`my.ini`