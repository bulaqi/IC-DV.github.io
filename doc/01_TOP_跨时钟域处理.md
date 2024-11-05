### 1. 基础知识
#### 1. 快时钟域>>>慢时钟域
##### 1. 背景:我们假定有两个时钟，CLK1 和 CLK2，还有一个信号叫 READ，CLK1 时钟频率快于 CLK2，现在我们需要将READ 信号同步到CLK2时钟域下。
##### 2. 方法一：展宽+打拍同步
###### 1. 原理
- READ_DLY1 信号是 READ 信号相对于 CLK1 时钟打一拍产生的，READ_DLY2 信号是 READ 信号相对于 CLK1 时钟打两拍产生的，
- 由于单纯的 READ 信号宽度根本不够 CLK2 采样，所以需要展宽 READ 的信号宽度,
- READ_OR 信号是由 READ 和 READ_DLY1 以及READ_DLY2 相或产生的。或之后 READ_OR 信号宽度以及够 CLK2 采样。
- 同步原理如下，直接使用 CLK2 采样 READ_OR 信号得到 READ_ SYNC，然后再对READ_SYNC 打 2 拍，
  - 第一拍得到 READ_ SYNC_DLY1，
  - 第二拍得到 READ SYNC_DLY2，
  - 然后READ_SYNC_DLY1 和 READ_OR_SYNC_DLY2 的取反信号相与得到 READ SYNC_PULSE，即已经同步到 CLK2 时钟域的 READ 信号上升沿指示信号。
~~~
1、展宽是为了让慢时钟也可以采集到该信号，展宽的倍数一般根据频率相差的倍数适当选择即可。
2、在展宽时，如果有效电平很宽，即使使得慢时钟能够采样到多次也没关系，因为后续在慢时钟域中进行的边沿检测就是为了最终使得该信号的有效电平只有一个慢时钟周期。
~~~
###### 2. 时序图
对 READ_SYNC 打 2 拍目的是消除亚稳态，打两拍之后的亚稳态概率已经非常非常小了，由于有电路噪声，所以寄存器会恢复到固定电平。我们画出如下的时序图。
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/4863385b-a3ad-4997-bf29-e262fe097314)
###### 3. 时序图
个人理解的限制: 原始快时钟的采样信号, 翻转速率有关系,不能太快,不能影响到展宽后的信号重叠
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/b2d0f5b2-ed37-4ad9-bab7-50aede16c2d1)

