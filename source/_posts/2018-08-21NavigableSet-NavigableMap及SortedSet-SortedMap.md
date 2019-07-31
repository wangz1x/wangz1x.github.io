---
title: NavigableMap/NavigableSet
date: 2018-08-21 14:56:44

categories: Java
---

navigation
英 [ˌnævɪˈgeɪʃn] 美[ˌnævɪˈɡeʃən]
noun
[U]
导航；领航
the skill or the process of planning a route for a ship or other vehicle and taking it there
<!--more-->

前边大概看了 TreeMap和TreeSet，更多的细节今后有需求在研究吧，再来看看他们分别实现的接口NavigableSet/NavigableMap，他们分别继承了SortedSet/SortedMap。

## NavigableMap

其中主要的方法都和其名称相符，即导航，查找和指定目标最接近的值，或是大于，或是小于；主要分为两类，找key或者找Entry：

``` java
//返回key值大于或等于指定key的Entry或Key
Map.Entry<K,V> ceilingEntry(K key);
K ceilingKey(K key);
```

``` java
//小于等于的
Map.Entry<K,V> floorEntry(K key);
K floorKey(K key);
```

``` java
//不包括等于
Map.Entry<K,V> lowerEntry(K key);
K lowerKey(K key);
Map.Entry<K,V> higherEntry(K key);
K higherKey(K key);
```

``` java
NavigableSet<K> descendingKeySet();
NavigableMap<K,V> descendingMap();
```

返回按照key值降序的集合；返回的集合和原集合是相互联系的(The descending map is backed by this map)，修改任一集合都会对另外一个集合产生影响；用迭代器遍历集合的同时修改集合，那么遍历的结果是不确定的。下面写几个例子：

``` java
public void testDesc() {
  NavigableMap<Integer, String> map = new TreeMap<>();
  map.put(1,"one");
  map.put(-1, "negative one");
  map.put(56, "fifty six");
  map.put(9, "nine");
  map.put(0, "zero");
  map.put(20, "twenty");

  System.out.println("before desc---------------------");
  for (Map.Entry<Integer,String> ele: map.entrySet()
      ) {
    System.out.println(ele.getKey() + " " + ele.getValue());
  }

  NavigableMap<Integer, String> descMap = map.descendingMap();
  System.out.println("after desc-----------------------");
  for (Map.Entry<Integer,String> ele: descMap.entrySet()
  ) {
    System.out.println(ele.getKey() + " " + ele.getValue());
  }

  descMap.put(100, "one hundred");
  System.out.println("after desc put-------------------");
  for (Map.Entry<Integer,String> ele: map.entrySet()
  ) {
    System.out.println(ele.getKey() + " " + ele.getValue());
  }
}

result：
before desc---------------------
-1 negative one
0 zero
1 one
9 nine
20 twenty
56 fifty six
after desc-----------------------
56 fifty six
20 twenty
9 nine
1 one
0 zero
-1 negative one
after desc put-------------------
-1 negative one
0 zero
1 one
9 nine
20 twenty
56 fifty six
100 one hundred
```

当我在逆序集合中插入新Entry后，在遍历原来的map也打印了新加入的Entry，所以是相互影响的。

``` java
//返回key值小于toKey的Entry组成的Map，也是相互关联的，需要注意的是，在headMap中新增Entry时，新Entry的key值同样不能大于toKey，否则会抛出异常；inclusive用来表示是否包括toKey
NavigableMap<K,V> headMap(K toKey, boolean inclusive);
//对应于headMap，返回大于fromKey的
NavigableMap<K,V> tailMap(K fromKey, boolean inclusive);
```

突然感觉没有写的必要？

## NavigableSet

set中的操作基本上就是map中对于key的操作，下面放一些方法：

``` java
E lower(E e);
E floor(E e);
E ceiling(E e);
E higher(E e);
NavigableSet<E> descendingSet();
NavigableSet<E> headSet(E toElement, boolean inclusive);
NavigableSet<E> tailSet(E fromElement, boolean inclusive);
```

唯一有点区别的就是Set中多了迭代器iterator，毕竟Collection继承了Iterator

``` java
Iterator<E> iterator();
Iterator<E> descendingIterator();
```

至于他们的父类Sorted一族也是接口，没什么好看的。在jdk1.8中，为集合新增了Spliterator(并行迭代器?)这个玩意，后边再看吧 - -
