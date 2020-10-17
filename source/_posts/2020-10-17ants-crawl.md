---
title: ants crawl
date: 2020-10-17 15:05:37
tags: 
- beautyOfProgramming
---

    一根细杆上有几只蚂蚁，杆子太细了以致于不能同时通过两只蚂蚁，开始时，蚂蚁的头朝向是随机的，只会朝前走或掉头，但不会后退。当任意两只蚂蚁碰头时，他们会同时调头朝反方向走，假设蚂蚁们每秒可以走1cm，求所有蚂蚁都离开木杆的最长和最短时间。

<!--more-->

由于蚂蚁们的速度是一样的，当两个蚂蚁相遇掉头时，可以转化为互换位置，如下图所示：

![change positions](fig1.png)

虽然蚂蚁不一样了，但是需要的所有的蚂蚁离开木杆的时间，这样转换对于最终的结果是没有影响的。

```java
import java.util.Arrays;
public class Beauty0407 {
    public static void main(String[] args) {
        int length = 27;
        int[] antPos = {3,7,11,17,23};
        System.out.println("min-max:" + Arrays.toString(calTime(length, antPos)));
    }

    public static int[] calTime(int length, int[] antPos) {
        // min time, max time
        int[] times = {0, 0};

        int currentMin;
        int currentMax;

        for (int antPo : antPos) {
            if (antPo < (length >> 1)) {         // left part
                currentMax = length - antPo;
            } else {
                currentMax = antPo;               // right part
            }

            currentMin = length - currentMax;         // reverse

            if (times[1] < currentMax) {
                times[1] = currentMax;
            }
            if (times[0] < currentMin) {      // 这个地方原书有点问题？
                times[0] = currentMin;        // 应该是计算最小值中的最大值
            }
        }
        return times;
    }
}
```

### 扩展1

    第i个蚂蚁，什么时候走出木杆？

引入一个结论：

    假设初始时一共N个蚂蚁，朝左的有a只，朝右的有N-a只，最终经过数次碰撞后，初始情况下从左数a只蚂蚁会从左边掉落，从右数N-a只蚂蚁会从右掉落

先考虑最简单的情况，比如只有两个蚂蚁的时候：

![two ants](fig2.png)

黑蚂蚁朝右边走，白蚂蚁朝左边走，`1s`后俩相遇：

![meet](fig3.png)

然后两蚂蚁掉头，一直走到木杆尽头：

![arrive at end](fig4.png)

经过统计后，黑蚂蚁用时`3s`（先右`1s`，后左`2s`），白蚂蚁用时`4s`（先左`1s`，后右`3s`）。

在这种简单的情况下， 很容易发现由于两蚂蚁速度是相同的，在相遇时，两只蚂蚁走过的距离是相同的，而后黑白蚂蚁又分别掉头，可以看出黑蚂蚁走过的路程起始是白蚂蚁往左走到尽头需要的距离，而白蚂蚁走过的路程，又是黑蚂蚁往右走到尽头的距离。

在考虑三个蚂蚁的情况：

![](fig5.png)

![](fig6.png)

![](fig7.png)

黑蚂蚁走了5格，白蚂蚁走了6格，灰蚂蚁走了4格

对比初始状态：

- 灰蚂蚁走过的路，正好是从右开始数，第一个朝右的白蚂蚁距离右端的距离
- 白蚂蚁走过的路，正好是从右开始数，第二个朝右的黑蚂蚁距离右端的距离
- 黑蚂蚁走过的路，正好是从左开始数，第一个朝左的灰蚂蚁距离左端的距离

推论：

    当i<=N-a时，说明蚂蚁i最终要掉左边，那么蚂蚁i走过的路程为从左往右数，第i个朝左的蚂蚁距离左端的距离；当i>N-a时，说明蚂蚁i最终要掉右边，那么蚂蚁i走过的路程为从右往左数，第N-i+1个朝右的蚂蚁距离右端的距离

但要如何证明这个结论呢

### 扩展2

    蚂蚁一共会碰撞多少次？

需要注意的是，一共的碰撞次数并不是所有蚂蚁碰撞次数之和，因为这样会重复计算碰撞，可以只选朝左（右）的蚂蚁作为计算单位，看他们左（右）边，朝右（左）的蚂蚁个数，就是该蚂蚁碰撞次数，这样累加标准方向的蚂蚁碰撞次数即为总的碰撞次数。





