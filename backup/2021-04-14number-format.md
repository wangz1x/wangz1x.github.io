---
title: java中四舍五入保留指定位数小数
date: 2021-04-14 17:31:23
tags:
- java
- number
- 笔试
---

在做一些笔试编程题的时候，偶尔需要输出指定位数的小数，目前用了两种简单方式：

1. 直接调用`System.out.printf("%.4f", number)`，四舍五入保留4位小数, 注意该方法
2. 偶尔可能要把数据处理完了统一输出，那就先把结果保存，`double/float res = xx.xxxxxx`, 在输出的时候，调用`String.format("%.4f", res)`

上述两种形式，最终都是通过`Formatter().format()`方法实现的