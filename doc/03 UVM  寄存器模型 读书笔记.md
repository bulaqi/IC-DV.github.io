### 1. 寄存器模型简介
#### 1. 前门访问VS 后门访问
1. 前门访问: 模拟CPU在总线上发出读指令,进行读写,消耗仿真时间一直推进
2. 后门访问: 不通过总线读写,通过层次化的引用来改变寄存器的值
#### 2. 寄存的功能
1. 简单的通过seq机制的公共流程,访问寄存器
2. mirror update: 批量完成寄存器模型与dut之间相关寄存器的交互
3. 本质: 重新定义了验证平台和DUT寄存的接口,方便验证人员更好组织及配置寄存器,简化流程,减少工作量
#### 3. 基本概念
1. uvm_reg_filed：寄存器域
2. uvm_reg： 
   - 比uvm_reg_field高一个级别， 但是依然是比较小的单位。 
   - 一个寄存器中至少包含一个uvm_reg_field
3. uvm_reg_block : 
   - 它是一个比较大的单位， 在其中可以加入许多的uvm_reg， 
   - 也可以加入其他的uvm_reg_block
4. uvm_reg_map:
   - 每个寄存器加入寄存器模型都有地址,uvm_reg_map 就是存储该地址(偏移地址),并将其转化为物理地址,
   - 前门读写时,uvm_reg_map将地址转化为绝对地址,启动一个读或者写seq,并将读写结果返还. 
   - 所以再每个reg_block内,至少(通常)只有一个uvm_reg_map
  
