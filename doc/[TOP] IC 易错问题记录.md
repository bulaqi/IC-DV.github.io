### 1. sv 约束范围约束的时候，必须inside{[小：大]}， 如果写反编译器不会报错，也不会报约束失败
### 2. super.configure_phase(),报错，super is not expect in this contex, 原因，**子类名称后忘记逗号**
### 3. 约束中local的使用
    在使用内嵌约束randomize（）with {CONSTRAINT}时，约束体中的变量名的查找顺序默认是从被随机化对象开始查找，但如果调用randomize（）函数局部域中也有同名变量，那就需要使用local::来显式声明该变量来源于外部函数，而非被随机化的对象（在约束中也可用this/super来索引这些变量
### 4. 队列的长度不要直接作为循环的条件，易错
### 5 .非类的变量约束,rand 变量能约束类变量,不能约束内的函数变量
### 6. 语法错误,编译器不会报错:
~~~
task  xx_tc::main_phase(uvm_phae phase);
        int q_rand;//函数内只能定义为变量,不能用rand 修饰
	beign

		//std::randmize(q_rand);
                //std::randomize(q_rand) with(q_randinside{[1:31]};); // 正确,注意语法,编译器不会报错,randomize后有括号,括号内包含q_rand,然后with 约束
                std::randomize() with(q_rand inside{[1:31]};); // 语法错误,编译器不会报错,randomize后有括号,括号内包含q_rand,然后with 约束

		$display("q_rand=%0d",q_rand);// 真随机，调用系统函数，
		$display("random_data=%0d",$random);//伪随机
	end
endmodule
~~~
### 6.约束失败导致的卡死,计算器卡死,导致平台卡死,无波形,固定卡在某个时间点,APB下配置的阶段,定位方向错误,所以, 有错误全文多上下文日志,否则看初始化流程,初步定位卡死的点
solver time out when solving following problem
sof cq_queue[i].depth dist{2:=10,[3:4095]:/30,[5096:65535]:/30,4095:=10}; //范围重复
sof cq_queue[i].depth dist{2:=10,[3:4095]:/30,[5096:65535]:/30,65536:=10};//错误,16bit最多表示65535

