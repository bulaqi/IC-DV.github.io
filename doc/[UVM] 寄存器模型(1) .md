### 1. 基础知识
#### 1. 背景
1. 框图
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/25165f5b-2366-4aa8-b5e8-c5de11c05f19)
2. 寄存器模型RAL(RAL, register abstract layer)是一组高度抽象的类,用来对DUT中具有地址映射的寄存器和存储器进行建模;
3. 寄存器模型,要能模拟任意数量的寄存器域操作、副作用以及不同寄存器间的交互作用.

#### 2. 为什么要寄存器?
1)寄存器建模要做的事情就是在软件的世界里面复刻RTL中的寄存器.既然是面向软件世界做的事情,自然就是为软件所用,要么方便软件观测，要么方便软件使用。这里的软件指的是整个验证环境所构造出来的面向对象的世界。有了寄存器模型，软件世界中的参考模型（reference model）可以很方便的获取到当前RTL的功能配置和状态，我们也可以很方便的收集到对寄存器各个域段甚至位的测试覆盖情况等等。


### 2. 注意事项
### 3. 传送门
1. [reg model1-简介1](https://www.cnblogs.com/csjt/category/2102623.html)
2. [reg model1-构建](https://www.cnblogs.com/csjt/category/2102624.html)
3. [reg model1-集成](https://www.cnblogs.com/csjt/category/2102625.html)
4. [reg model1-使用](https://www.cnblogs.com/csjt/category/2102626.html)
