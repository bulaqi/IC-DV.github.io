### 1. 基础概念
#### 1. 三者的关系
1. sequence不属于验证平台的任何一部分，但是它与sequencer之间有密切的联系， 这点从二者的名字就可以看出来。 
2. 只有在sequencer的帮助下，sequence产生出的transaction才能最终送给driver； 
3. 同样，sequencer只有在sequence出现的情况下才能体现其价值， 如果没有sequence， sequencer就几乎没有任何作用。
4. sequence就像是一个弹夹， 里面的子弹是transaction， 而sequencer是一把枪。 弹夹只有放入枪中才有意义， 枪只有在放入弹夹后才能发挥威力

#### 2. drive 的逻辑
- get_next_item , 时序输出, item_done();
- 

![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/031e6fb3-5cea-4bdd-936a-58f9b7ce1365)


### 2. 个人理解(结合AXI vip)
1. axi VIP是slave,需要将axi_salve_mem_response_sequce 传给VIP 环境,
2. 先在body中声明一个svt_axi_slave_transaction的对象req_resp，然后通过peek方式从slave sequencer（源头是slave的monitor，又通过了TLM port传给了sequencer）获取slave VIP的响应请求实例句柄，如下。
   ~~~
   p_sequencer.response_request_port.peek(req_resp);
   ~~~
3. 成功后，进行slave响应的设置，首先设置响应bresp和rresp的值，再设置delay的反压、交织（interleave，又名间插）。



### 3. 传送门
