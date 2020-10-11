---
title: Comparator/Comparable
date: 2018-08-10 15:32:44
tag: comparator/comparable
---

关于java中的Comparator和Comparable，经常会看到，但是因为没有深入的研究，老是把这两个东西搞混淆，很烦，在这里总结一下。

<!-- more -->
### 字面意思
Comparator: 比较器，就像是一个工具一样。
Comparable: 可比较的，描述一个类本身的属性。

### java.util.Comparator
#### 最主要的方法

``` java
/**
* @param o1 the first object to be compared.
* @param o2 the second object to be compared.
* @return a negative integer, zero, or a positive integer as the
*         first argument is less than, equal to, or greater than the
*         second.
* @throws NullPointerException if an argument is null and this
*         comparator does not permit null arguments
* @throws ClassCastException if the arguments' types prevent them from
*         being compared by this comparator.
*/
int compare(T o1, T o2);
```
可以看到**当有入参为null时就会抛出异常**

#### 使用
 1. 新建比较类
 2. 实现此接口，重写方法
 3. 自己调用该方法进行比较或者作为Collections.sort等入参

#### 示例
代码:
![按照销量升序](https://image.zero22.top/example1.png)
结果:
![enter description here](https://image.zero22.top/result1.png)

### java.util.Comparable
#### 只有一个方法

``` java
/**
* @param   o the object to be compared.
* @return  a negative integer, zero, or a positive integer as this object
*          is less than, equal to, or greater than the specified object.
*
* @throws NullPointerException if the specified object is null
* @throws ClassCastException if the specified object's type prevents it
*         from being compared to this object.
*/
public int compareTo(T o);
```
#### 使用
 1. 实现接口，重写方法
 2. 调用该方法

#### 示例
代码:
![enter description here](https://image.zero22.top/example2.png)
结果:
![enter description here](https://image.zero22.top/result2.png)

### 扩展
java.util.Collections.sort最终还是会调用java.util.Arrays里的sort方法，我们跟着他在源码中跳几下，看看这个过程
#### step0
![程序中调用Collections.sort](https://image.zero22.top/sort0.png)
#### step1
![调用List的sort](https://image.zero22.top/sort1.png)
#### step2
![List中调用Arrays.sort](https://image.zero22.top/sort2.png)
#### step3
![根据是否有比较器](https://image.zero22.top/sort3.png)
##### 没有比较器
![enter description here](https://image.zero22.top/sort4.png)
###### 介绍
> /**
>      * Sorts the specified array of objects into ascending order, according
>      * to the {@linkplain Comparable natural ordering} of its elements.
>      * All elements in the array must implement the {@link Comparable}
>      * interface.  Furthermore, all elements in the array must be
>      * <i>mutually comparable</i> (that is, {@code e1.compareTo(e2)} must
>      * not throw a {@code ClassCastException} for any elements {@code e1}
>      * and {@code e2} in the array).

**数组中的元素必须实现Comparable接口**
###### 使用
![enter description here](https://image.zero22.top/sort5.png)


##### 有比较器
我这里看的是 **TimSort.sort**
![enter description here](https://image.zero22.top/sort6.png)
继续看 **binarySort**
![enter description here](https://image.zero22.top/sort7.png)

#### step4
哇，这里还有好多的sort啊，看的我脑袋都大了，over