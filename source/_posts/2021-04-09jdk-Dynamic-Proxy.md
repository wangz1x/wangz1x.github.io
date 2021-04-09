---
title: jdk Dynamic Proxy
date: 2021-04-09 11:05:53
tags:
- java
- jdk
- 动态代理
---

## jdk动态代理

使用jdk提供的动态代理技术，主要包含以下几个步骤：

1. 创建服务接口
2. 实现服务接口，称为服务类，作为被代理类
3. 实现`InvocationHandler`接口，可以通过构造函数的形式，将被代理类传进去
   - 该接口主要需要实现`invoke(Object proxy, Method method, Object[] args)`方法，其中`proxy`为生成的代理对象，`method`为代理对象调用的方法(在使用时)，`args`为方法参数
   - 在实现该方法时，可以通过传进来的被代理类对象，调用被代理类的原生方法，在前后可以做增强操作
4. 调用`Proxy.newProxyInstance(ClassLoader loader, Class<?>[] interfaces, InvocationHandler h)`方法
   - `loader` 指定生产代理类时的类加载器
   - `interfaces` 指定代理类实现的接口
   - `h` 上边自定义的`InvocationHandler`实现类

这样就得到了一个代理类了，在调用代理类的方法时，实际上执行的是`InvocationHander`的`invoke`方法。

## 限制

`jdk`提供的动态代理只能代理，实现了接口的类；当代理一个没有实现接口的类的时候，得到的代理对象其实是没用的。

## 从源码看代理过程

1. 看`Proxy.newProxyInstance`方法

   ```java
   public static Object newProxyInstance(ClassLoader loader,
                                         Class<?>[] interfaces,
                                         InvocationHandler h)
       throws IllegalArgumentException
   {
       Objects.requireNonNull(h);
   
       final Class<?>[] intfs = interfaces.clone();
       // 权限检查 ...
   
       /*
            * Look up or generate the designated proxy class.
            * !!!!!!  查找或者生成代理类， 注意是 Class  !!!!!!
            */
       Class<?> cl = getProxyClass0(loader, intfs);
   
       /*
            * Invoke its constructor with the designated invocation handler.
            */
       try {
           if (sm != null) {
               checkNewProxyPermission(Reflection.getCallerClass(), cl);
           }
           // 获取生成代理类的，参数类型为 InvocationHandler 的构造方法
           final Constructor<?> cons = cl.getConstructor(constructorParams);
           final InvocationHandler ih = h;
           // 设置构造方法可访问
           // ...
   
           // 通过该构造方法创建一个代理对象
           // newProxyInstance方法中的InvocationHander参数,其实是该代理对象的一个参数
           return cons.newInstance(new Object[]{h});
       }
       // ...
   }
   ```

   该方法中，最重要的就是`Class<?> cl = getProxyClass0(loader, intfs);` 通过这个方法调用，就得到了代理对象类了，因此下一步看这个

2. `getProxyClass0`方法

   ```java
   private static Class<?> getProxyClass0(ClassLoader loader,
                                          Class<?>... interfaces) {
       if (interfaces.length > 65535) {
           throw new IllegalArgumentException("interface limit exceeded");
       }
   
       // If the proxy class defined by the given loader implementing
       // the given interfaces exists, this will simply return the cached copy;
       // otherwise, it will create the proxy class via the ProxyClassFactory
       return proxyClassCache.get(loader, interfaces);
   }
   ```

   根据注释得知，当该缓存中不存在时，会通过`ProxyClassFactory`创建代理类，而这个`ProxyClassFactory`类是`Proxy`类的静态内部类，直接去看这个类

