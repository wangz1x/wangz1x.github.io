---
title: LeetCode 22. Generate Parentheses
date: 2020-10-16 15:29:36
tags:
- parenthesis
- catalan
---

假设有`n`对括号，让你生成所有的有效的括号序列。

<!--more-->

### 分析

官方给出了三种方法，一是暴力法，生成所有可能的序列，然后再判断该序列是否有效；二是回溯法，即在生成括号的过程中就进行判断，主要是根据当前左右括号的数量。

第三种方法比较类似分治？因为第一个位置一定要是个`(`，那么和该括号匹配的`)`就需要在一个奇数位置（从0开始），这样这对括号之间才能空出偶数个空，才能放置有效的括号序列，类似这样：

```python
(..A..)..B..
```

若与第一个`(`匹配的`)`的坐标设为`2*i+1(0<=i<n)`，那么片段`A`就是包含`i`对括号的有效序列，片段`B`就是包含`n-i-1`对括号的有效序列，假设`n`对括号的有效序列数设为`f(n)`，那么就有下式：

```shell
f(n) = f(0)*f(n-1) + f(1)*f(n-2) + ... + f(n-1)*f(0)
```

### 实现

```java
public class Beauty0403 {

    static int n = 2;
    static ArrayList<String>[] caches = new ArrayList[2*n];
    public static void main(String[] args) {
        caches[0] = new ArrayList<>();
        caches[0].add("");
        List<String> generate = generate(n);
        System.out.println(generate);
    }

    public static List<String> generate(int n) {
        if (caches[n] != null) {
            return caches[n];
        }
        caches[n] = new ArrayList<>();
        ArrayList<String> ans = new ArrayList<>();
        for (int i = 0; i <= n-1; i ++) {
            for (String sf : generate(i)) {
                for (String ss : generate(n-i-1)) {
                    ans.add("(" + sf + ")" + ss);
                }
            }
        }
        caches[n] = ans;
        return ans;
    }
}
```

### 补充

上述表达式和[`Catalan Number`](https://en.wikipedia.org/wiki/Catalan_number)的定义类似，而且还有很多问题都和`Catalan Number`相关，比如编程之美的4.3，及其扩展问题，还有wiki上举的一些例子。

有些题目很容易理解，取值范围和`Catalan Number`一致时，可以直接套上边的模板，但是有个多边形划分为三角形问题，就不太一样。
