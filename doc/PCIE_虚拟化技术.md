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
0. ![image](https://github.com/user-attachments/assets/8d846a1e-d360-410d-ac99-8999c9189a1b)

1. 背景：
  - 一个处理器系统中存在两个 Domain， 其中一个为 Domain 1，而另一个为 Domain 2。 这两个 Domain 分别对应不同的虚拟机， 并使用独立的物理地址空间
  - GPA1 和 GPA2 采用独立的编码格式， 其地址都可以从各自 GPA 空间的 0x0000⁃0000 地址开始， 只是 GPA1 和 GPA2 空间在 System Memory 中占用的实际物理地址 HPA （Host Physi⁃cal Address） 并不相同
  - Device A 属于 Domain 1， 而 Device B 属于 Domain 2。
  - 在同一段时间内， Device A 只能访问 Domain 1 的 GPA1 空间， 也只能被 Domain 1 操作； 而 Device B 只能访问 GPA2 空间， 也只能被 Domain 2 操作
  - Device A 和 Device B 通过 DMA⁃Remmaping 机制最终访问不同 Domain 的存储器
2. 效果：
   device A / B 访问的空间彼此独立， 而且只能被指定的 Domain 访问， 从而满足了虚拟化技术要求的空间隔离
3. 问题：
  未实现每个 Domain 都可以自由访问所有外部设备


#### 2. IOMMU
0. ![image](https://github.com/user-attachments/assets/4ab68613-45c7-4057-b58d-7fa18bca264f)

1. 背景
  - 存在两个虚拟机， 其使用的地址空间分别为 GPA Domain1和 GPA Domain2。
  - 假设每个 GPA Domain 使用 1GB 大小的物理地址空间， 而且 Domain 间使用的地址空间独立， 其地址范围都为 0x0000⁃0000 ～ 0x4000⁃0000
  - 其中 Domain 1 使用的 GPA地址空间对应的 HPA 地址范围为 0x0000⁃0000 ～ 0x3FFF⁃FFFF； Domain 2 使用的 GPA 地址空间对应的 HPA 地址范围为 0x4000⁃0000 ～ 0x7FFF⁃FFFF。
  - EP1 隶属于 Do⁃main1， 而 EP2 隶属于 Domain2，  即 EP1 和 EP2 进行 DMA 操作时只能访问 Domain1 和 Do⁃  main2 对应的 HPA 空间
2. 实现方式
    intel的  VT⁃d /AMD的  IOMMU 细节不同
3. 转换过程(EP1 和 EP2 向主机进行 DMA 写操作为例)
   - Domain1 和 Domain2 填写 EP1 和 EP2 的 DMA 写地址和长度寄存器启动 DMA操作，  Domain1 和 Domain2 填入 EP1 和 EP2 的 DMA 写地址为 0x1000⁃0000， 而长度为 0x80， 这些地址都是 PCI 总线地址
   - EP1 和 EP2 的存储器写 TLP 到达 RC，由 RC 将 TLP 的地址字段转发到 TA 和 ATPT， 进行地址翻译
        - TA 将使用 Domain1 或者 Do⁃main2 的 I / O 页表， 进行地址翻译， 
          - EP1 隶属于 Domain1， 其地址 0x1000⁃0000 （PCI 总线地址） 被翻译为 0x1000⁃0000 （HPA）； 
          - 而 EP2 隶属于 Domain2， 其地址 0x1000⁃0000 （ PCI 总线地址） 被翻译为 0x5000⁃0000 （HPA）
   - 来自 EP1 和 EP2 存储器写 TLP 的数据将被分别写入到 0x1000⁃0000 ～ 0x1000⁃007F和 0x5000⁃0000 ～ 0x5000⁃007F 这两段数据区域
4. 效果
    不同的设备被映射到不同的domain 空间内



#### 3. AT
0. ![image](https://github.com/user-attachments/assets/00365819-cbb8-4e0d-991b-f10cba225254)

1. 解决思路：
  支持 ATS 机制的 PCIe 设备， 内部含有 ATC （Address Translation Cache）
2. 过程：
   - 在 ATC 中存放 ATPT 的部分内容， 当 PCIe 设备使用地址路由方式发送 TLP 时， 其地址首先通过 ATC 转换为 HPA 地址。
   - 如果 PCIe 设备使用的地址没有在 ATC 中命中时， PCIe 设备将通过存储器读 TLP 从 ATPT 中获得相应的地址转换信息， 更新 ATC 后， 再发送 TLP。
3. 新问题：
  需要维护设备内部的ATC相关的表项
4. 实现：
  - 具体见TLP报文的AT字段，
  - AT:0b00,addr 未转换；0b01： 转换请求报文 ; 0xb0: addr 已转换
5. 效果：
  解决RC处 TA 和 ATPT 的性能瓶颈，因为地址在设备本地进行了转换
6.  问题：
  还未解决跨domian域的设备访问


#### 4. SR-IOV- 基于硬件的虚拟化解决方案

0. ![image](https://github.com/user-attachments/assets/f3c5d837-bd7f-4ebb-b607-279d208165b0)
1. 简介：
    - SR⁃IOV 的 PCIe 设备由多个物理子设备 PF （Physical Function） 和多组虚拟子设备 VF （Virtual Function） 组成
    - 其中每一组 VF 与一个 PF 对应，  M 个 PF， 分别为 PF0 ～ M。 其中 “VF0， 1 ～ N1” 与 PF0 对应； 而 “VFM， 1 ～ N2” 与 PFM对应。
    - 每个 PF 都有唯一的配置空间， 而与 PF 对应的 VF 共享该配置空间， 每一个 VF 都有独立的 BAR 空间， 分别为 VF BAR0 ～ 5
    - 虚拟化环境中， 每个虚拟机可以与一个 VF 绑定，  其中每个虚拟机可以使用一个 VF，从而实现多个虚拟机使用一个设备的目的
2. 与传统的虚拟化技术对比
    - ![image](https://github.com/user-attachments/assets/fbe69ef6-dbc6-4d86-8cc4-80c235c76e9f)
    - 传统虚拟化系统使用Hypervisor（或者VMM）软件对虚拟机进行管理，软件层既消耗CPU资源，又有较深的调用栈，使得PCIe设备的性能优势无法彻底发挥。
    - SR-IOV可以实现多个虚拟机共享物理资源，且bypass Hypervisor（或者VMM）软件层，使得虚拟机可以使用到设备的高性能
    - 优点：VM可直接与VF通信，不需要Hypervisor接入IO处理，节约 vCPU资源的同时，又可以实现不同VF之间性能相互隔离，互不影响









