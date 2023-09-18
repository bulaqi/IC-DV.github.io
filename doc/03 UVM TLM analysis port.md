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
- 总结:第一种最简单， 但是其层次关系并不好， 第二种稍显麻烦， 第三种既具有明显的层次关系， 同时其实现也较简单
#### 2. 问题: 由于接收到的两路数据应该做不同的处理， 所以这个新的IMP也要有一个write任务与其对应。 但是write只有一个， 怎么办? ---uvm_analysis_imp_dec

~~~
文件： src/ch4/section4.3/4.3.3/my_scoreboard.sv
4 `uvm_analysis_imp_decl(_monitor)
5 `uvm_analysis_imp_decl(_model)
6 class my_scoreboard extends uvm_scoreboard;
7 my_transaction expect_queue[$];
8 9
uvm_analysis_imp_monitor#(my_transaction, my_scoreboard) monitor_imp;
10 uvm_analysis_imp_model#(my_transaction, my_scoreboard) model_imp;
…
15 extern function void write_monitor(my_transaction tr);
16 extern function void write_model(my_transaction tr);
17 extern virtual task main_phase(uvm_phase phase);
29918 endclass
~~~


### 2. 扩展
### 3. TLM_FIFO VS TLM anyssic端口
### 4. 传送门
