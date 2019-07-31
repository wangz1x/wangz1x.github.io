---
title: java中的static
date: 2018-08-08 18:27:33
categories: Java
---

java中的static想必很常见了，但是若要问到其具体的用法，你又能说出几种呢
<!-- more -->

### static修饰变量方法
这应该是最常见的一种用法了，当类中的属性或方法被static修饰后，就变成了类属性，也就是说访问这些方法或属性不需要类的实例，直接 ClassName.fieldName/ClassName.methodName
一般在访问这些静态变量或方法时，不推荐用类实例来访问
**示例:**

``` java
public class StaticOne {

    public static int flag = 123;
    private String hello;

    public void setHello(String hello) {
        this.hello = hello;
    }

    @Override
    public String toString() {
        return "StaticOne{" +
                "hello='" + hello + '\'' +
                "flag='" + StaticOne.flag + '\'' +
                '}';
    }

    public static void main(String[] args) {
        StaticOne staticOne1 = new StaticOne();
        staticOne1.setHello("staticOne1");
        System.out.println(staticOne1.toString());

        StaticOne staticOne2 = new StaticOne();
        staticOne2.setHello("staticOne2");
        System.out.println(staticOne2.toString());

        StaticOne.flag = 111;
        System.out.println(staticOne1.toString());
        System.out.println(staticOne2.toString());
    }
}
```
**运行结果:**
> StaticOne{hello='staticOne1'flag='123'}
> StaticOne{hello='staticOne2'flag='123'}
> StaticOne{hello='staticOne1'flag='111'}
> StaticOne{hello='staticOne2'flag='111'}

可以看到类实例共享类静态属性，类中的静态成员变量在jvm有特定的存放位置，叫做 **方法区**


### static修饰代码块
static修饰的代码块在类被加载时就运行，而且只在类被加载到jvm中时运行一次，后续创建该类实例时不再运行
**示例:**

``` java
public class StaticTwo {
    public StaticTwo() {
        System.out.println(System.currentTimeMillis());
    }
    static {
        System.out.println(System.currentTimeMillis());
        System.out.println("this is static block in class StaticTwo");
    }
    public static void main(String[] args) {
        StaticTwo staticTwo1 = new StaticTwo();
        StaticTwo staticTwo2 = new StaticTwo();
    }
}
```
**运行结果:**
> 1533725267598 
>  this is static block in class StaticTwo 
> 1533725267598
> 1533725267598

虽然时间都是一样的，但是还是可以看到，static代码块里的代码在实例化对象之前执行，我猜静态代码块一般用来初始化一些数据用


在面试题中也会出现，父类子类里边都有静态代码块、代码块、构造函数，让你说说他们的执行顺序
**让我们来改造一下示例代码:**
``` java
public class StaticTwo {
    public StaticTwo() {
        System.out.println("this is constructor " + System.currentTimeMillis());
    }
    static {
        System.out.println("this is static block in class StaticTwo " + System.currentTimeMillis());
    }
    {
        System.out.println("this is current block in class StaticTwo " + System.currentTimeMillis());
    }
    public static void main(String[] args) {
        StaticTwo staticTwo1 = new StaticTwo();
        StaticTwo staticTwo2 = new StaticTwo();
    }
}
```
很简单，就加了一个普通的代码块，先来看看执行结果吧:

> this is static block in class StaticTwo 1533725730951 
> this is current block in class StaticTwo 1533725730951 
> this is constructor 1533725730951
> this is current block in class StaticTwo 1533725730951
> this is constructor 1533725730951

很容易看出一些规律，在一个类中，每次新建类实例时，都会执行一遍普通代码块，再执行构造方法
**接着改造，加入父子类:**

