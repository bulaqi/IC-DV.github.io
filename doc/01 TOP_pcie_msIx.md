### 1. 基础知识

#### 1. 工作方式
1. pure polling
   - pcie 协议的要求
      ~~~
      If a masked vector has its Pending bit Set, and the associated underlying interrupt events are somehow satisfied (usually by software though the exact manner is Function-specific), the Function must Clear the Pending bit, to avoid sending a
      spurious interrupt message later when software unmasks the vector. However, if a subsequent interrupt event occurs while the vector is still masked, the Function must again Set the Pending bit.

      Software is permitted to mask one or more vectors indefinitely, and service their associated interrupt events strictly based on polling their Pending bits. A Function must Set and Clear its Pending bits as necessary to support this “pure polling” mode of operation.
      ~~~
   - 不使能msix中断，也不读pending_bit 寄存器，利用定时器，时间到后，直接读CQE队列，根据phase_tag判断有效的cqe数据，然后ring cqe hdbl
2. 中断，不屏蔽pvm
   - 当前公版nvme驱动的处理逻辑
   - 主机收到msix中断后，直接读cq队列中查看cqe的phase bit,pvm不动作
3. 中断（正常模块），
   - rc vip的处理逻辑
   - 进入中断时，pvm置位，退出中断前，pvm 清0 

#### 2. 控制信号
1. msix_func_en
2. msix_func_mask
3. pvm
4. pba状态--置位
   - 当msix_func_en为0时,PBA保持0       
   - 当msix_func_en为1时：
     - 若msix_func_mask为1，则触发中断时PBA置位；
     - 若msix_func_mask为0, 且pvm为1时，触发中断时PBA置位。
     - 中断服务程序过程中有新的中断源产生（非nvme的msix中断聚合）
        1. 结论：
           - 结论：msix 发生消耗时间，但没有ostd，会影响后续的msxi逻辑
        2. 第一次msix中断已发送，但未发生完，可能触发中断的被动聚合
           - 表现：少n次中断
           - 条件：在msix发送过程中，发送msix的axi信号未返回done，即msix无ostd 
           - 分析：第一次msix 的aw/w已握手，b通道未完成时，此时，dut满足发一次新的dma的条件（第二笔cq_dma完成），因第一次的msix未发完，dut是不会再发出新的msix中断，主机进入第一次中断服务程序后，查询cq 队列内有2笔cqe，如果一次性处理，则第二笔的dma 就不会产生中断，表现为中断的被动聚合

        3. 第二次中断激励在第一次的中断服务处理程序的位置
           - 已收到msix中断，PVM置1前,即进入中断前 --> 中断不聚合，不影响PBA,有N次触发条件，则触发N次中断
           - [PVM置1]  --> 无影响
           - PVM置1后，ring dbl前  -->PBA置1
           - [Ring dbl]  -->清掉PBA(前提：如果有)
           - 在ring dbl后，PVM 清0 前 -->PBA置1(常见模式)（因dut内部处理逻辑限制，PBA清0到再次置1，清0的过程，持续两个周期）
           - [PVM清0]  -->如果PBA为1，则立刻发送msix, 并清PBA
           - PVM清0后  --> 下次中断
           - 待续
     - 中断场景过程总结：
        1. mask场景下，进入中断服务程序，PVM置1，但主机未Ring CQ HDBL前，有新的中断条件触发（比如新的CQ_DMA），PBA会置1，此时在主机Ring CQ HDBL后会清除PBA；
        2. 在PBA清0后，dut会重新判断msix中断条件是否满足（比如在非聚合条件下队列中有CQ存在），若满足则会再次置起PBA，注：PBA清0到再次置1，清0的过程，持续两个周期。
        3. 总结（针对当msix_func_en为1时）：
            - 若msix_func_mask为1，则触发中断时置位PBA；
            - 若msix_func_mask为0,且vector mask为1则触发中断时置位PBA。
            - 综上，置位条件就是msix_fuvenc_mask为1或ctor_mask为1时满足中断条件置位PBA。

5. pba清0（前提：pba为1）
   - 中断模式下,主机ring cq dbl
   - 中断模型下，退出中断服务程序，发msix中断，pvm 清0后，
   - pure polling 模式下，ring cq dbl的时候

   
#### 3. msix_en
1. 功能msix功能的总开关
2. 为减少对设计的复杂性和状态切换的残留影响，建议msix_en不使能，其他状态保持默认非工作状态
   
#### 4. PBA
1. pba有2个功能
   - 在msix使能，msix mask时，指示是否有中断激励待处理
   - 潜在功能，因mask时，有该状态，可以防止中断丢失
2. 上述的中断激励处理包括
   - 可以是unmask后发生清PBA后立即msix_int，即中断模式，保证中断不丢失
   - 跳过中断状态，主机直接处理， 即纯pure polling 模式
3. PBA置位条件
   - cfg_msix_en=1
   - msix_func_mask或vector_mask为1
   - 期间有中断激励产生
4. 不使能MSI-X，PBA不能被置1
   - 原因：残留PBA有影响
   - 具体分析： 主机会在初始化CQ之前，把MSI-X配置好并且使能。如果此时，由于在使能前有残留PBA，并且发中断，主机会发现此时CQ并未初始化，然后在内核log中记录一个warning。

#### 4. 非中断聚合
1. 在非聚合模式下一次CQE DMA完成上报一次MSIX中断，因中断源太多仲裁不上、AXI总线反压等的被动聚合，中断数量可以少于DMA完成数量；
   
#### 5. 中断聚合

### 2. 经验
#### 1. nvme 协议解读
1. 协议
   ~~~
   It is recommended that the interrupt vector associated with the CQ(s)being processed be masked during processing of completion queue entries 
   within the CQ(s) to avoid spurious and/or lost interrupts. The interrupt
   mask table defined as part of MSI-X should be used to mask interrupts.

   建议在处理CQ(s)内的完成队列条目时，屏蔽与正在处理的CQ(s)相关的中断向量，   
   以避免产生虚假或丢失的中断。MSI-X定义的中断掩码表应用于屏蔽中断。
   ~~~
2. 虚假中断的理解
   - 如果不mask,没有pba，则无法表征是否在mask 期间是否有中断发生
   - 如果在第一次pvm mask 后和ring_dbl前，有中断激励触发的条件，则ring dbl可能会ring 全部的dbl
   - 待进入第二次中断的时候，cq队列为空，为虚假中断
3. 丢中断的理解,
   - eg，如果有mask,无pba,在进入第一次中断后，mask置位，此时新中断激励条件满足，因mask无中断产生
   - unmask后，上述的中断也无法发出，因为无信号标志标志有待发生的中断，该信号还必须是主机和dut都能看到的状态信号



### 3. 传送门
