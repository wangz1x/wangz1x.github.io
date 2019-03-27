---
title: LeetCode 44. Wildcard Matching
date: 2019-03-27 14:32:41
tags:
categories: LeetCode
---

Question:  

> Given an input string (s) and a pattern (p), implement wildcard pattern matching with support for '?' and '*'.

``` text
'?' Matches any single character.
'*' Matches any sequence of characters (including the empty sequence).
```

<!--more-->

---

Analysis:  

`*`可以匹配任意内容包括空字符串，所以这个`*`要匹配多少就是最根本的问题。