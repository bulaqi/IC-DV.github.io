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
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/fa9ef2e0-d872-4dd5-be2e-11510f9b5b27)

##### 3. code
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
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/f48df870-f95c-430c-9fc7-c91ef98202f1)



### 3. 传送门
1. [跨时钟域同步2---单bit信号同步实战(快到慢+慢到快)](https://zhuanlan.zhihu.com/p/452183878)
2. [跨时钟域信号处理——握手协议(handshake)](https://zhuanlan.zhihu.com/p/53799967)
