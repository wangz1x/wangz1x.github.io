---
title: WeakReference in ThreadLocalMap
date: 2021-08-13 16:50:27
tags:
- java
- WeakReference
- ThreadLocal
- ThreadLocalMap
---

`ThreadLocalMap`提供了一种线程私有变量的机制，对于某个变量，可以做到每个线程都有自己各自的一份，不会和其他线程冲突，当然也没法访问其他线程里的该变量.

`ThreadLocalMap`虽然名字里有个`Map`，但其实现并未实现任何接口，也没有父类，具体由`Entry`数组以及再哈希法实现.

`ThreadLocalMap`中的`Entry`键值对继承与`WeakReference`，该弱引用指向的是`ThreadLocal`，即`Entry`中的`key`.

`WeakReference`不会对其引用的对象造成任何影响，当其引用的对象没有其他强引用引用时，垃圾回收时就会将其回收，这里使用弱引用的考虑为:

- 假设不采用弱引用, 则对于每个`ThreadLocal`，用户代码声明其时会有一个强引用，在存值时，`ThreadLocalMap`中的`Entry`也会对该`ThreadLocal`生成一个强引用; 当用户不再使用该`ThreadLocal`时，只能去掉一个强引用，`Entry`中的强引用无法被消除, 此时就没法清理

- 采用弱引用后，用户代码中的`ThreadLocal`置为空，则没有强引用引用该对象，该对象可以被回收. 而在`ThreadLocal`中的某些操作，发现该弱引用引用的对象为空时，就知道该`key`被回收了, 那么也能对`value`作一个回收.

当然更保险的还是调用`ThreadLocal`的`remove`方法
