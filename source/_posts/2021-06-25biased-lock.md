---
title: synchronized关键字涉及到的四种形态
date: 2021-06-25 14:21:19
tags:
- java
- synchronized
- lock
---

`synchronized`关键字经过优化后，多了两种形态：**偏向锁**和**轻量级锁**

### 无锁

众所周知，锁的不同形态可以在一个对象的对象头中体现出来，具体的可以使用`jol`工具查看对象头信息，`maven`导入
```xml
<dependency>
    <groupId>org.openjdk.jol</groupId>
    <artifactId>jol-core</artifactId>
    <version>0.10</version>
</dependency>
```
即可. 

如果想要查看某个对象的对象头，直接
```java
System.out.println(ClassLayout.parseInstance(t).toPrintable());
```
即可. 

比如对于只包含一个`int`类型的属性的对象`t2`，其对象头显示如下:

```shell
com.wzx.Test object internals:
 OFFSET  SIZE   TYPE DESCRIPTION      VALUE
      0     4   (object header)       01 00 00 00 (00000001 00000000 00000000 00000000) (1)
      4     4   (object header)       00 00 00 00 (00000000 00000000 00000000 00000000) (0)
      8     4   (object header)       05 c1 00 20 (00000101 11000001 00000000 00100000) (536920325)
     12     4   int Test.field        7
Instance size: 16 bytes
Space losses: 0 bytes internal + 0 bytes external = 0 bytes total
```

这里需要注意的是，本人所使用的`jdk1.8`默认是开启了`UseCompressedOops`和`UseCompressedClassPointers`两个虚拟机选项的，表示采用指针压缩，原本`64bit`的指针压缩到`32bit`了，因此，在关闭这两个选项后(关闭任意一个均可)，`t2`对象头显示如下:

```shell
com.wzx.Test object internals:
 OFFSET  SIZE   TYPE DESCRIPTION      VALUE
      0     4   (object header)       01 00 00 00 (00000001 00000000 00000000 00000000) (1)
      4     4   (object header)       00 00 00 00 (00000000 00000000 00000000 00000000) (0)
      8     4   (object header)       28 b2 0a 83 (00101000 10110010 00001010 10000011) (-2096451032)
     12     4   (object header)       31 7f 00 00 (00110001 01111111 00000000 00000000) (32561)
     16     4   int Test.field        7
     20     4   (loss due to the next object alignment)
Instance size: 24 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total
```

和上边对比，发现`Mark Word`的8个字节没变化，下边的类指针多了4个字节.

通过对比相关资料对于`Mark Word`组成部分的描述，可以推断出`jol`是按低位到高位顺序输出对象头的(?)，想要得到和相关资料那样的顺序，只用把`jol`输出的字节顺序逆序即可.

无锁状态锁的标志位是`01`, 偏向锁状态是`0`.

### 偏向锁

当创建完对象，打印其对象头，发现不论怎么搞都得到的是初始无锁状态的对象，用`synchronized`加个锁就变**轻量级锁**了，怎么也去不到**偏向锁**的状态.

原来是因为虚拟机启动时，默认有个参数为`BiasedLockingStartupDelay=4000`，表示虚拟机启动`4s`之后才启用**偏向锁**. 这一步的目的为减少虚拟机启动时由于偏向锁的不当使用造成的影响.

那么可以把该参数设为0，或者等待个四五秒在创建对象，果然就是偏向状态了:

```shell
# 开启了指针压缩
com.wzx.Test object internals:
 OFFSET  SIZE   TYPE DESCRIPTION      VALUE
      0     4   (object header)       05 00 00 00 (00000101 00000000 00000000 00000000) (5)
      4     4   (object header)       00 00 00 00 (00000000 00000000 00000000 00000000) (0)
      8     4   (object header)       05 c1 00 20 (00000101 11000001 00000000 00100000) (536920325)
     12     4   int Test.field        7
Instance size: 16 bytes
Space losses: 0 bytes internal + 0 bytes external = 0 bytes total
```

