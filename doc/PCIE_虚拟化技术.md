### 一. 演化目标
同一个PCIE 设备可以被多台虚拟主机共享式使用

### 二.关键词
1. IOMMU ：将PCI 总线地址转换为 HPA 存储器域地址（主机端）
2. ATS  ：将PCI 总线地址转换为 HPA 存储器域地址（本地）
3. HPA  ：Host Physi⁃cal Address，处理器系统中真实的物理地址。
4. GPA  :Guest Physical Address, Domain内独立编码
5. SR-IOV：Single Root I / O Virtualization Extended Capabilities，将pcie 设备虚拟化的功能，需要设备支持
6. TA  :Translation Agent
7. ATPT: Address Translation and Protection Table
8. DMA_Repmaping：将PCI 总线地址转换为 HPA 存储器域地址

### 三. 演化路径

无IOMMU --> IOMMU- > ATS -> SR-IOV

### 四. 演化过程详解
#### 1. 无IOMMU
![image](https://github.com/user-attachments/assets/8d846a1e-d360-410d-ac99-8999c9189a1b)

1. 背景：
  一个处理器系统中存在两个 Domain， 其中一个为 Domain 1，而另一个为 Domain 2。 这两个 Domain 分别对应不同的虚拟机， 并使用独立的物理地址空间
  GPA1 和 GPA2 采用独立的编码格式， 其地址都可以从各自 GPA 空间的 0x0000⁃0000 地址开始， 只是 GPA1 和 GPA2 空间在 System Memory 中占用的实际物理地址 HPA （Host Physi⁃cal Address） 并不相同
  Device A 属于 Domain 1， 而 Device B 属于 Domain 2。
  在同一段时间内， Device A 只能访问 Domain 1 的 GPA1 空间， 也只能被 Domain 1 操作； 而 Device B 只能访问 GPA2 空间， 也只能被 Domain 2 操作
  Device A 和 Device B 通过 DMA⁃Remmaping 机制最终访问不同 Domain 的存储器
2. 效果：
   device A / B 访问的空间彼此独立， 而且只能被指定的 Domain 访问， 从而满足了虚拟化技术要求的空间隔离
3. 问题：
  未实现每个 Domain 都可以自由访问所有外部设备

#### 2. IOMMU


#### 3. AT


#### 4. SR-IOV- 基于硬件的虚拟化解决方案
