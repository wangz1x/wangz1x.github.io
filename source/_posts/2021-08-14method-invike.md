---
title: 方法调用
date: 2021-08-14 12:45:29
tags:
- java
- jvm
- 圣经
---

摘自《深入理解Java虚拟机》第二版`P244 8.3`.

## 8.3 方法调用

方法调用阶段唯一的任务就是确定被调用方法的版本，即调用哪一个方法

一切方法调用在`Class`文件里存储的都是符号引用，而不是方法在实际运行时内存布局中的入口地址

需要在类加载，甚至到运行期间才能确定目标方法的直接引用

### 8.3.1 解析

在类加载的解析阶段，会将其中一部分符号引用转化为直接引用

前提是，方法在程序真正运行之前就有一个**可确定**的调用版本，并且该版本在运行期是**不可变的**

`Java`中符合“编译期可知，运行期不变”的要求的方法，主要有**静态方法**和**私有方法**

对应的方法调用字节码指令为: `invokestatic`, `invokespecial`

只要是由这两条字节码指令调用的方法，都可以在解析阶段确定唯一的调用版本，符合这个条件的有静态方法，私有方法，实例构造器方法，父类方法4类，他们在类加载时就会把符号引用解析为该方法的直接引用，又称非虚方法

虽然`final`方法使用`invokevirtual`调用，但明确他是非虚方法

解析调用一定是个静态的过程，在编译期间就完全确定

### 8.3.2 分派

#### 1. 静态分派

典型: 重载(overload)

```java
Human man = new Man();
```

`Human`称为静态类型或外观类型, `Man`称为实际类型

静态类型的变化仅仅在使用时发生，变量本身的静态类型不会改变，并且最终的静态类型在编译期是可知的

实际类型的变化在运行期才可确定，编译器在编译程序的时候不知道一个对象的实际类型是什么

```java
// 实际类型变化
Human man = new Man();
man = new Woman();

// 静态类型变化
method((Man) man);
method((Woman) man);
```

**编译器在重载时是通过参数的静态类型而不是实际类型作为判断依据**，因此，在编译阶段，编译器会根据参数的静态类型决定使用哪个重载版本

所有依赖静态类型来定位方法执行版本的分派动作称为静态分派，发生在编译阶段

#### 2. 动态分派

典型: 重写(override)

与`invokevirtual`指令的多台查找过程有关，该指令的运行时解析过程大致可分为：

1. 找到操作数栈顶第一个元素所指向对象的**实际类型**

2. 如果在该类型中找到了与符号引用中的描述符和简单名称都相符的方法，再对其作权限校验，通过则返回该方法的直接引用；否则`java.lang.IllegalAccessError`异常

3. 没找到，则按照继承关系从下往上一次对各个父类进行第二步的过程

4. 最终还是没找到,则`java.lang.AbstractMethodError`异常

#### 3. 单分派与多分派

静态分派过程中，需要查看方法接受者(调用方法的对象)和方法参数的静态类型，属于多分派

动态分派过程中，只依据方法接受者的实际类型，属于单分派

#### 4. 动态分派的优化

由于动态分派很频繁，不优化，则方法选择过程需要运行时在类的方法元数据中搜索合适的目标方法

常用的优化就是在类的方法区中建立一个**虚方法表**(virtual method table, vtable)

如果某个方法在子类中没有重写，那么子类的虚方法表里边的地址入口和父类相同方法的地址入口是一致的，都指向父类的实现入口

方法表一般在类加载的连接阶段(验证，准备，解析)进行初始化，准备了类变量的初始值后，虚拟机会把虚方法表也初始化完毕