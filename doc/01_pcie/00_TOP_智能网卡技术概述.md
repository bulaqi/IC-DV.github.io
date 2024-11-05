### 1. 基础概念
### 2. 关键词
NIC DPU

#### 1. 演进史
#### 1. 缩略语
1. NIC -- Network Interface Card，NIC，网络接口卡

#### 2.  NIC过程举例
##### 1. 背景
1. Basic NIC
   - Basic NIC 是一个 PCIe 设备，实现了与以太网的连接，即：实现了 L1-L2 层的逻辑，负责 L2 层数据帧的封装/解封装，以及 L1 层电气信号的相应处理；
   - 而由 Host CPU 则负责处理网络协议栈中更高层的逻辑。即：CPU 按照 L3-L7 层的逻辑，负责数据包的封装/解封装等工作；
3. SmartNIC
   - SmartNIC 就是通过从 Host CPU 上 Offload（卸载）工作负载到网卡硬件，以此提高 Host CPU 的处理性能。
   - 其中的 “工作负载” 不仅仅是 Networking，还可以是 Storage、Security 等等

     
##### 2. FPGA 来实现 Smart NIC 举例
1. Basic NIC
   - 采用多个 Ethernet MAC 芯片和一个用于与 Host CPU 连接的 PCIe Interface。- - Host CPU 必须主动处理所有的 Ethernet Packets
   - ![image](https://github.com/user-attachments/assets/037cf4ec-174e-476e-9dd1-eef567dd2694)

2. 添加 DMA Engine 功能 
   - 添加 DMA Controller 和 DMA Interface，将 NIC Memory 直接映射到 Main Memory ZONE_DMA。
   - Host CPU 可以直接从 Main Memory 读取 Packets，而不再需要从 NIC Memory 中进行 Copy，从而减少了 Host CPU 的工作负载。
   - ![image](https://github.com/user-attachments/assets/d9f4ec3a-6a9a-464e-b25b-8fc129d6ebd8)

3. 添加 Filter Engine 功能
   - Packets Filter 模块提供 L2 Filtering、VLAN Filtering、Host Filtering 等功能，
   - 可以进一步减少了 Host CPU 的工作负载。
   - ![image](https://github.com/user-attachments/assets/b6eba5ab-1f62-444e-bd3f-dc5fb2bf289c)

4. 添加外部 DRAM 到 Filter Engine
   - 为 Packets Filter 添加用于存储 Filter Rules 的 DRMA 存储器，- 进一步增强 Packets Filter 的功能和灵活性。
   - ![image](https://github.com/user-attachments/assets/b0793076-ce49-4b80-a8ce-ac133b1f2340)

5. 添加 L2/L3 Offload Engine 功能
   - 添加 L2 Switching 和 L3 Routing 功能，卸载数据面转发功能，
   - 进一步减少 Host CPU 的工作负载。
   - ![image](https://github.com/user-attachments/assets/45a1cd51-bd53-4c92-bd55-f3e31efa9cf7)

6. 添加 Tunnel Offload Engine 功能
   - 将 VxLAN、GRE、MPLSoUDP/GRE 等 Host Tunnel 数据面功能卸载到 SmartNIC，
   - 进一步减轻 Host CPU 进行隧道封装/解封装的工作负载。
   - ![image](https://github.com/user-attachments/assets/60750c32-c8e1-4e45-80e0-914791cb5679)

7. 添加 Deep Buffering 外部存储
   - 添加 Deep Buffer（深度缓冲）专用存储器，
   - 用于构建支撑 L2/L3/Tunnel Offloading 的差异化 Buffer Rings。
   - ![image](https://github.com/user-attachments/assets/e93a8eff-870a-4f4e-a952-5e22cba9a5bb)

8. 添加 Flows Engine 功能
   - 针对 vSwitch / vRouter 虚拟网元的 Fast Path 提供 Traffic Flows 模块，
   - 另外配置一个 DRAM 存储器，可以处理数百万个 Flow Table entries。
   - ![image](https://github.com/user-attachments/assets/b6999afb-39ba-4bc8-b09f-854678824314)

9. 添加 TCP Offload Engine 功能
   - 卸载全部或部分 TCP 协议功能，
   - 减轻 TCP 服务器的 Host CPU 工作负载。
   - ![image](https://github.com/user-attachments/assets/18dbae24-d12d-43b2-b8d8-b53a9677379d)

10. 添加 Security Offload Engine 功能
    - 卸载 TLS 此类加密/解密功能，针对相应的 Traffic Flow 可以选择开启/关闭 TLS 加速。
    - ![image](https://github.com/user-attachments/assets/29a5e17b-ad2f-4120-8b8a-80b941facd0d)

11. 添加 QoS Engine 功能
    - 添加 QoS Engine 功能，卸载 TC 等流量控制模块，
    - 可以实现 Multi-Queues 和 QoS 调度功能
    - ![image](https://github.com/user-attachments/assets/1fecc1c3-9dce-4025-a1a0-e54b3b6bc10b)

12. 添加一个 Programmable Engine 功能
    - 添加 P4 RMT（Reconfigurable Match Tables，可重配置 Match-Action 表）此类 Programmable Engine，
    - 提供一定的可编程 Pipeline 能
    - ![image](https://github.com/user-attachments/assets/643df45f-3961-4ba2-b662-667af0d252d0)

13. 添加一个或多个 ASIC 板载处理器
    - 添加用于管理面和控制面的 CPU 处理器，提供完整的软件可编程性。
    - ![image](https://github.com/user-attachments/assets/6a9de37f-158f-4759-b6e6-46f3aac43421)

DPU 设备组成
### 3. DPU
#### 1. 现状&问题
1. 失效的摩尔定律
2. 沉重的数据中心税
   - ![image](https://github.com/user-attachments/assets/db6f9403-f715-4df9-b713-a6c6defee3a4)
   - CPU 30% 的 workload 都是在做流量处理，这个开销被形象的称作数据中心税（Datacenter Tax）。即还未运行业务程序，先接入网络数据就要占去的计算资源。
   - 逐渐普及的 40GbE 和 100GbE 场景中，CPU 就会出现阻塞。
   - 
4. 冯诺依曼内存墙
   - 内存墙“ 的现实就是 DDR（Main Memory 的容量和 Bus 传输带宽）已经成为了那块短板
   - ![image](https://github.com/user-attachments/assets/aa0387ee-c456-47ea-ae08-cf362377caf0)

   - 例如 AI DL/ML 训练场景，具有高并发、高耦合的特点，不仅有大量的数据参与到整个算法运行的过程中，这些数据之间的耦合性也非常强，因此对 Main Memory 提出了非常高的要求。
   - 有下列几种 “补丁式“ 的解决方法
        1. 加大存储带宽：
           - 采用高带宽的外部存储，如 HDM2，降低对 DDR 的访问
           - 这种方法虽然看似最简单直接，但问题在于缓存的调度对深度学习的有效性就是一个难点；
        2. 片上存储：
            - 在处理器芯片里集成大存储，抛弃 DDR，比如集成几十兆字节到上百兆的 SRAM。
            - 这种方法看上去也比较简单直接，但成本高昂也是显著的劣势。
        3. 存算一体（In-Memory Computing)：
            - 在存储器上集成计算单元，
            - 现在也是一个比较受关注的方向。
    -  
5. 数据 I/O 路径冗长
   1. 针对不同的应用场景，在冯·诺依曼体系中部署专用的协处理器（e.g. GPU、ASIC、FPGA、DSA）来进行加速处理。
   2. 存在一个直观的问题
      - ![image](https://github.com/user-attachments/assets/3252db9d-dcf1-4872-b98b-f28c7dd54f7b)

      - CPU 和 Main Memory 以及 Device Memory 之间的数据 I/O 路径冗长，同样会成为计算性能的瓶颈
      - 以 CPU+GPU 异构计算为例，
        - GPU 具有强大的计算能力，能够同时并行工作数百个的内核，
        - 但 “CPU+GPU 分离” 架构中存在海量数据无法轻松存储到 GPU Device Memory 中，需要等待显存数据刷新。
        - 同时，海量数据在 CPU 和 GPU 等加速器之间来回移动，也加剧了额外的速率消耗。 
   4. 以 CPU 为中心的体系架构在异构计算场景中，由于内存 IO 路径太长也会成为一种性能瓶颈。
#### 2. DPU
1. 将更多 CPU 和 GPU 的 workload offload 到 DPU（Data Processing Unit，数据处理单元）中，使得计算、存储和网络变得更加紧耦合
   - ![image](https://github.com/user-attachments/assets/3c4a3102-f946-4e90-91ee-367794809fce)

2. 重要趋势是，计算、存储和网络都在不断融合。而 DPU 的核心就是让计算发生在靠近数据产生的地方
   - CPU 负责通用计算。
   - GPU 负责加速计算
   - DPU 负责数据中心内部的数据传输和处理
3. DPU 的抽象架构
   1. ![image](https://github.com/user-attachments/assets/c9bd684f-80a5-4373-aa3e-92db0d9576b6)

   2. 控制平面
      由通用处理器（x86 / ARM / MIPS）和片上内存实现，可运行 NIC OS（Linux），主要负责以下工作：
      1. DPU 设备运行管理
         - 安全管理：信任根、安全启动、安全固件升级、基于身份验证的容器和应用生命周期管理等。
         - 实时监控：对 DPU 的各个子系统进行监控，包括：数据平面处理单元等。实时观察设备是否可用、设备中流量是否正常，周期性生成报表，记录设备访问日志核配置修改日志。
      2. DPU 计算任务和资源配置
         - 网络功能控制面计算任务。
         - 存储功能控制面计算任务。
         - 等。
   
   3. 数据平面
      由专用处理器（NP / ASIC / FPGA）和 NIC 实现，主要负责以下工作：
      
      1. 可编程的数据报文处理功能。
      2. 协议加速功能。
      
   4. I/O 子系统
      1. System I/O：由 PCIe 实现，负责 DPU 和其他系统的集成。支持 Endpoint 和 Root Complex 两种实现类型。
      
         1. Endpoint System I/O：将 DPU 作为 “从设备” 接入到 Host CPU 处理平台，将数据上传至 CPU 进行处理。
         2. Root Complex System I/O：将 DPU 作为 “主设备” 接入其他加速处理平台（e.g. FPGA、GPU）或高速外部设备（e.g. SSD），将数据分流至加速平台或外设进行处理。
      2. Network I/O：由 NIC（网络协议处理器单元）实现，与 IP/FC Fabric 互联。
      
      3. Main Memory I/O：由 DDR 和 HBM 接口实现，与片外内存互联，可作为 Cache 和 Shared Memory。
         - DDR 可以提供比较大的存储容量（512GB 以上）。
         - HBM 可以提供比较大的存储带宽（500GB/s 以上）。


### 2. 经验总结
### 3. 传送门
1. [高性能网络 — SmartNIC、DPU 设备演进与运行原理](https://zhuanlan.zhihu.com/p/625827685)
2. [SmartNIC与DPU有什么区别？为什么云级架构需要DPU？](https://zhuanlan.zhihu.com/p/388836636)
3. [高性能网络 — SmartNIC、DPU 设备演进与运行原理](https://www.zhihu.com/question/507393809)
