---
title: LeetCode 60. Permutation Sequence
date: 2019-04-11 09:49:11
tags:
- leetcode
---

Question:

> The set [1,2,3,...,n] contains a total of n! unique permutations.  
> By listing and labeling all of the permutations in order, we get the following sequence for n = 3:  
> 1."123"  
> 2."132"  
> 3."213"  
> 4."231"  
> 5."312"  
> 6."321"  
> Given n(1~9) and k, return the k<sup>th</sup> permutation sequence.  

<!--more-->

---

Analysis:  

通过观察示例我们会发现，当`n=3`时，第一位上每个数字重复的个数为2，这个重复的个数其实是由后边几位有多少种排列方式决定的。比如当`n=4`时，第一位上的重复的个数是由后边`3`位全拍列个数决定的，那就是第一位上会重复`6`次。也就是说，所有的全拍列已经被各个位上相同的数字分好了组，通过这种方式，我们可以从第一位开始，只用循环判断`n`次就能找到指定位置的排列组合。

Answer:

``` java
class Solution {
    public String getPermutation(int n, int k) {
        List<Integer> nums = new ArrayList<>();
        int[] fac={1, 1, 2, 6, 24, 120, 720, 5040, 40320};
        for (int i = 0; i < n; i ++) {
            nums.add(i+1);
        }
        String res = "";
        k--;
        int index = 0;
        for (int i = n - 1; i >= 0; i --) {
            index = k / fac[i];
            res += nums.remove(index);
            k = k % fac[i];
        }
        return res;
    }
}
```

More:

这里的k为什么要提前减1呢?

举个例子，当`n=3`时，比如说我们要求第二个，此时`k=2`。

如果我们不把k减1，得到的`index`为1，余数为0，那么按照`123`来取，第一位取到的就是`2`了。进一步归纳一下，如果k不减1，当余数为0时，其实是上一组（index-1）的最后一个。这样就会使得处理起来不那么方便。

如果我们把k减1，就是把全拍列的组合是从0开始计数的。按照上边的例子，此时`index`为0，余数为1，也就是第1组的第二个，要知道我们存储`nums`的数组也是从0开始计算的，这样就不用考虑当余数为0时是`index`还是`index-1`的问题，可以统一处理，比较方便。