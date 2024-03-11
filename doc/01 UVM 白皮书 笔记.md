### 1. 基础知识
#### 1. 简单的验证平台
1. uvm_info宏。 3个参数， 第一个参数是字符串， 用于把打印的信息归类； 第二个参数也是字符串， 是具体需要打印的信息； 第三个参数则是冗余级别。
2. 在SystemVerilog中使用interface来连接验证平台与DUT的端口。
3. 为my_driver是一个类， 在类中不能使用上述方式声明一个interface， 只有在类似top_tb这样的模块（ module） 中才可以。 在类中使用的是virtual interface：
4. UVM通过run_test语句实例化了一个脱离了top_tb层次结构的实例， 建立了一个新的层次结构uvm_test_top
   - tb_top 是硬件世界的抽象的，module类型
   - uvm_test_top ，是软件层次的抽象

### 2. 经验

### 3. 传送门
