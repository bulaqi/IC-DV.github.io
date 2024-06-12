### 1. 基础知识
#### 1. 信号列表
1. 2个hready: 分别是 input和output
   - hready_o: slave 未准备好，反压master
   - heady_i: 在piple模式下，slave 根据该线判断master 是否已经完成对其他slave的响应，
#### 2. 零等待时序--至少3拍完成
1. 1st_cycle: clk_posdege,master驱动地址和控制
2. 2st_cycle: slave 采用地址和控制，拉高hready_o
  - 写：master 写入数据
  - 读：slave 等hready后，读走数据
3. 3rd_cycle:
  - 写：master 读hready_o 高信号，表明salve 已将数据读走
  - 读：master 读hready_o 高信号，表明salve 已将数据读走
4. 注意时序：hready_o在数据有效期间必须为高，延续到第三个cycle 上升沿后，确保master采样正常

#### 2. 注意事项
1. 每笔包括地址传输周期和数据传输周期
2. piple模式： 本次的data_phase是上次的addr_phase
3. 
### 2. 经验
### 3. 传送门
1. [AMBA总线—AHB总线协议详解](https://blog.csdn.net/weixin_46022434/article/details/104987905)
