FlexNoC简介
### 0. FlexNoC hardware architecture concepts
 1. FlexNoC互连架构旨在用高度结构化的分层通信来取代传统的互连，例如总线(bus)或交叉开关(cross-bar)。
 2. FlexNoC方法借鉴了通用网络的一些概念，不仅具有更传统方法的引脚对引脚替换能力，而且还实现了高效、高度灵活和可扩展的解决方案，并由富有成效的设计流程支持。

#### 1. Transaction-based
为了取代传统总线、支持传统IP和通用SoC架构，FlexNoC互连架构利用了通常的基于事务的通信架构：
  1. 从IP发出的事务通过sockets进入互连，并通过sockets退出互连以到达Target IP。
  2. sockets以其事务级协议为特征，可以是任何标准支持的类型，例如 AMBA® AXI™、AHB™、APB™、OCP 等。
  3. 由于Initiator和Target sockets可以根据不同的协议进行操作，具有不同的数据宽度、时钟或其他属性，因此进入互连的事务通常会转换为多个不同但等效的事务，目的地为特定目标。
  4. 当事务无法转换时，它们将保持未处理状态，并由FlexNoC互连报告为错误。

#### 2. System-level tasks
除了事务转换，FlexNoC互连同时执行各种系统级任务，例如：
  1. 将事务请求路由到正确的Target。
  2. 将Target的响应返回给事务的Initiator。
  3. transaction之间的仲裁。
  4. 实施QoS策略。
  5. 记录错误。
这些任务由不同的 FlexNoC 硬件 IP 单元处理，并按层组织。

#### 3.Transaction layer
事务层关注互连外围，如FlexNoC网络接口单元 (NIU) 所示。这些单元负责互连sockets互操作性，以及将事务转换为数据包以供后续层处理。

下图显示了FlexNoC环境是如何组成一个shell的：
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/0f828d2c-9738-4b66-a59e-7ae454217cc2)

1. shell包含所有必要的转换硬件，特别是NIU specific-side，用于转换发送到 generic-side和从generic-side收到的transaction，以适应应用于外围的特定第三方sockets协议。
2. NIU generic-side旨在实现最大面积效率，并为互连核心(core)提供统一的 transaction，这些transaction为系统级处理和分组化做好准备。

#### 4.Packet serialization
  1. 尽管数据包内容本身在互连传输过程中不会改变，但它的序列化(serialization)可以，也就是说，一个给定的数据包可以通过宽链路或窄链路传输，这取决于带宽、延迟、线数(wire count)和时钟速率之间的权衡 .
  2. 因此，数据包在到达目的地之前可以通过多个具有不同序列化(serialization)的传输级(transport-level)接口。

### 2. Network interface and packet transport
  1. 互连是来自FlexNoC硬件IP库的单元的组合。例如，该库包括专用于数据路径定义、观察和寄存器访问的各类单元。
  2. 数据路径类别包括两个值得仔细研究的关键子类别：
       - 网络接口单元 (NIU)
       - 数据包传输单元 (PTU)
  3. 网络接口单元在互连的外围运行，处于事务级别。通常，它们处理传入和传出的读或写请求和响应事务。
  4. FlexNoC NIU将传入的事务信息转换为特殊的“通用”数据包，以优化互连内的传输。然后使用PTU来处理该信息，通常是请求或响应数据包，作为在互连内流动的通用信息。当事务到达互连中可以交付给端点的位置时，NIU再次转换通用事务信息以满足端点需求。

### 3. Advantages of the packet-based approach
  1. 基于数据包的传输架构本质上是可扩展的，因为它不需要在互连中存储有关特定事务状态的信息。  
  2. 因此，基于数据包的互连架构中未决事务(pending transactions)的潜在数量永远不受数据包传输本身的限制，而是受端点(end-points)（即initial和target sockets）的处理能力的限制。  
  3. 这对NoC硬件架构设计具有重要意义：  
  4. 只要NIU配置为处理任何给定第三方 IP 单元能够同时处理的最大事务数量，Arteris NoC从不限制待处理事务的数量。

