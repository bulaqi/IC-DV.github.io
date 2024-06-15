### 1. 基础知识
#### 1. 在seq 获取参数
1. config_db机制时， set函数的目标都是一个component，也可以是seq
2. 难点：参数路径的获取
   - config_db:: get的前提是已经进行了set。 
   - sequence本身是一个uvm_object， 它无法像uvm_component那样出现在UVM树中， 从而很难确定在对其进行设置时的第二个路径参数。 
   - 所以在sequence中使用config_db:: get函数得到参数的最大障碍是路径问题。
3. 解决方案：get_full_name
   - get_full_name（ ） 可以得到一个component的完整路径， 
   - 同样的， 可以在seq内调用，效果如下
   - 路径是由两个部分组成：sequencer路径 + 及实例化此sequence时传递的名字
    ~~~
    uvm_test_top.env.i_agt.sqr.case0_sequence
    ~~~
4. set 时的路径设置
    - set: 第二个路径参数里面出现了通配符， 这是因为sequence在实例化时名字一般是不固定的， 而且有时是未知的（ 比如使用default_sequence启动的sequence的名字就是未知的） ， 所以使用通配符
    - get:
        1. 在get函数原型中， 第一个参数必须是一个component， 而sequence不是一个component，所以这里不能使用this指针， 只能使用null或者uvm_root::get() 。 
        2. 前文已经提过， 当使用null时， UVM会自动将其替换为uvm_root::get()， 再加上第二个参数get_full_name()， 就可以完整地得到此sequence的路径， 从而得到参数
    - eg：
    ~~~
    //set
    function void my_case0::build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_db#(int)::set(this, "env.i_agt.sqr.*", "count", 9);
    ...
    ~~~


    ~~~
    //get
    ...
    virtual task pre_body();
        //当使用null时， UVM会自动将其替换为uvm_root::get()
        if(uvm_config_db#(int)::get(null, get_full_name(), "count", count))
            `uvm_info("seq0", $sformatf("get count value %0d via config_db", count), UVM_MEDIUM)
        else
            `uvm_error("seq0", "can't get count value!") 
    endtask
    ...
    ~~~

#### 2. 在seq 设置参数
1. 传给组件.scb_en
    ~~~
    class case0_vseq extends uvm_sequence;
        ...
        virtual task body();
            my_transaction tr;
            drv0_seq seq0;
            drv1_seq seq1;
            if(starting_phase != null) 
                starting_phase.raise_objection(this);
            fork
                `uvm_do_on(seq0, p_sequencer.p_sqr0);
                `uvm_do_on(seq1, p_sequencer.p_sqr1);
                begin
                    #10000;
                    uvm_config_db#(bit)::set(uvm_root::get(), "uvm_test_top.env0.scb", "cmp_en", 0);
                    #10000;
                    uvm_config_db#(bit)::set(uvm_root::get(), "uvm_test_top.env0.scb", "cmp_en", 1);
                end
            join 
            #100;
            if(starting_phase != null) 
                starting_phase.drop_objection(this);
        endtask
    endclass
    ~~~

2. 传给seq 
   1. 分析
    - sequence向自己传递了一个参数： first_start。 
    - 在一次仿真中， 当此sequence第一次启动时， 其first_start值为1； 
    - 当后面再次启动时， 其first_start为0。 
    - 根据first_start值的不同， 可以在body中有不同的行为。
    - 这里需要注意的是， 由于此sequence在virtual sequence中被启动， 所以其get_full_name的结果应该是uvm_test_top.v_sqr.*， 而不是uvm_test_top.env0.i_agt.sqr.*， 所以在设置时， 第二个参数应该是前者
  
   2. eg:
    ~~~
    class drv0_seq extends uvm_sequence #(my_transaction);
        my_transaction m_trans;
        bit first_start;
        `uvm_object_utils(drv0_seq)

        function  new(string name= "drv0_seq");
            super.new(name);
            first_start = 1;
        endfunction 
        
        virtual task body();
            void'(uvm_config_db#(bit)::get(uvm_root::get(), get_full_name(), "first_start", first_start));
            if(first_start)
                `uvm_info("drv0_seq", "this is the first start of the sequence", UVM_MEDIUM)
            else
                `uvm_info("drv0_seq", "this is not the first start of the sequence", UVM_MEDIUM)
            uvm_config_db#(bit)::set(uvm_root::get(), "uvm_test_top.v_sqr.*", "first_start", 0);
            repeat (10) begin
                `uvm_do(m_trans)
            end
        endtask
    endclass
    ~~~

#### 3. wait_modify的使用
1. 背景
   -  向scoreboard传递了一个cmp_en的参数， scoreboard可以根据此参数决定是否对收到的transaction进行检查。 
   -  在做一些异常用例测试的时候， 经常用到这种方式。 但是关键是如何在scoreboard中获取这个参数
   -  scoreboard都是在build_phase中调用get函数， 并且调用的前提是参数已经被设置过。 
   -  一个sequence是在task phase中运行的， 当其设置一个参数的时候， 其时间往往是不固定的。
   -  针对这种不固定的设置参数的方式， UVM中提供了wait_modified任务
2. wait_modified
   - 它的参数有三个， 与config_db:: get的前三个参数完全一样。 当它检测到第三个参数的值被更新过后， 它就返回， 否则一直等待在那里。
   - eg_componet：
    ~~~
    task my_scoreboard::main_phase(uvm_phase phase);
        my_transaction  get_expect,  get_actual, tmp_tran;
        bit result;
        bit cmp_en = 1'b1;
        
        super.main_phase(phase);
        fork
            while(1) begin
                //3个参数
                uvm_config_db#(bit)::wait_modified(this, "", "cmp_en");
                void'(uvm_config_db#(bit)::get(this, "", "cmp_en", cmp_en)); 
                `uvm_info("my_scoreboard", $sformatf("cmp_en value modified, the new value is %0d", cmp_en), UVM_LOW)
            end
            while (1) begin
                exp_port.get(get_expect);
                expect_queue.push_back(get_expect);
            end
            while (1) begin
                act_port.get(get_actual);
                if(expect_queue.size() > 0) begin
                    tmp_tran = expect_queue.pop_front();
                    result = get_actual.compare(tmp_tran);
        ...
    ~~~
   - eg_seq

    ~~~
    class drv0_seq extends uvm_sequence #(my_transaction);
        my_transaction m_trans;
        `uvm_object_utils(drv0_seq)

        function  new(string name= "drv0_seq");
            super.new(name);
        endfunction 
        
        virtual task body();
            bit send_en = 1;
            fork
                while(1) begin
                    uvm_config_db#(bit)::wait_modified(null, get_full_name(), "send_en");
                    void'(uvm_config_db#(bit)::get(null, get_full_name, "send_en", send_en)); 
                    `uvm_info("drv0_seq", $sformatf("send_en value modified, the new value is %0d", send_en), UVM_LOW)
                end
            join_none
            repeat (10) begin
                `uvm_do(m_trans)
            end
        endtask
    endclass
    ~~~
### 2. 经验
### 3. 传送门
