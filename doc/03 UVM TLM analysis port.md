### 0. 心得
- 非兄弟组件通信方便,只需要在需要通信的组件内 分别定义 analysis_port和uvm_analysis_imp_xxport 即可 ,不涉及tlm_fifo
-  使用write 实现,而不是put,get
  
### 1. 基础知识
#### 1. UVM中的analysis端口
##### 1. 区别
- analysis_port（ analysis_export） 与IMP之间的通信是一对多的通信， 而put和get系列端口与相应IMP的通信是一对一的通信, 广播通讯
- 但是对于analysis_port和analysis_export来说， 没有阻塞和非阻塞的概念。因为它本身就是广播所以不存在阻塞和非阻塞
- 一个analysis_port可以和多个IMP相连接进行通信， 但是IMP的类型必须是uvm_analysis_imp， 否则会报错
- 对于analysis_port和analysis_export来说， 只有一种操作： write。 在analysis_imp所在的component， 必须定义一个名字为write的函数。
   - put系列端口， 有put、 try_put、 can_put等操作， -
   - get系列端口， 有get、 try_get和can_get等操作
  
#### 2. 一个component内有多个IMP
#### 1. eg
- 背景: 由于monitor与scoreboard在UVM树中并不是平等的兄妹关系， 其中间还间隔了o_agt， 所以这里有三种连接方式
  -  第一种是直接在env中跨层次引用monitor中的ap
  -  第二种是在agent中声明一个ap并实例化它， 在connect_phase将其与monitor的ap相连， 并可以在env中把agent的ap直接连接到scoreboard的imp
  -  第三种是在agent中声明一个ap， 但是不实例化它， 让其指向monitor中的ap。 在env中可以直接连接agent的ap到scoreboard的imp
~~~
//my_agent 组件
class my_agent extends uvm_agent ;
	uvm_analysis_port #(my_transaction) ap;
…
	function void my_agent::connect_phase(uvm_phase phase);
		ap = mon.ap;
…
	endfunction
endclass

//my_env 组件
function void my_env::connect_phase(uvm_phase phase);
	o_agt.ap.connect(scb.scb_imp);
	…
endfunction
~~~
- 总结:第一种最简单， 但是其层次关系并不好， 第二种稍显麻烦， 第三种既具有明显的层次关系， 同时其实现也较简单
#### 2. 问题: 由于接收到的两路数据应该做不同的处理， 所以这个新的IMP也要有一个write任务与其对应。 但是write只有一个， 怎么办? ---uvm_analysis_imp_dec
my_scoreboard.sv
~~~
`uvm_analysis_imp_decl(_monitor)
`uvm_analysis_imp_decl(_model)
class my_scoreboard extends uvm_scoreboard;
	my_transaction expect_queue[$];

	uvm_analysis_imp_monitor#(my_transaction, my_scoreboard) monitor_imp;
	uvm_analysis_imp_model#(my_transaction, my_scoreboard) model_imp;

	extern function void write_monitor(my_transaction tr);
	extern function void write_model(my_transaction tr);
	extern virtual task main_phase(uvm_phase phase);
endclass
~~~

- 通过宏uvm_analysis_imp_decl声明了两个后缀_monitor和_model。
- UVM会根据这两个后缀定义两个新的IMP类：uvm_analysis_imp_monitor和uvm_analysis_imp_model，并在my_scoreboard中分别实例化这两个类： monitor_imp和model_imp。
- 当与monitor_imp相连接的analysis_port执行write函数时， 会自动调用write_monitor函数，-
- 与model_imp相连接的analysis_port执行write函数时， 会自动调用write_model函数
~~~
function void my_scoreboard::write_model(my_transaction tr);
	expect_queue.push_back(tr);
endfunction

function void my_scoreboard::write_monitor(my_transaction tr);
	my_transaction tmp_tran;
	bit result;
	if(expect_queue.size() > 0) begin
	...
	end
endfunction
~~~

### 2. 扩展
### 3. TLM_FIFO VS TLM anyssic端口
### 4. 传送门
