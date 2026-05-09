---
title: 修改Hexo中的分类名称
date: 2019-09-10 21:31:25
tags:
- hexo
- git
---

### 问题

某天突然发现我的`categories`中英文名称首字母是小写的，所以想把它们改为首字母大写，但是在文章里边改了之后，页面中的类别确实是变了，但是点进去会出现`404`.

<!--more-->

### 原因

由于写好`md`后，是由`hexo`进行部署等工作生成`public`文件，即具体的**页面**，在此过程可能是由于`git`大小写不敏感的原因，导致`categories`名称只修改首字母大小写并不能产生新的分类，也就使得`github`上的`public`文件中包含的类别名称还是原来的样子，比如`java`，但是在具体的文章页面中该分类已经变成了`Java`，且对应的`url`也变更了，所以会出现访问`404`的问题.

### 解决

通过手动修改`github`中`public`下的分类文件名称.

    由于`git`大小写不敏感，所以无法直接修改：
    $ git mv haha Haha
    Rename from 'haha' to 'Haha/haha' failed. Should I try again? (y/n) n
    fatal: renaming 'haha' failed: Permission denied

    可以采用间接临时文件名作为中转就行了:
    $ git mv java/ temp/
    $ git mv temp/ Java

===

现在已经不用分类了，太麻烦了，直接用`tag`