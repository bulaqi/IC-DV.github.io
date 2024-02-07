#### 1. 循环启动多个线程,最内层用automatic 变量
~~~
fork
	for(int i = 0; i < 5; i++) begin
		automatic int k= i;
		fork
			get_seq_data(k);
			pre_send(k);
			send_data(k);
		join_none
	end
join_none
~~~
#### 2. 数量和时间聚合
~~~
std::randmize(coal_num) with{coal_num inside {[1:8]};};
std::randmize(cola_timeout) with{cola_timeout inside {[1:20]};};
fork
	process proc_a;
	process proc_b;
	begin
		proc_a = process::self();
		wait(act_sqe_q[sq_id].size >= coal_num);
		proc_b.kill();
	end
	begin
		proc_b = process::self();
		repeat(100*cola_timeout) 
			@(posedge vif.clk);
		proc_a.kill();
	end
join
~~~

#### 3. 模拟流水线工作
- 通过类元素传递变量
- 通过队列实现模拟流水操作
~~~
class aem_sqcq_sq_info extends uvm_object;
	int pf_id;
	int pf_code
	svt_axi_transaction rsv_sq_data[$];
	svt_axi_transaction act_sq_q_tmp[$];
	`uvm_object_utils_begin(aem_sqcq_sq_info)
	`uvm_object_utils_end
	function new(string naem = "");
		super.new();
	endfunction
endclass


class aem_sq_colletor extends uvm_objec #(svt_axi_transaction);
	...
	`uvm_object_utils_begin(aem_sq_colletor)
	`uvm_object_utils_end
	...
	aem_sqcq_sq_info sq_info_arr[32][2];
	...

	function new(string naem = "");
		super.new();
		for(int ch_id =0 ;ch_id<32;  ch_id++) begin
			for(int type_id = 0; type_id < 2; type_id++) begin
				sq_info_arr[ch_id][type_id] = new($sformatf("sq_info_arr[$0d][$0d]",ch_id,type_id));
			fend
		end
	endfunction
	extern vitual task run_phase(uvm_phase phase);
endclass


task aem_sq_colletor::run_phase(uvm_phase phase);
	fork
		for(int i = 0; i<32; i++ ) begin
		automatic int sq_id = i;
			fork
				get_data(sq_id,0,sq_info_arr[sq_id][0]);
				get_data(sq_id,1,sq_info_arr[sq_id][1]);
								
				pre_send_data(sq_id,0,sq_info_arr[sq_id][0]);
				pre_send_data(sq_id,1,sq_info_arr[sq_id][1]);
								
				send_data(sq_id,0,sq_info_arr[sq_id][0]);
				send_data(sq_id,1,sq_info_arr[sq_id][1]);
			join_none
		end
	join
endtask


task automatic aem_sq_colletor::get_data(int sq_id,int pf_code,aem_sqcq_sq_info sq_info );
	while(1) begin
		wait(xx.sq_scb_axi.size() >0 );
		...
		// add time task,
		sq_info.rsv_sq_data.push_back(axi_split_tmp);
		...
	end
	@(posdege vif.aem_top_clk);
endtask


task automatic aem_sq_colletor::pre_send_data(int sq_id,int pf_code,aem_sqcq_sq_info sq_info );
	while(1) begin
		wait(sq_info.rcv_sq_data.size() >0 );
		...
		// add time task,
		sq_info.act_sq_q_tmp.push_back(sq_info.rcv_sq_data.pop_front());
		...
	end
	@(posdege vif.aem_top_clk);
endtask


task automatic aem_sq_colletor::send_data(int sq_id,int pf_code,aem_sqcq_sq_info sq_info );
	while(1) begin
		wait(sq_info.act_sq_q_tmp.size() >0 );
		...
		// add time task,
		sq_info.act_sq_q_tmp.push_back(sq_info.act_sq_q_tmp.pop_front());
		...
	end
	@(posdege vif.aem_top_clk);
endtask
~~~

#### 4.  数量聚合和时间聚合的代码示例,等到一个条件满足父进程继续
~~~
std::randmize(coal_num) with{coal_num inside {[1:8]};};
std::randmize(cola_timeout) with{cola_timeout inside {[1:20]};};
fork
	process proc_a;
	process proc_b;
	begin
		proc_a = process::self();
		wait(act_sqe_q[sq_id].size >= coal_num);
		proc_b.kill();
	end
	begin
		proc_b = process::self();
		repeat(100*cola_timeout) 
			@(posedge vif.clk);
		proc_a.kill();
	end
join
~~~
#### 5. mask的正反用法
~~~
wdata = ($urandom_range(32'h0,32'hffff_ffff) &mask)  | (val &^(~mask)))
//解读:mask 为1,选择随机值, mask为0,不屏蔽,选取VAL值
~~~
#### 6. 等待所以衍生线程
#### 7. 停止从当前线程衍生的所有 子线程
