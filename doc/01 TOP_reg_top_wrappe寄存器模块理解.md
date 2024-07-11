### 1. 基础知识
#### 1. 概述
#### 1. 顶层主要信号分类
1. ahb
2. 按照寄存器功能域段拆分为不同的信号线，连接kernal 信号
3. 按照R/W属性，将信号线分为输入、输出信号
   - WO: --> 输出，给kernal
   - RO：--> 输入，引自kernal的输出，输入给reg_warpper,让ahb 读走
   - RW： 
      - 特点：值的end_point
      - 实现：寄存器模块内有具体的寄存器锁存该值，kernal 只有信号无锁存寄存器值。
      - 接口：只有输出信号，无输出信号
        - xx_o: Soft通路，是输出信号，AHB写后，给kernal，驱动kernal动作
        - **无xx_i信号**： 过程：读时因寄存器实体在该模块内，AHB读该值，对kernal不发起动作，只是将该锁存值，送到AHB纵向上输出即可
   - RWHS: 
      - 特点：值的end_point
      - 实现：内部有寄存器承载锁存当前值，受SW/HW同时控制
      - 接口：同名的输入/输出信号，代表不同的通路
        - xx_o：Soft通路，是输出信号，AHB写后，给kernal，驱动kernal动作
        - xx_i：Hard通路，是输入信号，表示硬件修改该值的路径，通过该信号修改 锁存寄存的值；

#### 2. AHB写概述：
-  将AHB写地址，先分类，bac or kernal，然后按照不同规则进行地址译码，选择不同的控制线，该控制线输出给
#### 3. AHB读概述：
   - 特点: 具体值的endpoint可以在kernal,也可以在该模块内，
   - RO: 值锁存在kernal内，译码选择对应的信号线，将信号线的值输出给AHB，读走
   - RW: 对应的寄存器实体在该寄存器模块内
     - 写：ahb写命令修改 寄存器模块内的寄存器实体的值，将该值通过信号线输出给kernal
     - 读: ahb读寄存器模块内的寄存器实体的值，与kernal无交互

#### 2. 总体框图
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/b8528375-26e8-4b95-abc1-1eef717e0c84)

#### 2. 子模块功能介绍
##### 1. AHB2SRAM接口
1. 功能：完成AHB和ESRAM接口的协议转化，三个状态机构成：AHB读状态机，AHB写状态机，ESRAM状态机
2. 结构框图
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/9602c8c8-2bf2-4771-abe6-c49af617a0ae)

##### 2. Bus Access Control子模块
1. 主要功能
   - Address Decoder：主要是根据下表定义的地址空间，完成地址译码，将读写访问仲裁到BAC Register，  
   - Kernel_register_interface, Memory interface(如果选择有)
   - BAC Register : 主要是对定义的BAC register 按照地址空间进行读写访问，其中尤其注意FIFO的接口是固定的地址范围
   - Kernel Register interface, memory interface: 对kernel部分提供标准的ESRAM接口
2. bac_寄存器，因不涉及具体的功能，所以无需传到kernel, 仅在本模块保存值，所以bac寄存器仅可以在此找到具体的值
3. bac 寄存器是固定功能的，少量的几个寄存器，所以采用内部的信号作为索引（自定义），作为具体的选择信号，与kernal 寄存器的地址索引不同，请注意。
4. 结构框图
   - ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/e3ca9e9c-49fd-4028-bfc8-2e85e544d0c5)


##### 3. Register Bank子模块
1. 主要功能
   - 是提供kernel需要的寄存器，主要包括地址译码，寄存器读控制，寄存器写控制
2. 具体功能
   - Kernel寄存器地址译码：根据用户定义的寄存器地址做地址译码。
   - 寄存器读控制：根据译码的结果和读使能，对寄存器进行读操作。
   - AHB侧寄存器写控制：根据地址译码结果和写使能，对寄存器进行写操作
   - Kernel侧寄存器写操作：根据Kernel的hw_strb信号，对对应的寄存器做写操作
3. 个人理解
   - w属性的寄存器，outout, reg_wrapper ->kernal，将具体的寄存器值转为后信号传给kernal，实现写值的改变，影响kernal内的功能
   - r属性的寄存器, input,  kernal->reg_wrapper, 将具体的kernal内负责具体功能的线，输入给寄存器模块，实现读kernal内的当前功能值
  
#### 4. 寄存器类型

1. RO，WO，WOB和ROB四种类型的寄存器在寄存器工具内部 **无** 寄存器实体，可以通过因连接内部信号，或者
   - RO ：引kernal 信号，输入给reg_wraper的，通过AHB读走
   - WO ：是AHB写，reg_wraper地址译码，,选择具体的信号wire线,该线连到kernal,是kernal的输入信号，控制kernal的功能
2. RW，RWS，RWH，RWHS四种类型的寄存器在寄存器工具内部 **有** 实体
   - RW 是读写都支持
   - 所以，在Register Bank 有寄存器实体，锁存当前值，该寄存器实体直连kernal
   - R：kernal--硬连线->reg_back，AHB读，是将该reg_bank内的寄存器实体，进行输出
   - W：AHB发起，地址译码，修改reg_bank内的实体，该寄存器实体作为输出信号，输出给kernal,实现控制寄存器值的改变
3. RW在Register Bank有实体寄存器
4. RWHS： 
   - H：hard(DUT)可以rw, 
   - S: soft(ahb),可以rw
5. 寄存器表
   - ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/fa8728d3-2292-425c-b786-30597d45baa5)


### 2. 经验总结

### 3. 传送门
1. [reg、wire与logic的区别](https://blog.csdn.net/J_Hang/article/details/117450621)
