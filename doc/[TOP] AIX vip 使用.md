### 基础知识
#### 1. 协议
1. Constrain between size and address :  SVT_AXI_MAX_DATA_WIDTH

2. out of order transfer
~~~
this.slave_cfg[0].num_outstanding_xact = 16;
this.slave_cfg[0].reordering_algorithm = svt_axi_port_configuration::RANDOM;
this.slave_cfg[0].read_data_reordering_depth = 8;
~~~

~~~
Enable function
this.master_cfg[0].num_outstanding_xact = 16;
this.slave_cfg[0].num_outstanding_xact = 16;

Functional coverage
virtual function void new_transaction_started (svt_axi_port_monitor axi_monitor, svt_axi_transaction item);
  super.new_transaction_started(axi_monitor, item);
  num_outstanding_xact++;
endfunction

virtual function void transaction_ended (svt_axi_port_monitor axi_monitor, svt_axi_transaction item);
  super.transaction_ended(axi_monitor, item);
  num_outstanding_xact--;
endfunction
~~~

#### 2. 延时
1. 常用延时
~~~
// Master VIP
svt_axi_transaction::addr_valid_delay
svt_axi_transaction::wvalid_delay[]
svt_axi_transaction::rready_delay[]
svt_axi_transaction::bready_delay

// Slave VIP
svt_axi_transaction::addr_ready_delay
svt_axi_transaction::wready_delay[]
svt_axi_transaction::rvalid_delay[]
svt_axi_transaction::bvalid_delay
~~~

2.  Delay slave read response
~~~
if(req_resp.xact_type == svt_axi_slave_transaction::WRITE) begin
  put_write_transaction_data_to_mem(req_resp);
end
else begin
  req_resp.suspend_response = 1; 
  fork begin 
    repeat(10)@(posedge test_top.clk);//wait for some delay
    get_read_data_from_mem_to_transaction(req_resp);
    req_resp.suspend_response = 0;
  end
  join_none
end

~~~


3. Backdoor access on slave memory
~~~
axi_system_env.slave[0].axi_slave_mem.read(...);
axi_system_env.slave[0].axi_slave_mem.write(...);
axi_system_env.slave[0].axi_slave_mem.read_byte(...);
axi_system_env.slave[0].axi_slave_mem.write_byte(...);
axi_system_env.slave[0].axi_slave_mem.load_mem("mem_dump",,,0,32 );
~~~

4. Functional coverage
~~~
this.master_cfg[0].transaction_coverage_enable = 1
this.master_cfg[0].toggle_coverage_coverage_enable = 1
this.master_cfg[0].state_coverage_enable = 1

~~~

5. Error inject
~~~
virtual function void pre_read_data_phase_started (svt_axi_slave axi_slave, svt_axi_transaction xact);
  
  foreach (xact.rresp[index]) begin
    xact.rresp[index] = svt_axi_slave_transaction::SLVERR;
  end
endfunction

~~~
6. Bus inactive error
~~~
int attribute
svt_axi_system_configuration::bus_inactivity_timeout = 256000

//Bus inactivity is defined as the time when all five channels of the AXI interface are idle. A timer is started if such a condition occurs. The timer is incremented by 1 every clock and is reset when there is activity on any of the five channels of the interface. If the number of clock cycles exceeds this value, an error is reported. If this value is set to 0, the timer is not started.

~~~

7. Turn off trans log
~~~
svt_axi_port_configuration::silent_mode = 0
~~~
8. Trace log
~~~
//applicable when the axi system monitor is enabled
svt_axi_system_configuration::display_summary_report=6; 
svt_axi_port_configuration::enable_tracing=1;
svt_axi_port_configuration::enable_reporting=1;
svt_axi_port_configuration::data_trace_enable=1;

Log:
env.axi_system_env.master_0.monitor.transaction_trace

~~~


### 常用配置
#### 1. svt_axi_transaction
1. bvaild_delay
2. add_ready_delay
3. ZERO_DELAY_wt //于控制零延迟的权重
4. SHORT_DELAY_wt //短延迟的权重
5. LONG_DELAY_wt  //长延迟分布的权重

#### 2. port_configuration 
1. axi_interface_type
2. data_width
3. addr_width
4. id_width
5. reset_type
6. 信号的coverage和protocol check使能等，
7. 其中num_outstanding_xact可定义主从机支持的outstanding深度

### 传送门
1. [Synopsys验证VIP学习笔记（3）总线事务的配置和约束](https://blog.csdn.net/yumimicky/article/details/120531658?spm=1001.2101.3001.6661.1&utm_medium=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-120531658-blog-123188346.235%5Ev38%5Epc_relevant_yljh&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-120531658-blog-123188346.235%5Ev38%5Epc_relevant_yljh&utm_relevant_index=1)
