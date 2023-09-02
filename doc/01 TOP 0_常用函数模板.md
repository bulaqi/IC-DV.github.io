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