### 4. NIU Transaction Handling
  1. Arteris FlexNoC network interface unit (NIU) 是FlexNoC互连中transaction-level 的基础。  
  2. NIU事务处理的一个典型示例发生在initiator sockets发出突发事务，而这些事务的目的地是不具备突发能力的端点时。在这种情况下，事务在传递到target socket之前在NoC内拆分。

#### 4.1 Network Interface Unit Partition
  ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/89523398-6b19-4deb-99d0-b25dcaf8ccdf)

#### 4.2 Specific To Generic
  ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/7bb83e98-5b61-49b0-8bd9-9894b1245160)
  
  Request semantics conversion包括：
  ~~~
  1. AW-W and AR channel merge together
  2. ID compression
  3. Burst type conversion
  4. ……
  ~~~
  
  Response semantics conversion包括：
  ~~~
  1. Generic response split to R-channel and B-channel
  2. ID extending
  3. Semantics convert back to AXI protocol
  ~~~
#### 4.3 Generic To Transport
  ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/2f18c99b-9d9b-4e31-af50-f7795e4f2aa0)
  
  Request Process包括：
  ~~~
  1. Address decoding
  2. ID allocation, routing
  3. Transaction splitting
  4. Context table filling
      ……
  ~~~
  Response Process包括：
  ~~~
  1. Looking up context table
  2. ID de-allocation
  3. Response reassembly
  ~~~
  Context table包括：
  ~~~
  1. “Remember”a request waiting for a response
  2. Need as many entries as the lifetime of the transaction
  ~~~

### 5. 数据流实例
#### 5.0  背景介绍
  以1个一对一的简单NoC为例，从Initiator到Target的一笔request介绍数据流，response为相反操作，不再赘述。
  ~~~
  Initiator NIU protocol为AXI，addr width为64-bit，data width为256-bit。
  Target    NIU protocol 为NSP，addr width为64-bit，data width为32-bit。Target的start address为3f70_0000，size为f_ffff。
  ~~~
#### 5.1 AXI to GenReq
  AXI IP发出一笔的burst，其中，
  burst = INCR，
  awsize = 5，
  awlen = 0，
  awaddr = 64’h3f70_0020，
  ~~~
  wdata=256’hffff_eeee_dddd_cccc_bbbb_aaaa_9999_8888_7777_6666_5555_4444_3333_2222_1111_0000，
  ~~~
  wstrb = 32’ha77a_2c12。
  
  仿真波形如下，
  ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/6d8974ce-704a-4ca8-9685-f63479752732)
  
  由上图可知，
  1. AXI的AW/AR、W/R、B通道共同使用GenReq
  2. AXI与GenReq的 addr、data位宽一致
  3. AXI数据总线低bit放低地址的数据，而GenReq数据总线高bit放低地址的数据，即，
  ~~~
  w_data[255:0]=256'hffff_eeee_dddd_cccc_bbbb_aaaa_9999_8888_7777_6666_5555_4444_3333_2222_1111_0000，
  
  req_data[255:0]=256'h0000_1111_2222_3333_4444_5555_6666_7777_8888_9999_aaaa_bbbb_cccc_dddd_eeee_ffff。
  ~~~
  与之对应，byte enable分别信号如下，
  ~~~
  w_strb[31:0] = 32'ha77a_2c12，
  req_be[31:0] = 32'h4834_5ee5。
  ~~~
#### 5.2 GenReq to Transport
  仿真波形如下，
  ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/4e393156-ce48-45c6-a007-64e567e8b8dd)
  
  由上图可知，GenReq数据位宽为256bit，Transport数据位宽为334bit，其中，
  ~~~
  Req_Data[255:0]=256'h0000_1111_2222_3333_4444_5555_6666_7777_8888_9999_aaaa_bbbb_cccc_dddd_eeee_ffff，
  
  Tx_Data[333:0]=334'h…0910_0000_0000_002a_b550_0598_0000_0062_0019_9d56_ab76_00e6_733b_a000_07b8_01ff。
  ~~~
  Tx_Data由数据包头和数据组成：Tx_Data = {TxHdr，TxData}。
  
  1. TxHdr（45-bit）
  ~~~
  TxHdr = {Hdr_Lock，Hdr_RouteId，Hdr_Opc，Hdr_States，Hdr_Len1，Hdr_Addr，Hdr_Echo}
  ~~~
  2. TxData（289-bit）
  ~~~
  TxData = {1bit的worderr，32{1bit be + 8bit data} }
  
  每1bit byte enable + 8bit data为一组，共32组，共同构成256bit的Data和32bit的Be。
  ~~~