### 2. 简单的寄存器模型
#### 1. 只有一个寄存器的寄存器模型
##### 1 . 首先要从uvm_reg派生一个invert类
- demo
    ~~~
    文件： src/ch7/section7.2/reg_model.sv
    class reg_invert extends uvm_reg;
        rand uvm_reg_field reg_data;

        virtual function void build();
            reg_data = uvm_reg_field::type_id::create("reg_data");
            // parameter: parent, size, lsb_pos, access, volatile, reset value, has_reset, is_rand, indi
            reg_data.configure(this, 1, 0, "RW", 1, 0, 1, 1, 0);
        endfunction

        `uvm_object_utils(reg_invert)

        function new(input string name="reg_invert");
            //parameter: name, size, has_coverage
            super.new(name, 16, UVM_NO_COVERAGE); //16:一般与系统总线的宽度一致
        endfunction
    endclass
    ~~~
- 说明
  - new函数 
    - 要将invert寄存器的宽度作为参数传递给super.new函数。 这里的宽度并不是指这个寄存器的有效宽度， 而是指这个寄存器中总共的位数。 如对于一个16位的寄存器， 其中可能只使用了8位， 那么这里要填写的是16， 而不是8。 **这个数字一般与系统总线的宽度一致**。
    - super.new中另外一个参数是是否要加入覆盖率的支持， 这里选择UVM_NO_COVERAGE， 即不支持
  - build函数 
    - 每一个派生自uvm_reg的类都有一个build， 这个build与uvm_component的build_phase并不一样， 它不会自动执行， 而需要手工调用， 与build_phase相似的是所有的uvm_reg_field都在这里实例
    - 当reg_data实例化后， 要调用data.configure函数来配置这个字段
    - configure的
      - 第一个参数，就是此域( uvm_reg_field) 的父辈， 也即此域位于哪个寄存器中， 这里当然是填写this了
      - 第二个参数，是此域的宽度， 由于DUT中invert的宽度为1， 所以这里为1
      - 第三个参数，是此域的最低位在整个寄存器中的位置， 从0开始计数。 
        - 其低3位和高5位没有使用， 其中只有一个字段， 此字段的有效宽度为8位， 那么在调用configure时， 第二个参数就要填写8， 第三个参数则要填写3， 因为此reg_field是从第4位开始的
      - 第四个参数表示此字段的存取方式,
       - 共支持如下25种存取方式
       - 如上25种存取方式有时并不能满足用户的需求， 这时就需要自定义寄存器的模型。
            ~~~
            1. RO： 读写此域都无影响。
            2. RW： 会尽量写入， 读取时对此域无影响。
            3. RC： 写入时无影响， 读取时会清零。
            4. RS： 写入时无影响， 读取时会设置所有的位。
            5. WRC： 尽量写入， 读取时会清零。
            6. WRS： 尽量写入， 读取时会设置所有的位
            7. WC： 写入时会清零， 读取时无影响。
            8. WS： 写入时会设置所有的位， 读取时无影响。
            9. WSRC： 写入时会设置所有的位， 读取时会清零。
            10. WCRS： 写入时会清零， 读取时会设置所有的位。
            11. W1C： 写1清零， 写0时无影响， 读取时无影响。
            12. W1S： 写1设置所有的位， 写0时无影响， 读取时无影响。
            13. W1T： 写1入时会翻转， 写0时无影响， 读取时无影响。
            14. W0C： 写0清零， 写1时无影响， 读取时无影响。
            15 W0S： 写0设置所有的位， 写1时无影响， 读取时无影响。
            15. W0T： 写0入时会翻转， 写1时无影响， 读取时无影响。
            16. W1SRC： 写1设置所有的位， 写0时无影响， 读清零。
            17. W1CRS： 写1清零， 写0时无影响， 读设置所有位。
            18. W0SRC： 写0设置所有的位， 写1时无影响， 读清零。
            19. W0CRS： 写0清零， 写1时无影响， 读设置所有位。
            20. WO： 尽可能写入， 读取时会出错。
            21. WOC： 写入时清零， 读取时出错。
            22. WOS： 写入时设置所有位， 读取时会出错。
            23. W1： 在复位( reset. 后， 第一次会尽量写入， 其他写入无影响， 读取时无影响。
            24. .WO1： 在复位后， 第一次会尽量写入， 其他的写入无影响， 读取时会出错。
            ~~~
      - 第五个参数， 表示是否是易失的( volatile) ， 这个参数一般不会使用。
      - 第六个参数，表示此域上电复位后的默认值。
      - 第七个参数，表示此域是否有复位，
        - 一般的寄存器或者寄存器的域都有上电复位值，因此这里一般也填写1。
      - 第八个参数，表示这个域是否可以随机化
          - 这主要用于对寄存器进行随机写测试，
            -  如果选择了0， 那么此域将不会随机化，而一直是复位值，
            -  否则将会随机出一个数值来
          - 这一个参数当且仅当第四个参数为RW、 WRC、 WRS、 WO、 W1、 WO1时才有效
      - 第九个参数，表示这个域是否可以单独存取。


##### 2 . 定义好此寄存器后， 需要在一个由reg_block派生的类中将其实例化
1. demo
    ~~~
    文件： src/ch7/section7.2/reg_model.sv
    class reg_model extends uvm_reg_block;
        rand reg_invert invert;

        virtual function void build();
            default_map = create_map("default_map", 0, 2, UVM_BIG_ENDIAN, 0);

            invert = reg_invert::type_id::create("invert", , get_full_name());
            invert.configure(this, null, "");
            invert.build();
            default_map.add_reg(invert, 'h9, "RW");
        endfunction

        `uvm_object_utils(reg_model)

        function new(input string name="reg_model");
            super.new(name, UVM_NO_COVERAGE);
        endfunction

    endclass
    ~~~
2. 说明：
   1. 同uvm_reg派生的类一样， 每一个由uvm_reg_block派生的类也要定义一个build函数， 一般在此函数中实现所有寄存器的实例
   化。
   2. build
      - 一个uvm_reg_block中一定要对应一个uvm_reg_map， 系统已经有一个声明好的default_map， 只需要在build中将其实例化。
      - 例化函数，不是直接调用uvm_reg_map的new函数， 而是通过调用uvm_reg_block的create_map来实现，create_map参数:
           ~~~
           第一个参数是名字，
           第二个参数是基地址， 
           第三个参数则是系统总线的宽度， 这里的单位是byte而不是bit， 
           第四个参数是大小端， 
           最后一个参数表示是否能够按照byte寻址。
           ~~~
      - 随后实例化invert并调用invert.configure函数。 
        - 这个函数的主要功能是指定寄存器进行后门访问操作时的路径。
        - 参数
           ~~~
           1. 一个参数是此寄存器所在uvm_reg_block的指针， 这里填写this， 
           2. 第二个参数是reg_file的指针( 7.4.2节将会介绍reg_file的概念) 这里暂时填写null， 
           3. 第三个参数是此寄存器的后门访问路径， 关于这点请参考7.3节， 这里暂且为空。 
           ~~~
      - 当调用完configure时， 需要手动调用invert的build函数， 将invert中的域实例化。
      - 最后一步则是将此寄存器加入default_map中。 
        - uvm_reg_map的作用是存储所有寄存器的地址， 因此必须将实例化的寄存器加入default_map中， 否则无法进行前门访问操作。 
        - add_reg函数的参数
           ~~~
           第一个参数是要加入的寄存器， 
           第二个参数是寄存器的地址， 这里是16’h9， 
           第三个参数是此寄存器的存取方式。
           ~~~
