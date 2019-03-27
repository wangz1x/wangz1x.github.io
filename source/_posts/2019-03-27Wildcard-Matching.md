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

---

Answer:

1. 动态规划

``` java
class Solution {
    public boolean isMatch(String s, String p) {
        // value[i][j] 表示前i个模式串字符 和 前j个匹配串是否匹配
        boolean value[][] = new boolean[p.length()+1][s.length()+1];
        value[0][0] = true;
        // 初始化
        for (int j = 1; j <= s.length(); j ++) {
            value[0][j] = false;
        }
        // 遍历模式串进行匹配
        for (int i = 1; i <= p.length(); i ++) {
            char temp = p.charAt(i-1);
            if (temp == '*') {
                value[i][0] = value[i - 1][0];
                for (int j = 1; j <= s.length(); j ++) {
                    value[i][j] = value[i - 1][j] || value[i][j - 1] || value[i - 1][j - 1];
                }
            }
            else if (temp == '?') {
                value[i][0] = false;
                for (int j = 1; j <= s.length(); j ++) {
                    value[i][j] = value[i - 1][j - 1];
                }
            }
            else {
                value[i][0] = false;
                for (int j = 1; j <= s.length(); j ++) {
                    value[i][j] = (value[i - 1][j - 1]) && (p.charAt(i - 1) == s.charAt(j - 1));
                }
            }
        }
        return value[p.length()][s.length()];
    }
}
```

2. 双指针

通过指针记录`*`匹配的位置.

``` java
class Solution {
    public boolean isMatch(String s, String p) {
        int sp = 0;
        int pp = 0;
        int pstar_idx = -1;
        int sstar_idx = -1;
        boolean res = false;

        while (sp < s.length()) {
            if (pp < p.length() && (s.charAt(sp) == p.charAt(pp) || p.charAt(pp) == '?')) {
                sp ++;
                pp ++;
            }
            else if (pp < p.length() && p.charAt(pp) == '*') {
                pstar_idx = pp;
                sstar_idx = sp;
                pp ++;
            }
            // 记录'*'的位置，当后面不匹配时，就把不匹配的字符归到'*'里，从下一个在进行匹配操作
            else if (pstar_idx != -1) {
                pp = pstar_idx + 1;
                sp = ++ sstar_idx;
            }
            else {
                break;
            }
        }
        while (pp < p.length() && (p.charAt(pp) == '*')) {
            pp ++;
        }
        if (pp == p.length() && sp == s.length()) {
            res = true;
        }
        return res;
    }
}
```

当模式串中有多个`*`时，只会保存最新遇到的`*`，这样做可行吗，举个例子:  

> `s:abcdabcd` `p:ab*da*d`

这个模式串的格式为`ab...da...d`, 当模式串匹配到第二个`*`时，说明前面的`ab*da`都已经匹配到了，那么就不用再考虑了，也就只用记录最新碰到的`*`.