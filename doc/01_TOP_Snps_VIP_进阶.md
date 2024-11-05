### 1.	VIP的配置
#### 1. 概述
验证环境的verif/atb/cfg目录，有一个可以被扩展的基类（已经在VIP里定义好,svt_axi_system_configuration。在cfg目录里去扩展它，扩展后的内容就是AXI VIP的配置
#### 2. AXI VIP
~~~
•	common_clock_mode: 默认为1，表示整个环境里所有的AXI VIP使用同一个时钟，否则不是——建议修改为0。
•	num_masters : 整个环境里需要的master VIP个数，直接赋值即可，如果赋值为0则表示没有master VIP。
•	num_slaves：整个环境里需要的slave VIP个数，直接赋值即可，如果赋值为0则表示没有slave VIP。
•	create_sub_cfgs(num_masters, num_slaves)：创建配置让个数的配置生效。
•	wready_watchdog_timeout：wvaid有效后，等待wready的超时阈值，如果等待的clock数超过这个阈值则VIP报错，此配置only for master VIP——适用于存在反压的场景。
•	rready_watchdog_timeout：rvalid有效后，等待rready的超时阈值，如果等待的clock数超过这个阈值则VIP报错，此配置only for slave VIP——适用于存在反压的场景。
•	master_cfg[idx].addr_width：idx取值范围是[0, num_masters-1]，表示master VIP的地址宽度。
•	master_cfg[idx].data_width：idx取值范围是[0, num_masters-1]，表示master VIP的数据宽度。
•	master_cfg[idx].is_active：指定该VIP属于active输入模式还是passive输出模式，输出模式只有monitor没有driver和sequencer，默认是输入模式。
•	master_cfg[idx].axi_intereface_type：VIP使用的协议版本，赋值举例：svt_axi_port_configuration::AXI4、svt_axi_port_configuration::ACE、svt_axi_port_configuration::AXI4_STREAM。
•	master_cfg[idx].silent_mode：默认为0，为1的时候，可以减少类似表征VIP事务开始/结束的打印信息——适用于仿真log比较大、操作量大的场景。
•	master_cfg[idx].wysiwyg_enable：默认为0，为1的时候表示“所见即所得”，VIP将以图形表格的形式呈现仿真结果（没试过，不知道是什么效果）。
•	master_cfg[idx].num_outstanding_xact：顾名思义，VIP可以支持的outstanding个数，VIP如果发的事务个数等于这个值，那么会停止再发直到小于这个值——这个值请和自己的架构对齐。
•	master_cfg[idx].num_read_outstanding_xact：顾名思义，VIP可以支持的读outstanding个数，只有当num_outstanding_xact为-1的时候才生效——这个值请和自己的架构对齐。
•	master_cfg[idx].num_write_outstanding_xact：顾名思义，VIP可以支持的写outstanding个数，只有当num_outstanding_xact为-1的时候才生效——这个值请和自己的架构对齐。
•	master_cfg[idx].zero_delay_enable：默认为0，为1的时候表示所有和delay相关的参数被强制置零——请谨慎使用。
•	master_cfg[idx].enable_tracing：默认为0，为1的时候，可以生成一个文件，文件里包含VIP事务的trace信息（没试过，不知道是什么效果）。
•	master_cfg[idx].enable_reporting：默认为0，为1的时候，可以生成一个文件，文件里包含VIP事务的report信息（没试过，不知道是什么效果）。
•	master_cfg[idx].default_rready：设置master VIP rready初始值，默认为1（bready同理）。
•	slave_cfg[idx].num_outstanding_xact：顾名思义，VIP可以支持的outstanding个数，VIP如果收的事务个数等于这个值，那么不会拉高arready/awready直到小于这个值——这个值请和自己的架构对齐。
•	slave_cfg[idx].default_awready：设置slave VIP awready初始值，默认为1（arready同理）。
•	slave_cfg[idx].default_wready：设置slave VIP wready初始值，默认为1。
•	set_addr_range(idx, min_addr, max_addr)：为此slave VIP设置地址范围，可以设置多次以实现多个地址范围。
•	protocol_checks_enable：默认为1，表示使能协议检查，如果修改配置为0则不会报协议违例信息（error或warning）——建议用默认值1。
•	上面的master_cfg[idx]的参数同样适用于slave_cfg[idx]，解释相同，除了num_outstanding_xact有差别。
~~~
#### 1. AHB VIP
~~~
•	common_clock_mode: 默认为1，表示整个环境里所有的AHB VIP使用同一个时钟，否则不是——建议修改为0。
•	common_reset_mode: 默认为1，表示整个环境里所有的AHB VIP使用同一个复位，否则不是——建议修改为0。
•	num_masters : 同AXI VIP。
•	num_slaves : 同AXI VIP。
•	create_sub_cfgs(num_masters, num_slaves)：同AXI VIP。
•	master_cfg[idx].addr_width：同AXI VIP。
•	master_cfg[idx].data_width：同AXI VIP。
•	master_cfg[idx].is_active：同AXI VIP。
•	slave_cfg[idx].addr_width：同AXI VIP。
•	slave_cfg[idx].data_width：同AXI VIP。
•	slave_cfg[idx].is_active：同AXI VIP。
•	set_addr_range(idx, min_addr, max_addr)：同AXI VIP。
•	ahb_lite：默认为0，为1的时候表示打开Lite模式（不支持split和retry）。
•	ahb_lite_multilayer：默认为0，为1的时候支持多个AHB master VIP——所以，如果num_masters大于1，建议此处配置为1。
•	ahb5：默认为1，为1的时候使能AMBA 5 AHB特性。
•	protocol_checks_enable：同AXI VIP。

