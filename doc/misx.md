### 1. 基础知识
#### 0. 控制信号
1. msix_func_en
2. msix_func_mask
3. pvm
4. pba状态
   - 当msix_func_en为0时PBA为0       
   - 当msix_func_en为1时：
     - 若msix_func_mask为1，则触发中断时置位PBA；
     - 若msix_func_mask为0, 且vector mask为1则触发中断时置位PBA。
     - 其他场景PBA为0。

#### 1. 工作方式
1. pure polling
   不使能msix中断，也不读pending_bit 寄存器，而是定时，直接读CQE队列，根据phase_tag判断有效的cqe数据，然后ring cqe hdbl
2. 中断，不屏蔽pvm
   主机收到msix中断后，直接读cq队列中查看cqe的phase bit,pvm不动作
3. 中断，进入中断时，pvm置位，退出中断前，pvm 清0 
#### 2. msix_en
#### 3. pending_bit

#### 4. 中断聚合
#### 5. 典型场景
1. 中断模式,在收到中断mask中断过程中，可能丢MSI-X中断

### 2. 经验
### 3. 传送门