### 基础问题
#### 1. 模型中寄存器3个值
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
前门访问-寄存器产生uvm_reg_item，adapter把uvm_reg_item转为bus_drive能用的transaction，将transaction传递给bus_sequencer，在由sequencer传递给driver.  

无论前门还是后门的wirte，都会调用**uvm_reg::predict()**来修改mirror value，design value。
- 前门访问会在**总线事务完成后修改**，采用的显示预测。
- 后门访问直接**在0时刻修改**，采用自动预测。
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/4a3501f8-aadd-42e4-b99c-0f91f6f3e701)

##### 2. read
 同write，会调用uvm_reg::predict()来修改mirror value，design value
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/678d66ae-e099-4077-b941-b0c4b253a331)

##### 3. peek 后门读取，利用UVM DPI直接读取硬件实际值
##### 4. poke 后门修改硬件实际值
##### 5. set -修改寄存器模型中的desire value
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/6405aacc-3ebb-43d0-89a6-de049a88641e)

##### 6. mirror -读回硬件的实际值，通过第二个参数可以控制更新或者检查。
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/ff1769d6-2b7a-4cbc-a832-3166f9675e40)

mirror与read的区别在于mirror可以进行检查。
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/2290b724-cf15-4d3a-8fea-8b8748165b63)

##### 7. update -如果期望值/镜像值不同于实际值，则修改硬件实际值。
 在uvm_reg_block调用update后，会对里面的每个reg进行update，每个reg又会对自身的field进行write操作，所以可以更新期望值和镜像值
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/54471f70-2211-4ffe-8a55-88739685cc33)

##### 8. predict -能够修改mirror_value, design_value的核心。
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/4805c1ed-363a-4aa6-b81e-eea52f4e78c9)
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/ed873911-d7be-4377-82cc-8ede6d54dac5)

 更新field的镜像值和所需值

kind有三种参数：
How the mirror is to be updated
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/077bb4e3-d5ca-4523-9cb1-9099b6607078)
如果想要更新镜像值又不对DUT进行操作，要用UVM_PREDICT_DIRECT。
- write、read、peek和poke在完成对DUT的读写之后也会调用这个函数，更新镜像值，期望值。

##### 9：randomize
当寄存器随机化后，期望值会被随机，但是镜像值不变，之后调用update任务，可以更新DUT中的寄存器值。
　　一个field能够被随机化，要求：　　　　
  1. 在filed的configure第八个参数设为1.
　2. filed为rand类型。
  3. filed的读写类型为可写的。


#### 4. 总结
- read、write、peek、poke、update可以修改desire/mirror value，
- set，randomize只修改desire value，
- mirror只修改或检查mirror value，
- 
### 传送门
1. [寄存器模型常用方法](https://blog.csdn.net/qq_43445577/article/details/119701467)
2. [图解UVM寄存器訪問方法](https://xueying.blog.csdn.net/article/details/106148117?spm=1001.2014.3001.5502)
3. [uvm_reg中修改mirror、desired、actual value的方法总结](https://blog.csdn.net/LSC0311/article/details/127338692)
4. [【UVM】调用peek、poke后，后台访问无变化](https://blog.csdn.net/baidu_39603247/article/details/124082291)
