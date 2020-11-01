---
title: LeetCode213Week
date: 2020-11-01 14:23:52
tags:
- leetcode
- 优先队列
- 排列组合
- 找规律
---

leetcode第213场周赛，四个题目：

- <a href="###能否连接形成数组">能否连接形成数组</a>
- <a href="###统计字典序元音字符串的数目">统计字典序元音字符串的数目</a>
- 可以到达的最远建筑
- 第K条最小指令

<!--more-->

### 能否连接形成数组

[https://leetcode-cn.com/problems/check-array-formation-through-concatenation/](https://leetcode-cn.com/problems/check-array-formation-through-concatenation/)

先给定一个数组target和一个数组片段pieces（即包含很多个数组），这两个玩意中的元素都不带重复的，问能否由pieces，在不改变其各个数组中元素位置情况下（当然数组与数组的位置可以改变），组合成target

由于不存在重复元素，那直接遍历target数组，看pieces中有没有某个片段开头的元素与之等于，相等的话就遍历该片段看该片段是否能完全匹配target这一部分，可以的话就继续，不然就直接gg了。

```java
class Solution {
    public boolean canFormArray(int[] arr, int[][] pieces) {
        boolean[] visited = new boolean[pieces.length];
        int i = 0;
        int j = 0;
        int k = 0;
        for (i = 0; i < arr.length; ) {
            // find arr[i]
            for (j = 0; j < pieces.length; j++) {
                if (visited[j]) continue;
                if (pieces[j][0] == arr[i]) {
                    // visit all ele in pieces[j]
                    visited[j] = true;
                    for (k = 0; k < pieces[j].length; ) {
                        if (pieces[j][k] == arr[i]) {
                            k++;
                            i++;
                        } else {
                            return false;
                        }
                    }
                    // match, and jump to next part
                    break;
                }
            }
            // a loop and no found any piece match arr[i]
            if (j >= pieces.length) return false;
        }
        return true;
    }
}
```

### 统计字典序元音字符串的数目 

[https://leetcode-cn.com/problems/count-sorted-vowel-strings/](https://leetcode-cn.com/problems/count-sorted-vowel-strings/)

假设长度为n时，若a打头，则a后边可以跟所有长度为n-1的串；若e打头，则e后边可以跟所有不以a打头的长度为n-1的串，规律入下图所示：

![fig1](fig1.png)

```java
class Solution {
    public int countVowelStrings(int n) {
        if (n == 0) return 0;
        if (n == 1) return 5;
        int res = 0;
        int[] count = {1,1,1,1,1};
        for (int i = 1; i < n; i ++) {
            count[0] = count[0] + count[1] + count[2] + count[3] + count[4];
            count[1] = count[1] + count[2] + count[3] + count[4];
            count[2] = count[2] + count[3] + count[4];
            count[3] = count[3] + count[4];
            count[4] = count[4];
        }
        return count[0] + count[1] + count[2] + count[3] + count[4];
    }
}
```

### 可以到达的最远建筑

[https://leetcode-cn.com/problems/furthest-building-you-can-reach/](https://leetcode-cn.com/problems/furthest-building-you-can-reach/)

开始试着用dfs，即每当有个槛儿时，分别用砖头和梯子，看谁到的远就用谁，果然超时了。

后来又想，只要把梯子放在遇到的比较高的地方，其他的用砖头就好了，因此就用优先队列把遇到的槛儿都记录下来，而优先队列里边的就用梯子，当梯子用完了，就从队列里边找个最矮的槛换成砖头，如果砖头不够用了，那就不能再前进了（因为只有当梯子没得了才会考虑砖头哇）

```java
class Solution {
    public int furthestBuilding(int[] heights, int bricks, int ladders) {
        if (ladders >= heights.length - 1) return heights.length - 1;
        Queue<Integer> deque = new PriorityQueue<>();

        int i;
        for (i = 1; i < heights.length; i++) {
            if (heights[i] - heights[i - 1] > 0) {
                // use ladders
                deque.add(heights[i] - heights[i - 1]);
                // not enough ladders
                if (deque.size() > ladders) {
                    // replace shortest
                    if (bricks >= deque.peek()) bricks -= deque.poll();
                    else break;
                }
            }
        }
        return i - 1;
    }
}
```

发现一样的思路，按照大佬们的逻辑简化了代码，发现时间和内存都多了一点，不过这样看起来是真的简单，令人愉悦

### 第K条最小指令

[https://leetcode-cn.com/problems/kth-smallest-instructions/](https://leetcode-cn.com/problems/kth-smallest-instructions/)

记`choice[i, j]`为位于`(i, j)`时，到达目的地的线路个数，则`choice[i, j]=choice[i+1, j] + choice[i, j+1]`，那么可以先把最后一排和最后一列初始化为1，然后从右下角开始填满整个二维数组。

可以预见的，往右的优先级要高于往下的优先级（对于字典序来说），因此比较朝右的选择数和K，如果朝右的选择数大于k，就往右走；否则往下走，并且更新k，看它往下的选择中排老几。

其实就是排列组合`C_n^i`（假装latex）。

```java
class Solution {
    public String kthSmallestPath(int[] destination, int k) {
        StringBuilder sb = new StringBuilder(destination[0] + destination[1]);

        int[][] choose = new int[destination[0] + 1][destination[1] + 1];

        for (int i = 0; i < destination[1] + 1; i++) {
            choose[destination[0]][i] = 1;
        }
        for (int i = 0; i < destination[0] + 1; i++) {
            choose[i][destination[1]] = 1;
        }

        for (int i = destination[0] - 1; i >= 0; i--) {
            for (int j = destination[1] - 1; j >= 0; j--) {
                choose[i][j] = choose[i + 1][j] + choose[i][j + 1];
            }
        }

        int i = 0, j = 0;
        while (choose[i][j] != 1) {
            if (choose[i][j+1] >= k) {
                sb.append("H");
                j += 1;
            }
            else {
                sb.append("V");
                k -= choose[i][j+1];
                i += 1;
            }
        }
        while (i++ < destination[0]) sb.append("V");
        while (j++ < destination[1]) sb.append("H");
        return sb.toString();
    }
}
```

### 小结

再困难的题，总有大佬用我想象不到代码量完成。