#### 5.3 串行化处理
  仿真波形如下，
  ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/bc8ccc6a-a196-4467-bde6-a61d2ac92596)
  
  
  
  由上图可知，串行化处理是将1个clk周期的256bit Transport payload转换成8个clk周期的32bit Adapter payload。
  
  1. Transport
  ~~~
  Rx_Data[333:0] = {45bit header，1bit worderr，32{1bit be+8bit data}}
  ~~~
  2. Adapter
  ~~~
  Tx_Data[81:0] = {45bit header，1bit worderr，4{1bit be+8bit data}}
  ~~~
#### 5.4 Transport（串行化处理后）to GenReq
  仿真波形如下，
  ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/9398bb7c-d6b7-43a8-8b68-9ee9b03b8168)
  
  由上图可知，转换从每1个clk周期传输的Data中的
  1. Header中恢复CMD信息
  2. Payload中恢复Gen_Req_Data
  3. GenReq数据位宽为32bit，与Target的数据位宽一致

5.5 GenReq To NSP
  仿真波形如下，
  ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/6816ff59-c16c-4860-abc5-945c0e6eca6d)
  
  由上图可知，GenReq的 addr、data等信息位宽均与NSP一致。

#### 5.5 小结
  1. Generic与Specific其实是强相关的，并不是一种统一的格式。
  2. NoC内部统一的格式是Transport，所有的switching、routing、QoS等技术处理都基于这个统一格式。
  3. Transport格式与NSP格式非常相似，这也是FlexNoC在NoC级联时采用NSP协议的原因。减少非必要的协议转换，提高性能。

### 6. NIU需要额外配置的功能
#### 6.1 NIU 默认不支持AXI narrow burst
  1. 为了提高NoC内部路由器的效率，希望包的payload中每1个byte都是有效的，因此会把narrow burst拼成完整的word后再往下传输。这个拼的过程需要逻辑处理，还需要NIU内部有一个word fifo；
  2. 另一方面，在实际场景中，大部分IP不会发narrow burst。因此，NoC默认不支持narrow burst。需要支持时，可以进行配置，同时要配置所支持的最小narrow burst size。
  3. Narrow burst只针对于Initiator NIU，即Target NIU不会发narrow burst，有可能会发narrow的single操作。

#### 6.2 NIU默认不支持AXI WRAP
#### 6.3 NIU默认不支持AXI FIXED
#### 6.4若需要支持Interleaving，需要配置reorder buffer
  这里有2种 interleaving：
  1. AXI read interleaving
  2. Address interleaving

##### 6.4.1 AXI read interleaving
  1. 首先需要说明，AXI4取消了对write data interleaving的支持。在AXI4 中，一笔transaction的所有写数据必须以连续的transfer形式出现在写数据通道。即，AXI4不支持WID。
  2. 当Master无法接收read interleaving，但 Slave有可能返回read interleaving时，（在NoC中，每个Initiator和Target是否支持read interleaving都是单独配置的）NoC本身有一种保护机制：当它检测到不支持read interleaving的Master发出不同ID到同一个Target的命令，而Target又支持read interleaving时，就不允许第2个ID的命令出去，即采用反压的方式。但这种保护会有性能的下降。
  3. 如果不希望有性能的下降，可以在NIU上例化Reorder buffer，则它会通过NIU帮助把Slave返回的不连续的response拼成一个完整的response之后再返回给Master。
  4. 但是这也是有开销的，能允许有多少个outstanding的read，就必须要有多少个read的burst的长度的buffer在这里，因此面积开销是非常大的。

##### 6.4.2 Address interleaving
  1. 这种情况大多发生于Target为DDR时。
  2. 一笔 burst 的地址分布在2个Target中，即address1发往Target1，address2发往Target2，则NoC无法保证2个Target返回数据的时间。Reorder buffer可以先缓存address2返回的数据data2，等address1的数据data1返回后，先将data1返回给Master，再将data2返回给Master。
  ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/c8da0f93-1586-4b72-9753-b8b64c22df50)
