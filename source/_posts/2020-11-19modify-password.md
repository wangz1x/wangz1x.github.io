---
title: linux修改密码
date: 2020-11-19 16:54:21
tags:
- linux
---

修改`linux`中`root`的密码：

``` s
sudo passwd
```

不管之前有没有设置过密码，都直接输入新密码，然后确认一遍即可。


修改`linux`中普通用户的密码：

```s
passwd
```

需要输入原密码，在该新密码然后确认；

或者先切换到`root`，使用

```s
passwd username
```

直接修改用户的密码
