### 1. 基础知识
#### 1. virtual_seq的同步框图
![image](https://user-images.githubusercontent.com/55919713/223030949-4c41b899-a9a1-4c0f-9bcf-d45610910918.png)   

#### 2. virtual_seq的同步的实现
1. 定义virtual sequence， 一般需要一个**virtual sequencer**。
virtual sequencer里面包含指向其他真实sequencer的指针：
    ~~~
    class my_vsqr extends uvm_sequencer;
    
    my_sequencer p_sqr0;
    my_sequencer p_sqr1;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction 
    
    `uvm_component_utils(my_vsqr)
    endclass
    ~~~

2. 在base_test中， 实例化vsqr， 并在connect_phase将相应的sequencer赋值给vsqr中的sequencer的指针：
    ~~~
    class base_test extends uvm_test;

    my_env         env0;
    my_env         env1;
    my_vsqr        v_sqr;   
    
    function new(string name = "base_test", uvm_component parent = null);
        super.new(name,parent);
    endfunction
    
    ...
    endclass

    function void base_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    env0  =  my_env::type_id::create("env0", this); 
    env1  =  my_env::type_id::create("env1", this); 
    v_sqr =  my_vsqr::type_id::create("v_sqr", this); 
    endfunction

    function void base_test::connect_phase(uvm_phase phase);
    v_sqr.p_sqr0 = env0.i_agt.sqr;
    v_sqr.p_sqr1 = env1.i_agt.sqr;
    endfunction
    ~~~

3. virtual sequene 实现调度逻辑： 在virtual sequene中则可以使用uvm_do_on系列宏来发送transaction：
逻辑：
- 在case0_vseq中， 先使用uvm_do_on_with在p_sequencer.sqr0上发送一个最长包， 
- 当其发送完毕后， 再启动drv0_seq和drv1_seq。 
- 这里的drv0_seq和drv1_seq非常简单， 两者之间不需要为同步做任何事情：
    ~~~
    class cfg_vseq extends uvm_sequence;
    `uvm_object_utils(cfg_vseq)
    `uvm_declare_p_sequencer(my_vsqr) 
    function new(string name = "cfg_vseq");
        super.new(name);
    endfunction

    virtual task body();
        my_transaction tr;
        drv0_seq seq0;
        drv1_seq seq1;
        `uvm_do_on_with(tr, p_sequencer.p_sqr0, {tr.pload.size == 1500;})   
        `uvm_info("vseq", "send one longest packet on p_sequencer.p_sqr0", UVM_MEDIUM)
        fork
            `uvm_do_on(seq0, p_sequencer.p_sqr0);
            `uvm_do_on(seq1, p_sequencer.p_sqr1);
        join 
    endtask
    endclass
    ~~~

    ~~~
    class drv0_seq extends uvm_sequence #(my_transaction);
    my_transaction m_trans;
    `uvm_object_utils(drv0_seq)

    function  new(string name= "drv0_seq");
        super.new(name);
    endfunction 
    
    virtual task body();
        repeat (10) begin
            `uvm_do(m_trans)
            `uvm_info("drv0_seq", "send one transaction", UVM_MEDIUM)
        end
    endtask
    endclass

    class drv1_seq extends uvm_sequence #(my_transaction);
    my_transaction m_trans;
    `uvm_object_utils(drv1_seq)

    function  new(string name= "drv1_seq");
        super.new(name);
    endfunction 
    
    virtual task body();
        repeat (10) begin
            `uvm_do(m_trans)
            `uvm_info("drv1_seq", "send one transaction", UVM_MEDIUM)
        end
    endtask
    endclass
    ~~~
   

4. 小结：
   - 在使用uvm_do_on宏的情况下， 虽然seq0是在case0_vseq中启动， 但是它最终会被交给p_sequencer.p_sqr0， 也即env0.i_agt.sqr 而不是v_sqr。 
   - 这个就是virtual sequence和virtual sequencer中virtual的来源。 它们各自并不产生transaction， 而只是控制其他的sequence为相应的sequencer产生transaction。   
   - **virtual sequence和virtual sequencer只是起一个调度的作用。 由于根本不直接产生transaction， 所以virtual sequence和virtual sequencer在定义时根本无需指明要发送的transaction数据类型。**

5. 扩展：手动启动vir_sqe
   - 如果不使用uvm_do_on宏， 那么也可以手工启动sequence， 其效果完全一样。
   -  手工启动sequence的一个优势是可以向其中传递一些值：  
   -  eg，如下：在read_file_seq中， 需要一个字符串的文件名字， 在手工启动时可以指定文件名字， 但是uvm_do系列宏无法实现这个功能，因为string类型变量前不能使用rand修饰符。 这就是手工启动sequence的优势。   
   -  在case0_vseq的定义中， 一般都要使用uvm_declare_p_sequencer宏。 这个在前文已经讲述过了， 通过它可以引用sequencer的成员变量。

    ~~~
    class read_file_seq extends uvm_sequence #(my_transaction);
    my_transaction m_trans;
    string file_name;
    ...
    endclass

    class case0_vseq extends uvm_sequence;
    ...
    virtual task body();
        my_transaction tr;
        read_file_seq seq0;
        drv1_seq seq1;
        if(starting_phase != null) 
            starting_phase.raise_objection(this);
        `uvm_do_on_with(tr, p_sequencer.p_sqr0, {tr.pload.size == 1500;})
        `uvm_info("vseq", "send one longest packet on p_sequencer.p_sqr0", UVM_MEDIUM)
        seq0 = new("seq0");
        seq0.file_name = "data.txt";
        seq1 = new("seq1");
        fork
            seq0.start(p_sequencer.p_sqr0);
            seq1.start(p_sequencer.p_sqr1);
        join 

    ...
    endtask
    endclass
    ~~~

6. 总计
-  **回顾一下**，为了解决sequence的同步， 之前使用send_over这个全局变量的方式来解决。 
- virtual sequence的解决方案：
  1. 由于virtual sequence的body是顺序执行， 所以只需要先产生一个最长的包， 
  2. 产生完毕后再将其他的sequence启动起来， 没有必要去刻意地同步。 这只是virtual sequence强大的调度功能的一个小小的体现。   
- virtual sequence的使用可以减少config_db语句的使用。 
  1. 由于config_db::set函数的第二个路径参数是字符串， 非常容易出错，所以减少config_db语句的使用可以降低出错的概率。 
  2. 在上节中， 使用了两个uvm_config_db语句将两个sequence送给了相应的sequencer作为default_sequence。 假如验证平台中的sequencer有多个， 如10个， 那么就需要写10个uvm_config_db语句， 这是一件很令人厌烦的事情。 使用virtual sequence后可以将这10句只压缩成一句：  
    ~~~
    function void my_case0::build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_db#(uvm_object_wrapper)::set(this, 
                                            "v_sqr.main_phase", 
                                            "default_sequence", 
                                            case0_vseq::type_id::get());
    endfunction
    ~~~
    - 
    virtual sequence作为一种特殊的sequence， 也可以在其中启动其他的virtual sequence：
    ~~~
    class case0_vseq extends uvm_sequence;
    ...

    virtual task body();
        cfg_vseq cvseq;
        if(starting_phase != null) 
            starting_phase.raise_objection(this);
        `uvm_do(cvseq)
    ...

    endtask
    endclass

    ~~~


### 2. 经验总结

### 3. 传送门
1.  [UVM仿真技术（Virtual Sequence & Virtual Sequencer）](https://zhuanlan.zhihu.com/p/369681031)
2. [理解UVM中的virtual sequencer和virtual sequence](https://blog.csdn.net/kevindas/article/details/120934619)