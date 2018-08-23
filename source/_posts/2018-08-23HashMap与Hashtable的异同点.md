---
title: HashMap与Hashtable的异同点
date: 2018-08-23 11:15:38
tags:
- different
categories: java
---

总结一下`HashMap`和`Hashtable`的区别，可能会不全，后面有发现了再补充。

### 并发

这应该是最明显的一点不同了，`HashMap`不是线程安全的，但是`Hashtable`是的，看一下Hashtable中的方法，基本上都加了`synchronized`，但是呢，这种同步实在是太粗糙了，所以在并发的情况下才会推荐使用`ConcurrentHashMap`吧。

### 构造方式

#### 默认容量

在构建相应的实例时，如果没有指定`initialCapacity`，`HashMap`默认指定为16，`Hashtable`默认指定为11：

``` java
//Hashtable默认构造函数
public Hashtable() {
  this(11, 0.75f);
}

/**
 * Constructs an empty <tt>HashMap</tt> with the default initial capacity
 * (16) and the default load factor (0.75).
 */
public HashMap() {
  this.loadFactor = DEFAULT_LOAD_FACTOR; // all other fields defaulted
}
```

#### 创建桶

他们两个实际创建**桶**的时机也是不一样的，HashMap应该是懒加载：

``` java
public Hashtable(int initialCapacity, float loadFactor) {
  if (initialCapacity < 0)
    throw new IllegalArgumentException("Illegal Capacity: "+
                        initialCapacity);
  if (loadFactor <= 0 || Float.isNaN(loadFactor))
    throw new IllegalArgumentException("Illegal Load: "+loadFactor);

  if (initialCapacity==0)
    initialCapacity = 1;
  this.loadFactor = loadFactor;
  table = new Entry<?,?>[initialCapacity];     // 在这里就为桶分配内存了
  threshold = (int)Math.min(initialCapacity * loadFactor, MAX_ARRAY_SIZE + 1);
}

//但是在HashMap的构造函数中，找不到类似的为桶分配内存的命令，
//因为在分配内存是在resize()方法中，这里截取部分
Node<K,V>[] oldTab = table;
int oldCap = (oldTab == null) ? 0 : oldTab.length;    // 由于没有分配内存，所以此时table还是null，因此oldCap == 0
int oldThr = threshold;
int newCap, newThr = 0;
if (oldCap > 0) {
  // ...
}
else if (oldThr > 0)     // 注意如果新建HashMap时指定了initialCapacity，那么会根据这个值初始化 threshold
  newCap = oldThr;
else {     // 这里就是啥都没指定的
  newCap = DEFAULT_INITIAL_CAPACITY;
  newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
}
if (newThr == 0) {    // 确定新阀值
  float ft = (float)newCap * loadFactor;
  newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
       (int)ft : Integer.MAX_VALUE);
}
threshold = newThr;
@SuppressWarnings({"rawtypes","unchecked"})
  Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];     // 呐呐，在这分配内存
table = newTab;     // 我们的table不为null了
```

### hash

`Hashtable`计算元素的hash值是这样的：

``` java
int hash = key.hashCode();
int index = (hash & 0x7FFFFFFF) % tab.length;
```

而`HashMap`就比较精致了：

``` java
static final int hash(Object key) {
  int h;
  return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
}
```

一个是求余，一个是位运算，效率肯定也不一样。

### 结构

虽然从整体上来看，`HashMap`和`Hashtable`都是用链地址法解决冲突，但是1.8的`HashMap`作了优化，当冲突超过一定时，会将链表进行树化。

### 扩容

两个数据结构扩容的方式也不同，`Hashtable`就比较简单了，扩大容量后，把旧table中的点遍历一遍，重新计算hash值采用**头插法**放到新table中；而`HashMap`就不一样了，除了要考虑树的情况，在从旧table放到新table的过程中，是先把旧table中的冲突链表或树，分成两份，放进新table中(具体的可以看这：[https://zero22.top/2018/08/17/HashMap-%E4%B8%80/](https://zero22.top/2018/08/17/HashMap-%E4%B8%80/))。

### 总结

对比一下`HashMap`和`Hashtable`，不得不佩服Josh Bloch、Arthur van Hoff、Neal Gafter、Doug Lea等作者，总是在不断的优化、创新，让我看到这么漂亮的**code**，感谢。 - -