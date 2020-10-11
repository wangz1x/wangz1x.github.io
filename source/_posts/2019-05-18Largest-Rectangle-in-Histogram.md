---
title: LeetCode 84. Largest Rectangle in Histogram
date: 2019-05-18 11:27:34
tags: 
- 单调栈
- leetCode
---

Question:

> Given n non-negative integers representing the histogram's bar height where the width of each bar is 1, find the area of largest rectangle in the histogram.

<!-- more -->

Example:

![histogram](https://image.zero22.top/max/rectangle/histogram.png)
Above is a histogram where width of each bar is 1, given height = [2,1,5,6,2,3].

![largest](https://image.zero22.top/max/rectangle/histogram_area.png)
The largest rectangle is shown in the shaded area, which has area = 10 unit.

Analysis:

暴力循环是可以求出来，但是超时。通过观察可以发现，最大的面积一般不是由最高的柱决定，但是往往都会把它包含起来。所以，在找最大面积时，可以在找到了一个顶点时，再往前扫描计算面积。拿示例来说，0位置的2是一个顶点，计算面积；往后到了3位置的6又是一个顶点，往前扫描分别得到6， 10等。如此一来，就避免了很多无谓的计算。由于是在找到顶点时再计算面积，所以需要保存前面的值来判断哪个值是顶点，使用单调递增栈这一数据结构可以保存这些信息。单调递增栈，首先是个栈，其次保存的数据是递增的，当入栈的值小于栈顶时，对栈顶元素做出栈操作，直到当前值可以作为栈顶元素。

Answer:

``` java
class Solution {
    public int largestRectangleArea(int[] heights) {

        // 保存最大的长方形
        int maxR = 0;

        // 取出的栈顶
        int nowH = 0;

        //单调递增栈
        ArrayDeque<Integer> stack = new ArrayDeque<>();

        // 这里循环到 heights.length
        for (int i = 0; i <= heights.length; i ++) {
            if ((stack.isEmpty()) || (i < heights.length && heights[stack.peekLast()] <= heights[i])) {
                // 栈里边放的是位置，便于计算宽
                stack.offerLast(i);
            }
            else {
                // 取出的栈顶当做当前矩形的高
                nowH = stack.pollLast();

                // 1. 由于栈中是递增顺序的，取出栈顶nowH后，栈如果为空且nowH前边原本是有元素的，说明nowH比前边的都要小，也就是以[nowH]为高时可以
                //      把前边的也包含住，所以宽为 i
                // 2. 如果取出nowH后，栈不为空，根据相应位置计算宽
                maxR = Math.max(maxR, heights[nowH]*(stack.isEmpty()? i: (i - 1 - stack.peekLast())));

                i --;
            }
        }

        return maxR;
    }
}
```
