---
title: 比synchronized高级的同步结构
date: 2018-09-07 17:23:14
tags:
- CountDownLatch
- CyclicBarrier
categories: java
---

这些同步结构都在`java.util.concurrent`并发包下，这里只看一下基础的用法。

### CountDownLatch

直接用API来介绍吧
>A synchronization aid that allows one or more threads to wait until a set of operations being performed in other threads completes.

简单说来就是让一些线程等待其他线程的操作完成

写一个示例程序:

``` java
package concurrent.countdownlatch;

import java.util.concurrent.CountDownLatch;

public class Test1 {
    public static void main(String[] args) throws InterruptedException {
        CountDownLatch countDownLatch = new CountDownLatch(5);      // 这里一般对应的操作数，这是几，就要有几次countDown操作
        for (int i = 0; i < 5; i ++) {                              // 新建5个线程跑起来
             MyThread myThread = new MyThread(i, countDownLatch);
             myThread.start();
        }
        System.out.println("prepare to wait for other thread finish work...");
        countDownLatch.await();                                     // 要点1

        System.out.println("all threads have finish work!!!");
    }
}

class MyThread extends Thread {

    private int tId;
    private CountDownLatch countDownLatch;

    public MyThread(int tId, CountDownLatch countDownLatch) {
        this.tId = tId;
        this.countDownLatch = countDownLatch;
    }

    @Override
    public void run() {
        try {
            //
            Thread.sleep(1000 * (5-tId));                           // 模拟工作, 不要介意为啥这样写
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("thread i=" + tId + " has finish work");
        countDownLatch.countDown();                                 // 要点2
    }
}
```

附上运行结果:
![CountDownLatch](https://image.zero22.top/countdownlatch.gif)

注意我注释中标记了要点的地方，`CountDownLatch`主要操作方式就是`await/countDown`，在该程序中，`await`在`main`方法中执行，从线程方面来看，就是我们的`main`线程在等待5个`MyThread`线程执行结束，就是这样

### CyclicBarrier

再来看看API中的第一句
>A synchronization aid that allows a set of threads to all wait for each other to reach a common barrier point.
允许一堆线程在`barrier`互相等待

看个示例:

``` java
package concurrent.cyclicbarrier;

import java.util.concurrent.BrokenBarrierException;
import java.util.concurrent.CyclicBarrier;

public class Test2 {
    public static void main(String[] args) {
        CyclicBarrier cyclicBarrier = new CyclicBarrier(5, ()->{            // 要点1
            System.out.println("all thread arrive barrier !! ");
            System.out.println("let's rest a while");
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });

        for(int j = 0; j < 5; j ++) {
            Mythread mythread = new Mythread(cyclicBarrier, j);
            mythread.start();
        }
    }
}

class Mythread extends Thread {
    private CyclicBarrier cyclicBarrier;
    private int j;                                                          // 休息时间
    public Mythread(CyclicBarrier cyclicBarrier, int j) {
        this.cyclicBarrier = cyclicBarrier;
        this.j = j;
    }
    @Override
    public void run() {
        for (int i = 0; i < 3; i ++) {
            try {
                Thread.sleep(j*1000);                                       // 模拟工作
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(Thread.currentThread().getName() + " run i=" + i);
            try {
                cyclicBarrier.await();                                      // 要点2
            } catch (InterruptedException | BrokenBarrierException e) {
                e.printStackTrace();
            }
        }
    }
}
```

运行结果:
![CyclicBarrier](https://image.zero22.top/cyclicbarrier.gif)

先说一下要点1，在创建`CyclicBarrier`对象时可以传递一个`Runnable`对象，这个`Runnable`会在所有的相互等待的线程都到达`barrier`时执行，从运行结果可以看出来，当我们的5个线程都做完了工作执行`await`之后，`Runnable`定义的操作就会运行。

### 区别

这里简单写一下二者的区别

 1. `CountDownLatch`是一次性的, 因为初始化中传递的`count`在`CountDownLatch`中是无法被恢复的; 但是`CyclicBarrier`是可以用多次的，从运行结果我们也可以看出来, 这是因为`CyclicBarrier`内部把最初的值保留在`parties`中, 每次执行减法的是它的拷贝`count`, 当`CyclicBarrier`运行完一轮后, 通常会自动调用`nextGeneration`方法, 在该方法内部又把`parties`赋值给`count`了
 2. 逻辑上来讲, `CountDownLatch`是让A组线程等待B组线程全部执行完, 然后A组线程继续做该做的; `CyclicBarrier`是A组线程中的每个线程都做一些事到达`barrier`, 即进入等待状态后, `CyclicBarrier`可以做个总结之类的, 然后A组线程中的每一个又开始继续做事, 这样循环下去