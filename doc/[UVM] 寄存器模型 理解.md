### 基础问题
### 1. 模型中寄存器3个值
   寄存器模型中的寄存器，其每个field有两个值，分别是：
   1. 期望值（desired value），
   2. 镜像值（mirror value）。
   3. 硬件中寄存器的值为实际值（actual value），利用三个值可以帮助实现寄存器模块的检查
#### 2. 修改3个值的方法
   1. read
   2. write
   3. peek
   4. poke
   5. mirror
   6. update
   7. set
#### 3. 方法展开
##### 1. write
前门访问-寄存器产生uvm_reg_item，adapter把uvm_reg_item转为bus_drive能用的transaction，将transaction传递给bus_sequencer，在由sequencer传递给driver
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/4a3501f8-aadd-42e4-b99c-0f91f6f3e701)
无论前门还是后门的wirte，都会调用**uvm_reg::predict()**来修改mirror value，design value。
前门访问会在**总线事务完成后修改**，采用的显示预测。后门访问直接**在0时刻修改**，采用自动预测。

### 传送门
1. [寄存器模型常用方法](https://blog.csdn.net/qq_43445577/article/details/119701467)
2. [uvm_reg中修改mirror、desired、actual value的方法总结](https://blog.csdn.net/LSC0311/article/details/127338692)
