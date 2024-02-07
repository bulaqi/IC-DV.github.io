### 基础知识

#### 数量类型分类:net和variable
  在Verilog中，由于需要描述不同的硬件结构，数据类型总体分为net和variable两大类。
 
  - net类型设计用于表示导线结构，它不存储状态，只能负责传递驱动级的输出。使用assign关键字连续赋值。虽然assign语句一般被综合成组合逻辑，但net本质还是导线，真正被综合成组合逻辑的是assign右边的逻辑运算表达式。**常见的net类型数据包括wire**、tri、wand和supply0等。

  - variable类型设计用于表示存储结构，它内部存储状态，并在时钟沿到来或异步信号改变等条件触发时改变内部状态。variable类型数据需要使用过程赋值（procedural assignment），即赋值定义在always、initial、task或function语法块中。**reg是最典型的variable类型数据**，但需要说明的是，综合工具可能将reg优化综合成组合逻辑，并不一定是寄存器。常见的variable类型数据包括**reg**、integer、time、real、realtime等。
 
 - 所以总结Verilog wire和reg的区别：
   1. wire表示导线结构，reg表示存储结构。
   2. wire使用assign赋值，reg赋值定义在always、initial、task或function代码块中。
   3. wire赋值综合成组合逻辑，reg可能综合成时序逻辑，也可能综合成组合逻辑。

 - SystemVerilog的logic类型
  SystemVerilog在Verilog基础上新增支持logic数据类型，logic是reg类型的改进，它既可被过程赋值也能被连续赋值，编译器可自动推断logic是reg还是wire。**唯一的限制是logic只允许一个输入，不能被多重驱动**，所以inout类型端口不能定义为logic。不过这个限制也带来了一个好处，由于大部分电路结构本就是单驱动，如果误接了多个驱动，使用logic在编译时会报错，帮助发现bug。**所以单驱动时用logic，多驱动时用wire**

在Jason的博客评论中，Evan还提到一点logic和wire的区别。wire定义时赋值是连续赋值，而logic定义时赋值只是赋初值，并且赋初值是不能被综合的。
~~~
wire mysignal0 = A & B;     // continuous assignment, AND gate
logic mysignal1 = A & B;    // not synthesizable, initializes mysignal1 to the value of A & B at time 0 and then makes no further changes to it.
logic mysignal2;
assign mysignal2 = A & B;   // Continuous assignment, AND gate
~~~
#### 总结
所以总结SystemVerilog logic的使用方法：
- 单驱动时logic可完全替代reg和wire，除了Evan提到的赋初值问题。
- 多驱动时，如inout类型端口，使用wire

### 传送门
1. [SystemVerilog logic、wire、reg数据类型详解](https://zhuanlan.zhihu.com/p/38563777)
