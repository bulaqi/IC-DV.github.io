# 1. 预知识
    interface的信号可以不连接到DUT上，可以利用该信号实现 接收N个数据后，才结束平台

# 2.思路
  思路，在用例fork一个线程，该线程检测初始是否是有N次

# 3. 实例

- 1. interface(声明信号，信号复位逻辑，只维持1拍)
~~~
logic nxt_xx_done;
...
always@(posedge  sys_clk) begin
	if(nxt_xx_done == 1'b1) begin
		nxt_xx_dones <=1'b1
	end else begin
		nxt_xx_done <=1'b0
	end
end
~~~

- 2. out_monitor( 收到axi总线数据后，置位计数信号)
~~~
fork
    xx_rev_pkt();
    rcv_wait_done(tr);
join


...
task xx::rcv_wait_done(axi_transcaion tr)
    if(tr.addr) 
	xx_vif.nxt_xx_done << 1;
endtask
...
~~~

- 3. basic_tc( 等待收到1次axi的接收完成信号)
~~~
task xx_basic_tc::one_axi_trans_done
	@(posedge top_vif.axi_clk iff(top_vif.nxt_xx_done ==1'b1));
endtask
~~~

- 4. 用例中xx_test.sv（run_phase中等待，发的数目和接收的数目一致）
~~~
run_phase();
...
	fork
		repeat(N) begin
			`uvm_do_with(my_transacion)
		end
		
		repeat(N) begin
			one_axi_trans_done();
		end	
	join
....
end_phase
~~~