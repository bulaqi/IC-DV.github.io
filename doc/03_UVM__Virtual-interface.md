[TOC]

背景：应该尽量杜绝在验证平台中使用绝对路径
### 1.绝对路径

driver中等待时钟事件（@posedge top.clk）、给DUT中输入端口赋值（top.rx_dv<=1‘b1）都是使用绝对路径，绝对路径的使用大大减弱了验证平台的可移植性。一个最简单的例子就是假如clk信号的层次从top.clk变成了top.clk_inst.clk，那么就需要对driver中的相关代码做大量修改。因此，从根本上来说，应该尽量杜绝在验证平台中使用绝对路径

### 2.宏   
![image](https://user-images.githubusercontent.com/55919713/221830405-6c213f4d-76b7-4ce3-b348-8d0cd970e7d3.png)

当路径修改时，只需要修改宏的定义即可。但是假如clk的路径变为了top_tb.clk_inst.clk，而rst_n的路径变为了

top_tb.rst_inst.rst_n，那么单纯地修改宏定义是无法起到作用的。



### 3.interface

在SystemVerilog中使用interface来连接验证平台与DUT的端口
![image](https://user-images.githubusercontent.com/55919713/221830126-6e031452-334c-4574-8d19-52668d392c9d.png)