3. 小结
 - uvm_reg_field: 是最小的单位，是具体存储寄存器数值的变量，可以直接用这个类。 
 - uvm_reg: 则是一个“空壳子”， 或者用专业名词来说， 它是一个纯虚类， 因此是不能直接使用的， 必须由其派生一个新类， 在这个新类中至少加入一个uvm_reg_field，然后这个新类才可以使用。
 - uvm_reg_block则是用于组织大量uvm_reg的一个大容器。 
   - uvm_reg是一个小瓶子， 其中必须装上药丸(uvm_reg_field) 才有意义， 这个装药丸的过程就是定义派生类的过程， 
   - 而uvm_reg_block则是一个大箱子， 它中可以放许多小瓶子(uvm_reg) ， 也可以放其他稍微小一点的箱子(uvm_reg_block) 。 
   - 整个寄存器模型就是一个大箱子(uvm_reg_block) 。

#### 2. 将寄存器模型集成到验证平台中
1. 寄存器模型的前门访问方式工作流程
2. 寄存器模型的前门访问操作可以分成读和写两种
无论是读或写， 寄存器模型都会通过sequence产生一个uvm_reg_bus_op的变量， 
此变量中存储着操作类型（ 读还是写） 和操作的地址， 
如果是写操作， 还会有要写入的数据。 
此变量中的信息要经过一个转换器（ adapter） 转换后交给bus_sequencer， 随后交给bus_driver， 由bus_driver实现最终的前门访问读写操作。 
因此， 必须要定义好一个转换器。 

3. 转换器
- 一个转换器要定义好两个函数，reg2bus &bus2reg，
- reg2bus： 其作用为将寄存器模型通过sequence发出的uvm_reg_bus_op型的变量转换成bus_sequencer能够接受的形式
- bus2reg: 其作用为当监测到总线上有操作时， 它将收集来的transaction转换成寄存器模型能够接受的形式， 以便寄存器模型能够更新相应的寄存器的值
- 特殊点：发起的读操作的数值是如何返回给寄存器模型
  - 由于总线的特殊性， bus_driver在驱动总线进行读操作时， 它也能顺便获取要读的数值， 
  - 如果它将此值放入从bus_sequencer获得的bus_transaction中时， 那么bus_transaction中就会有读取的值， 此值经过adapter的bus2reg函数的传递， 最终被寄存器模型获取， 这个过程如图7-5a所示。 
  - 由于并没有实际的transaction的传递， 所以从driver到adapter使用了虚线。
- demo
    ~~~
    class my_adapter extends uvm_reg_adapter;
        string tID = get_type_name();

        `uvm_object_utils(my_adapter)

    function new(string name="my_adapter");
        super.new(name);
    endfunction : new

    function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        bus_transaction tr;
        tr = new("tr"); 
        tr.addr = rw.addr;
        tr.bus_op = (rw.kind == UVM_READ) ? BUS_RD: BUS_WR;
        if (tr.bus_op == BUS_WR)
            tr.wr_data = rw.data; 
        return tr;
    endfunction : reg2bus

    function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        bus_transaction tr;
        if(!$cast(tr, bus_item)) begin
            `uvm_fatal(tID,
            "Provided bus_item is not of the correct type. Expecting bus_transaction")
            return;
        end
        rw.kind = (tr.bus_op == BUS_RD) ? UVM_READ : UVM_WRITE;
        rw.addr = tr.addr;
        rw.byte_en = 'h3;
        rw.data = (tr.bus_op == BUS_RD) ? tr.rd_data : tr.wr_data;
        rw.status = UVM_IS_OK;
    endfunction : bus2reg
    ~~~
