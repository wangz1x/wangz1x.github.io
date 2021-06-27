---
title: java中的String
date: 2021-04-14 17:50:33
tags:
- java
- String
---

### 字节码层面

```java
String str0 = "str0";
String str1 = "str"+"str1";
String str2 = new String("str2");

// 字节码为：
 0 ldc #2 <str0>
 2 astore_1
 3 ldc #3 <str1str2>
 5 astore_2
 6 new #4 <java/lang/String>
 9 dup
10 ldc #5 <newString>
12 invokespecial #6 <java/lang/String.<init>>
15 astore_3
16 return
```

带有引号的字符串在编译阶段，会放到`Class`文件的常量池中，在类加载的加载阶段，二进制字节流会按照虚拟机设定的格式存储在方法区中，而常量池就被放到运行时常量池中。

`ldc`指令的含义为：将`int`, `float`, `String`类型的常量值从常量池中推送至栈顶，因此`str0`,`str1`都是直接指向了常量池中的字符串；而`str2`则是根据常量池中的`str2`作为参数构造一个新的字符串对象。

