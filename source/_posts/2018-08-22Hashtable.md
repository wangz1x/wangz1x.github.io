---
title: Hashtable
date: 2018-08-22 11:27:40
tags:
- fail-fast
- Hashtable
categories: Java
---

基本上不会用到了，在官方API中这样写道：

>Unlike the new collection implementations, Hashtable is synchronized. If a thread-safe implementation is not needed, it is recommended to use HashMap in place of Hashtable. If a thread-safe highly-concurrent implementation is desired, then it is recommended to use ConcurrentHashMap in place of Hashtable.

<!--more-->

如果必须需要线程安全，请用HashMap；如果高并发线程安全是必要的，请用ConcurrentHashMap。不过还是来了解一下吧，看看Hashtable为啥被抛弃了。

### put

``` java
public synchronized V put(K key, V value) {
  // Make sure the value is not null
  if (value == null) {
    throw new NullPointerException();
  }

  // Makes sure the key is not already in the hashtable.
  Entry<?,?> tab[] = table;
  int hash = key.hashCode();
  int index = (hash & 0x7FFFFFFF) % tab.length;
  @SuppressWarnings("unchecked")
  Entry<K,V> entry = (Entry<K,V>)tab[index];
  for(; entry != null ; entry = entry.next) {
    if ((entry.hash == hash) && entry.key.equals(key)) {
      V old = entry.value;
      entry.value = value;
      return old;
    }
  }

  addEntry(hash, key, value, index);
  return null;
}
```

从put中我们可以知道下面几点：

 1. value不能为null，其实key也不能为null；
 2. 索引的计算方法 `(hash & 0x7FFFFFFF) % tab.length` ，这个叫做**除留余数法**，用到了取模，可能会影响效率。
 3. 当产生冲突时，用**链地址法**解决冲突，并且采用头插法把新来的插在首位。

当经过上面的步骤还没有处理新来的key-value，就交给`addEntry`

``` java
private void addEntry(int hash, K key, V value, int index) {
  modCount++;

  Entry<?,?> tab[] = table;
  if (count >= threshold) {
    // Rehash the table if the threshold is exceeded
    rehash();

    tab = table;
    hash = key.hashCode();
    index = (hash & 0x7FFFFFFF) % tab.length;
  }

  // Creates the new entry.
  @SuppressWarnings("unchecked")
  Entry<K,V> e = (Entry<K,V>) tab[index];
  tab[index] = new Entry<>(hash, key, value, e);
  count++;
}
```

这个`modCount`后面再说

首先判断hashtable中的键值对的数量是否超过了阀值，超过了要先扩容再重新计算index，否则直接插入。
要注意的是这种情况，在put的过程中，hash冲突了，但是key值不一样，这时候也还是要到`addEntry`中，但是我们看好像并没有把这个新的key-value插入到链表呀，但其实看看这个`new Entry<>(hash, key, value, e)` 就会发现key-value是在这个时候被放到`e`的前边了，还是头插法。

再来继续看`rehash`

``` java
protected void rehash() {
  int oldCapacity = table.length;
  Entry<?,?>[] oldMap = table;

  // overflow-conscious code
  int newCapacity = (oldCapacity << 1) + 1;
  if (newCapacity - MAX_ARRAY_SIZE > 0) {
    if (oldCapacity == MAX_ARRAY_SIZE)
      // Keep running with MAX_ARRAY_SIZE buckets
      return;
    newCapacity = MAX_ARRAY_SIZE;
  }
  Entry<?,?>[] newMap = new Entry<?,?>[newCapacity];

  modCount++;
  threshold = (int)Math.min(newCapacity * loadFactor, MAX_ARRAY_SIZE + 1);
  table = newMap;

  for (int i = oldCapacity ; i-- > 0 ;) {
    for (Entry<K,V> old = (Entry<K,V>)oldMap[i] ; old != null ; ) {
      Entry<K,V> e = old;
      old = old.next;

      int index = (e.hash & 0x7FFFFFFF) % newCapacity;
      e.next = (Entry<K,V>)newMap[index];
      newMap[index] = e;
    }
  }
}
```

逻辑比较简单：
 1.容量扩大一倍加一，最多能有`0x7fffffff-8`个桶
 2.按照新容量重建一个hashtable
 3.计算阀值
 4.把旧table中的点按照新table的长度重新计算索引，放到新table中，采用头插法

### get

很简单，就看看

``` java
public synchronized V get(Object key) {
  Entry<?,?> tab[] = table;
  int hash = key.hashCode();
  int index = (hash & 0x7FFFFFFF) % tab.length;
  for (Entry<?,?> e = tab[index] ; e != null ; e = e.next) {
    if ((e.hash == hash) && e.key.equals(key)) {
      return (V)e.value;
    }
  }
  return null;
}
```

### contains