4. 将一个寄存器模型集成到base_test中
  - 至少需要在base_test中定义两个成员变量， 一是reg_model， 另外一个就是reg_sqr_adapter
  - 将所有用到的类在build_phase中实例化。 
  - 实例化后reg_model还要做四件事： 
    1. 调用configure函数， 
       - 参数1是：parent block， 由于是最顶层的reg_block， 因此填写null， 
       - 参数2是：后门访问路径， 请参考7.3节， 这里传入一个空的字符串。
    2. 调用build函数， 将所有的寄存器实例化。 
    3. 调用lock_model函数， 调用此函数后， reg_model中就不能再加入新的寄存器了。 
    4. 调用reset函数， 如果不调用此函数， 那么reg_model中所有寄存器的值都是0， 调用此函数后， 所有寄存器的值都将变为设置的复位值
5. 寄存器模型的前门访问操作最终都将由uvm_reg_map完成， 因此在connect_phase中， 需要将转换器和bus_sequencer通过
set_sequencer函数告知reg_model的default_map， 并将default_map设置为自动预测状态

#### 3. 在验证平台中使用寄存器模型
1. 当一个寄存器模型被建立好后， 可以在sequence和其他component中使用。 
   - 以在参考模型中使用为例， 需要在参考模型中有一个寄存器模型的指针
   - rm
        ~~~
        文件： src/ch7/section7.2/my_model.sv
        class my_model extends uvm_component;
            …
            reg_model p_rm;
            …
        endclass
        ~~~
   - 已经为env的p_rm赋值， 因此只需要在env中将p_rm传递给参考模型即
        ~~~
        文件： src/ch7/section7.2/my_env.sv
        function void my_env::connect_phase(uvm_phase phase);
            …
            mdl.p_rm = this.p_rm;
        endfunction
        ~~~
2. 对于寄存器， 寄存器模型提供了两个基本的任务： read和write。 
   1. read
      - 使用read
        ~~~
        task my_model::main_phase(uvm_phase phase);
            my_transaction tr;
            my_transaction new_tr;
            uvm_status_e status;
            uvm_reg_data_t value;
            super.main_phase(phase);
            p_rm.invert.read(status, value, UVM_FRONTDOOR);'
            
            while(1) begin
                port.get(tr);
                new_tr = new("new_tr");
                new_tr.copy(tr);
                //`uvm_info("my_model", "get one transaction, copy and print it:", UVM_LOW)
                //new_tr.print();
                if(value)
                    invert_tr(new_tr);
                ap.write(new_tr);
            end
        endtask
        ~~~

      - read原型
        - 常用参数的是其前三个参数。 
          - 其中第一个是uvm_status_e型的变量， 这是一个输出， 用于表明读操作是否成功；
          - 第二个是读取的数值， 也是一个输出； 
          - 第三个是读取的方式， 可选UVM_FRONTDOOR和UVM_BACKDOOR。
            ~~~
            extern virtual task read(output uvm_status_e status,
                                    output uvm_reg_data_t value,
                                    input uvm_path_e path = UVM_DEFAULT_PATH,
                                    input uvm_reg_map map = null,
                                    input uvm_sequence_base parent = null,
                                    input int prior = -1,
                                    input uvm_object extension = null,
                                    input string fname = "",
                                    input int lineno = 0);
            ~~~


   2. 使用write
        1. 在sequence中使用寄存器模型， 通常通过p_sequencer的形式引用。 需要首先在sequencer中有一个寄存器模型的指针， 代码清单7-10中已经为v_sqr.p_rm赋值 
            ~~~
            class case0_cfg_vseq extends uvm_sequence;
            ...
            
                virtual task body();
                    uvm_status_e   status;
                    uvm_reg_data_t value;
        
                    p_sequencer.p_rm.invert.read(status, value, UVM_FRONTDOOR);
                    ...
                endtask

            endclass
            ~~~
        2. write原型
           - 常用参数的也只有前三个。 
             - 其中第一个为uvm_status_e型的变量， 这是一个输出， 用于表明写操作是否成功。 
             - 第二个要写的值， 是一个输入， 
             - 第三个是写操作的方式， 可选UVM_FRONTDOOR和UVM_BACKDOO
                ~~~
                extern virtual task write(output uvm_status_e status,
                                    input uvm_reg_data_t value,
                                    input uvm_path_e path = UVM_DEFAULT_PATH,
                                    input uvm_reg_map map = null,
                                    input uvm_sequence_base parent = null,
                                    input int prior = -1,
                                    input uvm_object extension = null,
                                    input string fname = "",
                                    input int lineno = 0)
                ~~~

