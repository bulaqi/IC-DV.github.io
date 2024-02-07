### 1. 常用包含功能
#### 1. 循环启动多个线程
~~~
...
	fork //启动但是不阻塞主线程
		for(int i =0 ;i<5 ;i++) begin
			fork   //for循环内必须是fork_join,才能是循环启动
				automatic int k k=i;  //参数必须是automatic 类型
				if(pf_if_type[k]== 0) begin
					get_act_data(k)   //启动该函数,如果函数的变量不共享,则子函数需定义为atuomatic 类型
				end
			join_none
		end
	join_none 
...
~~~
