---
title: 原子类AtomicInteger的自增
date: 2018-08-13 16:38:56
tags:
- java
---

包 java.util.concurrent.atomic 下有很多原子类，可以在不使用锁的前提下实现并发，下面就AtomicInteger来深入看看原子类。

<!--more-->

### 成员变量

``` java
private static final long serialVersionUID = 6214790243416807050L;

// setup to use Unsafe.compareAndSwapInt for updates
private static final Unsafe unsafe = Unsafe.getUnsafe();
private static final long valueOffset;

static {
  try {
    valueOffset = unsafe.objectFieldOffset
      (AtomicInteger.class.getDeclaredField("value"));
  } catch (Exception ex) { throw new Error(ex); }
}

private volatile int value;
```

Unsafe类提供了像C/C++那样操作内存的方法，在很多地方都有用到Unsafe类。由于Unsafe类中大多都是native方法，没有提供源码，连注释都没有(jdk1.8)，看起来有点不爽。

Unsafe.objectFieldOffset()方法返回成员变量相对于对象位置的偏移量(而且这个偏移量也有点意思)，举个例子，假设Book类有个成员变量bookName，且偏移量为12，那么当新建一个Book对象，对象地址为 0x1a3234c3(这地址我瞎举的)，那么bookName的地址就是(0x1a3234c3 + 12)。该方法需要一个java.lang.reflect.Field参数，和反射有关。

value变量保存了当前的对象的值，这个变量被volatile修饰了，即当有多个线程时，只要该变量修改了，能保证其他线程在用这个值得时候是最最最新的。后边也打算写一下volatile。

### 重点方法

``` java
/**
  * Atomically increments by one the current value.
  *
  * @return the updated value
  */
public final int incrementAndGet() {
  return unsafe.getAndAddInt(this, valueOffset, 1) + 1;
}
```

这个方法实现了AtomicInteger的自增1操作，而且是原子的。我们知道，在多线程的环境下使用 num++，最终的结果可能会和预期有差异，这是由于num++不是原子性的，需要读取、加、写入，在这些过程中，可能会丢失掉一部分的写入操作，和数据库中的第二类丢失更新类似。那么这个方法为什么是原子性的呢? 

把相关的方法都找出来:

``` java
public final int getAndAddInt(Object var1, long var2, int var4) {
  int var5;
  do {
    var5 = this.getIntVolatile(var1, var2);
  } while(!this.compareAndSwapInt(var1, var2, var5, var5 + var4));

  return var5;
}
```

很不幸的是，getAndAddInt()里边的两个方法都是native，在java中没有源码。这里我们来实际用用这些方法。

#### 实例化Unsafe

Unsafe使用了单例模式:

``` java
@CallerSensitive
public static Unsafe getUnsafe() {
  Class var0 = Reflection.getCallerClass();
    if (!VM.isSystemDomainLoader(var0.getClassLoader())) {
      throw new SecurityException("Unsafe");
  } else {
    return theUnsafe;
  }
}
```

虽然是单例模式，但不是你想getUnsafe就能得到Unsafe的，他被设计成只有引导类加载器(bootstrap class loader)加载才能返回 Unsafe实例。

这里看文章都写了两种方法，一种是加jvm参数，另一种是反射。加jvm参数我没成功，所以说说反射吧。

``` java
Field field = Unsafe.class.getDeclaredField("theUnsafe");
field.setAccessible(true);
Unsafe unsafe = (Unsafe) field.get(null);
```

这里有点反射的知识，当Field为成员变量时，field.get(not null)必须有个对象参数，否则会有空指针异常；如果Field是静态变量，那么就不需要对象作为参数了。

#### 方法调用

先来试试getIntVolatile方法。

``` java
public native int getIntVolatile(Object var1, long var2);
```

两个参数，var1为对象，var2为变量偏移量

``` java
class UserTwo {
  private String name = "default";
  private int userName = 12;
  private int fieldTwo = 2;
  private static String staticString = "static string";
}

Field field1 = UserTwo.class.getDeclaredField("userName");
field1.setAccessible(true);
// 域偏移量
long offset = unsafe.objectFieldOffset(field1);
System.out.println("getInt: " + unsafe.getInt(userTwo, offset));
```

上边用的getInt，和getIntVolatile大同小异，应该根据具体变量进行选择，输出结果:

``` java
getInt: 12
```

所以这个方法作用为，**根据变量的相对偏移量，得到具体对象的属性值**

再来看看compareAndSwapInt方法

``` java
public final native boolean compareAndSwapInt(Object var1, long var2, int var4, int var5);
```

根据上面的分析，var1，var2用来获取对象属性值，var4为期望值，var5为目标值，写一些示例:

``` java
System.out.println("getAndAddInt: " + unsafe.getAndAddInt(userTwo, offset, 12));
System.out.println("test=" + field1.get(userTwo));
System.out.println("compareAndSwapInt: " + unsafe.compareAndSwapInt(userTwo, offset , 24, 23));
System.out.println("test=" + field1.get(userTwo));
System.out.println("compareAndSwapInt: " + unsafe.compareAndSwapInt(userTwo, offset , 45, 24));
System.out.println("test=" + field1.get(userTwo));
```

输出结果:

``` java
getAndAddInt: 12
test=24
compareAndSwapInt: true
test=23
compareAndSwapInt: false
test=23
```

getAndAddInt，当执行成功时，即实际属性值和期望值相同，即那段时间内内存中的值没有修改过，可以更新，则返回旧值，但其实这时实际内存中的值已经更新了，12+12，所以得到24；
而 compareAndSwapInt，当执行成功时返回true，并将内存中的值更新为目标值，否则返回false。

所以，getAndAddInt方法的大致流程为，取内存中的值，把该值当做目标值，在compareAndSwapInt中在此比较内存中的值和目标值是否相同，如果相同说明其他线程没有修改该变量，此线程可以进行修改，但是具体的修改过程我就不知道，可能还需要看下C++代码吧