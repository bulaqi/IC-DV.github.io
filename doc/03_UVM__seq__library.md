### 1. 基础知识
##### 1. 背景-- 根据特定的算法随机选择注册在其中的一些sequence， 并在body中执行这些sequence
##### 2. 基础使用
1. 定义sequence library
    - 1.从uvm_sequence派生时要指明此sequence library所产生的transaction类型， 这点与普通的sequence相同； 
    - 2.是在其new函数中要调用init_sequence_library， 否则其内部的候选sequence队列就是空的； 
    - 3.调用uvm_sequence_library_utils注册
2. eg
   ~~~
    class simple_seq_library extends uvm_sequence_library#(my_transaction);
    function  new(string name= "simple_seq_library");
        super.new(name);
        init_sequence_library();
    endfunction

    `uvm_object_utils(simple_seq_library)
    `uvm_sequence_library_utils(simple_seq_library);

    endclass
   ~~~
3. uvm_add_to_seq_lib, 将某些sqe添加给sequence library
   - uvm_add_to_seq_lib两个参数， 第一个是此sequence的名字， 第二个是要加入的sequence library的名字。 
   - 一个sequence可以加入多个不同的sequence library
   - 多个sequence加入同一sequence library中
    ~~~
    class seq0 extends uvm_sequence#(my_transaction);
    function  new(string name= "seq0");
        super.new(name);
    endfunction

    `uvm_object_utils(seq0)
    `uvm_add_to_seq_lib(seq0, simple_seq_library)
    virtual task body();
        repeat(10) begin
            `uvm_do(req)
            `uvm_info("seq0", "this is seq0", UVM_MEDIUM)
        end
    endtask 
    endclass
    ~~~

4. 当sequence与sequence library定义好后， 可以将sequence library作为sequencer的default sequence
~~~
function void my_case0::build_phase(uvm_phase phase);
   super.build_phase(phase);

   uvm_config_db#(uvm_object_wrapper)::set(this, 
                                           "env.i_agt.sqr.main_phase", 
                                           "default_sequence", 
                                           simple_seq_library::type_id::get());
endfunction

~~~
5. 效果: UVM会随机从加入simple_seq_library的sequence中选择几个， 并顺序启动它们。
   

##### 2. 控制选择算法
1. selection_mode --决定 随机从其sequence队列中选择几个执行
2. eg
   ~~~
   uvm_sequence_lib_mode selection_mode;

    //uvm_sequence_lib_mode是一个枚举类型
   ...
   typedef enum
    {
    UVM_SEQ_LIB_RAND,
    UVM_SEQ_LIB_RANDC,
    UVM_SEQ_LIB_ITEM,
    UVM_SEQ_LIB_USER
    } uvm_sequence_lib_mode;
   ...
   ~~~
3. UVM_SEQ_LIB_RAND： 完全的随机
   ~~~
    function void my_case0::build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_db#(uvm_object_wrapper)::set(this, 
                                            "env.i_agt.sqr.main_phase", 
                                            "default_sequence", 
                                            simple_seq_library::type_id::get());
    uvm_config_db#(uvm_sequence_lib_mode)::set(this, 
                                            "env.i_agt.sqr.main_phase", 
                                            "default_sequence.selection_mode", 
                                            UVM_SEQ_LIB_RANDC);
    endfunction
   ~~~
4. UVM_SEQ_LIB_RANDC ： 类似randc 变量的随机，在全部遍历前，不会有seq被执行2次
5. UVM_SEQ_LIB_ITEM ：并不执行其sequence队列中的sequence， 而是自己产生transaction
   - 在此种情况下就是一个普通的sequence， 只是其产生的transaction除了定义时施加的约束外， 没有任何额外的约束。
   - 
6. UVM_SEQ_LIB_USER ： 用户自定义选择的算法，需要用户重载select_sequence参数
    - 背景：假设有4个sequence加入了sequence library中： seq0、 seq1、 seq2和seq3。 
    - 需求：现在由于各种原因， 不想使用seq2了。 
    - 原理：
        1. 下述代码的select_sequence第一次被调用时初始化index队列， 把seq0、 seq1和seq3在sequences中的索引号存入其中。
        2. 之后， 从index中随机选择一个值返回， 相当于是从seq0、 seq1和seq3随机选一个执行。
        3. sequences是sequence library中存放候选sequence的队列。  
        4. select_sequence会传入一个参数max， select_sequence函数必须返回一个介于0到max之间的数值。 如果sequences队列的大小为4， 那