~~~

#### 3. APB VIP
~~~
•	num_slaves : 同AXI VIP。
•	create_sub_cfgs( num_slaves)：同AXI VIP
•	paddr_width: APB VIP地址宽度。
•	pdata_width：APB VIP数据宽度。
•	apb3_enable：使能APB3特性。
•	apb4_enable：使能APB4特性。
•	slave_addr_range[idx]：首先要执行new，创建其实例化对象。
•	slave_addr_range[idx].start_addr：设置slave VIP的地址范围的起始地址。
•	slave_addr_range[idx].end_addr：设置slave VIP的地址范围的结束地址。
•	slave_addr_range[idx].slave_id：为当前的slave VIP设置一个id——当系统中有两个或以上的APB slave VIP时，建议进行配置，且互相不能有相同的。

~~~

### 2.	VIP的sequence for driver
#### 1. AXI master VIP
1. AXI master写
~~~
1.要扩展svt_axi_master_base_sequence，产生扩展类。
2.在扩展类的body task中，可以实现修改master VIP发送的事务时序。
先在body中声明一个svt_axi_master_transaction的对象，然后create它的实例，如下（以写为示例，读同理）。
svt_axi_master_transaction write_trans;
`uvm_create(write_trans)
然后配置该实例的协议类型内容：
//awburst、awsize、awaddr、awid、awlen请提前赋值
write_trans.xact_type = svt_axi_master_transcation::WRITE;
write_trans.burst_type = awburst;
write_trans.burst_size = awsize;
write_trans.addr = awaddr;
write_trans.id = awid;
write_trans.burst_length = awlen;

write_trans.wstrb = new[write.trans.burst_length];
write_trans.data = new[write.trans.burst_length];
write_trans.wvalid_delay = new[write.trans.burst_length];

//驱动wstrb，请提前声明好wstrb_width
foreach(write_trans.wstrb[i]) begin
    wstrb_width = (1<<write_trans.burst_size);
    write_trans.wstrb[i] = (1<<wstrb_width) - 1;
end

//驱动写数据,请按照位宽提前声明好data
foreach(write_trans.data[i]) begin
    write_trans.data[i] = (data>>(i*8));
end

//驱动wvalid和下一个wvalid之间的delay，此处设置为0，可以修改为其它值
foreach(write_trans.wvalid_delay[i]) begin
    write_trans.wvalid_delay[i] = 0;
end

//驱动bready拉高完成握手后再拉低反压的时钟数，注意先把上面提到的default_bready设置为默认的1。
//如果default_bready改为0，则bready_delay表示拉高持续的时钟数。
write_trans.bready_delay = $urandom_range(15);
上述协议内容配置完毕，可以发送了，然后等待完成。
`uvm_send(write_trans);

