---
title: 欧拉回环与哈密尔顿图
date: 2021-03-05 16:20:38
tags:
- 欧拉回环
- Eulerian path
---



欧拉回环：一笔画问题，每条边只能走一次，能否遍历所有的边。

- 第一种递归：后序遍历，为了保证能把中间节点的环放到整个大环里边
- 第二种递归：先序遍历，但是需要优先访问大的边，这样可以把所有的边都访问完了才回去						

哈密尔顿图：每个节点只能访问一次，能否遍历所有的点。比上边的苛刻很多，一个点只能遍历一次，那么该点所有的边只有一条会被遍历，其他都无法访问了（不然就重复访问了该点）