3. `ProxyClassFactory`类

   ```java
   private static final class ProxyClassFactory
       implements BiFunction<ClassLoader, Class<?>[], Class<?>>
   {
       // prefix for all proxy class names
       private static final String proxyClassNamePrefix = "$Proxy";
   
       // next number to use for generation of unique proxy class names
       private static final AtomicLong nextUniqueNumber = new AtomicLong();
   
       @Override
       public Class<?> apply(ClassLoader loader, Class<?>[] interfaces) {
   
           Map<Class<?>, Boolean> interfaceSet = new IdentityHashMap<>(interfaces.length);
           for (Class<?> intf : interfaces) {
               // 对待实现接口的一系列验证
               // 确认类加载器解析该接口的到的名字一致
               // 确认该接口确实是接口对象
               // 确认接口没有重复的
           }
   
           String proxyPkg = null;     // package to define proxy class in
           int accessFlags = Modifier.PUBLIC | Modifier.FINAL;
   
           /*
                * Record the package of a non-public proxy interface so that the
                * proxy class will be defined in the same package.  Verify that
                * all non-public proxy interfaces are in the same package.
                */
           for (Class<?> intf : interfaces) {
   		    // 确认所有的 非公有 接口，都在同一个包下，因为最终生成的代理对象会定义在
                // 和 非公有 接口相同的包下，如果有多个，就不晓得最后要放哪了 
           }
   
           if (proxyPkg == null) {
               // if no non-public proxy interfaces, use com.sun.proxy package
               proxyPkg = ReflectUtil.PROXY_PACKAGE + ".";
           }
   
   	    // 生成代理对象的名字，一般匿名内部类的名字也含有$
           long num = nextUniqueNumber.getAndIncrement();
           // jdk1.8 中就是 com.sun.proxy.$Proxynum
           String proxyName = proxyPkg + proxyClassNamePrefix + num;
   
   	    // 生成具体的 代理类的 class 文件
           byte[] proxyClassFile = ProxyGenerator.generateProxyClass(
               proxyName, interfaces, accessFlags);
           try {
               return defineClass0(loader, proxyName,
                                   proxyClassFile, 0, proxyClassFile.length);
           } catch (ClassFormatError e) {
   		   // invalid aspect of the arguments supplied to the proxy
               // class creation (such as virtual machine limitations exceeded).
               throw new IllegalArgumentException(e.toString());
           }
       }
   }
   ```

   该类实现了一个函数式接口(简单理解为只包含一个抽象方法，会加上注解`@FunctionalInterface`)，其`apply`方法，会在上一步缓存中没找到该代理对象时调用。该类中的`apply`方法中最重要的就是`byte[] proxyClassFile = ProxyGenerator.generateProxyClass(proxyName, interfaces, accessFlags);`这一句，看看

4. `ProxyGenerator.generateProxyClass`方法

   ```java
    public static byte[] generateProxyClass(final String name,
                                            Class<?>[] interfaces,
                                            int accessFlags)
    {
        ProxyGenerator gen = new ProxyGenerator(name, interfaces, accessFlags);
        final byte[] classFile = gen.generateClassFile();
   
        if (saveGeneratedFiles) {
            // 保存class文件
        }
   
        return classFile;
    }
   ```

   在下一步，通过`gen.generateClassFile()`方法就得到字节码文件了！！！！

5. `generateClassFile`方法

   ``` java
    private byte[] generateClassFile() {
   
        // 为接口中的方法提供代理
        for (Class<?> intf : interfaces) {
            for (Method m : intf.getMethods()) {
                addProxyMethod(m, intf);
            }
        }
   
        try {
            // 提供构造方法
            methods.add(generateConstructor());        
   
            // ...
   
        }
        // ...
   
        /* ============================================================
         * Step 3: Write the final class file.
         */
        // ...
        try {
            // ... 父类: "java/lang/reflect/Proxy"
            dout.writeShort(cp.getClass(superclassName));
            // ...
        }
   
        return bout.toByteArray();
    }
   ```

   通过该方法就可以知道，代理类是`Proxy`的子类!!!

有上述可知，如果某个类没有实现接口，那么最终代理出来的类完全是和该类没有关系的，是个无用的代理类；但是如果实现了接口，那么代理类中就会有该接口的方法，在使用该代理类时，可以通过转化为相应的接口（多态）而代替原被代理类。



