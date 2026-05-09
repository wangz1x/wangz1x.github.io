---
title: 创建其他类中非静态内部类
date: 2020-07-30 18:55:08
tags:
- 内部类
---

```java

public class JHSDB_TestCase {
    class NoStaticTest {}
}

class Outter {
    private void test() {
        JHSDB_TestCase jhsdb_testCase = new JHSDB_TestCase();
        JHSDB_TestCase.NoStaticTest noStaticTest =
                jhsdb_testCase.new NoStaticTest();
    }
}
```