可以看到此时偏向状态为`1`, 而前边所有的bit都为0(包括线程ID, epoch, 分带年龄), 由于偏向ID为空，此时的状态也称作匿名偏向状态, 即后续可以直接偏向其他的线程. 

需要注意的是, 由于`Mark Word`会随着锁的不同状态而重用这部分数据结构, **轻量级锁**与**重量级锁**状态下, 对象的`Mark Word`会被保存到持有该锁的线程栈帧中, 而**无锁**状态下切换到**偏向锁**状态时, 其原本的`Mark Word`并不会保存到其他位置, 因此当调用了对象的强一致性`hashcode()`方法(即未重写过对象的`hashcode()`方法)后, 对象就无法在到达**偏向锁**状态了, 实验如下:

```shell
com.wzx.Test object internals:
 OFFSET  SIZE   TYPE DESCRIPTION       VALUE
      0     4   (object header)        05 00 00 00 (00000101 00000000 00000000 00000000) (5)
      4     4   (object header)        00 00 00 00 (00000000 00000000 00000000 00000000) (0)
      8     4   (object header)        05 c1 00 20 (00000101 11000001 00000000 00100000) (536920325)
     12     4   int Test.field         7
Instance size: 16 bytes
Space losses: 0 bytes internal + 0 bytes external = 0 bytes total

# 这里调用对象继承自Object类的hashcode()方法
# 为了突出hashcode, 把高25bit未使用的位用'-'表示
hashcode: ee7d9f1
com.wzx.Test object internals:
 OFFSET  SIZE   TYPE DESCRIPTION       VALUE
      0     4   (object header)        01 f1 d9 e7 (00000001 11110001 11011001 11100111) (-405147391)
      4     4   (object header)        0e 00 00 00 (-0001110 -------- -------- --------) (14)
      8     4   (object header)        05 c1 00 20 (00000101 11000001 00000000 00100000) (536920325)
     12     4   int Test.field         7
Instance size: 16 bytes
Space losses: 0 bytes internal + 0 bytes external = 0 bytes total
```

从上边可以发现, 原本处于匿名偏向状态的对象, 调用过强一致性`hashcode()`方法后, 其偏向状态变为了`0`.

这里突出强调是**强一致性hashcode**的原因在于, 如果重写了`hashcode()`方法, 那么其计算结果不会保存到`Mark Word`中, 如下:

```shell
com.wzx.Test object internals:
 OFFSET  SIZE   TYPE DESCRIPTION                               VALUE
      0     4        (object header)                           05 00 00 00 (00000101 00000000 00000000 00000000) (5)
      4     4        (object header)                           00 00 00 00 (00000000 00000000 00000000 00000000) (0)
      8     4        (object header)                           05 c1 00 20 (00000101 11000001 00000000 00100000) (536920325)
     12     4    int Test.field                                7
Instance size: 16 bytes
Space losses: 0 bytes internal + 0 bytes external = 0 bytes total

# 重写hashcode方法
hashcode: 7777777
com.wzx.Test object internals:
 OFFSET  SIZE   TYPE DESCRIPTION                               VALUE
      0     4        (object header)                           05 00 00 00 (00000101 00000000 00000000 00000000) (5)
      4     4        (object header)                           00 00 00 00 (00000000 00000000 00000000 00000000) (0)
      8     4        (object header)                           05 c1 00 20 (00000101 11000001 00000000 00100000) (536920325)
     12     4    int Test.field                                7
Instance size: 16 bytes
Space losses: 0 bytes internal + 0 bytes external = 0 bytes total
```

结果很明显了, 调用重写后的`hashcode()`方法并没有像上边那样写入到`Mark Word`中, 因为自定义的`hashcode()`方法很有可能和对象的属性相关, 那么对象的属性一旦修改, 计算出来的`hashcode`也就不同了, 没必要放到`Mark Word`中.

除了上边的一些介绍, 最主要的还是要和其他锁状态联系起来, 探究其状态转换, 比如升级到轻量级锁, 批量重偏向, 批量撤销等.

### 轻量级锁







### 重量级锁