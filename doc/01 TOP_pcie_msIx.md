### 1. 基础知识
#### 0. 控制信号
1. msix_func_en
2. msix_func_mask
3. pvm
4. pba状态--置位
   - 当msix_func_en为0时PBA为0       
   - 当msix_func_en为1时：
     - 若msix_func_mask为1，则触发中断时置位PBA；
     - 若msix_func_mask为0, 且vector mask为1时，触发中断时置位PBA。
     - 中断服务程序过程中有新的中断源产生（非nvme的msix中断聚合模式）
        1. 第一次msix中断已发送，但未完全发送，被动聚合
           - 表现：少了一次中断
           - 在msix发送过程中，发送msix的axi信号未返回done
           - 上一次msix发送还没回done的时候又来了一个发了一个新的dma，如果在还没回done的时候来的新的dma，是不会再发出新的msix的
           - 主机收到第一次的中断后，即msix后，查询fun是2次中断激励的结果，所以一并处理，表现为中断的被动聚合

        2. 第二次中断激励在第一次的中断服务程序的位置
           - 已收到msix中断，PVM置1前,即进入中断前 --> 不影响PBA,有N次触发条件，则触发N次中断
           - [PVM置1]  --> 无影响
           - PVM置1后，ring dbl前  -->PBA置1
           - [Ring dbl]  -->清掉PBA(前提是如果有)
           - 在ring dbl后，PVM 清0 前 -->PBA置1(常见模式)
           - [PVM清0]  -->如果PBA为1，则立刻发送msix, 并清PBA
           - PVM清0后  --> 下次中断
           - 待续
     - 过程详细描述：
        1. mask场景下，进入当前的中断服务程序，PVM置1，但主机未Ring CQ HDBL前有新的中断条件触发（比如完成新的CQ），PBA会置1，此时在主机Ring CQ HDBL后会清除PBA；
        2. 在PBA清除后电路会重新判断中断条件是否满足（比如在非聚合条件下队列中有CQ存在），若满足则会再次置起PBA，在清除到再次置起间隔两个周期的低电平。
        3. 总结（针对当msix_func_en为1时）：
            - 若msix_func_mask为1，则触发中断时置位PBA；
            - 若msix_func_mask为0,且vector mask为1则触发中断时置位PBA。
            - 具体来说置位条件就是msix_func_mask为1或vector_mask为1时满足中断条件置位PBA。

5. 清pba状态（前提是pba为1）
   - 中断模型下，退出中断服务程序，pvm 清0后，发出msix中断的时候
   - pure polling 模式下，ring cq dbl的时候

 
7. 非聚合模式的总结
   - 在非聚合模式下一次CQE DMA完成上报一次MSIX中断，因中断源太多仲裁不上、AXI总线反压等的被动聚合，中断数量可以少于DMA完成数量；
   
   
#### 1. 工作方式
1. pure polling
   - pcie 协议的要求
     ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/abfcd6bd-8c4f-4cc3-af6a-df5b3d7b965c)

   - 不使能msix中断，也不读pending_bit 寄存器，而是定时，直接读CQE队列，根据phase_tag判断有效的cqe数据，然后ring cqe hdbl
2. 中断，不屏蔽pvm
   - 当前公版nvme驱动的处理逻辑
   - 主机收到msix中断后，直接读cq队列中查看cqe的phase bit,pvm不动作
3. 中断（正常模块），
   - rc vip的处理逻辑
   - 进入中断时，pvm置位，退出中断前，pvm 清0 
#### 2. msix_en
#### 3. PBA
- PBA置：cfg_msix_en=1 & cfg_msix_func_mask=1时，当中断发生需要置起PBA
- 不使能MSI-X，PBA不能被置1
  原因：主机会在初始化CQ之前，把MSI-X配置好并且使能。如果此时，由于在使能前有残留PBA，并且发中断，主机会发现此时CQ并未初始化，然后在内核log中记录一个warning。

  
#### 4. 中断聚合
#### 5. 典型场景


### 2. 经验
### 3. 传送门
