### 1. 知识点
#### 1. program 与 module
1. 建议：
   - **硬件电路设计**部分放置在 module 中，
   - 将 **测试** 采样部分放置在 program 中。
2. module（硬件盒子）、program（软件盒子）和interface（硬件软件的媒介）的作用和定义它们的初中在于SV需要更清晰的界限来划分硬件域（module）、软件域（program和class）以及中间域（interface）
   - module：硬件域
   - program和class：软件域
   - 中间域：interface
3. program vs  module
- program
  ~~~
  1.  program 看做是软件的“领地”，所以program内不可以出现和硬件行为相关的过程语句和实例，例如 always、module、interface，也不应出现其他program例化语句。
  2. 为了使得program进行类软件的方式**顺序执行**，可以在program内部定义变量，以及发起多个initial块
  3. program内部定义的变量赋值的方式应该采用阻塞赋值（软件方式）
  4. program内部再驱动外部的硬件信号时应该使用非阻塞赋值（硬件方式）
  5. 包含 class 定义、Subroutine 定义、对象实例、initial 块等
  6. 不包含 always 块、module 的实例化、interface 的实例化、program 的实例化
  ~~~
- module
  功能：
  - 用于表示设计块，
  - 但也可以作为验证代码的容器，
  - 以及验证块和设计块之间的互连。
  - module 可以 包括 以下内容：
  ~~~
  class 定义、constant 定义、Subroutine 定义等
  modulss、programs、interfaces的实例化
  procedural 块、generate 块、specify 块等
  ~~~
4. 总结
- 如果为验证环境建立独立的测试盒子，可以考虑采用 program 来帮助消除采样竞争问题以及自动结束测试用例；
- 也可以采用 module 硬盒子的方式，使用 interface clocking 来消除采样竞争问题，使用$stop() 、$finish() 系统方法来显式结束测试用例。

#### 2. class 与 module
1. 数据和方法定义： 二者均可以作为封闭的容器来定义和存储
2. 例化：
   - module: 必须在仿真一开始就确定是否应该被例化，可以通过 generate 来实现设计结构的变化；
   - class: 变量在仿真的任何时段都可以被构造(开辟内存)创建新的对象。
   - 重要区别:按照硬件世界和软件世界区分的观点，
       - 硬件部分必须在仿真一开始就确定下来，即 module 和其内部过程块、变量都应该是静态的 (static) ；
       - 而软件部分，即 class 的部分可以在仿真任何阶段声明并动态创建出新的对象，这正是软件操作更为灵活的地方
3. 封装性：
   - module: 内的变量和方法是对外部公共开放的，
   - class: 类则可以根据需要来确定外部访问的权限是否是默认的公共类型、或者受保护类型 (protected) 还是私有类型 (local)
4. 继承性：
   - module: 没有任何的继承性可言，即无法在原有module的基础上进行新 module 功能的扩展，唯一可支持的方式恐怕只有简单的拷贝和在拷贝的 module 上做修改，
   - class: 而继承性正是类的一大特点

#### 3. class 与 struct
1. 二者本身都可以定义数据成员
2. 类变量在声明之后，需要构造才会构建对象实体，而 struct 在变量声明时已经开辟内存
3. 类除了可以声明数据变量成员，还可以声明方法(function/task)，而 struct 则不能
4. 从根本上讲，struct 仍然是一种数据结构，而 class 则包含了数据成员以及针对这些成员们操作的方法

### 2. 经验
### 3. 传送门
1. [SV中各种区别联系](https://blog.csdn.net/weixin_42493102/article/details/122952867)
2. [模块（module）, 程序块（program）的区别](https://blog.csdn.net/m0_56242485/article/details/123349780)
