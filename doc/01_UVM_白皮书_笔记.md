### 1. 基础知识
#### 1. 简单的验证平台
1. uvm_info宏。 3个参数， 第一个参数是字符串， 用于把打印的信息归类； 第二个参数也是字符串， 是具体需要打印的信息； 第三个参数则是冗余级别。
2. 在SystemVerilog中使用interface来连接验证平台与DUT的端口。
3. 为my_driver是一个类， 在类中不能使用上述方式声明一个interface， 只有在类似top_tb这样的模块（ module） 中才可以。 在类中使用的是virtual interface：
4. UVM通过run_test语句实例化了一个脱离了top_tb层次结构的实例， 建立了一个新的层次结构uvm_test_top
   - tb_top 是硬件世界的抽象的，module类型
   - uvm_test_top ，是软件层次的抽象
5. config_db 跨越硬件和软件之间传递数量,
   - 概述： set操作， 读者可以简单地理解成是“寄信”， 而get则相当于是“收信”
   - 应用， 在top_tb 将interface 传给 软件世界
   - 理解：
     - config_db的set和get函数都有四个参数， 这两个函数的第三个参数必须完全一致。
     - set函数的第四个参数表示要将哪个interface通过config_db传递给my_driver，
     - get函数的第四个参数表示把得到的interface传递给哪个my_driver的成员变量。
     - set函数的第二个参数表示的是路径索引， 即在2.2.1节介绍uvm_info宏时提及的路径索引。 在top_tb中通过run_test创建了一个my_driver的实例， 实例的名字是是uvm_test_top： UVM通过run_test语句创建一个名字为uvm_test_top的实例 【注意】。
   - eg
     ~~~
     文件： src/ch2/section2.2/2.2.4/top_tb.sv
      44 initial begin
      45 uvm_config_db#(virtual my_if)::set(null, "uvm_test_top", "vif", input_if);   // 注意：第二个参数是实例名，不是类名
      46 end
     ~~~
     
     ~~~
     文件： src/ch2/section2.2/2.2.4/my_driver.sv
      13 virtual function void build_phase(uvm_phase phase);
      14 super.build_phase(phase);
      15 `uvm_info("my_driver", "build_phase is called", UVM_LOW);
      16 if(!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
      17 `uvm_fatal("my_driver", "virtual interface must be set for vif!!!")
      18 endfunction
     ~~~
   - 备注：是在top_tb set, 软件时间get
   
6. run_test创建了一个的实例，不论传的是什么参数，实际的实例的名字是是uvm_test_top

### 2. 经验

### 3. 传送门
