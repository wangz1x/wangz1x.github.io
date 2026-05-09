---
title: 从0打造亿级流量秒杀项目(一)
date: 2021-08-18 20:36:04
tags:
- miaosha
- springboot
- java
---

### Mybatis Generator

第一次知道有这么个东西，可以用来快速生成模板代码，包括与数据库对应的实体对象(DO)，Mapper接口，以及Mapper.xml配置文件

```xml

<build>
    <plugins>
        <!-- springboot 打包 -->
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>

        <!-- Mybatis Generator -->
        <plugin>
            <groupId>org.mybatis.generator</groupId>
            <artifactId>mybatis-generator-maven-plugin</artifactId>
            <version>1.3.5</version>
            <dependencies>
                <dependency>
                    <groupId>org.mybatis.generator</groupId>
                    <artifactId>mybatis-generator-core</artifactId>
                    <version>1.3.5</version>
                </dependency>
                <dependency>
                    <groupId>mysql</groupId>
                    <artifactId>mysql-connector-java</artifactId>
                    <version>8.0.26</version>
                </dependency>
            </dependencies>
            <executions>
                <execution>
                    <id>Generate MyBatis Artifacts</id>
                    <phase>package</phase>
                    <goals>
                        <goal>generate</goal>
                    </goals>
                </execution>
            </executions>
            <configuration>
                <!-- 输出详细信息? 允许移动生产的文件?-->
                <verbose>true</verbose>
                <!-- 覆盖生成文件 -->
                <overwrite>false</overwrite>
                <!-- 定义配置文件 -->
                <configurationFile>src/main/resources/mybatis-generator.xml</configurationFile>
            </configuration>
        </plugin>
    </plugins>
</build>
```


### 跨域问题

解决: 注解，且需要前端`ajax`请求配合参数设置


### 嵌套实体



### 参数校验

  

### 统一异常处理



### 统一返回值




### 分层模型

每一层都应有对应的模型对象： VO、Model、DO
