### 1. 基础知识
#### 1. 前门vs后门 的本质
1. 前门： 走总线
2. 后门： 绕过总线
#### 1. 前门vs后门 访问方法
##### 1.前门：
  1. 访问域： 对外提供的寄存器
  2. drive直接驱动总线， cbus的实现
  3. 寄存器模型，read(output uvm_status_e status,output uvm_reg_data_t value,input uvm_path_e path = UVM_DEFAULT_PATH,xxx)
     - 第一个是uvm_status_e型的变量， 这是一个输出， 用于表明读操作是否成功；
     - 第二个是读取的数值， 也是一个输出；
     - 第三个是读取的方式， 选UVM_FRONTDOOR
##### 2.后门：
  1. 访问域： 对外提供的寄存器 + 内部的信号
  2. 寄存器方法：
     - read/write， 特点: 进行操作时模仿DUT的行为，只读寄存器， 写不进去的
     - peek/pork ， 特点：不管DUT的行为， 只读寄存器， 使用该方法可以写进去
     
  4. 非公开内部信号的访问：uvm_hdl_force /uvm_hdl_release/uvm_hdl_deposit
  5. 寄存器模型，read/write(output uvm_status_e status,output uvm_reg_data_t value,input uvm_path_e path = UVM_DEFAULT_PATH,xxx)
     - 第一个是uvm_status_e型的变量， 这是一个输出， 用于表明读操作是否成功；
     - 第二个是读取的数值， 也是一个输出；
     - 第三个是读取的方式， 选UVM_BACKDOOR
   


### 2. 经验
#### 1. 获取寄存器的值
   - xx_reg_model.xxx_kenel_block.RESET_HANDSHAKE_REG,AHB_COM_RESET_REQ_EN.value


### 3. 传输门
1. [UVM及SystemVerilog中的force、deposit及两者的区别](https://zhuanlan.zhihu.com/p/621413134)
