---
title: java中的Enum
date: 2018-08-16 10:04:09
tags:
- enum
---

最近看java内存模型讲 volatile时候，举了一个DCL(Double Check Lock?)双重检测的单例模式，让我想到了之前看过的枚举实现单例模式，感觉很神奇而且陌生，讲道理，我基本上没怎么用过枚举，还是我见识太少了吧，所以我打算看看这个Enum是怎么回事。
<!--more-->

### 初识

一般用枚举的话，我们一般用的是 "enum"，而不是"Enum"，就好比 "class" 和 "Class"一样。枚举是一种特殊的类，声明时用"enum"，就像接口用"interface"一样，写个简单的例子:

``` java
public enum EnumTest{
    ENUM1;
    EnumTest(){
        System.out.println("this is EnumTest()");
    }
    private void nothing() {
        System.out.println("nothing");
    }
    public static void main(String[] args){
        EnumTest.ENUM1.nothing();
    }
}
```

看起来和一个类没什么区别，可以有 成员变量、方法什么的，但是这也只是看起来而已。

### 深入

下面我们更加深入的看一看这个enum到底是什么玩意，直接反编译：

``` java
public final class EnumTest extends java.lang.Enum<EnumTest> {
  public static final EnumTest ENUM1;

  public static EnumTest[] values();
    Code:
       0: getstatic     #1                  // Field $VALUES:[LEnumTest;
       3: invokevirtual #2                  // Method "[LEnumTest;".clone:()Ljava/lang/Object;
       6: checkcast     #3                  // class "[LEnumTest;"
       9: areturn

  public static EnumTest valueOf(java.lang.String);
    Code:
       0: ldc           #4                  // class EnumTest
       2: aload_0
       3: invokestatic  #5                  // Method java/lang/Enum.valueOf:(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;
       6: checkcast     #4                  // class EnumTest
       9: areturn

  public static void main(java.lang.String[]);
    Code:
       0: getstatic     #11                 // Field ENUM1:LEnumTest;
       3: invokespecial #12                 // Method nothing:()V
       6: return

  static {};
    Code:
       0: new           #4                  // class EnumTest
       3: dup
       4: ldc           #13                 // String ENUM1
       6: iconst_0
       7: invokespecial #14                 // Method "<init>":(Ljava/lang/String;I)V
      10: putstatic     #11                 // Field ENUM1:LEnumTest;
      13: iconst_1
      14: anewarray     #4                  // class EnumTest
      17: dup
      18: iconst_0
      19: getstatic     #11                 // Field ENUM1:LEnumTest;
      22: aastore
      23: putstatic     #1                  // Field $VALUES:[LEnumTest;
      26: return
}
```

哇，可以看到我之前在枚举类中加入的 "ENUM1"竟然是这个类的静态实例，而且还是**final**的，那么这里有个问题，final变量在使用之前必须初始化，但是我们看到这里只是声明，并没有初始化。我们继续往下看，发现还有一个静态代码块！这一下应该能猜到**ENUM1**是在静态代码块里初始化的，我们来看看。

 - new 在java堆上为EnumTest对象分配内存空间，并将地址压入操作数栈顶
 - dup 复制操作数栈顶值，并将其压入栈顶，也就是说此时操作数栈上有连续相同的两个对象地址
 - ldc 把常量池中 ENUM1 推送至栈顶
 - invokespecial 指令调用实例初始化方法"\<init>":(Ljava/lang/String;I)V

看到这大概也就清楚了，静态代码块中确实会初始化ENUM1，这也解决了我的一个疑惑，看下面的程序：

``` java
public enum EnumOut{
    ONE,TWO;
    EnumOut(){
        System.out.println("this is constructor");
    }

    public static void main(String[] args){
        System.out.println("this is main");
    }
}
```

直接给出输出：

``` java
this is constructor
this is constructor
this is main
```

在没有分析字节码之前，我不懂为什么会执行构造函数，但现在，豁然开朗。另外，要注意enum的构造方法只能是private的。

### 实现单例模式

下面看看如何使用枚举实现单例模式：

``` java
public enum SingletonEnum{
    INSTANCE;
    private Singleton instance;

    private SingletonEnum() {
        instance = new Singleton();
    }

    public Singleton getInstance(){
        return instance;
    }

    public static void main(String[] args){
        Singleton single1 = SingletonEnum.INSTANCE.getInstance();
        Singleton single2 = SingletonEnum.INSTANCE.getInstance();
        System.out.println(single1 == single2);
    }
}

class Singleton{
    private int id;
}
```

在jvm第一次加载SingletonEnum类时，INSTANCE就已经被定死了，后边调用**SingletonEnum.INSTANCE.getInstance()** 方法时得到的都是INSTANCE对象中的Singleton，所以保证了单例。