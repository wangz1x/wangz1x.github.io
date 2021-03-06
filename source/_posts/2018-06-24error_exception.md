---
title: error/exception in java
date: 2018-06-24 23:24:09
tags:
- error/exception
---

### java异常分为Error和Exception，二者都是继承自Throwable
![enter description here](fig1.png)
<!-- more -->

#### 先来看看Exception：

> The class Exception and its subclasses are a form of Throwable that
> indicates conditions that a reasonable application might want to
> catch.

> The class Exception and any subclasses that are not also subclasses of
> RuntimeException are checked exceptions. Checked exceptions need to be
> declared in a method or constructor’s throws clause if they can be
> thrown by the execution of the method or constructor and propagate
> outside the method or constructor boundary.

可以知道Exception的子类除了RuntimeException 都是检查型异常，在程序中需要捕获处理或者抛给上层处理。

#### 再看看RuntimeException

> RuntimeException is the superclass of those exceptions that can be
> thrown during the normal operation of the Java Virtual Machine.

> RuntimeException and its subclasses are unchecked exceptions.
> Unchecked exceptions do not need to be declared in a method or
> constructor’s throws clause if they can be thrown by the execution of
> the method or constructor and propagate outside the method or
> constructor boundary.

可以看到不要求在编译的时候处理。

### Error的定义

> An Error is a subclass of Throwable that indicates serious problems
> that a reasonable application should not try to catch. Most such
> errors are abnormal conditions. The ThreadDeath error, though a
> “normal” condition, is also a subclass of Error because most
> applications should not try to catch it.


> A method is not required to declare in its throws clause any
> subclasses of Error that might be thrown during the execution of the
> method but not caught, since these errors are abnormal conditions that
> should never occur. That is, Error and its subclasses are regarded as
> unchecked exceptions for the purposes of compile-time checking of
> exceptions.

Error是程序中严重的错误，任何合理的程序都不能去捕获Error。
![enter description here](fig2.png)