### 基础知识
#### 1.peek/poke (path=BACKDOOR)
1. peek/poke同属于后门访问register/register field方式, 与backdoor read/write类似,但是peek/poke不会模拟寄存器的行为;
2. 如果对一个只读寄存器进行write操作,无论是BACKDOOR还是FRONTDOOR,都不能写进去,而对其进行poke操作(即写操作),能写进去; 
3. 如果对一个读清零的寄存器来说,进行read操作,无论是BACKDOOR还是FRONTDOOR, DUT中此寄存器的值在read操作之后都会变为0,而peek则会得到寄存器的值,但是DUT中寄存器的值依然保持不变;
4. peek/poke操作完成后,寄存器模型会根据操作的结果更新期望值和镜像值(二者相等);
~~~
regmodel.register.poke(status,value,.parent(this));
regmodel.register.peek(status,value,.parent(this));
~~~
#### 2.peek源码
1. peek task内部会判断寄存器是否能进行BACKDOOR操作,比如是否设置该寄存器的hdl path;
2. 主要是调用backdoor_rd task与do_predict(UVM_PREDICT_READ); do_predict用于更新register model中寄存器的相关值;
~~~
task uvm_reg::peek(output uvm_status_e      status,
                   output uvm_reg_data_t    value,
                   input  string            kind = "",
                   input  uvm_sequence_base parent = null,
                   input  uvm_object        extension = null,
                   input  string            fname = "",
                   input  int               lineno = 0);

   uvm_reg_backdoor bkdr = get_backdoor();
   uvm_reg_item rw;

   m_fname = fname;
   m_lineno = lineno;

   if (bkdr == null && !has_hdl_path(kind)) begin
      `uvm_error("RegModel",
        $sformatf("No backdoor access available to peek register \"%s\"",
                  get_full_name()));
      status = UVM_NOT_OK;
      return;
   end

   if(!m_is_locked_by_field)
      XatomicX(1);

   // create an abstract transaction for this operation
   rw = uvm_reg_item::type_id::create("mem_peek_item",,get_full_name());
   rw.element      = this;
   rw.path         = UVM_BACKDOOR;
   rw.element_kind = UVM_REG;
   rw.kind         = UVM_READ;
   rw.bd_kind      = kind;
   rw.parent       = parent;
   rw.extension    = extension;
   rw.fname        = fname;
   rw.lineno       = lineno;

   if (bkdr != null)
     bkdr.read(rw);
   else
     backdoor_read(rw);

   status = rw.status;
   value = rw.value[0];
   `uvm_info("RegModel", $sformatf("Peeked register \"%s\": 'h%h",
                          get_full_name(), value),UVM_HIGH);

   do_predict(rw, UVM_PREDICT_READ);

   if (!m_is_locked_by_field)
      XatomicX(0);
endtask: peek
~~~
#### 3. poke源码
1. 主要是调用backdoor_wr task与do_predict(UVM_PREDICT_WRITE);
2. 本质上采用的是deposit函数;
3. poke与backdoor write的区别在于后者在调用backdoor_write操作前,先使用backdoor的read读出原来寄存器的值,把读出来的值以及要写入的数值通过调用uvm_reg_field的XpredictX,得到一个新的值,这个值其实就完全模拟了FRONTDOOR行为的一个值,之后再把这个值写入,而前者则是直接写入;
~~~
task uvm_reg::poke(output uvm_status_e      status,
                   input  uvm_reg_data_t    value,
                   input  string            kind = "",
                   input  uvm_sequence_base parent = null,
                   input  uvm_object        extension = null,
                   input  string            fname = "",
                   input  int               lineno = 0);

   uvm_reg_backdoor bkdr = get_backdoor();
   uvm_reg_item rw;

   m_fname = fname;
   m_lineno = lineno;


   if (bkdr == null && !has_hdl_path(kind)) begin
      `uvm_error("RegModel",
        {"No backdoor access available to poke register '",get_full_name(),"'"})
      status = UVM_NOT_OK;
      return;
   end

   if (!m_is_locked_by_field)
     XatomicX(1);

   // create an abstract transaction for this operation
   rw = uvm_reg_item::type_id::create("reg_poke_item",,get_full_name());
   rw.element      = this;
   rw.path         = UVM_BACKDOOR;
   rw.element_kind = UVM_REG;
   rw.kind         = UVM_WRITE;
   rw.bd_kind      = kind;
   rw.value[0]     = value & ((1 << m_n_bits)-1);
   rw.parent       = parent;
   rw.extension    = extension;
   rw.fname        = fname;
   rw.lineno       = lineno;

   if (bkdr != null)
     bkdr.write(rw);
   else
     backdoor_write(rw);

   status = rw.status;
   `uvm_info("RegModel", $sformatf("Poked register \"%s\": 'h%h",
                              get_full_name(), value),UVM_HIGH);

   do_predict(rw, UVM_PREDICT_WRITE);

   if (!m_is_locked_by_field)
     XatomicX(0);
endtask: poke
~~~
  
