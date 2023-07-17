### 基础知识
#### UVM接口
1. uvm_hdl_check_path 检查给定的HDL路径是否存在。
2. uvm_hdl_deposit 将给定的HDL路径设置为指定的值。
3. uvm_hdl_force 强制给定路径上的值。
4. uvm_hdl_force_time 强制给定路径上的值为指定数量的force_time。
5. uvm_hdl_release_and_read 释放先前使用uvm_hdl_force设置的值。
6. uvm_hdl_release 释放先前使用uvm_hdl_force设置的值。
7. uvm_hdl_read() 获取给定路径处的值。
~~~
//与SV中force语句相对应
import "DPI-C" context function int uvm_hdl_force(
    string path,
    uvm_hdl_data_t value
)

//与SV中release语句相对应   
import "DPI-C" context function int uvm_hdl_release(
    string path
)

//与SV中assign语句相对应   
import "DPI-C" context function int uvm_hdl_deposit(
    string path,
    uvm_hdl_data_t value
)

//用于检查HDL path是否存在
import "DPI-C" context function int uvm_hdl_check_path(
    string path
)

//用于读取HDL path变量的值
import "DPI-C" context function int uvm_hdl_read(
    string path,
    output uvm_hdl_data_t value
)

//用于release然后读取HDL path变量的值    
import "DPI-C" context function int uvm_hdl_release_and_read(
    string path,
    inout uvm_hdl_data_t value
)
~~~
### SV 接口
#### 1. force
#### 2. relese


### UVM 和SV接口 区别
#### 1. 区别
- 从上面这些UVM接口的输入端口类型为字符串就可以知道，这么做的话函数的输入是字符串而不是HDL（hardware description language, 硬件描述语言 ）的层次结构(path)。
- 除此之外，使用uvm_hdl相关后门接口可以在case_lib包在package里访问RTL的信号，而常规SystemVerilog的force则不行，常规的force必须要求case_lib在package之外，即$unit空间。 也就是说，如果case_lib在package里，下面第一行不可行，但是第二行可行，但这有个条件，需要添加编译选项-debug_access+f来支持该功能。
- eg
  ~~~
  force top.DUT.A = 0; //不可行
  uvm_hdl_force("top.DUT.A",0); //可行
  ~~~
说了这么多给个简单的例子吧，大家也可以自己仿真看看结果，参考：
~~~
force top.DUT.A = 4'b1111;
`uvm_info("DEBUG",$sformatf("after normal force A value is %b",top.DUT.A),UVM_NONE)
release top.DUT.A;

begin
    int read_value;
    if(uvm_hdl_check_path("top.DUT.A"))begin
        `uvm_info("DEBUG",
                  $sformatf("uvm_hdl_check_path success, mean HDL path %s exists!","top.DUT.A"),UVM_NONE)
    end
    if(uvm_hdl_deposit("top.DUT.A",4'b0011))begin
        `uvm_info("DEBUG",
                  $sformatf("after uvm deposit, A value is %b",top.DUT.A),UVM_NONE)
    end
    if(uvm_hdl_force("top.DUT.A",4'b1100))begin
        `uvm_info("DEBUG",
                  $sformatf("after uvm force, A value is %b",top.DUT.A),UVM_NONE)
    end   
    if(uvm_hdl_read("top.DUT.A",read_value))begin
        `uvm_info("DEBUG",
                  $sformatf("after uvm force, read_value is %b",read_value),UVM_NONE)
    end  
    if(uvm_hdl_release("top.DUT.A",read_value))begin
        `uvm_info("DEBUG",
                  $sformatf("uvm release success!"),UVM_NONE)
    end
    if(uvm_hdl_read("top.DUT.A",read_value))begin
        `uvm_info("DEBUG",
                  $sformatf("after uvm release, read_value is %b",read_value),UVM_NONE)
    end  
    if(uvm_hdl_force("top.DUT.A",4'b1010))begin
        `uvm_info("DEBUG",
                  $sformatf("after uvm force, A value is %b",top.DUT.A),UVM_NONE)
    end  
    if(uvm_hdl_release_and_read("top.DUT.A",read_value))begin
        `uvm_info("DEBUG",
                  $sformatf("after uvm release, read_value is %b",read_value),UVM_NONE)
    end     
end
~~~
仿真结果为：
~~~
UVM_INFO ...[DEBUG] after normal force A value is 1111
UVM_INFO ...[DEBUG] uvm_hdl_check_path success, mean HDL path top.DUT.A exists!
UVM_INFO ...[DEBUG] after uvm deposit A value is 0011
UVM_INFO ...[DEBUG] after uvm force, A value is 1100
UVM_INFO ...[DEBUG] after uvm force, read_value is 1100
UVM_INFO ...[DEBUG] uvm release success!
UVM_INFO ...[DEBUG] after uvm release, read_value is 1100
UVM_INFO ...[DEBUG] after uvm force, A value is 1010
UVM_INFO ...[DEBUG] after uvm release, read_value is 1100
~~~
#### 2. 注意点:
需要注意的是，release之后，根据release的对象类型的不同，结果也会不同，具体如下：
1. 对于wire来说，release之后值将会立刻被改变为当前其他连线的驱动值。
2. 其他类型则是release之后将会保持之前force的值直到下一次被assign新的值。

### 传输门
1. [UVM及SystemVerilog中的force、deposit及两者的区别](https://zhuanlan.zhihu.com/p/621413134)
2. [UVM HDL后门访问支持例程](https://blog.csdn.net/Michael177/article/details/123413738)