么传入的max的数值是3， 而不是4。
    ~~~
    class simple_seq_library extends uvm_sequence_library#(my_transaction);
    function  new(string name= "simple_seq_library");
        super.new(name);
        init_sequence_library();
    endfunction

    `uvm_object_utils(simple_seq_library)
    `uvm_sequence_library_utils(simple_seq_library);

    // 重载
    virtual function int unsigned select_sequence(int unsigned max);
        static int unsigned index[$];
        static bit inited;
        int value;
        if(!inited) begin
            for(int i = 0; i <= max; i++) begin
                if((sequences[i].get_type_name() == "seq0") ||
                (sequences[i].get_type_name() == "seq1") ||
                (sequences[i].get_type_name() == "seq3"))
                index.push_back(i);
            end
            inited = 1;
        end
        value = $urandom_range(0, index.size() - 1);
        return index[value];
    endfunction
    endclass
    ~~~


##### 3. 控制执行次数（受libaray内部变量的控制）
1. 执行次数，是sqe_library 内部的min_random_count、max_random_count控制
   ~~~
   int unsigned min_random_count=10;
   int unsigned max_random_count=10;
   ~~~
2. sequence library会在min_random_count和max_random_count之间随意选择一个数来作为执行次数。
3. selection_mode为UVM_SEQ_LIB_ITEM时， 将会产生10个item； 
4. 为其他模式时， 将会顺序启动10个sequence。 可以设置这两个值为其他值来改变迭代次数
5. eg
   ~~~
    function void my_case0::build_phase(uvm_phase phase);

        uvm_config_db#(uvm_object_wrapper)::set(this,
                                                "env.i_agt.sqr.main_phase",
                                                "default_sequence",
                                                simple_seq_library::type_id::get());
        uvm_config_db#(uvm_sequence_lib_mode)::set(this,
                                                "env.i_agt.sqr.main_phase",
                                                "default_sequence.selection_mode",
                                                UVM_SEQ_LIB_ITEM);
        //设置max 和mix 参数
        uvm_config_db#(int unsigned)::set(this,
                                                "env.i_agt.sqr.main_phase",
                                                "default_sequence.min_random_count",
                                                5);
        uvm_config_db#(int unsigned)::set(this,
                                                "env.i_agt.sqr.main_phase",
                                                "default_sequence.max_random_count",
                                                20);
    endfunction
    ~~~

##### 3. sqe_library_cfg
1. 背景： 如上述。用3个config_db设置迭代次数和选择算法稍显麻烦。 UVM提供了一个类uvm_sequence_library_cfg来对sequence library进行配置。 它一共有三个成员变量
    ~~~
    class uvm_sequence_library_cfg extends uvm_object;
        `uvm_object_utils(uvm_sequence_library_cfg)

        uvm_sequence_lib_mode selection_mode;
        int unsigned min_random_count;
        int unsigned max_random_count;
        …
    endclass  
    ~~~
2. 通过配置如上三个成员变量， 并将其传递给sequence library就可对sequence library进行配置：
    ~~~
    function void my_case0::build_phase(uvm_phase phase);
    uvm_sequence_library_cfg cfg;
    super.build_phase(phase);

    cfg = new("cfg", UVM_SEQ_LIB_RANDC, 5, 20);
    
    uvm_config_db#(uvm_object_wrapper)::set(this, 
                                            "env.i_agt.sqr.main_phase", 
                                            "default_sequence", 
                                            simple_seq_library::type_id::get());
    uvm_config_db#(uvm_sequence_library_cfg)::set(this, 
                                            "env.i_agt.sqr.main_phase", 
                                            "default_sequence.config", 
                                            cfg);
    endfunction
    ~~~
3. 最简单的方法,对sequence library进行实例化后， 对其中的变量进行赋值  (**推荐**）
    ~~~
    function void my_case0::build_phase(uvm_phase phase);
    simple_seq_library seq_lib;
    super.build_phase(phase);

    seq_lib = new("seq_lib");
    seq_lib.selection_mode = UVM_SEQ_LIB_RANDC;
    seq_lib.min_random_count = 10;
    seq_lib.max_random_count = 15; 
    uvm_config_db#(uvm_sequence_base)::set(this, 
                                            "env.i_agt.sqr.main_phase", 
                                            "default_sequence", 
                                            seq_lib);
    endfunction
    ~~~
   

### 2. 经验总结
1.  min_random_count/max_random_count 只是的范围是指示seq_lib 总计可以启动seq的数量
2.  当前的经验是，只能从build_phase 下通过config_db传递给default_seq才可以，在main_phase 运行，当前尝试seq_lib.start(xxx)无效，原因未知
3.  注意：使用时，严格参考白皮书代码，只要例化sequence library，无需例化seq，用default_seq启动
4.  注意一个lib下的seq是逐个调度的，在一个lib下同时只有1个seq有效，方便实现，超长包和超短包的混合调度，交替发送，不适合4个硬件通路同时发送激励，适合一个端口下error_trans,normal_trans,long_trans的发送
   
### 3. 传送门
