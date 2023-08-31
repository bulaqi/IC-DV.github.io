### 1. 波形入门
1. 信号是clk上升沿采集的
2. clk 上升沿的左值是上次值,右侧是本次值

### 2. 信号(时间的理解,采样是采信号点前的数据,赋值是影响clk后的数据)
1. 采样是采clk上升沿前的数据
2. 把逻辑信号赋值是,是上升沿后的信号被赋予新值
3. eg 
   ![901c6a2513f931bd2655fb67470b2bd](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/336b129c-5152-4717-b84a-e2f80e99ff8f)


### 3. 上升沿,下降沿判断
1. 上升沿:(signal== 1'b1) && (signal_1delay==0)
2. 下降沿:(signal== 1'b0) && (signal_1delay==1)
