### 1. 知识点
#### 1. SystemVerilog仅使用类型的   名称   来确定类的类型等效性。例如，假设我下面有这两个类定义A和B：
   ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/ac294ee9-fc40-4f46-a16c-8d8238519b98)

#### 2. SystemVerilog认为这两个类定义是不相等的类型，因为它们的名称不同，即使它们的内容或类主体是相同的。
- 类的名称不仅包括简单名称A和B，名称还包括定义的声明范围。
- 当你在package中声明一个类时，package名称将成为该类名称的前缀 <br />
     ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/ec2a2ed7-dd00-41f8-b643-ab0ced7a3628)
- eg:
     1. 不兼容举例，有A类的两个定义，一个定义为P::A，另一个定义为Q::A。而且变量P::a1和Q::a1是类型不兼容的，引用了两个不同的A类。使用包含文件重写以上示例将导致相同的情况，即还是两个不兼容的类定义。 <br />
     ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/6d422653-30c9-48cc-a7dc-41d5c843d7ac) <br>
     2. 问题： A 类没有包含在package中, 在将A类包含在每个package中之后，将得到A类的两个定义，因为使用include只是在文件中剪切和粘贴文本的快捷方式,所以结果毫无疑问与图2一样

#### 3.将功能类用pack 封装，然后从包中导入名称不会重复文本。这样就可以从另一个软件包中看到该名称，而无需复制定义。
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/56a6947c-57b5-4839-81f6-2c8129b04325)
- 类A在package P中声明，并且仅在package P中声明。
- 变量R::a1和S::a1是类型兼容的，因为它们都是P::A类型

### 2. 总结
- include将文件中所有文本原样插入包含的文件中。这是一个预处理语句，`include在import之前执行。主要作用就是在package中平铺其他文件，从而在编译时能够将多个文件中定义的类置于这个包中，形成一种逻辑上的包含关系。
- import不会复制文本内容。但是import可package中内容引入import语句所在的作用域，以帮助编译器能够识别被引用的类，并共享数据。
    


### 3.本质
- SystemVerilog中的package提供了保存和共享数据、参数和方法的机制，可以在多个module、class、program和interface中重用。
- package中声明的内容都属于这个package作用域（scope）。在使用这些内容时，需要先import这个package，然后通过package引用。

### 4. 实战使用
1. package的封装应用：在package内，前面是import 所依赖library，比如“import uvm_pkg::*”，紧接着即使include 自定义的文件，通常会把本目录下相关的文件都include进来，比如virtual sequence文件，testcase文件。
2. package外的include文件：这种用法在我们现在的环境中使用不多，目前最常用的是include interface文件，比如，在xxx_env_pkg文件的最开头，include "xxx_if.sv"
3. SV 文件只include 其他sv文件： 为了文件管理方法，将部分code写到一个单独的文件中，然后在主文件中直接include进来，相当于将多个文件合并成一个文件。比如，一个subsys要用到很多API，而这些API共有A, B，C三类，分别由3个人完成，则可以写成api_a.sv, api_b.sv, api_c.sv，在l0_basic_vseq.sv中，将这三个文件include进来。

### 3. 传送门
1.  [SV中import和include的区别](https://blog.csdn.net/Andy_ICer/article/details/115679314)
