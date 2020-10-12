---
title: java中的transient
date: 2018-08-10 09:02:00
tags:
- transient关键字
---

### transient本意
英 [ˈtrænziənt]   美 [ˈtrænziənt]  
adj. 短暂的;转瞬即逝的;临时的
n. 临时旅客;瞬变现象;候鸟

<!--more-->

### 序列化与反序列化
要说transient，就要说序列化和反序列化
**维基百科的定义**
> 序列化（serialization）在计算机科学的资料处理中，是指将数据结构或物件状态转换成可取用格式（例如存成档案，存于缓冲，或经由网络中传送），以留待后续在相同或另一台计算机环境中，能恢复原先状态的过程。依照序列化格式重新获取字节的结果时，可以利用它来产生与原始物件相同语义的副本。对于许多物件，像是使用大量参照的复杂物件，这种序列化重建的过程并不容易。面向对象中的物件序列化，并不概括之前原始物件所关联的函式。这种过程也称为物件编组（marshalling）。从一系列字节提取数据结构的反向操作，是反序列化（也称为解编组,deserialization, unmarshalling）。

> 序列化在计算机科学中通常有以下定义:
>  1. 对同步控制而言，表示强制在同一时间内进行单一存取。
>  2. 在数据储存与传送的部分是指将一个对象存储至一个储存媒介，例如档案或是记亿体缓冲等，或者透过网络传送资料时进行编码的过程，可以是字节或是XML等格式。而字节的或XML编码格式可以还原完全相等的对象。这程序被应用在不同应用程序之间传送对象，以及服务器将对象储存到档案或数据库。相反的过程又称为反序列化。

