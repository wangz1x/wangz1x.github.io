---
title: HashMap如何产生环
date: 2018-07-31 15:22:26
tags:
- HashMap
---

HashMap本身不是线程安全的，所以高并发的情况下不应该使用HashMap，但是这里还是看了一下HashMap可能会产生的问题及其原因。这里讨论的主要是jdk1.7版本的HashMap。

<!-- more -->

### 正常情况下HashMap

当HashMap中的元素超过其阀值时，HashMap要进行扩容，进行resize()操作, 下边的是jdk1.7的实现

``` java
void transfer(Entry[] newTable) {  
    Entry[] src = table;                   //src引用了旧的Entry数组  
    int newCapacity = newTable.length;  
    for (int j = 0; j < src.length; j++) { //遍历旧的Entry数组  
        Entry<K, V> e = src[j];             //取得旧Entry数组的每个元素  
        if (e != null) {  
            src[j] = null;//释放旧Entry数组的对象引用（for循环后，旧的Entry数组不再引用任何对象）  
            do {  
                Entry<K, V> next = e.next;  
                int i = indexFor(e.hash, newCapacity); //！！重新计算每个元素在数组中的位置  
                e.next = newTable[i]; //标记[1]  
                newTable[i] = e;      //将元素放在数组上  
                e = next;             //访问下一个Entry链上的元素  
            } while (e != null);  
        }  
    }  
}  
```

单线程下的resize()
![enter description here](fig1.gif)
接下来进行resize()操作，首先e指向A，next指向B，然后把e放到新的HashMap中
![enter description here](fig2.gif)
结束这一次迭代时把e指向B
就这样循环的把每一个Entry都放到新的HashMap中
![enter description here](fig3.gif)
最终变成这样：
![enter description here](fig4.gif)
**注意while循环的结束条件为 e==null**

### 并发下的HashMap
假设有两个线程对上边的HashMap进行操作，在他们运行时，都知道要进行resize()，首先是线程1：
![enter description here](fig5.gif)
刚把e和next赋值，cpu就被线程2抢走了，而且线程2还比较厉害，一直把resize()完成才退出，那么线程2结束时我们的HashMap就变成这样了：
![enter description here](fig6.gif)
**这里线程2对HashMap的操作会影响线程1中的e和next，因为操作的都是同一块内存**
然后线程1继续执行，但是他不知道e和next的位置已经发生了变化，甚至不知道他已经不用再resize()了，需要注意的是，在resize()过程中，新表在建立过程中会把旧表中的Entry都置为null，但是线程1可不管那么多，他只知道e和next还指向内存块，他还要进行resize().

然后线程1在线程2建立的新表的基础上继续resize()，要注意的是，此时线程1在循环之前就把他的新表建立了，线程1继续执行的效果如下
![enter description here](fig7.gif)
把A取出放入新表中，然后e指向next即B，注意此时B的next为A，然后新一轮迭代中

``` java
 next = e.next
```

所以next指向了A
![enter description here](fig8.gif)

下一轮迭代中，e指向next即A，next指向null，然后用头插法把A插到头，结果就变成这样了！！
![enter description here](fig9.gif)

虽然建表的过程就此结束了，但是新表中含有了环！！那么下次只要有查询的需求并且查到了这个环，那么就会一直查下去造成死循环！

------

上边的图参考自其他的`blog`，现在再看有些复杂了，重新画下：

1. 首先是线程1过来想要`rehash()`，刚标好`e`和`next`:

   ![](fig10.png)



2. 线程2抢占了线程1，也要操作这个`HashMap`，并且也需要`rehash()`，首先一点，`HashMap`是个对象，放在堆中，各个线程访问的都是一样：

   ![](fig11.png)

3. 线程2执行完`rehash()`后，又到线程1接着跑，但是此时线程1不知道别的线程已经完成了`rehash()`，接着之前的工作，此时线程1之前做的标记还☞着原本的节点：

   ![](fig12.png)

   采用头插法将`A:3`插到了前边，且`A:3`.`next`指向了`B:7`，需要注意的是`B:7`.`next`由于线程2的修改指向了`A:3`，此时环就形成了。

### 总结

总的说来，resize()会产生环主要是把元素放到新桶中用的头插法，在1.8中已经改进了，并且1.8一般不会再产生环了。


### 参考 

[https://mailinator.blogspot.com/2009/06/beautiful-race-condition.html](https://mailinator.blogspot.com/2009/06/beautiful-race-condition.html)
