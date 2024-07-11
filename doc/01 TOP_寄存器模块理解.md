### 1. 基础知识
#### 1. 总体框图

#### 2. 子模块功能介绍

   
##### 1. AHB2SRAM接口
1. 功能：完成AHB和ESRAM接口的协议转化，三个状态机构成：AHB读状态机，AHB写状态机，ESRAM状态机
2. 结构框图
   

##### 2. Bus Access Control子模块
1. 主要功能
   - Address Decoder：主要是根据下表定义的地址空间，完成地址译码，将读写访问仲裁到BAC Register，  
   - Kernel_register_interface, Memory interface(如果选择有)
   - BAC Register : 主要是对定义的BAC register 按照地址空间进行读写访问，其中尤其注意FIFO的接口是固定的地址范围
   - Kernel Register interface, memory interface: 对kernel部分提供标准的ESRAM接口

2. 结构框图


##### 3. Register Bank子模块
1. 主要功能
   - 是提供kernel需要的寄存器，主要包括地址译码，寄存器读控制，寄存器写控制
2. 具体功能
   - Kernel寄存器地址译码：根据用户定义的寄存器地址做地址译码。
   - 寄存器读控制：根据译码的结果和读使能，对寄存器进行读操作。
   - AHB侧寄存器写控制：根据地址译码结果和写使能，对寄存器进行写操作
   - Kernel侧寄存器写操作：根据Kernel的hw_strb信号，对对应的寄存器做写操作

#### 3. 寄存器类型
1. RW，RWS，RWH，RWHS四种类型的寄存器在寄存器工具内部有实体，
2. 而RO，WO，WOB和ROB四种类型的寄存器在寄存器工具内部无寄存器实体。
3. RW在Register Bank有实体寄存器
4. RWHS： H—>hard, S->soft

#### 4. 总结
1. RO 是kernal 对reg_wraper的输入, 
2. RW 是reg_wraper 对kernalreg_wraper的输出
3. 同时通过信号线直连kernal	

#### 3. 个人理解

### 2. 经验总结

### 3. 传送门
1. [reg、wire与logic的区别](https://blog.csdn.net/J_Hang/article/details/117450621)