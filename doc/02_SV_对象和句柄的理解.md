### 基本知识

### 示例
~~~
for(int i=0;i<inputs.burst_length;i++)
	axi_rcv_data_arrary.push_back(inputs.data[i]);
	while(axi_rcv_data_arrary.size > 0) begin
		//nvme_cqe_trans= new ("nvme_cqe_trans")// 易错点，如果没有，端口数据只会是最后一个数据，
							//因为句柄会被覆盖
		axi_rcv_data_arrary = axi_rcv_data_arrary.pop_front;
		for(int i=0; i<4;i ++) begin
			cqe_data_array[i]= axi_rcv_data_arrary[i*32+32];
			
		end
		bit_array = {>>{16'(pf_id),16'(cq_id),cqe_data_array[0],cqe_data_array[1],cqe_data_array[2],cqe_data_array[3]}};
		nvme_cqe_trans.unpack(bit_array);
		hw_outport[pf_id].put(nvme_cqe_trans);
	end
~~~

### 常用函数
### 注意事项
### 参考
