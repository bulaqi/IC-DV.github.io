[TOC]
#### 1. FIFO简介
   两种FIFO，①uvm_tlm_analysis_fifo， ②uvm_tlm_fifo。  
   差别在于前者有一个analysis_export端口， 并且有一个write函数， 而后者没有
   ![image](https://user-images.githubusercontent.com/55919713/224034193-04171266-0a16-4d35-abdd-2360668b50f8.png)\
说明
- 以圆圈表示的EXPORT虽然名字中有export， 但是本质上都是IMP。
- 上图中还有两个analysis_port： put_ap和get_ap\
    当FIFO上的blocking_put_export或者put_export被连接到一个blocking_put_port或者put_port上时， FIFO内部被定义的put任务被调用， 这个put任务把传递过来的Transaction放在FIFO内部的缓存里， 同时， 把这个transaction通过put_ap使用write函数发送出去.
- 调试 
   > used：用于查询FIFO缓存中有多少transaction。   
   > is_empty/is_full：用于判断当前FIFO缓存是否为空/满。  
   > flush：用于清空FIFO缓存中的所有数据， 它一般用于复位等操作

#### 2. 示例
![image](https://user-images.githubusercontent.com/55919713/224035753-56c18760-7209-4636-ba07-c3441c9b67b7.png)
![image](https://user-images.githubusercontent.com/55919713/224035777-98d339b2-009b-41ae-99b6-43eba6b6cf9b.png)

#### 3. 分析
端口对应关系：\
![image](https://user-images.githubusercontent.com/55919713/224035913-641657d7-bbe2-49bd-a22a-4a64d0362ff9.png)  

#### 4. 总结:

##### 1. 定义端口类型：  
~~~
   `define OUTPORT uvm_blocking_put_port  
   `define INPORT uvm_get_peek_port
~~~
##### 2. connet phase 连线     
~~~
   uvm_tlm_analysis_fifo #(my_transaction) u_fifo_rm_2_scb  
   ...  
   u_fifo_rm_2_scb = new("u_fifo_rm_2_scb");   
   ...  
   //connect_pahse   
   scb.inport.connect(u_fifo_rm_2_scb.get_peek_export);   
   rm.outport.connect(u_fifo_rm_2_scb.blocking_put_export);  
~~~
##### 3. 实际使用   
~~~~
   inport.get(xx_in_trans);  
   outport.put(xx_out_trans); 
~~~~