##### 4. code
1. rtl
~~~
odule asyn_process ( 
    input clk1 , //快时钟信号
    input read , //信号，快时钟阈的
    input clk2 , //慢时钟信号

    input sys_rst_n , //复位信号，低电平有效
    output wire read_sync_pulse //输出信号
);

 //reg define
 reg read_dly1 ;
 reg read_dly2 ;
 reg read_or ;

 reg read_sync ;
 reg read_sync_dly1 ;
 reg read_sync_dly2 ;

 //*****************************************************
 //**                   main code
 //*****************************************************
 always @(posedge clk1 or negedge sys_rst_n) begin
    if (sys_rst_n ==1'b0) 
        read_dly1 <= 1'b0;
    else 
        read_dly1 <=read;
 end

 always @(posedge clk1 or negedge sys_rst_n) begin
    if (sys_rst_n ==1'b0) 
        read_dly2 <= 1'b0;
    else 
        read_dly2 <= read_dly1 ;
 end

 always @(posedge clk1 or negedge sys_rst_n) begin
    if (sys_rst_n ==1'b0) 
        read_or <= 1'b0;
    else 
        read_or <= read | read_dly1 | read_dly2;
 end

 always @(posedge clk2 or negedge sys_rst_n) begin
    if (sys_rst_n ==1'b0) begin
        read_sync <= 1'b0;
    end
    else 
        read_sync <= read_or;
 end

 always @(posedge clk2 or negedge sys_rst_n) begin
    if (sys_rst_n ==1'b0) 
        read_sync_dly1 <= 1'b0;
    else
        read_sync_dly1 <= read_sync;
 end

 always @(posedge clk2 or negedge sys_rst_n) begin
    if (sys_rst_n ==1'b0) 
        read_sync_dly2<= 1'b0;
    else 
        read_sync_dly2 <= read_sync_dly1;
 end

 assign read_sync_pulse = read_sync_dly1 & ~read_sync_dly2;

 endmodule
~~~
2. 测试代码
~~~
`timescale 1ns / 1ps

module TB();

reg sys_clk1; 
reg sys_clk2; 
reg sys_rst_n; 
reg read ;
initial begin
    sys_clk1 = 1'b0;
    sys_clk2 = 1'b0;
    sys_rst_n = 1'b0;

    read = 1'b0;

    #200
    sys_rst_n = 1'b1;

    #100
    read = 1'b1;

    #20
    read = 1'b0;
    #100
    read = 1'b1;
    #20
    read = 1'b0;

end

 always #10 sys_clk1 = ~sys_clk1;
 always #30 sys_clk2 = ~sys_clk2;

 asyn_process u_asyn_process(
    .clk1 (sys_clk1 ),
    .clk2 (sys_clk2 ),
    .sys_rst_n (sys_rst_n),
    .read (read ),
    .read_sync_pulse(read_sync_pulse )
 );
endmodule
~~~
3. 仿真结果   
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/1618853f-281c-469f-b64d-91993c050118)
- 注意，在波形仿真中是不会出现亚稳态的，但是在实际电路中，亚稳态是实实在在存在的，一定要严格遵守亚稳态的处理规则。


#### 2. 慢时钟域>>>快时钟域
#### 1. 原理
##### 1. 2级DFF的局限(可能有,特殊处理应该不会,如part1 所示)
- 两级DFF的办法（两级DFF同步器）可以实现单比特信号跨时钟域处理。但你或许会有疑问，是所有的单比特信号跨时钟域都可以这么处理吗？
- NO！两级DFF同步器，是对信号有一定的要求的。
- 问题:想象一下，如果频率较高的时钟域A中的信号D1 要传到频率较低的时钟域B，但是D1只有一个时钟脉冲宽度（1T），clkb 就有几率采不到D1了，如图1。
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/94b5e2f4-c154-4bd7-8c85-da6d862fe2b0)
- 因此只有当D1 在很长一段时间内为1或0，确保一定可以被clkb采样到，才能用两级DFF同步器处理。
- [补充个人问题], 如果快信号变化很快,短时间内多次翻转,是否可以被打两拍,位宽展开扩展识别到,用上述打两拍的的方法?
- 如果信号D1 只有1T或几个T的脉宽，又需要传到时钟频率较低甚至或快或慢不确定的时钟域B，这种情况该怎么如何处理呢？
##### 2. handshake
- 握手协议(handshake)异步信号处理是一种常见的异步信号处理方法。常见的握手协议异步信号处理行为波形图大致如下图2：
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/538d9464-c0d4-48ad-a22a-9c0a1786d6b6)
- 分析
~~~
信号d_in 所处时钟域是clk_in,且d_in只有1T 的宽度，想要传送到clk_out 时钟域(clk_out 跟clk_in不相关)。
因为clk_out 和 clk_in相位关系不确定，时钟周期大小关系不确定，无法保证一定能采样到d_in。
因此需要把d_in展宽，产生d_req 信号；
d_req 信号一直拉高，经过clk_out时钟域两级DFF 同步器后，得到d_reg_sync；
取d_req_sync 上升沿1T，即可得到传送到clk_out 时钟域的d_out。
此时，d_in 从clk_in 传送到clk_out 的任务就算是结束了。
但对于handshake 电路来说，任务还没结束，因为d_req 还一直是高电平。
因此，需要把d_req_sync 信号再用两级DFF同步器，传回clk_in 时钟域，得到d_ack信号；
当clk_in 看到d_ack拉高后，就可以把d_req 信号拉低，到这里一个handshake电路行为才算是结束了。
根据上面的波形图，可以看到握手协议异步信号处理并不复杂，但是细心的朋友应该会注意到，这个处理方法信号传递的速度相对较慢。
从图2 的波形来看，至少需要3个clk_in 和2个clk_out时钟周期。根据不同的应用需求，人们会对图2的波形做不同的改造。但万变不离其宗，原理都是一样的，电路也大同小异。
~~~
- 个人总结
~~~
1. req 从clk_a-> clk_b : clk_a 的d_in信号锁存,保持(扩展),被clk_b 时钟域采集到,然后2级DFF通路,然后采集上升沿形成d_out
2. ack 从clk_b-> clk_a:  把d_req_sync(req的同步信号)信号再用两级DFF同步器，传回clk_in 时钟域，得到d_ack信号, 用d_ack 信号把req 拉低完成一次握手
~~~
- 留4个问题供大家思考:  
1. 图2中的d_req的逻辑怎么实现？
2. 图2中的d_out的逻辑怎么实现？
3. 假设时钟域clka比clkb 频率高，如果输入信号的两个相邻脉冲D0和D1非常较近，如下图所示，如果使用握手协议处理，会发生怎样的事情？
4. 问题3里面，如果要确保D1数据一定要被能传送到clkb，电路该如何实现？
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/92138167-a541-457c-bd6f-e3bd9fba1a12)
5. 答案
~~~
问题1：
always@(posedge clk_in or negedge rst_n) begin
  if(rst_n==1'b0) d_reg<=1'b0;  // 复位
  else if (d_in==1'b1) d_reg<=1'b1;  // 注意:如果d_in==1 ,d_reg<=1, 但是d_in !=1,不满足该条件,跳过赋值语句
  else if (d_ack==1'b1) d_reg<=1'b0;  // d_ack ==1 ,d_reg 情况,如果 d_ack!=1, 不影响d_reg状态,暗含d_reg 会一致保持之前的状态,产生类似打拍后,多个信号与或的效果
end

问题2：
assign d_out=d_req_sync & (~d_req_sync_d);

问题3：
不能接收到数据D2。因为两者的展宽信号重叠了。

问题4：
数据类信号的异步处理用异步FIFO？
补充一下，如果应用可以接受，改变优先级，牺牲D0,传输D1 。
~~~




#### 2.code
1. rtl
~~~
module handshake_sync ( 
    input clk1 , //快时钟信号
    input sys_rst_n , //复位信号，低电平有效
    input read , //信号，快时钟阈的
    input clk2 , //慢时钟信号

    output read_sync_pulse //输出信号
);

//in1表示该信号在clk1时钟域
reg req_in1 ;
reg ack_in1 ;
reg ack_in1_dly1 ;
//in2表示该信号在clk2时钟域
reg req_in2 ;
reg req_in2_dly1 ;

//*****************************************************
//**                   main code
//*****************************************************

//1、clk1时钟域下req信号的生成
always @(posedge clk1 or negedge sys_rst_n) begin
   if (sys_rst_n == 1'b0) 
       req_in1 <= 1'b0;
   else if(read == 1'b1)
       req_in1 <= 1'b1;
   else if(ack_in1_dly1 == 1'b1)
       req_in1 <= 1'b0;
   else
       req_in1 <= 1'b0;
end


//2、clk2时钟域下req信号的采样
always @(posedge clk2 or negedge sys_rst_n) begin
   if (sys_rst_n == 1'b0) begin
       req_in2 <= 1'b0;
       req_in2_dly1 <= 1'b0;
   end
   else begin
       req_in2 <= req_in1;
       req_in2_dly1 <= req_in2;
   end
end

//3、clk1时钟域下ack信号的采样 直接采样req_in2_dly1作为ack信号即可
//这是因为有了req_in2和req_in2_dly1之后我们就可以生成dout，所以此时就可以返回ack信号了
always @(posedge clk1 or negedge sys_rst_n) begin
   if (sys_rst_n == 1'b0) begin
       ack_in1 <= 1'b0;
       ack_in1_dly1 <= 1'b0;
   end

   else begin
       ack_in1 <= req_in2_dly1 ;
       ack_in1_dly1 <= ack_in1;
   end

end

//4、dout信号的产生
assign read_sync_pulse = req_in2 & ~req_in2_dly1;
endmodule
~~~

3. 测试代码
~~~
`timescale 1ns / 1ps

module TB();

reg sys_clk1; 
reg sys_clk2; 
reg sys_rst_n; 
reg read ;
initial begin
    sys_clk1 = 1'b0;
    sys_clk2 = 1'b0;
    sys_rst_n = 1'b0;

    read = 1'b0;

    #200
    sys_rst_n = 1'b1;

    #100
    read = 1'b1;

    #20
    read = 1'b0;
    #100
    read = 1'b1;
    #20
    read = 1'b0;

end

 always #10 sys_clk1 = ~sys_clk1;
 always #30 sys_clk2 = ~sys_clk2;

 handshake_sync u_handshake_sync(
    .clk1 (sys_clk1 ),
    .clk2 (sys_clk2 ),
    .sys_rst_n (sys_rst_n),
    .read (read ),
    .read_sync_pulse(read_sync_pulse )
 );

endmodule
~~~
4. 仿真结果
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/abb8173f-608a-4199-91ae-8d79bd11be08)



### 3. 传送门
1. [跨时钟域同步2---单bit信号同步实战(快到慢+慢到快)](https://zhuanlan.zhihu.com/p/452183878)
2. [IC面试中常被问到：跨时钟域信号处理——握手协议)](https://zhuanlan.zhihu.com/p/53799967)
3. [IC面试中常被问到——跨时钟域信号如何处理？](https://mp.weixin.qq.com/s?__biz=MzIxMzg0MDk0Mg==&mid=2247483904&idx=1&sn=198f0071e5a87740022e8bdc528cfb93&chksm=97b1e741a0c66e57607bdffa4d179e758b52ef6c6b8d1e328cf35db70040ea47d16ae69d2e13&scene=21#wechat_redirect)
4. [跨时钟域同步3---多bit信号同步(延迟采样法/慢到快)](https://zhuanlan.zhihu.com/p/452187232)
