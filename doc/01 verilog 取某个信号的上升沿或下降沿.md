### 1. 知识点
#### 1. 概述
  - 取一个信号的上升沿或下降沿信号，可以通过将信号delay后，然后将原信号和delay信号，通过不同的与非操作，获取上升沿信号或下降沿信号：
#### 2. 阶段1
eg delay;        // delay信号
~~~
always @ ( posedge clk or negedge rstn )
  if( !rstn )
     delay <= 0;
  else
     delay <= orig;   // orig是原信号
wire pos_signal = orig && ( ~delay );       // 原信号上升沿位置处产生的pulse信号
wire neg_signal = ( ~orig ) && delay;      // 原信号下降沿位置处产生的pulse信号
~~~

#### 2. 阶段2
- 存在问题:
  上述操作会存在亚稳态问题，并且得到的上升沿信号pos_signal和下降沿信号neg_signal无法被原采样时钟clk采样。正确做法是，先将原信号用采样时钟delay 2次（打两拍），得到和采样时钟同时钟域的信号delay2，然后再按上述方法获取上升沿和下降沿信号，这时得到的上升沿或下降沿就可以被原采样时钟采样。
eg ori_signal;// 需取上升沿或下降沿的原信号
~~~
reg delay1;
reg delay2;

always @ ( posedge clk or negedge rstn )
  if( !rstn )
     delay1 <= 0;
  else
     delay1 <= ori_signal;   

always @ ( posedge clk or negedge rstn )
  if( !rstn )
     delay2 <= 0;
  else
     delay2 <= delay1;  // delay2 已与clk同域


reg delay3;
always @ ( posedge clk or negedge rstn )
  if( !rstn )
     delay3 <= 0;
  else
     delay3 <= delay2;   
	 
wire pos_signal = delay2 && ( ~delay3 );       // 原信号上升沿位置处产生的pulse信号
wire neg_signal = ( ~delay2 ) && delay3;      // 原信号下降沿位置处产生的pulse信号
~~~
- 上升沿电路如下：
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/9f508a0c-1e8a-43c6-a4d5-96b2c0549263)

#### 3. 阶段3
用阶段二的语句会比较繁琐，可以用下述语句简化：
~~~
reg[2:0] delay;
always @ ( posedge clk or negedge rstn )
  if( !rstn )
     delay <= 0;
  else
     delay <= { delay[1:0], ori_signal} ; // ori_signal是原信号


wire pos_signal = delay[1] && ( ~delay[2] );       // 原信号上升沿位置处产生的pulse信号
wire neg_signal = ( ~delay[1] ) && delay[2];      // 原信号下降沿位置处产生的pulse信号
~~~


### 2. 传送门
1. [verilog入门经验（三）取某个信号的上升沿或下降沿信号](https://blog.csdn.net/phenixyf/article/details/46634257#:~:text=%E5%8F%96%E4%B8%80%E4%B8%AA%E4%BF%A1%E5%8F%B7%E7%9A%84%E4%B8%8A%E5%8D%87%E6%B2%BF%E6%88%96%E4%B8%8B%E9%99%8D%E6%B2%BF%E4%BF%A1%E5%8F%B7%EF%BC%8C%E5%8F%AF%E4%BB%A5%E9%80%9A%E8%BF%87%E5%B0%86%E4%BF%A1%E5%8F%B7delay%E5%90%8E%EF%BC%8C%E7%84%B6%E5%90%8E%E5%B0%86%E5%8E%9F%E4%BF%A1%E5%8F%B7%E5%92%8Cdelay%E4%BF%A1%E5%8F%B7%EF%BC%8C%E9%80%9A%E8%BF%87%E4%B8%8D%E5%90%8C%E7%9A%84%E4%B8%8E%E9%9D%9E%E6%93%8D%E4%BD%9C%EF%BC%8C%E8%8E%B7%E5%8F%96%E4%B8%8A%E5%8D%87%E6%B2%BF%E4%BF%A1%E5%8F%B7%E6%88%96%E4%B8%8B%E9%99%8D%E6%B2%BF%E4%BF%A1%E5%8F%B7%EF%BC%9Areg%20delay%3B%20%2F%2F%20delay%E4%BF%A1%E5%8F%B7always%20%40%20%28posedge%20clk%20or,negedge%20rstn%29%20if%20%28%21rstn%29%20delay%20else%20delay%20wire_verilog%E8%AF%AD%E8%A8%80%E5%8F%96%E4%BF%A1%E5%8F%B7%E7%9A%84%E4%B8%8A%E5%8D%87%E6%B2%BF)
