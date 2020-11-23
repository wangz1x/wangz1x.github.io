---
title: github connection timed out
date: 2020-11-23 15:35:03
tags:
- github
---

修改协议很麻烦，无法保证修改后可以使用，那就直接在`.ssh`下新建config文件，内容如下：

```s
Host github.com
Hostname ssh.github.com
Port 443
```

但是就算这样改了，也不能保证一定可行，那就过一段时间在push