### 3. 后门访问和前门访问
#### 1. UVM中前门访问的实现
##### 1. 概述
参考模型中，通过p_sqr得到一个sequencer的指针， 也可以在此sequencer上启动一个sequence。(并env中将sequencer的指针赋值给此变量即可) 
##### 2. UVM内建了一种transaction： uvm_reg_item。 通过adapter的bus2reg及reg2bus， 可
以实现uvm_reg_item与目标transaction的转换
##### 3. 读
1. 原始
    ~~~
    · 参考模型调用寄存器模型的读任务。
    · 寄存器模型产生sequence， 并产生uvm_reg_item： rw。
    · 产生driver能够接受的transaction： bus_req=adapter.reg2bus（rw） 。
    · 把bus_req交给bus_sequencer。   
    · driver得到bus_req后驱动它， 得到读取的值， 并将读取值放入bus_req中， 调用item_done。
    · 寄存器模型调用adapter.bus2reg（bus_req， rw） 将bus_req中的读取值传递给rw。
    · 将rw中的读数据返回参考模型
    ~~~

2. 问题：
     - sequence的应答机制时提到过， 如果driver一直发送应答而sequence不收集应答， 那么将会导致sequencer的应答队列溢出。 
3. 解决：
   UVM考虑到这种情况， 在adapter中设置了provide_responses选项
    ~~~
    virtual class uvm_reg_adapter extends uvm_object;
        …
        bit provides_responses;
        …
    endclass
    ~~~
4. 设置了此选项后， 寄存器模型在调用bus2reg将目标transaction转换成uvm_reg_item时， 其传入的参数是rsp， 而不是req。 使用应答机制的操作流程为：
    ~~~
    · 参考模型调用寄存器模型的读任务。
    · 寄存器模型产生sequence， 并产生uvm_reg_item： rw。
    · 产生driver能够接受的transaction： bus_req=adapter.reg2bus（rw） 。
    · 将bus_req交给bus_sequencer。
    · driver得到bus_req， 驱动它， 得到读取的值， 并将读取值放入rsp中， 调用item_done。 //rsp
    · 寄存器模型调用adapter.bus2reg（rsp， rw） 将rsp中的读取值传递给rw。
    · 将rw中的读数据返回参考模型。
    ~~~


#### 2. 后门访问操作的定义
1. 背景：只读统计计数器特点
   - 只读， 无法通过前门访问操作对其进行写操作
   - 位宽一般都比较大，它们的位宽超过了设计中对加法器宽度的上限限制
2. 后门访问是与前门访问
   - 所有不通过DUT的总线而对DUT内部的寄存器或者存储器进行存取的操作都是后门访问操作。
3. 后门的优点
   - 因后门访问不消耗仿真时间，替代前门工作。 
     - 缩写配置时间，在大型芯片验证中，前面配置时间长， 如后门访问操作， 则时间可能缩短为原来的1/100。
     - 后门访问操作能够完成前门访问操作不能完成的事情。 
       - 如在网络通信系统中， 计数器通常都是只读的（有一些会附加清零功能） ， 无法对其指定一个非零的初值。 而大部分计数器都是多个加法器的叠加， 需要测试它们的进位操作。 
       - 32bit 宽计数器的功能验证， 可以给只读的寄存器一个初值。
4. 后门的劣势
   - 前门访问操作都可以在波形文件中找到总线信号变化的波形及所有操作的记录。 
   - 后门访问操作则无法在波形文件中找到操作痕迹，只能通过打印。


#### 3. 使用interface进行后门访问操作
1. 绝对路径的后门访问：起始与top_tb.sv，移植性差
2. 在driver或monitor中使用后门访问， 一种方法是使用接口。 可以新建一个后门interface
3. eg
- demo
    ~~~
    interface backdoor_if(input clk, input rst_n);

    function void poke_counter(input bit[31:0] value); // poke_counter为后门写
        top_tb.my_dut.counter = value;
    endfunction

    function void peek_counter(output bit[31:0] value); //peek_counter为后门读
        value = top_tb.my_dut.counter;
    endfunction
    endinterface
    ~~~