还不是很清楚，引用这篇[博客](https://www.cnblogs.com/szlbm/p/5504166.html)说的:

> 序列化：将一个对象转换成一串二进制表示的字节数组，通过保存或转移这些字节数据来达到持久化的目的。 

>反序列化：将字节数组重新构造成对象。

### java实现序列化及反序列化
java中要实现对象序列化只需要实现java.io.Serializable接口，想要更深的了解Serializable接口，只需要看其相关API或javadoc即可，下面我们来捡一些我看得懂的重要内容看

> Serializability of a class is enabled by the class implementing the
> java.io.Serializable interface. Classes that do not implement this
> interface will not have any of their state serialized or deserialized.
> All subtypes of a serializable class are themselves serializable. The
> serialization interface has no methods or fields and serves only to
> identify the semantics of being serializable.

只有实现了Serializable接口才能序列化，所有实现了Serializable接口的类的子类也能序列化，该接口没有任何方法和属性，只是用作标识能够序列化，这种用法在java中应该还有其他的，现在没影响了。

> To allow subtypes of non-serializable classes to be serialized, the
> subtype may assume responsibility for saving and restoring the state
> of the supertype's public, protected, and (if accessible) package
> fields. The subtype may assume this responsibility only if the class
> it extends has an accessible no-arg constructor to initialize the
> class's state. It is an error to declare a class Serializable if this
> is not the case. The error will be detected at runtime.

大意就是上面说的，实现了Serializable接口的类的子类(没有明确实现Serializable的)要想能够序列化，那么其父类必须要有一个没有参数的子类能够访问的构造方法，下面写个简单的示例:
![enter description here](https://image.zero22.top/$VN73C@D%25%7B%7DZLG%5DW4J$ZY%25N.png)
父类没有无参构造函数，子类直接报错了，下面在父类中添加无参构造函数
![enter description here](https://image.zero22.top/C%28NL3WKG%29_S%29BVOY7P%29%603YK.png)
可以看到没报错了

> Classes that require special handling during the serialization and deserialization process must implement special methods with these exact signatures:
>  private void writeObject(java.io.ObjectOutputStream out) throws IOException;
>  private void readObject(java.io.ObjectInputStream in) throws IOException, ClassNotFoundException; 
>  private void readObjectNoData() throws ObjectStreamException;

想要自定义序列化或反序列化的过程，需要在类中实现这些方法。

默认的序列化和反序列化的方法分别在java.io.ObjectInputStream/java.io.ObjectOutputStream中方法名称分别为defaultReadObject/defaultWriteObject

> The serialization runtime associates with each serializable class a
> version number, called a **serialVersionUID**, which is used during
> deserialization to verify that the sender and receiver of a serialized
> object have loaded classes for that object that are compatible with
> respect to serialization. If the receiver has loaded a class for the
> object that has a different serialVersionUID than that of the
> corresponding sender's class, then deserialization will result in an
> **InvalidClassException**. A serializable class can declare its own
> serialVersionUID explicitly by declaring a field named
> "serialVersionUID" that must be **static**, **final**, and of type **long**:
> 
>  **ANY-ACCESS-MODIFIER static final long serialVersionUID = 42L;**

大意为每个可序列化的类必须要有一个叫做 serialVersionUID 的属性，接收端在进行反序列化时会判断序列化中对象的UID和本地的相应类的UID是否相同，如果不同会抛出**InvalidClassException**异常，该属性必须叫这个名字，而且是 static,final,long类型的

>If a serializable class does not explicitly declare a serialVersionUID, then the serialization runtime will calculate a default serialVersionUID value for that class based on various aspects of the class, as described in the Java(TM) Object Serialization Specification. However, it is strongly recommended that all serializable classes explicitly declare serialVersionUID values, since the default serialVersionUID computation is highly sensitive to class details that may vary depending on compiler implementations, and can thus result in unexpected InvalidClassExceptions during deserialization. Therefore, to guarantee a consistent serialVersionUID value across different java compiler implementations, a serializable class must declare an explicit serialVersionUID value. It is also strongly advised that explicit serialVersionUID declarations use the private modifier where possible, since such declarations apply only to the immediately declaring class--serialVersionUID fields are not useful as inherited members. Array classes cannot declare an explicit serialVersionUID, so they always have the default computed value, but the requirement for matching serialVersionUID values is waived for array classes.

这一段很长，主要就是说这个UID很重要，如果你没有明确声明，那么jvm会在序列化时候，计算一个UID作为默认的，但是这个计算方式非常依赖编译器，并且产生的结果和这个类本身(即属性，方法什么的)有很大的关系，所以这样一来，不同的jvm对同一个类默认生成的UID可能不同，而且一旦修改了类内容，那么肯定新的UID非常可能会和旧UID不同，这样很容易导致反序列化失败，我这里做一个修改类的例子:
![enter description here](https://image.zero22.top/K4TB~B95B%256PZN49RB6%60B_G.png)
很正常的一个类，下面是序列化和反序列化
![enter description here](https://image.zero22.top/1.png)
![enter description here](https://image.zero22.top/2.png)
反序列化结果:
![https://image.zero22.top/result.png](https://image.zero22.top/result.png)
然后我把Book类中的test字段删除，发送端的已经保存到dest1.txt中了，我现在修改Book类相当于是接收端修改了类，然后接收端再从dest1.txt反序列化，结果:
![enter description here](https://image.zero22.top/exception.png)
可以看到报异常了，所以说，这个serialVersionUID还是自己声明一个比较好


### transient关键字
transient说来应该就是为序列化和反序列化服务的，当一个字段声明为transient时，在默认的序列化和反序列化过程中就会跳过该字段，但并不是说该字段就不能被序列化了，我们可以自定义序列化过程来使得其进行序列化，还记得前边的 writeObject/readObject方法吧，我们可以在这些方法中自定义序列化过程。这样一来，我们对于序列化的掌握就更加深了，对于一般的字段，用默认序列化方法即可，对于一些特殊的字段，比如用户密码什么的，我们可以对其声明transient，然后在自定义序列化中对其进行一些加密或其他处理在序列化。其实在上边的示例中仔细看就会发现Book类中flag字段是 transient的，但是在反序列时我依然可以读取该字段，就是因为我自定义了序列化/反序列化:
![enter description here](https://image.zero22.top/complete.png)


### 序列化扩展
在上面引用的序列化定义中写道"将一个对象转换成一串二进制表示的字节数组"，那么如今我把这个二进制的字节数组写到了dest1.txt文件，那么我们为什么不看一看文件内容呢
![enter description here](https://image.zero22.top/dest.png)
这里有两个文件，左边的dest.txt是没有自定义序列化的，右边的是自定义了序列化的，所以右边比左边多出了一个**flag**，值为1，下边对文件**dest1.txt**内容进行分析，还是参考了这篇[博客](https://www.cnblogs.com/szlbm/p/5504166.html)
#### 序列化文件头

 - AC ED：STREAM_MAGIC序列化协议
 - 00 05：STREAM_VERSION序列化协议版本
 - 73：TC_OBJECT声明这是一个新的对象

#### 序列化的类的描述

 - 72：TC_CLASSDESC声明这里开始一个新的class
 - 00 04：十进制的4，表示class名字的长度是4个字节
 - 42 6F 6F 6B：类名，包括包名，但是我这里没加包就没有
 - DB 46 ......85 65：八个字节，long类型的长度，表示serialVersionUID
 - 03：
 - 00 02：该类所包含的域的个数，可以看到这里不包括transient的字段
 
#### 对象中各个属性项的描述
 - 49：字符"I"，表示该属性是一个基本类型
 - 00 06：十进制的6，表示属性名的长度
 - 62 6F 6F 6B 49 64：字符串“bookId”，属性名
 - 4C：字符"L"，表示该属性是一个对象类型而不是基本类型
 - 00 08：属性名长度
 - 八个字节："bookName"
 - 74：TC_STRING，代表一个new String，用String来引用对象

#### 该对象父类的信息(这里我不是很懂)
 - 00 12：十进制的18，表示父类的长度
 - 4C 6A 61 ... 6E 67 3B：“L/java/lang/String;”表示的是父类属性
 - 78：TC_ENDBLOCKDATA，对象块结束的标志
 - 70：TC_NULL，说明没有其他超类的标志

#### 对象的属性项的实际值
如果属性项是一个对象，这里还将序列化这个对象，规则和第2部分一样
 - 00 00 00 01：bookId的值，为1，我才基本类型就直接显示值
 - 74：前边说是代表一个new String
 - 00 05：应该是new String 的长度
 - 62 6F 6F 6B 31：bookName的值"book1"
*在后边就是自定义序列化增加的内容了*
 - 77：w，应该是标识write
 - 04：表示写了4个字节
 - 00 00 00 01：表示flag的值，为1
 - 78：对象块结束的标志

#### 额外
 - 在自定义序列化中，可以看到上边我用的是writeInt，写4个字节，还有一个write(int)方法，只写一个字节，当参数超过一个字节时，只写低8位，看一个示例：
 我把上边的flag改为 77777777，很明显这个数超过8个字节了，其16进制为04a2cb71，我们看一下写到文件中的内容：
 ![enter description here](https://image.zero22.top/dest3.png) 
 只写了一个71
 - **static**变量也不会被序列化

### over

