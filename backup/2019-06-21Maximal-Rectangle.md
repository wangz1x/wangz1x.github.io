---
title: LeetCode 85.Maximal Rectangle
date: 2019-06-21 12:31:09
tags: 
- 二进制
- leetcode
---

Question:

> Given a 2D binary matrix filled with 0's and 1's, find the largest rectangle containing only 1's and return its area.

<!--more-->

Example:

Input:

[

  ["1","0","1","0","0"],

  ["1","0","1","1","1"],

  ["1","1","1","1","1"],

  ["1","0","0","1","0"]

]

Output: 6

Analysis:

除了循环使用单调栈的方法，看到了一种很有趣的方法，即采用二进制运算。根据多行数据之间的`&`运算计算高度，同行数据和移位后数据的`&`运算计算宽度。但是这种方法需要对输入数据做预处理，将字符数组转化为二进制数。

Answer:

``` python
# 假设数据处理后 datas = {10100, 10111, 11111, 10010}
for i in range(4):
  temp = data[i]

  for j in range(i, 4):
    temp = temp & data[j]
    if temp is none:
      break
    height = j - i + 1
    move = temp
    width = 0
    while move != 0:
      width = width + 1
      move = move & move > 1
    if height * width > max:
      max = height * width
```
