---
title: insert into a red-black tree
date: 2019-12-24 15:08:48
tags: red-black-tree
categories: Algorithm
---

### 性质

1. 每个节点是红的或黑的
2. 根节点是黑的
3. 所有的叶子节点(NIL)是黑的
4. 红色节点的孩子只能是黑的
5. 从任一节点到叶子节点所经过的黑色节点个数相同

<!--more-->
就像这样:
![](https://image.zero22.top/red-black/500px-Red-black_tree_example.svg.png)


### 插入

不管是插入还是删除，只要能理出节点插入时其周围节点颜色的情况，就能对操作有个整体的认识。

还要注意的是，在插入时，把待处理的节点默认为红色会更方便，破坏的规则更少。

整体流程图：
![](https://image.zero22.top/red-black/insert-red-black-tree.png)

#### case1

如果根节点为空，则待插入节点当作根节点，并设置为黑色。

#### case2

如果父节点为黑色，那么插入一个红节点不会破坏任何性质，ok

#### case3

如果父节点为红色，这时候就需要考虑叔叔节点了，如果叔叔也是红色，那么就把父亲和叔叔变为黑色，爷爷变为红色，这样保持遍历该棵树时黑色节点数目不变，然后把爷爷当作待插入节点，递归处理。(因为在这里是爷爷，可能是别人的儿子)

![](https://image.zero22.top/red-black/400px-Red-black_tree_insert_case_3.svg.png)

#### case4

还是父节点为红，叔叔为黑色或没有，这时就需要旋转操作了，如果待插入节点和父亲节点在同一边，就绕着父亲节点做一次对应的旋转:

![](https://image.zero22.top/red-black/400px-Red-black_tree_insert_case_5.svg.png)

如果不在同一边，就需要先做一次旋转转到同一边，再继续。

![](https://image.zero22.top/red-black/400px-Red-black_tree_insert_case_4.svg.png)


### 删除

删除的主要思想是用待删除节点的前继或后继节点替换该节点，再删除原前/后继节点，这里考虑用后继节点替换该待删除节点，(那么可知后继节点左孩子是叶子节点)，把后继节点的值copy到待删除节点上，然后只用考虑把后继节点删除就行了。因此后边的待删除节点都是☞原节点的后继节点了，不要搞错对象咯。

主要流程图：
![](https://image.zero22.top/red-black/delete-red-black-tree.png)

#### 自己为红

那么它已经没得孩子了，直接删除就好。

![](https://image.zero22.top/red-black/deletecase1.png)

#### 右孩子为红

把自己删了之后，用右孩子顶上，并改为黑色。

![](https://image.zero22.top/red-black/deletecase2.png)

#### 兄弟为红

通过旋转往这边均个点改为黑的(图优点问题，还没刷新)。

![](https://image.zero22.top/red-black/deletecase3.png)

#### 兄弟同边孩子为红

![](https://image.zero22.top/red-black/deletecase4.png)

#### 兄弟异边孩子为红

![](https://image.zero22.top/red-black/deletecase5.png)

#### 父亲为黑

删除后把兄弟节点改为红的，这时候这个子树是没问题的，但是它作为更大的树的一部分，经过`P`的路径就会比原来少一个黑点，所以要再递归平衡`P`点。
![](https://image.zero22.top/red-black/deletecase6.png)

#### 父亲为红

![](https://image.zero22.top/red-black/deletecase7.png)
