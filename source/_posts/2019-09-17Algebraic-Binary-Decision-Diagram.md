---
title: Algebraic Binary Decision Diagram
date: 2019-09-17 14:40:38
tags:
categories: Dependable Systems
---
<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>

由于没有可信计算的背景知识，看师哥的故障树文章感觉很困难，主要是没有系统的学习其中的分析方法，表达式，以及概率计算公式，大致记录一下《An Algebraic Binary Decision Diagram for Analysis of Dynamic Fault Tree》一文中出现的名词。

### 静态故障树

故障树是一种用于分析系统可靠性与安全性的传统方法，包括基本事件`(basic event)`、中间事件`(intermediate)`、顶端事件`(top event)`以及各种门`(gate)`。当所有的门都是与`(AND)`、或`(OR)`、权重门`(Voting gate)`时，就把这种模型称为静态故障树`(Static Fault Tree)`.

### 动态故障树

由于静态故障树无法处理某些动态系统，因此有些人在故障树中加入了一些动态门，比如`Warm Spare(WSP)`，`Cold Spare(CSP)`，`Priority-AND(PAND)`，`Sequence enforcing(SEQ)`和`Functional Dependency(FDEP)`。这种具有动态门的模型就称作动态故障树`(Dynamic Fault Tree)`.

### 具体的模型

由于本文提出的`ABDD`方法相当于是结合`Algebraic Method`,`BDD`和`SBDD`的各自优点，因此文章对于这些知识做了进一步的介绍。

#### Algebraic Method

代数方法通过添加新的时序运算符`BEFORE`来对系统进行代数建模。

---

    对该运算符举个简单的例子：

$A$ ◁ $B$

其中$A$和$B$分别代表`DFT`中的事件，`◁` 表示 BEFORE运算符。

该式子表示只有事件$A$在事件$B$之前发生时，这个事件($A$ ◁ $B$)才会发生。

因此该事件等价为:

$A◁B=AB+AB'$

$B'$表示$B$永远不会发生。

---

通过使用函数$d(A)$表示$A$出现的唯一的数据(???)，对该运算符做标准的定义：

$$ A◁B=\begin{cases}
A & d(A)<d(B) \\
\bot & d(A)>d(B) \\
\bot & d(A)=d(B) \\
\end{cases}$$

其中$\bot$是永不发生的事件，因此$d(\bot)=+\infty$。

#### 传统的BDD

`BDD`就是`Binary Decision Diagram`，将布尔逻辑函数用二叉树进行表示。

基于香农分解`Shannon decomposition`(公式如下)，`BDD`是一个有向无环图`DAG`。

$f=xf_{x=1}+x'f_{x=0}=ite(x, F_1, F_0)$

式中$ite$是`if-then-else`的缩略词。

`BDD`有两个`sink`节点`0`和`1`，分别表示系统操作?与失效。

    所以计算系统失效概率时，走的是到达节点1的路径

通过下面的公式遍历故障树并得到对应的`BDD`

$$g◇h=ite(x, G_1, G_0)◇ite(y, H_1, H_0)=\begin{cases}
ite(x, G_1◇H_1, G_0◇H_0) & index(x)=index(y) \\
ite(x, G_1◇h, G_0◇h) & index(x)<index(y) \\
ite(y, g◇H_1, g◇H_0) & index(x)>index(y) \\
\end{cases}$$

其中$g$和$h$表示遍历的子树的布尔表达式，$G_i$是$g$的子表达式，$index$是在变量输入列表中定义的顺序，◇表示逻辑运算符，比如`AND`,`OR`。

转化的到`BDD`后，在通过下面的递归公式计算出概率???

$Pr\{f\}=Pr\{x\}·Pr\{F_1\}+Pr\{x'\}·Pr\{F_0\}$

#### 传统的SBDD

在`BDD`的基础上引入了连续节点，比如($A \prec B$)，$\prec$是一个优先操作符，和◁的主要区别在于($A \prec B$)只有在$A$优先于$B$且$A$和$B$都会发生，该事件才会发生。

用公式表示为：

$A◁B=A \prec B+AB'$

由于$\prec$运算符的运算规则不是非常完善，`SBDD`无法适用于所有的`DFT`中。

### ABDD

`ABDD`主要包含三个步骤

1. `DFT`模型转化

首先根据`DFT`得到其代数表达式，即包含`BEFORE`运算符，然后根据各种化简公式将该表达式化简为连乘形式，比如这样：$TE=(A◁B)·(C◁B)·(S◁B)·(A+B)$

2. 建立`ABDD`模型

首先假定事件之间的顺序，例如$(A◁B)<(C◁B)<(S◁B)<A<B$，然后用图表示出来:

![ADBB](https://image.zero22.top/adbb/abdd.jpg)

3. SDP generation and DFT probability calculation

根据`ADBB`可得到两条导致系统失效的路径：

$$\begin{cases}
(A◁B)·(C◁B)·(S◁B)·A \\
(A◁B)·(C◁B)·(S◁B)·A'·B \\
\end{cases}$$

如果可以化简的话就继续化简，我这里的例子是随便敲的，不能肯定是否能化简，最后得到的`SDP`如下：

$TE=(A◁B)·(C◁B)·(S◁B)·A + (A◁B)·(C◁B)·(S◁B)·A'·B$

然后计算`DFT`失效故障概率:

$Pr\{TE\}=Pr\{(A◁B)·(C◁B)·(S◁B)·A\}(t)+Pr\{(A◁B)·(C◁B)·(S◁B)·A'·B\}(t)$

在后边就是把上述概率公式转化为微积分进行计算，实在是看不懂了啊。。