``` java
//这个其实就是判断是否包含某个value，看下边的containsValue就知道
//判断包含value比判断包含key的代价更高，因为直接判断包含value需要遍历整个hashtable
public synchronized boolean contains(Object value) {
  if (value == null) {
    throw new NullPointerException();
  }

  Entry<?,?> tab[] = table;
  for (int i = tab.length ; i-- > 0 ;) {
    for (Entry<?,?> e = tab[i] ; e != null ; e = e.next) {
      if (e.value.equals(value)) {
        return true;
      }
    }
  }
  return false;
}

public boolean containsValue(Object value) {
  return contains(value);
}

public synchronized boolean containsKey(Object key) {
  Entry<?,?> tab[] = table;
  int hash = key.hashCode();
  int index = (hash & 0x7FFFFFFF) % tab.length;
  for (Entry<?,?> e = tab[index] ; e != null ; e = e.next) {
    if ((e.hash == hash) && e.key.equals(key)) {
      return true;
    }
  }
  return false;
}
```

### forEach

``` java
public synchronized void forEach(BiConsumer<? super K, ? super V> action) {
  Objects.requireNonNull(action);     // explicit check required in case
                    // table is empty.
  final int expectedModCount = modCount;

  Entry<?, ?>[] tab = table;
  for (Entry<?, ?> entry : tab) {
    while (entry != null) {
      action.accept((K)entry.key, (V)entry.value);
      entry = entry.next;

      if (expectedModCount != modCount) {
        throw new ConcurrentModificationException();
      }
    }
  }
}
```

这个方法是jdk1.8新增的，支持lambda表达式，下次要遍历时可以`.`一下看看有没有forEach， 有的话就可以这样遍历了：

``` java
Hashtable<Integer, String> hashtable = new Hashtable<>();

hashtable.put(1, "one");
hashtable.put(0, "two");
hashtable.put(5, "five");
hashtable.put(2, "two");
hashtable.put(100, "hundred");
hashtable.put(55, "fifty five");

hashtable.forEach((key, value) -> System.out.println("key: " + key + " value: " + value));

//output----------------------------------------------
key: 55 value: fifty five
key: 0 value: two
key: 100 value: hundred
key: 1 value: one
key: 2 value: two
key: 5 value: five
```

### other

#### fail-fast

上面看到了一个变量，叫做`modCount`，我理解为**修改次数**，在绝大多数集合或Map中都能看到这个值(至于是不是绝大多数我也不太确定，后面看的多了在作修改)，看一下官方对这个值的解释：

> The number of times this Hashtable has been structurally modified
Structural modifications are those that change the number of entries in
the Hashtable or otherwise modify its internal structure (e.g.,
rehash).  This field is used to make iterators on Collection-views of
the Hashtable fail-fast.  (See ConcurrentModificationException).
  
大概就是当`Hashtable`发生结构变化(比如增删entry、`rehash`等)时，这个值就会自加一表示`Hashtable`被修改了。这个值主要用于`iterator`的`fail-fast`机制，对于该机制`Hashtable`也作了解释：

>if the Hashtable is structurally modified at any time
after the iterator is created, in any way except through the iterator's own
remove method, the iterator will throw a ConcurrentModificationException.
  
当迭代器创建后，任何非迭代器产生的结构变化都会抛出`ConcurrentModificationException`异常，再找找具体的使用吧：

``` java
public synchronized void replaceAll(BiFunction<? super K, ? super V, ? extends V> function) {
  Objects.requireNonNull(function);     // explicit check required in case
                      // table is empty.
  final int expectedModCount = modCount;

  Entry<K, V>[] tab = (Entry<K, V>[])table;
  for (Entry<K, V> entry : tab) {
    while (entry != null) {
      entry.value = Objects.requireNonNull(
        function.apply(entry.key, entry.value));
      entry = entry.next;

      if (expectedModCount != modCount) {
        throw new ConcurrentModificationException();
      }
    }
  }
}
```

其实上边的`forEach`也有用到，来分析一下：

 1. 首先在任何操作之前，记录此时的`modCount`值
 2. 遍历hashtable进行替换操作
 3. 每当替换一个`entry.value`后，都要比较现在的`modCount`和刚在记录的`expectedModCount`是否一致，如果不一致就会抛出异常。

看起来似乎可以保证并发安全? 不！再来看看官方说明：
>Note that the fail-fast behavior of an iterator cannot be guaranteed as it is, generally speaking, impossible to make any hard guarantees in the presence of unsynchronized concurrent modification.
>the fail-fast behavior of iterators should be used only to detect bugs.

`fail-fast`机制只用来检测程序bug！

#### fail-safe

参考[这里](https://www.nowcoder.com/questionTerminal/95e4f9fa513c4ef5bd6344cc3819d3f7?pos=101&mutiTagIds=570&orderByHotValue=1)
除了`fail-fast`，还有另一种机制`fail-safe`，简单说来就是：
>采用安全失败机制的集合容器，在遍历时不是直接在集合内容上访问的，而是先复制原有集合内容，在拷贝的集合上进行遍历。
>缺点：基于拷贝内容的优点是避免了Concurrent Modification Exception，但同样地，迭代器并不能访问到修改后的内容，即：迭代器遍历的是开始遍历那一刻拿到的集合拷贝，在遍历期间原集合发生的修改迭代器是不知道的。
