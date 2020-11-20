---
title: mysql-in-docker
date: 2020-11-20 09:57:26
tags:
- docker
- mysql
- question
---

### 问题1

在docker中启动一个mysql容器，在容器外部进行连接的时候，指定ip可以为`127.0.0.1`，也可以为本机（运行docker的机器）的ip，还可以为docker为该容器分配的ip（docker inspect container_name），啊

### 问题2

这个问题我自己没有遇到，在查看ip相关的blog时，发现有人提到这一点，就是用5.7的mysql client去连接8.0的mysql server会由于两个版本验证方式不同而无法连接，需要修改mysql server中的认证方式：

这样查看plugin（不晓得怎么翻译）
```sql
select host,user,plugin from mysql.user;
```

8.0的应该是`caching_sha2_password`，需要修改5.7用的`mysql_native_password`:

```sql
alter user 'root'@'%' identified with mysql_native_password by 'your_password';
flush privileges;
```

一般blog都说要加上后边的密码，但是我这不加密码也行？

太多问题了
