---
title: Java中的String
date: 2020-07-31 19:20:32
tags:
- java
- 字符串常量池
- StringTable
- jvm
---

```java
// 看看最后判断的结果是什么 -----------jdk1.8之后-------------
public static void main(String[] args) {

    String str = new StringBuilder("str").append("str").toString();
    String str1 = new String("str1");
    String str2 = "str1";

    System.out.println(str == str.intern());
    System.out.println(str1 == str1.intern());
    System.out.println(str2 == str1.intern());

}
```

<!--more-->

```java
System.out.println(str == str.intern());           // true
System.out.println(str1 == str1.intern());         // false
System.out.println(str2 == str1.intern());         // true
```

看到`JVM`中提到的各种常量池，我真是

其中当然也包括**字符串常量池**(**StringTable**)，看了网上众说纷，我真是

下面用几个简单的示例，来看看用`JHSDB`看到的东西，先看

### case1

```java
public static void main(String[] args) {
    String str = new StringBuilder("str").append("str").toString();
    System.out.println("debug");
}
```

在上述输出语句打上断点，用`jps`查看进程id，用`jhsdb hsdb --pid id`连上该进程

依次点击`Tools->Object Histogram`, 在列出来的类中双击`String`类型，然后找到上边写的`str`串，如下图

![](https://image.zero22.top/string_in_java/str.png)

发现如下三点：

1. 字符串已经排好序了
2. 只有一个`str`
3. 只有一个`strstr`

通过依次点击`Tools->Heap Parameters`，可以看到当前堆的地址范围，比较得知，上述提到的两个字符串的地址是在堆范围内的。

### case2

```java
public static void main(String[] args) {
    String str1 = new String("str1");
    System.out.println("debug");
}
```

这次只修改了字符串的声明，仍然按照上述步骤，看到的信息如下

![](https://image.zero22.top/string_in_java/str1.png)

发现这里出现了两个`str1`，继续

### case3

```java
public static void main(String[] args) {
    String str = new StringBuilder("str").append("str1").toString();
    System.out.println("debug");
}
```

对**case1**进行修改，`append`一个不一样的串，结果如下

![](https://image.zero22.top/string_in_java/strstr1.png)

在类似的地址上找到了三个串，继续变

### case4

```java
public static void main(String[] args) {
    String str = new StringBuilder("str").toString();
    System.out.println("debug");
}
```

这次也不追加了，就一个，结果如下

![](https://image.zero22.top/string_in_java/strstr.png)

结果和**case2**一样，继续

### case5

```java
public static void main(String[] args) {
    String str2 = "str2";
    System.out.println("debug");
}
```

结果如下，只有一个串

![](https://image.zero22.top/string_in_java/str2.png)

-------

下面对上边五种情况作个小结，含有**猜**的成分

- 字符串还是放在堆上的，至于**字符串常量池**这个概念，里边放的到底是什么，就上边几个简单例子来看，是不会放字符串本身的，也就只能放引用了
- 程序中被双引号引起来的字符串，都会先到堆中，重复的不会重复放(对比**case1**和**case3**)
- 对于`new`操作，会把最终合成的字符串(`new String("a")+new String("b")`, `new StringBuilder("a").append("b")`, 以及`new String("a").concat("b")`生成的`"ab"`或单纯的`new String("ab")`)在堆中创建一遍(对比**case1/2/3/4**)
- **字符串常量池**中放的引用其实是指向堆中的字符串的，而且不会重复(即使堆中有多个字面量相同的字符串，**字符串常量池**中也只会有一个指向该字面量的引用)

---

这样一来，在对开头的示例进行解释

1. `str == str.intern()` 在为`str`赋值时，加引号的`"str"`先被创建且其对应的引用也放到**字符串常量池**中了，然后在堆上创建`"strstr"`对象，此时还没放到**字符串常量池**中，在调用`str`的`intern()`方法时将其引用放到了**字符串常量池**中，因此`str`和`str.intern()`实际上都指向的是同样一个对象, 返回`true`
2. `str1 == str1.intern()` 根据前边的小结，在执行`String str1 = new String("str1");`时，首先根据双引号，在堆中创建了一个`"str1"`串，记为**H1**, 然后将其引用放入**字符串常量池**中，接着又在堆中`new`了另外一个`"str1"`, 记为**H2**, 此时**H2**可不会再放到**字符串常量池**中了，结果`str1 ---> H2`，`str1.intern() ---> H1`，他们指向不同的地址，返回`false`
3. `str2 == str1.intern()` 由于`str2`在创建时，发现**字符串常量池**已经有指向`"str1"`字面值的引用了，因此直接返回了，相当与`str2 ---> H1 <--- str1.intern()`，指向相同的地址，返回`true`

再对这个例子画个小图

![](https://image.zero22.top/string_in_java/figstr.png)

-----

最后再引用一些其他说法

[http://tangxman.github.io/2015/07/27/the-difference-of-java-string-pool/](http://tangxman.github.io/2015/07/27/the-difference-of-java-string-pool/) 

提到了一句话：全局字符串池里的内容是在**类加载完成，经过验证，准备阶段**之后在堆中生成字符串对象实例，然后将该字符串对象实例的引用值存到string pool中

再结合上图，如果这句话没错的话，那么灰色的字符串是在准备阶段后生成的，而白色的则是在程序运行过程中生成的

[https://www.zhihu.com/question/57109429](https://www.zhihu.com/question/57109429)

根据[RednaxelaFX](https://www.zhihu.com/people/rednaxelafx)的回答，`StringTable`放置于`native memory`中，且只存放引用





