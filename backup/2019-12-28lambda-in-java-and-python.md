---
title: lambda in java and python
date: 2019-12-28 15:22:20
tags: lambda
---

[Anonymous function](https://en.wikipedia.org/wiki/Anonymous_function): In computer programming, an anonymous function (function literal, lambda abstraction, or lambda expression) is a function definition that is not bound to an identifier. 

<!--more-->
可以简单的理解为去掉了标识符的匿名函数，下面记下自己用到的为数不多的地方= =

### using in java

就我菜鸡而言，在`java`中`Lambda`主要在线程以及比较时见的多，比如下面新创建一个线程：

```java

new Thread(()->{
    System.out.println("hello from: " + Thread.currentThread());
}).start();

// output:
// hello from: Thread[Thread-0,5,main]
```

或者实现一个自定义的比较:

```java
// Collections.sort(strings, (a, b) -> b.length() - a.length());
strings.sort((a, b) -> b.length() - a.length());
```

### using in python

在`python`中，我主要在排序中用到，比如说按照`key-value`中的`key`或`value`来进行排序：

```python
# 按照value进行升序排序
d = {'a':1, 'g':3, 'd':2, 'c':0}
d = sorted(d.items(), key=lambda item:item[1])
print(d)

# output:
# [('c', 0), ('a', 1), ('d', 2), ('g', 3)]
```

在`map`中作为映射使用：

```python
l = [1,2,3,4,5]
ll = list(map(lambda x:x*x, l))
print(ll)

# output:
# [1, 4, 9, 16, 25]
```
