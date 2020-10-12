---
title: Levenshtein distance
date: 2019-11-26 21:40:43
tags:
- 编辑距离
- dp
---

`Levenshtein distance`就是编辑距离，简单说就是将一个字符串A通过删除、插入、替换三种操作转化为字符串B，最少的操作数就称为编辑距离。可以通过DP实现编辑距离求解.

<!--more-->

### Analysis

假设我们现在要求字符串A的前i个字符转化为字符串B的前j个字符的最小操作数，如**图1**所示

![图1](fig1.png)

图中的箭头表示这个状态矩阵填写的顺序，因此我们也已经有了`T[i-1][j]`, `T[i][j-1]`, `T[i-1][j-1]`等知识

那么能否利用这些已经计算的值，来计算`T[i][j]`呢?

在两个字符串都进行扩充时，新增加的字符有两种可能:

1. `A[i] == B[j]`

这种情况比较好，说明当前新增的两个字符已经是匹配的，就不用再操他们的心了，此时`T[i][j] = T[i-1][j-1]`

2. `A[i] != B[j]`

这时就不好办了，肯定要对字符串A进行三种操作中的一种才能得到字符串B，此时`T[i][j] = min(三种操作) + 1`

那么这个`min(三种操作)`怎么理解呢?

- `T[i][j-1]`表示前i个转化为前j-1个，然后A通过**插入**一个和B[j]一样的字符到i+1处，完成转化过程
- `T[i-1][j]`表示前i-1个转化为前j个，然后通过**删除**A中第i个字符，完成转化过程
- `T[i-1][j-1]`表示前i-1个转化为前j-1个，然后通过**替换**A中第i个字符为B中的第j个字符，完成转化过程

因此第二种情况下的转移方程可以写为`T[i][j] = min(T[i][j-1], T[i-1][j], T[i-1][j-1]) + 1`


### Source

```python
def cal_dis(keyword1, keyword2):
	"""
	@keyword1: 
	@keyword2:
	"""
	len1 = len(keyword1)
	len2 = len(keyword2)
	if len1 == 0:
		return len2
	elif len2 == 0:
		return len1

	# state matrix
	T = [[0 for i in range(len2+1)] for j in range(len1+1)]

	# initial T
	for i in range(len1):
		T[i][0] = i
	for j in range(len2):
		T[0][j] = j

	for i in range(len2):
		char1 = keyword2[i]
		for j in range(len1):
			char2 = keyword1[j]
      # case 1
			if char1 == char2:
				T[j+1][i+1] = T[j][i]
      # case 2
			else:
				T[j+1][i+1] = min(min(T[j-1][i], T[j][i-1]), T[j-1][i-1]) + 1
	return T[len1][len2]


if __name__ == '__main__':
	cal_ = cal_dis('kitten', 'sitting')
	print('cal =', cal_)
```

### Other

感觉之前做了好一些关于字符串的题，大多是用DP求解的，自己还是太垃圾了，经常会混淆不同目的下的转移过程，唉。。。

比如说[这一题](https://zero22.top/2019/07/25/Distinct-Subsequences/)，其目的是计算从A串到B串有多少种转移方式，哎。
