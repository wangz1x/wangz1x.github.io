---
title: LeetCode 91.Decode ways
date: 2019-07-03 08:29:25
tags: 
- dp
- leetCode
---

Question

> A message containing letters from A-Z is being encoded to numbers using the following mapping:

<!--more-->
'A' -> '1'
'B' -> '2'
...
'Z' -> '26'

> Given a non-empty string containing only digits, determine the total number of ways to decode it.

Analysis:
刚开始想的是把字符串中不用分开的保留出来，比如'12134621'可以分成'1213|4|6|21'，然后把'1213'和'21'能分的种数相乘，现在的问题就是考虑'1213'和'21'有多少分法。这其实也是一种斐波拉契数列，例如:

    f('1') = 1
    f('12') = 2
    f('121') = f('12|1') + f('1|21') = f('12') + f('1')
    ...
    f(n) = f(n-1) + f(n-2)

另一种解法，直接遍历字符串，根据上述公式进行计算，感觉更加简洁明了。

Answer:

``` python
class Solution(object):
    def numDecodings(self, s):
        """
        :type s: str
        :rtype: int
        """
        # 当前n个字符分好后，n+1个字符长度有dp[n]+dp[n-1]
        # 比如 '12212' = '122'|'12' + '1221'|'2'
        # 当然要注意能分开的条件
        if len(s) == 0 or s[0] == '0':
            return 0
        if len(s) == 1:
            return 1
        length = len(s)
        # dp[i]表示前i个字符可分的方法数
        dp = [0 for i in range(length+1)]
        dp[0] = 1
        for i in range(length):
            # 先假设'0'不能和前边的划分在一起, 那么这个'0'是无法处理的
            if s[i] == '0':
                dp[i+1] = 0
            # 把s[i]单独划分
            else:
                dp[i+1] = dp[i]
            # 把s[i]和s[i-1]分一起
            if i > 0 and s[i-1] == '1' or (s[i-1] == '2' and s[i] < '7'):
                dp[i+1] += dp[i-1]
        return dp[length]
```
