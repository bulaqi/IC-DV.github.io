### 概述
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
https://blog.csdn.net/gsjthxy/article/details/105518782
