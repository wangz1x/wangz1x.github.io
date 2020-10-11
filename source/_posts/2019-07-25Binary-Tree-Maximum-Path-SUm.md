---
title: LeetCode 124.Binary Tree Maximum Path Sum
date: 2019-07-25 09:14:33
tags: 
- 递归
- leetcode
---

Question:

> Given a non-empty binary tree, find the maximum path sum.

<!--more-->

Example:

    Input: [-10,9,20,null,null,15,7]

       -10
       / \
      9  20
        /  \
       15   7

    Output: 42

Analysis:

因为是只用求最大路径长度，所以可以优先设置一个全局变量记录此最大长度。当遍历到某一点时，需要知道它左右各自最长的长度用作比较，所以这里选用后序遍历。在该点有三种路径，该点及左边、该点及右边、该点及两边；分别比较它们与全局最大长度比较，更新全局最大长度。

Answer:

``` python
# class TreeNode:
#     def __init__(self, x):
#         self.val = x
#         self.left = None
#         self.right = None

class Solution:
    def maxPathSum(self, root: TreeNode) -> int:
        if not root:
            return 0
        maxS = -sys.maxsize
        def helper(root):
            nonlocal maxS
            if not root:
                return 0
            maxl = helper(root.left)
            maxr = helper(root.right)
            oneSide = max(maxl, maxr, 0) + root.val
            connect = maxl+maxr+root.val
            maxS = max(maxS, oneSide, connect)
            return oneSide
        helper(root)
        return maxS
```
