---
title: LeetCode 95.Unique Binary Search Trees II
date: 2019-07-06 11:27:10
tags:
- leetcode
---

Question:

> Given an integer n, generate all structurally unique BST's (binary search trees) that store values 1 ... n.

<!--more-->

Example:

    Input: 3
    Output:
    [
      [1,null,3,2],
      [3,2,null,1],
      [3,1,null,null,2],
      [2,1,3],
      [1,null,2,null,3]
    ]
    Explanation:
    The above output corresponds to the 5 unique BST's shown below:

      1         3     3      2      1
       \       /     /      / \      \
        3     2     1      1   3      2
       /     /       \                 \
      2     1         2                 3

Analysis:

二叉搜索树，其任一节点的左子树都小于该节点，右子树都大于该节点。由于节点的值从1到n，所以可以考虑将每个值都当做根节点，然后该值左边的放在左边，右边的放右边，比如`5`作为根节点时，`1~4`就作为左子树，`5~n`作为右子树。

Answer:

``` python
# Definition for a binary tree node.
# class TreeNode(object):
#     def __init__(self, x):
#         self.val = x
#         self.left = None
#         self.right = None

class Solution(object):
    def generateTrees(self, n):
        """
        :type n: int
        :rtype: List[TreeNode]
        """
        if n == 0:
            return None
        if n == 1:
            root = TreeNode(1)
            return [root]
        return self.helper(1, n)

    def helper(self, start, end):
        res = []
        # only one node
        if start == end:
            s = TreeNode(start)
            res.append(s)
            return res
        # 由于i是从start开始的，在第一轮递归时，其范围为(start, i-1)，这时候会有start > end
        # 比如说是1~3，在1作为根节点时，其左子树为None，因此这里是这样处理的
        if start > end:
            res.append(None)
            return res

        # make i as the root node
        for i in range(start, end + 1):
            left = self.helper(start, i - 1)
            right = self.helper(i + 1, end)
            # combine each left and right
            for le in left:
                for ri in right:
                    root = TreeNode(i)
                    root.left = le
                    root.right = ri
                    res.append(root)
        return res
```
