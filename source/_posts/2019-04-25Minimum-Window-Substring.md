---
title: LeetCode 76. Minimum Window Substring
date: 2019-04-25 08:27:50
tags: substring
categories: LeetCode
---

Question:

> Given a string S and a string T, find the minimum window in S which will contain all the characters in T in complexity O(n).

<!--more-->

---

Analysis:

在S串中找到一个子串，包含T中所有的字符。可以通过滑动窗口来求解，所谓的窗口在这就可以理解为S的子串。利用数组分别保存窗口中各个字符的个数和T串中字符的个数，同时设置一个计数器，用来统计窗口中的符合T串的字符的个数。那么如何判断哪些字符是在T串中的呢，只需要判断在窗口中该字符出现的次数是否小于T串中该字符出现的次数就好了。

Answer:

``` java

class Solution {
    public String minWindow(String s, String t) {
        // 在s中找一个子串，包含t中所有的字符

        if (s.length() < t.length()) {
            return "";
        }

        int lenS = s.length();
        int lenT = t.length();

        int[] sFre = new int[58];
        int[] tFre = new int[58];
        // 窗口边界
        int l = 0;
        int r = 0;

        // 记录最小窗口
        int start = -1;
        int end = lenS + 1;

        // 记录当前窗口匹配的字符个数
        int count = 0;

        for (int i = 0; i < lenT; i ++) {
            tFre[t.charAt(i) - 'A'] ++;
        }

        // 比如 s="adceba" t="abc", 那么 l <= 3, 如果l超过3,后边所有字符长度也不够t的长度了
        while (l <= lenS - lenT) {
            // 窗口右标没有越界, 并且还没有把t串完全包含
            if (r < lenS && count < lenT) {
                char temp = s.charAt(r);
                sFre[temp - 'A'] ++;
                // 当s频率小于t中的频率, 说明该字符包含在t中 
                if (sFre[temp - 'A'] <= tFre[temp - 'A']) {
                    count ++;
                }
                r ++;
            }
            else if (count >= lenT) {
                char temp = s.charAt(l);

                if (r - l < end - start) {
                    start = l;
                    end = r;
                }

                if (sFre[temp - 'A'] <= tFre[temp - 'A']) {
                    count --;
                }

                sFre[temp - 'A'] --;
                l ++;
            }
            else {
                break;
            }
        }

        return start == -1? "": s.substring(start, end);
    }
}

```