``` java
public class StaticTwo {
    public StaticTwo() {
        System.out.println("this is StaticTwo constructor " + System.currentTimeMillis());
    }
    static {
        System.out.println("this is static block in class StaticTwo " + System.currentTimeMillis());
    }
    {
        System.out.println("this is current block in class StaticTwo " + System.currentTimeMillis());
    }
}

class StaticTwoChild extends StaticTwo{
    public StaticTwoChild() {
        System.out.println("this is StaticTwoChild constructor " + System.currentTimeMillis());
    }
    static {
        System.out.println("this is static block in class StaticTwoChild " + System.currentTimeMillis());
    }
    {
        System.out.println("this is current block in class StaticTwoChild " + System.currentTimeMillis());
    }
    public static void main(String[] args) {
        StaticTwoChild staticTwoChild1 = new StaticTwoChild();
        StaticTwoChild staticTwoChild2 = new StaticTwoChild();
    }
}
```
**运行结果:**

> this is static block in class StaticTwo 1533726245985 
> this is static block in class StaticTwoChild 1533726245986
> this is current block in class StaticTwo 1533726245986 
> this is StaticTwo constructor 1533726245986 
> this is current block in class StaticTwoChild 1533726245986 
> this is StaticTwoChild constructor 1533726245986
> this is current block in class StaticTwo 1533726245986 
> this is StaticTwo constructor 1533726245986 
> this is current block in class StaticTwoChild 1533726245986 
> this is StaticTwoChild constructor 1533726245986

**分析:**

 1. java中扩展类的初始化过程是这样的，最初虚拟机会依次递推找到最上层的父类，执行完类加载与静态成员的初始化；当main函数中执行代码，产生某个子类对象时，再依次递归找到最上层的父类先进行成员初始化（对象引用没有直接赋值就初始化为Null）,再调用相应的构造器产生对象，然后逐层的进行对象初始化直到最底层的子类。
 2. 所以我们可以看到，jvm在加载StaticTwoChild时，能发现它有父类StaticTwo，所以先去加载他的父类，他的父类没有显示的父类，所以就直接加载，然后在下去加载StaticTwoChild，所以输出前两行是父类静态代码块->子类静态代码块
 3. 子类在执行构造函数时，会先找父类的非默认构造方法并执行，所以下边输出结果就是先父类即StaticTwo的构造方法，再是子类即StaticTwoChild的构造方法，上边也说过了，普通代码块在每次实例化对象时都会最先执行，所以是父类普通代码块->父类构造方法->子类普通代码块->子类构造方法

### static修饰内部类
内部类就是在一个类的内部，像定义变量方法那样，定义一个类，就叫内部类。其实在JDK中就有很多的内部类，尤其是在集合类中，比如下边:
![enter description here](https://image.zero22.top/LCEVBC3FJ7LK89S$%5BAADK@H.png)
![enter description here](https://image.zero22.top/%7DZY_%29SO%5DISN5NIYFA814%28PD.png)
还有很多就不放图了。
这里有会涉及静态内部类和普通内部类的区别，这里简单的说几点基本的吧:
 1. 创建实例方式不同
 2. 静态内部类中只能访问外部类中静态成员，普通内部类都行
 3. 普通内部类中不能有static关键字，但是静态内部内中静不静态都行

静态类有什么用呢？我也不清楚，抄一下别人的
 1. 内部类一般只为其外部类使用；
 2. 内部类提供了某种进入外部类的窗户；
 3.  也是最吸引人的原因，每个内部类都能独立地继承一个接口，而无论外部类是否已经继承了某个接口。因此，内部类使多重继承的解决方案变得更加完整。
可能还是我阅读量太少，并没有体会到内部类的精髓。


### 静态引入
想来这也是最不常见的吧，我也不记得第一次在哪看到的了，不过还有影响的是在一个测试类中引入的断言，应该是这样的:
``` java
import static org.junit.Assert.*;
```
使用静态引入可以方便我们编码，比如下边的示例
``` java
import static java.lang.System.out;
public class StaticFour {
    public static void main(String[] args) {
        out.println();
    }
}
```
不用多说了吧。