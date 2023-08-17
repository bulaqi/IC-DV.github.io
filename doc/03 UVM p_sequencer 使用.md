### 0. 应用背景
- sequence 通过p_sequencer 访问 uvm_component 组件元素, 进而可以访问层次化的访问uvm_component的其他元素
- 原因概述: sequence是从uvm_object拓展而来，它不能访问uvm_component组成的uvm层次结构的，如果非要访问uvm_component就要通过一个媒介，这个媒介就是p_sequencer
- 用于从sequence中访问组件层次结构中的配置信息和其他资源。可以通过调用m_sequencer.get_full_name() 来获取sequencer的完整层次名称

### 1. 基础知识
#### 1. m_sequencer vs  p_sequencer
1. m_sequencer 

~~~
- 可以理解为member_sequencer，隐藏or局部sequencer，。
- 类型是uvm_sequencer_base类型，定义在uvm_sequence_item类中，注意：类型很重要。
- 可以理解为每个sequence中默认都有m_sequencer这一成员变量。
- m_sequencer 是一个指向执行当前sequence的sequencer句柄。
~~~

2. p_sequencer

~~~
可以理解为parent_sequencer，父类sequencer
使用 `uvm_declare_p_sequencer(my_sequencer) 宏声明p_sequencer，宏本质是在当前sequence也就是case0_sequence中声明了一个成员变量p_sequencer。
类型为my_sequencer，定义在case0_sequence中。
p_sequencer是my_sequencer的句柄
~~~

### 2. 过程解析

#### 1. 背景
##### 1. 问题： 如何在case0_sequence的body()任务中得到my_sequencer中的成员变量dmac和smac？ 即在sequence内获取seqence的对象
- 定义一个my_sequencer，内含成员变量dmac和smac。

- 再定义一个case0_sequence，case0_sequence在my_sequencer上启动：case0_sequence.start（my_sequencer）
~~~
class case0_sequence extends uvm_sequence #(my_transaction);
	my_trasaction m_trans;
	`uvm_object_utils(case0_squence)
	...
	
	virtual task body();
	...
	repeat(10) 
		begin
		... //如何得到dmac和smac？
		end
	...
endclass
~~~



##### 2. 思考：

- 所有的sequence都要在sequencer中启动：如case0_sequence.start(my_sequencer)，当sequence启动的时候，m_sequencer 句柄就指向了my_sequencer，若 case0_sequence.start(my_sequencer1)，则此时m_sequencer 句柄指向了my_sequencer1。
- sequence是从uvm_object拓展而来，它不能访问uvm_component组成的uvm层次结构的，如果非要访问uvm_component就要通过一个媒介，这个媒介就是sequencer。
- m_sequencer可作为媒介，用于从sequence中访问组件层次结构中的配置信息和其他资源。可以通过调用m_sequencer.get_full_name() 来获取sequencer的完整层次名称。
- 使用case0_sequence默认的m_sequencer这个媒介获取dmac和smac，代码如下，但是编译错误？
~~~
class case0_sequence extends uvm_sequence #(my_transaction);
	my_trasaction m_trans;
	`uvm_object_utils(case0_squence)
	...
	
	virtual task body();
		...
	repeat(10) 
		begin
		`uvm_do_with(m_trans,{m_trans.dmac==m_sequencer.dmac;
		                      m_trans.smac==m_sequencer.smac;})
		end
	...
endclass
~~~
- 原因是:
1. m_sequencer类型是uvm_sequencer_base(uvm_sequencer的基类)，而不是my_sequencer类型。
2. 解决问题的关键是：将case0_sequence 的m_sequencer类型从uvm_sequencer_base转换成my_sequencer
~~~
class case0_sequence extends uvm_sequence #(my_transaction);
	my_trasaction m_trans;
	`uvm_object_utils(case0_squence)
	...
	
	virtual task body();
		my_sequencer x_sequencer;
		...
		$cast(x_sequencer,m_sequencer);  // 强转
		...
	repeat(10) 
		begin
		`uvm_do_with(m_trans,{m_trans.dmac==x_sequencer.dmac;
		                      m_trans.smac==x_sequencer.smac;})
		end
	...
endclass
~~~
##### 3. 用p_sequencer

到这看起来没有p_sequencer什么事情，那p_sequencer是干啥的？？上诉的做法有点麻烦，UVM提供了强大的内建宏`uvm_declare_p_sequencer(SEQUENCER)来解决这个问题。呈上代码
~~~
class case0_sequence extends uvm_sequence #(my_transaction);
	my_trasaction m_trans;
	`uvm_object_utils(case0_squence)
	`uvm_declare_p_sequencer(my_sequencer) //使用宏定义my_sequencer
	...
	
	virtual task body();
		...
	repeat(10) 
		begin
		`uvm_do_with(m_trans,{m_trans.dmac==p_sequencer.dmac;
		                      m_trans.smac==p_sequencer.smac;})
		end
	...
endclass
~~~

**其实就是将x_sequencer换成了p_sequencer，UVM会自动将m_sequencer通过$cast() 转换成p_sequencer，在pre_body() 之前完成**，等价代码如下：

~~~
class case0_sequence extends uvm_sequence #(my_transaction);
	my_trasaction m_trans;
	`uvm_object_utils(case0_squence)
	...
	
	virtual task body();
		my_sequencer p_sequencer;
		...
		$cast(p_sequencer,m_sequencer);
		...
	repeat(10) 
		begin
		`uvm_do_with(m_trans,{m_trans.dmac==p_sequencer.dmac;
		                      m_trans.smac==p_sequencer.smac;})
		end
	...
endclass
~~~

##### 4.  p_sequencer总结
`uvm_declare_p_sequencer(my_sequencer)宏干了两件事：
1. 声明了一个sequencer类型的句柄p_sequencer
2. 将m_sequencer句柄通过$cast(p_sequencer,m_sequencer)转化为p_sequencer 类型的句柄。

##### 5.  思考问题
p_sequencer为什么理解成parent sequencer？这个问题我也没大整明白，p_sequencer是my_sequencer的句柄，可以理解为m_sequencer的父类是my_sequencer吗？
~~~
$cast(p_sequencer,m_sequencer);//父类传子类用 $cast
~~~
###  4. 注意事项
- `uvm_declare_p_sequencer(my_sequencer) 注册 //使用宏定义my_sequencer
- 使用时候,之间用p_sequencer 可以访问被调的sqr

### 5. 传送门
1. [关于UVM中m_sequencer和p_sequencer的个人理解](https://blog.csdn.net/u011177284/article/details/106274611)