### 7.Verilog 位拼接运算符{}语法要点总结
[Verilog 位拼接运算符{}语法要点总结]
(https://blog.csdn.net/hanshuizhizi/article/details/116521728)
~~~
bit[11:0] aq_size;
bit[11:0] sq_size;
bit[31:0] aqa;
constrant aq_size_cons{aq_size dist {2:/10,[3:4095]:/30,4096:/10};}
constrant sq_size_cons{sq_size dist {2:/10,[3:4095]:/30,4096:/10};}
constran  aqa_cons{slove aq_size before aqa;slove sq_size before aqa;}
constrain qu_con {
  //soft aqa == {4'b0,aq_size,4'b0,sq_size}; //易错点,结果[31:28]  [15:12] 不为0
  soft aqa == {{4'b0},aq_size,{4'b0},sq_size}; //知识点:变量或者常量的重复（扩展）与拼接,变量必须用{}括起来再参与拼接
}
~~~

### 8.复杂的约束,求解器约束失败,系统卡死
在transaction 内有如下约束
~~~
...
	soft cq_queue[0].base_addr[63:12] inside{[64'h500,64'h600]};
	soft cq_queue[0].base_addr[11: 0] == {12{b'0}};
	soft cq_queue[0].depth dist{2:=10,[3:4095]}
	
	foreach(cq_queue[i]) { //cq_queue 深度33
		if(i > 0) {
			//soft cq_queue[i].depth dist {2:10,[3:4095]:/30}; //复杂度太高,求解器无法求出,仿真卡死
			soft cq_queue[i].depth inside {[2:4095]};
			soft cq_queue[i].base_addr == cq_queue[i-1].base_addr + 16* cq_queue[i-1].depth;
		}
	}
...
...
~~~

2种解决方案:
1. 将上述计算cq_queue[i].base_addr移至post_randomize
2. 写新类,内部用randc,选择addr的初值

### 9. for 循环内嵌套foreach
~~~
...
for(int i=0;i<5;i++) begin
	foreach(pf_cfg_pkt_p[i].cq_queue[j]){         //for循环内嵌套forech ,foreach变量j,内循环
		pf_cfg_pkt_p[i].cq_queue[j].depth > 32; 
	}
end
...
~~~

### 10. 结构体 auto_file 那个函数？
无，不能传递结构体，只能传递函数，函数用file_object实现

### 11. unpack  数组定位是那个方法？
packer.counter

### 12.类里面只能是变量初始化和复制,不能在类内直接计算
~~~
class xx_test extends basic_tc4;
int i =5;
int j =8;
if(i>5)                  //编译报错,类内不能直接赋值
  $print("i out rang");  //编译报错,类内不能直接赋值

~~~

### 13. for 循环内用fork
- 函数传参必须是automatic
- 被调函数也应该是automatic类型,否则被调函数内部变量会被公用
~~~
task cal_exp_burst_cnt();
  ...
	for (int i =0 ;i<5; i++) begin
		fork
			automatic int pf_id = i;  //必须是automaitc,否则cal_pf_exp_burst_cnt参数是5
			if(pf_bitmap_en[pf_id])
				cal_pf_exp_burst_cnt(pf_id);
		join_none
	end	
  ...
~~~

~~~
task automatic cal_pf_exp_burst_cnt(pf_id);
	int req_split; //如果函数类型不是automatic,则全部子进程公用一套req_split 变量
	...
endtask
~~~

### 14. 尽量选择同步电路,慎重使用组合逻辑,监测上升沿
背景:检测某型号的上升沿,采用@(posdege xx),
~~~
while(1) begin
   ...
   @(posdege xx);
   ...
end
~~~
问题:不可靠,组合逻辑内部是有可能出现毛刺,但是波形上不显示(受显示策略的影响)
解决方案:参考逻辑的实现,监测上升沿, if(singe == 1 && singe_1dely == 0)
~~~
while(1) begin
   ...
   @(posdege sys.clk);
   if(singe == 1 && singe_1dely == 0) begin 
   ...
   end
   ...
end
~~~


### 15 .跨时钟域的处理
- 背景: elbi 接口ack 和rsp 握手时候,信号采丢了,系统时钟是500M,elbi 时钟是1G. 核心问题,**ack 下降沿采丢了,没有做信号宽度扩展**
- 知识点: 跨时钟域的处理
  1. 单bit: 打一拍
  2. 多bit: 握手/ 异步fifo /转为独热码或格雷码
- 传送门   
  1. [芯片设计进阶之路——跨时钟信号处理方法](https://zhuanlan.zhihu.com/p/113832794)
  2. [跨异步时钟域的6种方法](https://blog.csdn.net/z951573431/article/details/117260698)

### 16. 跨层级的约束注意问题(易犯错)
在用例中通过seq约束transaction中的结构体数组,需要注意,结构体元素和结构体数组都应该设置为rand 类型,否则报约束冲突错误

### 16. 跨层级的约束
- 背景:transaction中基础约束,seq中附件约束,最终在用例中继续实现多态的约束
- 实现:尽量避免跨层级的约束,如果非要跨层级约束,建议修改为用例传参给下一级seq,
- 然后在seq内约束tranaction,不建议直接约束

### 17.正确理解rand 类型
- 知识点: 只有rand 类型的数据才能被randmomzize ,
- 背景:seq 中定义的变量如果是rand类型,则才能被randomize ,否则只能被之间赋值
- 方式1: \
1. xxx_sequence.sv
~~~
class xxx_sequence extends xxx_base_sequence
    ...
    rand bit [4:0] pf_bitmap_en;
    rand bit [4:0][32:0]  msix_ch_bitmap_en;
    ...
~~~
2. xxx_test.sv
~~~
assert(xxx_seq.randmozi with{
   ...
   xxx_seq.pf_bitmap_en == local:pf_bitmap_en;     // 只有rand 类型的才能在randmoize内约束
   xxx_seq.msix_ch_bitmap_en == local:msix_ch_bitmap_en;
   ...
});
~~~


- 方式2:
1. xxx_sequence.sv
~~~
class xxx_sequence extends xxx_base_sequence
    ...
    bit [4:0] pf_bitmap_en;       //非rand 类型
    bit [4:0][32:0]  msix_ch_bitmap_en;   //非rand 类型
    ...
~~~

2. xxx_test.sv
~~~
    //assert(xxx_seq.randmozi with{
    //  ...
    //  xxx_seq.pf_bitmap_en == local:pf_bitmap_en;     // 只有rand 类型的才能在randmoize内约束
    //  xxx_seq.msix_ch_bitmap_en == local:msix_ch_bitmap_en;
    // ...
    //});
	xxx_seq.pf_bitmap_en =  pf_bitmap_en;

	xxx_seq.msix_ch_bitmap_en == msix_ch_bitmap_en;
	xxx_seq.randmize();
~~~
### 18.assert 语法常见错误,多条件std约束时候,最后一个约束条件, 后必须有分号
~~~
assert(std::randomize(target) with{target>10;target<20;}); //注意,多条件std约束时候,最后一个约束条件,targe<20 后必须有分号
~~~


### 19. Makefile 编译的理解
编译时,指定sv的文件路径,如果该路径无sv文件,则编译错误,跳出编译
总结:依赖关系必须是要对应
~~~
.shadow/complile_tb:./shadow/compile_uvm $(TB_PAHT)/atc/*/*.sv  $(TB_PAHT)/atc/*/*/*.sv
~~~
问题描述:如果$(TB_PAHT)/atc/*/*.sv找不到文件,则依赖关系未解决,退出编译
修改:如果该路径无用例,则删除该路径;否则在路径下添加用例


### 20. 慎用disabale fork禁用整个衍生进程
~~~
fork
	begin:ring_host_dbl_timeout
		for(int i=0; i<5; i+++) begin
			automatic int pf_id = i;
			for(int cq_id; cq_id<33; cq_id++) begin
				fork
					automatic int cq_ch_id = cq_id;
					ring_host_dbl_with_mode(pf_id,cq_ch_id); //该子进程内部是死循环,内部调用AHB总线查询寄存器
				join_none				
			end
		end
	end
	
	while(1) begin
		@(posedeg aem_top_vif.aem_top_clk)
		if(!aem_top_vif.axim_wlast_o)
			idle_clk_cnt++;
		else 
			idle_clk_cnt =0 ;
			
		if(idle_clk_cnt > 2000) begin
			disable ring_host_dbl_timeout;  //问题:timeout跳出的时候,有可能上面的衍生子进程ring_host_dbl_with_mode,还在while(1) 调用AHB_vip
											//因:AHB_VIP 发送了seq请求,但是ring_host_dbl_with_mode被kill 掉,AHB_VIP 报错
			break;
		end
	end
joinjoin_any
~~~

- 报错信息:
xxx_uvm_test_top.env.ahb_sys_env.master[0].sequencer[SEQREQZMB] SEQREQZMB] The task responsible for requesting a wait_for_grant on sequencer 'xxx' for sequence 'default_parent_seq' has been bkilled, to avolid a deadlock thee sequence will be removed form the arbitraction queues.
- 解决方案
  在ring_host_dbl_with_mode 内部判断aem_top_vif.axim_wlast_o 超时,超时后break跳出
- 建议
  不建议,粗暴的之间disabel fork join 块,慎用

### 21. 合理的选择实现死循环读取的操作,建议写成seq,并且合理的选择 fork_join的操作,尽量避免fore循环嵌套多次层的fork join,
原因:如果最底层调用SEQ 读取接口,可以回报 xxx_uvm_test_top.env.elbi.sequencer[SEQREQZMB] SEQREQZMB] The task responsible for requesting a wait_for_grant on sequencer 'xxx' for sequence 'default_parent_seq' has been bkilled, to avolid a deadlock thee sequence will be removed form the arbitraction queues.

~~~
task check_msix_int_func()
	for(int i =0; i<5 ;i++) begin
		automatic int pf_id =i;
		...
		for(int j=0;j<33; j++) bgein
			automatic int int_ch_id =j;
			fork
				check_msix_ch_int_func(pf_id, int_ch_id);
			join
		end
	end	
endtask
~~~


~~~
task automatic  check_msix_ch_int_func(int pf_id, int int_ch_id);
	while(1) begin
		@(posedge aem_top_vif.aem_top_clk);
		if(cfg.main_phase_to_done_flag == 0) begin
			check_cqe_exit(pf_id,int_ch_id);
			delay_times(1000);
		end else if(cfg.main_phase_to_done_flag == 1)
		    break;
	end
endtask
~~~


~~~
task automatic check_cqe_exit(int pf_id, int int_ch_id);
	int ch_size = msix_ch_map_cq_tbl[pf_id][int_ch_id].size;
	for(int i=0; i < ch_size; i ++) begin
		ch = msix_ch_map_cq_tbl[pf_id][int_ch_id][i];
		read_pf_host_dbl_head(pf_id,cd,cq_head);                       // 此处,由前门访问改为后面访问,否则太消耗仿真时间,导致main_phase_to_done_flag后任务删除,seq报错
		read_pf_host_dbl_tail(pf_id,cd,cq_tail);                       // 此处,由前门访问改为后面访问
		if(cq_head != cq_tail) begin
			int cq_head_target = (cq_head < cq_tail)? cq_head:cq_tail
			//fork                                                      //此次不宜加fork_join,并行的运行,减少提前发送seq
				ring_pf_host_hdbl(pf_id,ch,cq_head_target);
			//join
		end
	end
endtask
~~~

### 22. 背景检查线程应该写在哪里? rm? basic_tc? seq? xx_tc?
根据aem项目经验,应该用seq实现,在用例中调用该seq,用例中控制该seq的启停,如果rm中有信号需要同步给tc,用全局变量或者event事件驱动

### 23. 功能覆盖率,covergroup的bin设置的时候, 不能直接用变量传进去,会报运行错误
1. 问题
~~~
covergroup cq_doordbl_overage_cov;
	iocq_door_size: coverpoint ahb_trans.data[0] iff (ahb_trans.addr == 'h1008) {
		bins over_iocq_depth = {[cfg.iocqe_ring_depth[0] : $]};  //此处cfg.iocqe_ring_depth,不能直接传,需要用采用通用覆盖组参数传,或者直接改为常量
	}
	acq_door_size: coverpoint ahb_trans.data[0] iff (ahb_trans.addr == 'h1008) {
		bins over_acq_depth = {[cfg.acqe_ring_depth[0] : $]};    //此处cfg.iocqe_ring_depth,不能直接传,需要用参数传
	}
endgroup
~~~
2. 解决方案
   2.1 covgrp 传参
   ~~~
   covergroup cq_doordbl_overage_cov(aem_top_config cfg);
   	iocq_door_size: coverpoint ahb_trans.data[0] iff (ahb_trans.addr == 'h1008) {
		bins over_iocq_depth = {[cfg.iocqe_ring_depth[0] : $]};  //此处cfg.iocqe_ring_depth,不能直接传,需要用采用通用覆盖组参数传
	}
	acq_door_size: coverpoint ahb_trans.data[0] iff (ahb_trans.addr == 'h1008) {
		bins over_acq_depth = {[cfg.acqe_ring_depth[0] : $]};    //此处cfg.iocqe_ring_depth,不能直接传,需要用采用通用覆盖组参数传
	}
   endgroup
   ~~~
   2.2 bin仓改为常量
   ~~~
   covergroup cq_doordbl_overage_cov();
   	iocq_door_size: coverpoint ahb_trans.data[0] iff (ahb_trans.addr == 'h1008) {
		bins over_iocq_depth = {[3 : $]};  //直接改为常量
	}
	acq_door_size: coverpoint ahb_trans.data[0] iff (ahb_trans.addr == 'h1008) {
		bins over_acq_depth = {[5 : $]};    //直接改为常量
	}
   endgroup
   ~~~
3. 原理总结
   bin仓是一个已经规定好的仓,目的是coverpoint是否在该范围,所以默认是常量,如果需要用到变量,需要特殊的处理,eg,参数传递

24. fork join 循环调用错误的使用,注意点:
    1. fork 内嵌套for循环,for 循环内的第一句应该就是automatic变量
    2. 后续条件中涉及cq_id 变量控制的,都应该替换为automatic变量
~~~
task automatic send_cq_axis(int pf_id,ref int send_iocq_hw_cnt[5]);
	fork
		for(int cq_id =0 ;cq_id <32 ;cq_id++) begin
			fork
				automatic int k = cq_id;        // for循环内的第一句应该就是automatic 变量问题
				//if(cqx_bitmap_en[pf_id][cq+1]) begin   //cq 在循环内必须完成需要已经,cq_id== 32
				if(cqx_bitmap_en[pf_id][k+1]) begin   //automatic内的必须是k为索引的
					send_cqe_axis_per_ch(pf_id,k,sen_iocq_hw_cnt)
				end
			join_none
		
		end
		while(1) begin
			@(posedge aem_top_vif.aem_top_clk);
			if(axi_rx_send_done[pf_id] == 'hffff)
				break;	
		end
	join
endtask
~~~

25. 循环启动衍生线程,且等待衍生线程的执行结果,通过全局变量实现,并行启动衍生线程,衍生线程置全部变量控制位,父线程循环检测完成状态
 - 1.正确方法示范:
1.send_cq_axis.sv 循环启动多线程,设置并行线程,等待子函数运行结束,通过axi_rx_send_done全局变量控制
~~~
task automatic send_cq_axis(int pf_id,ref int send_iocq_hw_cnt[5]);
	fork
		for(int cq_id =0 ;cq_id <32 ;cq_id++) begin
			fork
				automatic int k = cq_id;        // for循环内的第一句应该就是automatic 变量问题
				//if(cqx_bitmap_en[pf_id][cq+1]) begin   //cq 在循环内必须完成需要已经,cq_id== 32
				if(cqx_bitmap_en[pf_id][k+1]) begin   //automatic内的必须是k为索引的
					send_cqe_axis_per_ch(pf_id,k,sen_iocq_hw_cnt)
				end
			join_none
		
		end
		while(1) begin
			@(posedge aem_top_vif.aem_top_clk);
			if(axi_rx_send_done[pf_id] == 'hffff) //循环等待32个子线程,每个子线程完成后至该全部变量1bit的值,全部线程执行完备等效与该变量为FFFF
				break;	
		end
	join  // 此处是join,两个条件都满足才能结束父线程
endtask
~~~
2.send_cqe_axis_per_ch.sv 被调函数,内部对 控制线程的全局变量至位
~~~
task automatic send_cqe_axis_per_ch(int pf_id,int cq_id,ref int send_iocq_hw_cnt[5]);
	aem_axi_iocq_seq = aem_axi_iocq_sequence::type_id::creat("aem_axi_iocq_seq");
	aem_axi_iocq_err_seq = aem_axi_iocq_err_sequence::type_id::creat("aem_axi_iocq_err_seq");
	aem_axi_iocq_seq.start(vsequencer);
        send_iocq_hw_cnt[pf_id] = send_iocq_hw_cnt[pf_id] +aem_axi_iocq_seq.send_iocq_hw_cnt[pf_id];
	
	delay_time_ns(11000);
	aem_axi_iocq_err_seq.start(vsequencer);
	send_iocq_hw_cnt[pf_id] = send_iocq_hw_cnt[pf_id] +aem_axi_iocq_err_seq.send_iocq_hw_cnt[pf_id];
	
	axi_rx_send_done[pf_id][cq_id] = 1;  //子函数运行完成后对应为置1
endtask
~~~
 - 2. 易错方法解析:
   1.send_cq_axis.sv 循环启动多线程,设置并行线程,等待子函数运行结束,通过axi_rx_send_done全局变量控制
~~~
task automatic send_cq_axis(int pf_id,ref int send_iocq_hw_cnt[5]);
	fork
		for(int cq_id =0 ;cq_id <32 ;cq_id++) begin
			fork
				automatic int k = cq_id;        // for循环内的第一句应该就是automatic 变量问题
				//if(cqx_bitmap_en[pf_id][cq+1]) begin   //cq 在循环内必须完成需要已经,cq_id== 32
				if(cqx_bitmap_en[pf_id][k+1]) begin   //automatic内的必须是k为索引的
					send_cqe_axis_per_ch(pf_id,k,sen_iocq_hw_cnt)
				end
			join_none
		
		end
		while(1) begin
			@(posedge aem_top_vif.aem_top_clk);
			if(axi_rx_send_done[pf_id] == 'hffff) //循环等待32个子线程,每个子线程完成后至该全部变量1bit的值,全部线程执行完备等效与该变量为FFFF
				break;	
		end
	join  // 此处是join,两个条件都满足才能结束父线程
endtask
~~~
2.send_cqe_axis_per_ch.sv,该函数只运行了aem_axi_iocq_seq
~~~
task automatic send_cqe_axis_per_ch(int pf_id,int cq_id,ref int send_iocq_hw_cnt[5]);
	aem_axi_iocq_seq = aem_axi_iocq_sequence::type_id::creat("aem_axi_iocq_seq");
	aem_axi_iocq_err_seq = aem_axi_iocq_err_sequence::type_id::creat("aem_axi_iocq_err_seq");
	aem_axi_iocq_seq.start(vsequencer);
        send_iocq_hw_cnt[pf_id] = send_iocq_hw_cnt[pf_id] +aem_axi_iocq_seq.send_iocq_hw_cnt[pf_id];
	
	delay_time_ns(11000);
	aem_axi_iocq_err_seq.start(vsequencer);
	send_iocq_hw_cnt[pf_id] = send_iocq_hw_cnt[pf_id] +aem_axi_iocq_err_seq.send_iocq_hw_cnt[pf_id];
	
	//axi_rx_send_done[pf_id][cq_id] = 1;  //子函数运行完成后对应为置1
endtask
~~~