//等待事务完成，检查响应
//resp_check_type表示用户的期望响应结果，请提前赋值。
get_response(rsp);
case(resp_check_type)
    2'b00:
        if(rsp.bresp != svt_axi_slave_transaction::OKAY)
            `uvm_error(get_type_name,"xxxxxx")
    2'b10:
        if(rsp.bresp != svt_axi_slave_transaction::SLVERR)
            `uvm_error(get_type_name,"xxxxxx")
    2'b11:
        if(rsp.bresp != svt_axi_slave_transaction::DECERR)
            `uvm_error(get_type_name,"xxxxxx")
endcase
自此，AXI master写的sequence就完成了。通过上述代码，我们可以看到可以修改burst的行为类型，bready的反压、期望的响应。
~~~
2. AXI master读:
- 对于AXI master读来说，基本相似，提一下几个不同的点：
1. 等待事务完成&检查响应的时候，顺便可以获取响应里的读数据rdata结果：rdata = rsp.data（rdata是数组，其有效元素个数等于burst_length）；
2. 读的rresp也是个数组，数组长度就是burst_length，这点和bresp不同，bresp只有一个而不是数组；
3. rready_delay也同理是个数组，长度和上面的一致，它的含义也和default_rready强相关，通过操作这部分可实现rready的反压。

#### 2. AXI slave VIP
~~~
首先，要扩展svt_axi_slave_base_sequence，产生扩展类。然后在扩展类的body task中，可以实现修改slave VIP发送的事务时序。
先在body中声明一个svt_axi_slave_transaction的对象req_resp，然后通过peek方式从slave sequencer（源头是slave的monitor，又通过了TLM port传给了sequencer）获取slave VIP的响应请求实例句柄，如下。
p_sequencer.response_request_port.peek(req_resp);
成功后，进行slave响应的设置，首先设置响应bresp和rresp的值，再设置delay的反压。
status = req_resp.randomize with {
    bresp == xxx;//请给定你需要的响应值
    foreach (rresp[index]) {
        rresp[index] == xxx;//请给定你需要的响应值
    }

    addr_ready_delay == xxx;//请给定你需要的awready/arready反压时间，注意提前要把default_awready/default_arready设为默认的1，否则这个delay表示不同的含义
    
    foreach(wready_delay[index]) {
        wready_dealy[index] = xxx;//请给定你需要的wready反压时间，注意提前要把default_wready设为默认的1，否则这个delay表示不同的含义
    }

    bvalid_delay == xxx;//请给定你需要的bvalid有效时间

    foreach(rvalid_dealy[index]) {
        rvalid_delay[index] == xxx;//请给定你需要的rvalid有效时间
    }
}
对于写操作，slave VIP可以将数据写到内建memory中；对于读操作，slave VIP可以从内建memory中读取数据——这样方便我们执行后门操作。
if(req_resp.get_transmitted_channel() == svt_axi_slave_transcation::WRITE) begin
    `protect
    put_write_transcation_data_to_mem(req_resp);
    `endprotect
end
else if(req_resp.get_transmitted_channel() == svt_axi_slave_transcation::READ) begin
    `protect
    get_read_data_from_mem_to_transcation(req_resp);
    `endprotect
end
最后，发送响应激励：
$cast(req, req_resp);
`uvm_send(req);
~~~


#### 3. AHB master VIP
~~~
首先，要扩展svt_ahb_master_transaction_base_sequence，产生扩展类。然后在扩展类的body task中，可以实现修改master VIP发送的事务时序。
先在body中声明一个svt_ahb_master_reg_transaction的对象，然后create它的实例，如下（以写为示例，读同理）。
svt_ahb_master_reg_transaction write_tran;
`uvm_create(write_tran)
然后配置该实例的协议类型内容，并发送：
`uvm_rand_send_with (write_tran,
    {
        write_tran.xact_type == svt_ahb_transaction::WRITE;
        write_tran.addr == waddr;//给定haddr
        write_tran.burst_type == local::burst_type;//给定hburst
        write_tran.burst_size == local::burst_size;//给定hsize
        write_tran.num_incr_beats == ahb_len;//用于不定长INCR，否则这个值要给0
        //写数据，如果是读的话就不需要下面的代码
        foreach (write_tran.data[i])
            write_tran.data[i] == wdata[i];
    }
)
发送完毕后，等待响应完成并检查结果。
get_response(rsp);

//检查响应
foreach(rsp.all_beat_response[i]) begin
    if(rsp.all_beat_response[i] != xxx)//请提前给定期望的hresp值
        `uvm_error(get_type_name(),"xxx")
end
如果是读的话，在上面这一步同时还要获取读数据结果。
foreach(rsp.data[i])
    rdata[i] = rsp.data[i];//请提前声明好rdata

~~~



#### 3. AHB slave VIP
##### 1.步骤
1. 首先，要扩展svt_ahb_slave_transaction_base_sequence，产生扩展类。
2. 然后在扩展类的body task中，可以实现修改slave VIP发送的事务时序。
~~~
先在body中声明一个svt_ahb_slave_transaction的对象req_resp，
然后通过peek方式从slave sequencer（源头是slave的monitor，
又通过了TLM port传给了sequencer）获取slave VIP的响应请求实例句柄，
代码同AXI slave VIP，不再赘述。
~~~
3. 然后，对AHB slave响应的行为进行设置。
~~~
status = req_resp.randomize with {
    num_wait_cycles inside {[0:16]};//表示响应时间，单位是时钟数，反压场景可以修改，值的大小应和架构对齐
    response_type == xxx;//表示hresp的期望值，默认是OKAY
}
~~~
4. 对于写操作，slave VIP可以将写数据写到内建memory中；对于读操作，slave VIP可以从内建memory中读取数据——这样方便我们执行后门操作（代码同AXI slave VIP）。
5. 发送响应激励（代码同AXI slave VIP）。

##### 2. 配置寄存器
对于APB VIP，使用场景（配置寄存器）比较简单，不属于本文讨论的内容。

### 3.	VIP的后门访问
- 下面列出AXI、AHB、APB slave VIP后门读的用法：
~~~
//AXI读一个字节
env.xxx_axi_system_env.slave[index].read_byte(raddr, rdata);
//AHB读一个字
rdata_word = env.xxx_ahb_system_env.slave[index].ahb_slave_mem.read(raddr);
//APB读一个字
rdata_word = env.xxx_apb_system_env.slave[index].apb_slave_mem.read(raddr);
~~~

### 3.	注意事项
