### 1. 基础知识
#### 1.  跨时钟域的产生
- 概述:
  1. SOC芯片中的CPU通常会工作在一个频率上，
  2. 总线信号（比如DRAM BUS）会工作在另一个时钟频率下，
  3. 而普通的信号又会工作在另外的时钟频率下。
  4. 交互:这3个不同时钟频率下工作的信号往往需要相互沟通和传递信号。
- 问题:
  1. 不同时钟域下的信号传递就涉及到跨时钟域信号处理，因为相互之间的频率、相位不一样，如果不做处理或者处理不当，如下图所示的时钟域CLK_A的数据信号A可能无法满足时钟域CLK_B的setup/hold时间，可能导致：
    - 数据丢失，无法采到预期中的信号；
    - 亚稳态的产生。
    - ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/e81097cb-a11c-4962-abed-433878f6ceb2)
#### 2. 常见的跨时钟域信号处理方法 
1. 两级DFF同步器
2. 握手协议
3. 异步FIFO
#### 3. 单比特信号处理 --- 通常采用两级DFF串联进行同步
1. 图示
   - ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/661d4b03-a89e-465c-a2ec-47fb4b449a63)
2. 从时钟域A(CLKA)传过来的信号a_in, 直接用时钟域B CLKB采用很容易产生亚稳态，用两级DFF 敲过后再使用就可以把亚稳态概率降到一个合理的值。
3. 问题:为什么是两级DFF呢？
   - 这里有一个平均失效间隔时间MTBF(Mean Time Between Failure)的考虑。MTBF时间越长，出现亚稳态的概率就越小，但是也不能完全避免亚稳态。
   - 注意采样时钟频率越高，MTBF可能会迅速减小。
   - 统计分析
     ~~~
     有文献给出的数据：对于一个采样频率为200Mhz的系统，
     如果不做同步MTBF是2.5us，
     一级DFF同步的MTBF大概是23年，
     两级DFF同步的大约MTBF大概是640年，
     MTBF越长出错的概率越小。
     所以一级看上去不太稳，二级差不多够用了，至于三级可能会影响到系统的性能，而且增加面积，所以看上去没什么必要。
     ~~~
#### 3. 单比特信号处理 易错问题
##### 1. 错误1 ：时钟域A的组合逻辑信号直接敲两级DFF同步到时钟域B
1. 图示
   - ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/89dacafc-5853-406a-8ccd-527444b206e9)
2. 所示虽然时钟域A的逻辑信号c0 传输到时钟域B的时候，也用了两级DFF 同步器，但我们知道组合逻辑电路各个输入信号的不一致性以及组合逻辑内部路径的延时时间不一样，运算后的信号存在毛刺如图(2),而我们又无法预先知道CLKB 的上升沿何时会到来，CLKB 采样到的信号就无法预知，这显然不是我们想要的结果。
3. 因此，要想CLKB 能采到稳定的信号，时钟域A的信号必须是经过CLKA 敲过，在一个时钟周期内是稳定的信号，如图（3）所示:
   - ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/ab0eedbe-332c-4fc5-8e39-573fe6bbdb7c)
##### 2. 错误2 ： Clock-gating enable 信号没有经过异步处理
1. 图示:
   - ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/1df4f75a-8ccf-471e-a6e0-d3eefada368b)
2. 分析:
   在下图中a_in 信号经过CLKA的DFF敲过，再送到两级DFF 同步器处理，完全没毛病。但是F2的使能信号EN是从时钟域A来的，当EN信号变化的时候，由于时钟域不一样，无法保证使能之后的CLKB信号采样数据时满足setup/hold time 要求，这时F2输出信号也就变得无法预测了。
  


### 2. 传送门
1. [IC面试中常被问到——跨时钟域信号如何处理？](https://mp.weixin.qq.com/s?__biz=MzIxMzg0MDk0Mg==&mid=2247483904&idx=1&sn=198f0071e5a87740022e8bdc528cfb93&chksm=97b1e741a0c66e57607bdffa4d179e758b52ef6c6b8d1e328cf35db70040ea47d16ae69d2e13&scene=21#wechat_redirect)
