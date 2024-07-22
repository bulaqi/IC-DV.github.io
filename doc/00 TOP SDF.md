### 1. 基础知识
#### 1. 综合网表VS PR网表 vs PG网表
- 综合网表：后端通过综合工具将RTL综合后生成的网表，无时序信息我司也称之为zero delay网表,主要为了try flow，改用例 
- PR网表(时序仿真)：基于综合网表+DFT逻辑+布局布线，即带SDF的网表
    - SDF: PR网表+时序信息 ==> SS (maximum), FF (minimum), TT (typical)
- PG网表：基于PR网表+power switch 信息+ 电源信息+ 相关库文件

#### 2. DFT
##### 1.涉及的关键方面
- Scan Chain Simulation：在DFT设计中，通常会将电路中的寄存器连接成扫描链（Scan Chain），这样可以通过串行方式将测试向量输入到电路中，并将结果输出，便于检测电路的各个部分。仿真会验证扫描链的正确性，确保测试向量能够正确地传播并通过电路。
- Boundary Scan Simulation：对于I/O引脚，边界扫描（Boundary Scan）技术被用来隔离和测试芯片外部的引脚。JTAG（Joint Test Action Group）接口就是一个典型的边界扫描接口，它允许访问和控制芯片的边界寄存器。DFT仿真会验证边界扫描功能的正确性。
- ATPG（Automatic Test Pattern Generation）Simulation：自动测试模式生成是用于创建测试向量的过程，这些向量旨在检测电路中的所有可能故障。DFT仿真会验证这些测试模式是否能够正确地检测到设计中预想的故障点。
- Clock Gating and Power Gating Simulation：为了降低功耗，现代芯片设计中经常使用时钟门控（Clock Gating）和电源门控（Power Gating）。DFT仿真需要确保这些节能技术不会影响到芯片的测试性。
- Memory BIST（Built-In Self-Test）Simulation：对于片上存储器，内置自测（BIST）电路用于检测存储器的故障。DFT仿真会验证BIST电路的正确性和有效性。
### 2. 经验

### 3. 传送门

 