- 用例中应用
    ~~~
    task my_case0::configure_phase(uvm_phase phase);
        phase.raise_objection(this);
        @(posedge vif.rst_n);
            vif.poke_counter(32'hFFFD);
        phase.drop_objection(this);
    endtask
    ~~~
- 缺点：
  - 移植性差：如果有n个寄存器， 那么需要写n个poke函数， 同时如果有读取要求的话， 还要写n个peek函数， 这限制了其使用
- 适用场合：
  - 不想使用寄存器模型提供的后门访问或者根本不想建立寄存器模型， 同时又必须要对DUT中的一个寄存器或一块存储器（ memory） 进行后门访问操作的情况

#### 4. UVM中后门访问操作的实现： DPI(sv)+VPI(verilog)
1. VPI接口(Verilog后门读)
   - 特点：
     - 是Verilog提供的接口
     - 可以将DUT的层次结构开放给外部的C/C++代码
   - 常用的2个VPI接口
       ~~~
       vpi_get_value(obj, p_value);   //从RTL中得到一个寄存器的值
       vpi_put_value(obj, p_value, p_time, flags); //将RTL中的寄存器设置为某个值
       ~~~
   - 缺点： 纯VPI， 在SystemVerilog与C/C++之间传递参数时将非常麻烦。 
2. DPI(sv后门读)）
   - 特点：是SystemVerilog提供了一种更好的接口
   - 读demo:
        ~~~
        int uvm_hdl_read(char *path, p_vpi_vecval value);
        ~~~
   - 底层：在这个函数中通过最终调用vpi_get_value得到寄存器的值，是对verilog 提供的函数的封装。
   - SystemVerilog中首先需要使用如下的方式将在C/C++中定义的函数导入
        ~~~
        import "DPI-C" context function int uvm_hdl_read(string path, output uvm_hdl_d ata_t value);
        ~~~
   - 优点：SV中像普通函数一样调用uvm_hdl_read函数了。 这种方式比单纯地使用VPI的方式简练许多。 它可以直接将参数传递给C/C++中的相应函数， 省去了单纯使用VPI时繁杂的注册系统函数的步骤
   - 效果：DPI+VPI的方式中， 要操作的寄存器的路径被抽像成了一个字符串， 而不再是一个绝对路径
    ~~~
    uvm_hdl_read("top_tb.my_dut.counter", value);
    ~~~
  - 优势： 
        路径被抽像成了一个字符串， 从而可以以参数的形式传递， 并可以存储，这为建立寄存器模型提供了可能。 
3. UVM中使用DPI+VPI的方式来进行后门访问操作， 它大体的流程
   1. 在建立寄存器模型时将路径参数设置好。
   2. 在进行后门访问的写操作时， 寄存器模型调用uvm_hdl_deposit函数：
      - 开放C/C++接口
      ~~~
      import "DPI-C" context function int uvm_hdl_deposit(string path, uvm_hdl_data_t value);
      ~~~
      - 在C/C++侧， 此函数内部会调用vpi_put_value函数来对DUT中的寄存器进行写操作。
   3. 进行后门访问的读操作时，调用uvm_hdl_read函数， 在C/C++侧， 此函数内部会调用vpi_get_value函数来对DUT中的寄存器进行读操作， 并将读取值返回


#### 5. UVM中后门访问操作接口


### 4. 复杂的寄存器模型

#### 1. 层次化的寄存器模型
#### 2. reg_file的作用
#### 3. 多个域的寄存器
#### 4. 多个地址的寄存器
#### 5. 加入存储器

### 5. 寄存器模型对DUT的模拟
#### 1. 期望值与镜像值
#### 2. 常用操作及其对期望值和镜像值的影响

### 6. 内建的sequence
#### 1.检查后门访问中hdl路径的sequence
#### 2.检查默认值的sequence
#### 3. 检查读写功能的sequence


### 7. 高级用法
#### 1. 使用reg_predictor
#### 2. 使用UVM_PREDICT_DIRECT功能与mirror操作
#### 3. 寄存器模型的随机化与update
#### 4. 扩展位宽

### 8. 其他常用函数
#### 1. get_root_blocks
#### 2.get_reg_by_offset函数