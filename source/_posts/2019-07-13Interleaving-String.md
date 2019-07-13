---
title: LeetCode 97.Interleaving_String
date: 2019-07-13 08:23:25
tags: dp
categories: LeetCode
---

Question:

> Given s1, s2, s3, find whether s3 is formed by the interleaving of s1 and s2.

<!--more-->

Example:

    Input: s1 = "aabcc", s2 = "dbbca", s3 = "aadbbcbcac"
    Output: true

Analysis:

刚开始的想法是回溯，用三个游标分别记录当前字符串遍历到的字符，当`s1`和`s2`中只有一个字符和`s3`相同，那么该字符串和`s3`的游标移动到下一个，这是比较好处理的情况；另一种情况`s1`、`s2`、`s3`的当前游标字符都相同，这时候是用`s1`的还是`s2`的呢，我把当前三个游标的位置记录下来，先默认使用`s1`的，当后续出现不匹配的情况时，选择和当前判断最近的这种情况，在用`s2`进行处理。当然最后超时了。

比较好的方法就是动态规划了，`dp[i][j]`表示`s1`串前`i`个字符和`s2`串前`j`个字符能否组成`s3`串前`i+j`个字符，其核心规律为:

    dp[i][j] = (dp[i-1][j] and s1[i] == s3[i+j-1]) or (dp[i][j-1] and s2[j] == s3[i+j-1]) 

Answer:

``` python
class Solution(object):
    def isInterleave(self, s1, s2, s3):
        """
        :type s1: str
        :type s2: str
        :type s3: str
        :rtype: bool
        """
        # dp[i][j] 前i个s1和前j个s2能否组成前i+j个s3
        len1 = len(s1)
        len2 = len(s2)
        len3 = len(s3)
        if len1 + len2 != len3:
            return False
        dp = [[False for j in range(len2+1)] for i in range(len1+1)]
        dp[0][0] = True
        # j = 0
        for i in range(len1):
            if dp[i][0] and s1[i] == s3[i]:
                dp[i+1][0] = True
        # i = 0
        for j in range(len2):
            if dp[0][j] and s2[j] == s3[j]:
                dp[0][j+1] = True

        for i in range(1, len1+1):
            for j in range(1, len2+1):
                dp[i][j] = (dp[i-1][j] and s1[i-1] == s3[i+j-1]) or (dp[i][j-1] and s2[j-1] == s3[j+i-1])
        return dp[len1][len2]
```
