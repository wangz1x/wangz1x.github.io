---
title: java中的流
date: 2018-09-12 21:27:30
tags:
- io
- java
---

Java类库中的I/O类分成**输入**和**输出**两部分, 可以在JDK文档的类层次结构中看到。通过继承, 任何自`InputStream`和`Reader`派生而来的类都含有名为`read`的基本方法, 用于读取单个字节或字节数组。同样, 任何继承自`OutputStream`和`Writer`而来的类都含有名为`write`的基本方法, 用于写单个字节或字节数组。我们很少使用单一的类来创建流对象, 而是通过叠合多个对象来提供所期望的功能, 也就是类外套上其他的类, 即装饰器设计模式。

<!--more-->

### InputStream

`InputStream`的作用是用来表示那些从不同数据源产生输入的类。这些数据源包括但不限于:

 1. 字节数组
 2. String对象
 3. 文件
 4. 管道, 工作方式和实际管道类似, 从一端输入, 从另一端输出

这些数据源都有对应的`InputStream`子类, 一般称为**介质流**:

 1. ByteArrayInputStream
 2. StringBufferInputStream(Deprecated)
 3. FileInputStream
 4. PipedInputStream

可以把以上输入流归为**介质流**, 因为这些流是和具体的源数据打交道的。
另外, `FilterInputStream`也是一种输入流, 只不过它是套在*介质流*之外的, 可以称作**包装流/过滤流**, 主要有以下几种:

 1. BufferedInputStream
 2. DataInputStream
 3. PushbackInputStream


### OutputStream

和`InputStream`对应, `OutputStream`流中的*介质流*也主要有以下几种:

 1. ByteArrayOutputStream
 2. FileOutputStream
 3. PipedOutputStream

*包装流/过滤流*主要有:

 1. BufferedOutputStream
 2. DataOutputStream
 3. PrintStream

### other

#### 如何按照指定编码读取文件?

 读取文件一般就想到用`FileInputStream`, 但是我们看下它的构造方法, 并没有提供"编码"这项功能, 其实基本上字节流都没有指定编码这项功能, 在一番查找下, 才最终在`InputStreamReader`中找到了`charset`

 ``` java
public InputStreamReader(InputStream in, String charsetName)
    throws UnsupportedEncodingException
{
    super(in);
    if (charsetName == null)
        throw new NullPointerException("charsetName");
    sd = StreamDecoder.forInputStreamReader(in, this, charsetName);
}

public InputStreamReader(InputStream in, Charset cs) {
    super(in);
    if (cs == null)
        throw new NullPointerException("charset");
    sd = StreamDecoder.forInputStreamReader(in, this, cs);
}

public InputStreamReader(InputStream in, CharsetDecoder dec) {
    super(in);
    if (dec == null)
        throw new NullPointerException("charset decoder");
    sd = StreamDecoder.forInputStreamReader(in, this, dec);
}
```

说到编码, 其实`String`类的构造函数中也提供了指定编码的功能:

``` java
public String(byte bytes[], int offset, int length, Charset charset) {
    if (charset == null)
        throw new NullPointerException("charset");
    checkBounds(bytes, offset, length);
    this.value =  StringCoding.decode(charset, bytes, offset, length);
}
```

`InputStreamReader`和`OutputStreamWriter`是连接*字节流*和*字符流*的桥梁: 
`InputStreamReader`用指定的编码或者默认平台编码从字节中读取数据并把他们解码为字符
`OutputStreamWriter`用指定的编码或默认平台编码把写入的字符编码为相应的字节

#### 如何采用"追加"方式向文件中写东西?

这个平时还真没注意, 但是在`c`或`python`我还记得是以`a`方式打开文件, 然后翻了`FileOutputStream`发现`java`中并没有所谓的"方式", 在`write`方法中会隐藏一个`append`字段:

``` java
public void write(byte b[]) throws IOException {
    writeBytes(b, 0, b.length, append);
}

public void write(byte b[], int off, int len) throws IOException {
    writeBytes(b, off, len, append);
}

private native void writeBytes(byte b[], int off, int len, boolean append)
    throws IOException;

......
```

那么这个字段值是在哪指定的呢? 再看它的构造函数:

``` java
public FileOutputStream(File file, boolean append){}

public FileOutputStream(String name, boolean append){}
```

在构造文件输出流时就会让你选择是否以追加的模式构建流.