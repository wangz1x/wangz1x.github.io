---
title: stream and character
date: 2021-08-09 17:22:12
tags:
- stream
- character
---

`java`中有很多字节流, 字符流, 由于不经常见到(项目做少了), 记录下见到的

### 字符流

#### InputStreamReader

三个构造方法:

```java
InputStreamReader(InputStream in)
InputStreamReader(InputStream in, String charsetName)
InputStreamReader(InputStream in, Charset cs) {
```

看到其构造方法就知道这个玩意能够指定编码


#### FileReader

```java
public FileReader(String fileName) throws FileNotFoundException {
    super(new FileInputStream(fileName));
}
FileReader(File file)
FileReader(FileDescriptor fd)
```

从其构造方法可以看出，这个玩意就是替我们把`stream`的创建过程省了, 但是这样只能用默认的编码了

#### PrintWriter

打印流，能装挺多的

```java
PrintWriter(File file)
PrintWriter(File file, String csn)
PrintWriter(OutputStream out)
PrintWriter(OutputStream out, boolean autoFlush)

// 基本都会包个 BufferedWriter
public PrintWriter(String fileName) throws FileNotFoundException {
    this(new BufferedWriter(new OutputStreamWriter(new FileOutputStream(fileName))),
          false);
}

PrintWriter(String fileName, String csn)
PrintWriter (Writer out)
PrintWriter(Writer out, boolean autoFlush)
```

就是不太懂为啥指定编码的那个构造方法要设为`private`, 上边和文件相关的构造方法如果指定了编码方式都会调用这个私有的构造方法

这里可以指定一个`boolean`表示是否自动`flush`


#### BufferedReader

```java
BufferedReader(Reader in, int sz)
BufferedReader(Reader in)
```

给`Reader`套一层缓冲, 一般流的最外边都会套个这个?

### 字节流

#### FileOutputStream

```java
FileOutputStream(File file)
FileOutputStream(File file, boolean append)
FileOutputStream(FileDescriptor fdObj)
FileOutputStream(String name)
FileOutputStream(String name, boolean append)
```

这里也有个`boolean`， 用来指定是否以追加的方式写入文件
