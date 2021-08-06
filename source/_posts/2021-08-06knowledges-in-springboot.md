---
title: knowledges in springboot
date: 2021-08-06 11:36:40
tags:
- springboot
---

记录`springboot`中的一些小知识点.

### 配置文件加载

当一个项目中同时存在多个配置文件, 比如`application.properties`, `application.yml`, `application.yaml`, 如果这些文件中有相同的配置项, 比如都配置了`server.port`，但是具体端口配置的不一样，那么最后应用启动时用到的是哪个配置文件中的信息呢?


配置文件的加载顺序为: `yaml---yml---properties`, 而后加载的配置会覆盖先加载的配置，因此最后用到的是`properties`中的端口


如果启动项目时有一些配置项，比如`java -jar demo-app.jar --server.port=7777`，应用启动后的端口就是`7777`，即启动参数会覆盖所有的配置文件中相应的配置。


### 配置文件读取

在配置文件中如果加入了一些自定义的配置, 比如`com.wzx.foo=bar`, 想要在应用中读取到该配置该怎么做呢?


1. 使用`@Value("${com.wzx.foo}")` 注解

```java
@Component
public class MyFoo {

    @Value("${com.wzx.foo}")
    private String foo;

    public String getFoo() {
        return foo;
    }
}

@SpringBootApplication
public class DemoApplication implements CommandLineRunner{

    @Autowired
    private MyFoo myFoo;

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }

    @Override
    public void run(String... args) throws Exception {
        System.out.println("myFoo: " + myFoo.getFoo());
    }
}
```

output：

![控制台输出](myfoo-bar.png)


注意使用这种方式, 即使`bean`未实现`setter`也能起作用。


2. 使用`@ConfigurationProperties(prefix = "com.wzx")`注解

```java
@Component
@ConfigurationProperties(prefix = "com.wzx")
public class MyFoo {

    private String foo;

    public String getFoo() {
        return foo;
    }

    public void setFoo(String foo) {
        this.foo = foo;
    }
}

// DemoApplication 不变
```

output: 一样


注意，使用这种方式需要`bean`实现`setter`方法，否则异常：


![异常](no-setter.png)

