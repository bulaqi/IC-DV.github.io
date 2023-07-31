### 0. 概述
   寄存器模型主要功能分为4部分，分别是：
-  1.寄存器模型ral文件
-  2.base_tc中寄存器模式的例化,以及工作模式设置
-  3.env中，组件的连接
-  4.寄存器模型的时序的组件
-  5.寄存器模型的调用
   
### 1.    寄存器模型ral文件
该文件一般是由脚本生成
### 2.   base_tc中寄存器模式的例化,以及工作模式设置
#### 1. 声明:
~~~
reg_model  rm;
~~~

#### 2. build_phase中设置
在实例化后reg_model还要做四件事： 
1. 第一是调用configure函数， 其第一个参数是parent block， 由于是最顶层的reg_block， 因此填写null，第二个参数是后门访问路径， 请参考7.3节， 这里传入一个空的字符串。
2. 第二是调用build函数， 将所有的寄存器实例化。
3. 第三是调用lock_model函数， 调用此函数后， reg_model中就不能再加入新的寄存器了。
4. 第四是调用reset函数， 如果不调用此函数， 那么reg_model中所有寄存器的值都是0， 调用此函数后， 所有寄存器的值都将变为设置的复位值
~~~
   rm = reg_model::type_id::create("rm", this);
   rm.configure(null, "");
   rm.build();
   rm.lock_model();
   rm.reset();
   reg_sqr_adapter = new("reg_sqr_adapter");
   env.p_rm = this.rm; //rm其实中在base_tc中，env中的p_rm指向了该对象
~~~




#### 3. connecet_phase中设置
~~~
function void base_test::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   v_sqr.p_my_sqr = env.i_agt.sqr;
   v_sqr.p_bus_sqr = env.bus_agt.sqr;
   v_sqr.p_rm = this.rm;
   rm.default_map.set_sequencer(env.bus_agt.sqr, reg_sqr_adapter);
   rm.default_map.set_auto_predict(1);
endfunction
~~~

### 3.    env中，组件的连接
#### 1. 声明
~~~
   reg_model  p_rm;
~~~

#### 2. conect_phase内组件的连接
~~~
function void my_env::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   i_agt.ap.connect(agt_mdl_fifo.analysis_export);
   mdl.port.connect(agt_mdl_fifo.blocking_get_export);
   mdl.ap.connect(mdl_scb_fifo.analysis_export);
   scb.exp_port.connect(mdl_scb_fifo.blocking_get_export);
   o_agt.ap.connect(agt_scb_fifo.analysis_export);
   scb.act_port.connect(agt_scb_fifo.blocking_get_export); 
   mdl.p_rm = this.p_rm;  // md1组件内的地址，实际指向了env中的寄存器模型（其实是basic_tc中的）
endfunction
~~~
### 4.    寄存器模型的时序的组件
eg,AHB的对DUT端口的时序代码，此次不赘述

### 5.    寄存器模型的调用，调用read/write 函数
#### 1.rm中声明寄存器模型的，让实际指向basic_tc中的寄存器模型句柄
~~~
   reg_model p_rm;
~~~

#### 2. main_phase中使用
~~~
   uvm_status_e status;
   uvm_reg_data_t value;  
   ...
    p_rm.invert.read(status, value, UVM_FRONTDOOR);
~~~

### 6.    常用的方法
#### 1. 根据寄存器名称读写寄存器
关键词：get_reg_by_name/ get_field_by_name
~~~
task xxx::read_reg_f(string reg_name, string field_name, output uvm_reg_data); //读reg_name内field_name域段的值
    uvm_status_e status;
    uvm_reg reg_name_h;
    uvm_reg_field filed_name_h;

    reg_name_h = xxx_regmodel.xx_block.get_reg_by_name(reg_name);
    reg_name_h.read(status,rdata);
    filed_name_h = reg_name_h.get_field_by_name(filed_name);
    rdata = filed_name_h .get();
endtask
~~~

### 7. 传送门
1. [[UVM]UVM RAL Model中get_reg_by_name應用詳解](https://blog.csdn.net/gsjthxy/article/details/105518782)
2. [UVM- 寄存器模型 Register Model](https://blog.csdn.net/weixin_43830240/article/details/111302866)
