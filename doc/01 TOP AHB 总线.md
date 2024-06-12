### 1. 基础知识
#### 1. 信号列表
1. 2个hready: 分别是 input和output
   - hready_o: slave 未准备好，反压master
   - heady_i: 在piple模式下，slave 根据该线判断master 是否已经完成对其他slave的响应，

#### 2. 注意事项
1. 每笔包括地址传输周期和数据传输周期
2. piple模式： 本次的data_phase是上次的addr_phase
3. 
### 2. 经验
### 3. 传送门
1. [AMBA总线—AHB总线协议详解](https://blog.csdn.net/weixin_46022434/article/details/104987905)
