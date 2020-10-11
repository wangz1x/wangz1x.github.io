---
title: LeetCode 115.Distinct Subsequences
date: 2019-07-25 08:42:38
tags: 
- dp
- leetCode
---

Question:

> Given a string S and a string T, count the number of distinct subsequences of S which equals T.

<!--more-->

Example:

    Input: S = "rabbbit", T = "rabbit"
    Output: 3
    Explanation:

    As shown below, there are 3 ways you can generate "rabbit" from S.
    (The caret symbol ^ means the chosen letters)

    rabbbit
    ^^^^ ^^
    rabbbit
    ^^ ^^^^
    rabbbit
    ^^^ ^^^

Analysis:

动态规划，`dp[i][j]`表示前`i`个`S`串能组成前`j`个`T`串的字串个数。

如果`S[i] == T[j]`，那么`dp[i][j]`就有两种组成字串的可能，一种是由于`S[i]`和`T[j]`相同，直接用`S[i-1]`和`T[j-1]`组成的字串在分别加上`S[i]`和`T[j]`；另一种是直接把`S[i]`删掉不考虑。

因此`dp[i][j] = dp[i-1][j-1] + dp[i-1][j]`

当`S[i] != T[j]`，直接把`S[i]`删掉不考虑，

因此`dp[i][j] = dp[i-1][j]`

Answer:

``` python
class Solution(object):
    def numDistinct(self, s, t):
        """
        :type s: str
        :type t: str
        :rtype: int
        """
        # dp
        lens = len(s)
        lent = len(t)
        if lens < lent:
            return 0
        if lent == 0:
            return 1
        if lens == 0:
            return 0
        dp = [[0 for i in range(lent+1)] for j in range(lens+1)]
        # init
        dp[0][0] = 1
        for i in range(1, lens+1):
            dp[i][0] = 1
        for j in range(1, lent+1):
            dp[0][j] = 0
        for i in range(1, lens+1):
            for j in range(1, lent+1):
                if t[j-1] == s[i-1]:
                    dp[i][j] = dp[i-1][j-1] + dp[i-1][j]
                else:
                    dp[i][j] = dp[i-1][j]
        return dp[lens][lent]
```
