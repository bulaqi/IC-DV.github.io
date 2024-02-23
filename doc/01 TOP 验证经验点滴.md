### 1. 经验记录
#### 1. 反压:
1. 业务的角度出发 ,eg:不ring dbl ,cq 空间满
2. 总线的角度出发 ,eg:axi_wr,不回复response 信号

#### 2. 绑定关系:
1. 1 vs 1
2. {min,middle,max} coress {min,middle,max}
3. 多对1的场景简化:
   ~~~
   {min,max} coress {min} ;
   {min,max} coress {max};
   {all} corss {min,middle,max}
   ~~~


#### 平台组件设计思路
  在平台内尽量减少用，clk, 因为阻塞端口，应该是基于有数据就处理的原则，而不是按照clk处理，除非特殊情况
