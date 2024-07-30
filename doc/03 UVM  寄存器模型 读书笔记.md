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
1.寄存器模型的后门访问功能的步骤
   1. 在reg_block中调用uvm_reg的configure函数时， 设置好第三个路径参数
        ~~~
        class reg_model extends uvm_reg_block;
            rand reg_invert invert;
            rand reg_counter_high counter_high;
            rand reg_counter_low counter_low;

            virtual function void build();
                ...
                invert.configure(this, null, "invert");
                ...
                counter_high.configure(this, null, "counter[31:16]");
                ...
                counter_low.configure(this, null, "counter[15:0]");
                ...
            endfunction

            `uvm_object_utils(reg_model)

            function new(input string name="reg_model");
                super.new(name, UVM_NO_COVERAGE);
            endfunction 
        endclass
        ~~~
   2. 在将寄存器模型集成到验证平台时， 需要设置好根路径hdl_root
        ~~~
        function void base_test::build_phase(uvm_phase phase);
            ...
            rm = reg_model::type_id::create("rm", this);
            rm.configure(null, "");
            rm.build();
            rm.lock_model();
            rm.reset();
            rm.set_hdl_path_root("top_tb.my_dut");//hdl_root
            ...
        endfunction
        ~~~
2. UVM提供两类后门访问的函数对比：
   1. UVM_BACKDOOR形式的read和write --> 在进行操作时模仿DUT的行为
   2. peek和poke  -->完全不管DUT的行为
   3. eg,RO_reg进行写操作， 那么第一类由于要模拟DUT的只读行为， 所以是写不进去的， 但是使用第二类可以写进去。


### 4. 复杂的寄存器模型
  
#### 1. 层次化的寄存器模型
##### 1. 建立层次化的寄存器模型
1. 一般的， 只会在第一级的uvm_reg_block中加入寄存器， 而第二级的uvm_reg_block通常只添加uvm_reg_block。
   - 优点：结构清晰
##### 2. 将一个子reg_block加入父reg_block中步骤
1. 先实例化子reg_block。
2. 调用子reg_block的configure函数
   - 如果需要后门访问，则在这个函数中要说明子reg_block的路径， 这个路径不是绝对路径， 而是相对于父reg_block来说的路径（如果，路径参数设置为空字符串， 不能发起后门访问操作）
3. 调用子reg_block的build函数
4. 调用子reg_block的lock_model函数
5. 将子reg_block的default_map以子map的形式加入父reg_block的default_map中,
   原因:
   - 因为一般在子reg_block中定义寄存器时， 给定的都是寄存器的偏移地址， 其实际物理地址还要再加上一个基地址。
   - 寄存器前门访问的读写操作最终都要通过default_map来完成。
   - 子reg_block的default_map并不知道寄存器的基地址， 它只知道寄
存器的偏移地址， 只有将其加入父reg_block的default_map， 并在加入的同时告知子map的偏移地址， 这样父reg_block的default_map
就可以完成前门访问操作了。
6. 总结
   - 一般将具有同一基地址的寄存器作为整体加入一个uvm_reg_block中， 而不同的基地址对应不同的uvm_reg_block。 
   - 每个uvm_reg_block一般都有与其对应的物理地址空间。 
   - 子reg_block， 其里面还可以加入小的reg_block， 这相当于将地
址空间再次细化。


#### 2. reg_file的作用
##### 1. uvm_reg_file的背景
1. 作用：主要是用于区分不同的hdl路径
2. 问题：
   - 背景：两个寄存器regA和regB， 它们的hdl路径分别为top_tb.mac_reg.fileA.regA和top_tb.mac_reg.fileB.regB，设top_tb.mac_reg下面所有寄存器的基地址为0x2000， 
   - 在最顶层的reg_block中加入mac模块时， 其hdl路径要写成
        ~~~
        mb_ins.configure(this, "mac_reg");
        ~~~
   - 在mac_blk的build中， 要通过如下方式将regA和regB的路径告知寄存器模型
        ~~~
        regA.configure(this, null, "fileA.regA");
        … 
        regB.configure(this, null, "fileB.regB");
        ~~~
   - 假如fileA中有几十个寄存器时， 那么很显然， fileA.*会几十次地出现在这几十个寄存器的configure函数里，假如有一天， fileA的名字忽然变为filea_inst， 那么就需要把这几十行中所有fileA替换成filea_inst， 这个过程很容易出错
   - 解决方案： 引入uvm_reg_file
##### 2. uvm_reg_file的应用
1. uvm_reg_file同uvm_reg相同是一个纯虚类， 不能直接使用， 而必须使用其派生类：
2. demo
   - 分析
    1. 先从uvm_reg_file派生一个类， 然后在my_blk中实例化此类， 
    2. 之后调用其configure函数， 
        - 第一个参数是其所在的reg_block的指针， 
        - 第二个参数是假设此reg_file是另外一个reg_file的父文件， 那么这里就填写其父reg_file的指针。 由于这里只有这一级reg_file， 因此填写null。 
        - 第三个参数则是此reg_file的hdl路径。 
            当把reg_file定义好后， 在调用寄存器的configure参数时，就可以将其第二个参数设为reg_file的指针。
   - code
        ~~~
        class regfile extends uvm_reg_file;
        function new(string name = "regfile");
            super.new(name);
        endfunction

        `uvm_object_utils(regfile)
        endclass

        ...

        class mac_blk extends uvm_reg_block;

        rand regfile file_a;
        rand regfile file_b;
        rand reg_regA regA;
        rand reg_regB regB;
        rand reg_vlan vlan;
        
        virtual function void build();
            default_map = create_map("default_map", 0, 2, UVM_BIG_ENDIAN, 0);

            file_a = regfile::type_id::create("file_a", , get_full_name());
            file_a.configure(this, null, "fileA");
            file_b = regfile::type_id::create("file_b", , get_full_name());
            file_b.configure(this, null, "fileB");
            ...
            //未引入regfile时的写法：regA.configure(this, null, "fileA.regA");
            regA.configure(this, file_a, "regA"); //第二个参数
            ...
            regB.configure(this, file_b, "regB");  //第二个参数
            ...

        endfunction

            `uvm_object_utils(mac_blk)

            function new(input string name="mac_blk");
                super.new(name, UVM_NO_COVERAGE);
            endfunction 
        
        endclass
        ~~~
3. 加入reg_file的概念后， 当fileA变为filea_inst时， 只需要将file_a的configure参数值改变一下即可， 其他则不需要做任何改变。 这大大减少了出错的概率。
   

#### 3. 多个域的寄存器
##### 1. 如果一个寄存器有多个域时， 那么在建立模型时不同
##### 2. 问题
1. 背景：某个寄存器有三个域， 其中最低两位为filedA， 接着三位为filedB， 接着四位为filedC， 其余位未使用
2. 这个寄存器从逻辑上来看是一个寄存器， 但是从物理上来看， 即它的DUT实现中是三个寄存器， 因此这一个寄存器实际上对应着三个不同的hdl路径： fieldA、 fieldB、 fieldC。
3. demo
    ~~~
    class three_field_reg extends uvm_reg;
        rand uvm_reg_field fieldA;
        rand uvm_reg_field fieldB;
        rand uvm_reg_field fieldC;

        virtual function void build();
            fieldA = uvm_reg_field::type_id::create("fieldA");
            fieldB = uvm_reg_field::type_id::create("fieldB");
            fieldC = uvm_reg_field::type_id::create("fieldC");
        endfunction
        ...
    endclass


    class mac_blk extends uvm_reg_block;
        ...
    rand three_field_reg tf_reg;
    
    virtual function void build();
        ...   
        tf_reg = three_field_reg::type_id::create("tf_reg", , get_full_name());
        //最后一个代表hdl路径的参数已经变为了空的字符串
        tf_reg.configure(this, null, "");
        tf_reg.build();
        tf_reg.fieldA.configure(tf_reg, 2, 0, "RW", 1, 0, 1, 1, 1);
        //重点：参数分为为：路径 ，起始位，位宽
        tf_reg.add_hdl_path_slice("fieldA", 0, 2);
        tf_reg.fieldB.configure(tf_reg, 3, 2, "RW", 1, 0, 1, 1, 1);
        tf_reg.add_hdl_path_slice("fieldA", 2, 3);
        tf_reg.fieldC.configure(tf_reg, 4, 5, "RW", 1, 0, 1, 1, 1);
        tf_reg.add_hdl_path_slice("fieldA", 5, 4);
        default_map.add_reg(tf_reg, 'h41, "RW");
    endfunction
    ...   
    endclass
    ~~~
4. 分析
   1. 先从uvm_reg派生一个类， 在此类中加入3个uvm_reg_field。 
   2. 在reg_block中将此类实例化后， 调用tf_reg.configure时要注意， 最后一个代表hdl路径的参数已经变为了空的字符串， 
   3. 在调用tf_reg.build之后要调用tf_reg.fieldA的configure函数。
   4. 调用完fieldA的configure函数后， 需要将fieldA的hdl路径加入tf_reg中， 此时用到的函数是**add_hdl_path_slice**,参数如下：
       - 第一个参数是要加入的路径 
       - 第二个参数则是此路径对应的域在此寄存器中的起始位数， 如fieldA是从0开始的， 而fieldB是从2开始的 
       - 第三个参数则是此路径对应的域的位宽

#### 4. 多个地址的寄存器
##### 1. 问题背景
DUT中的counter是32bit的， 而系统的数据位宽是16位的， 所以就占据了两个地址
##### 2. 方法
1. 将一个寄存器分割成两个寄存器的方式加入寄存器模型中的。 因其每次要读取counter的值时， 都需要对counter_low和counter_high各进行一次读取操作， 然后再将两次读取的值合成一个counter的值， 所以这种方式使用起来非常不方便
2. 新方法解决一个寄存器占据多个地址
3. demo
    ~~~
    class reg_counter extends uvm_reg;

        rand uvm_reg_field reg_data;

        virtual function void build();
            reg_data = uvm_reg_field::type_id::create("reg_data");
            // parameter: parent, size, lsb_pos, access, volatile, reset value, has_reset, is_rand, individually accessible
            reg_data.configure(this, 32, 0, "W1C", 1, 0, 1, 1, 0);
        endfunction

        `uvm_object_utils(reg_counter)

        function new(input string name="reg_counter");
            //parameter: name, size, has_coverage
            super.new(name, 32, UVM_NO_COVERAGE);
        endfunction
    endclass


    class reg_model extends uvm_reg_block;
    rand reg_invert invert;
    rand reg_counter counter;

    virtual function void build();
            ...      
        counter= reg_counter::type_id::create("counter", , get_full_name());
        counter.configure(this, null, "counter");
        counter.build();
        default_map.add_reg(counter, 'h5, "RW");
    endfunction
    ...

    endclass
    ~~~

2. 分析：
     1. 可以定义一个reg_counter， 并在其构造函数中指明此寄存器的大小为32位， 此寄存器中只有一个域， 此域的宽度也为32bit， 之后在reg_model中将其实例化即可。  
     2. 在调用default_map的add_reg函数时， 要指定寄存器的地址， 这里只需要指明最小的一个地址即可。 这是因为在前面实例化default_map时， 已经指明了它使用UVM_LITTLE_ENDIAN形式， 同时总线的宽度为2byte， 即16bit， UVM会自动根据这些信息计算出此寄存器占据两个地址。 
     3. 当使用前门访问的形式读写此寄存器时， 寄存器模型会进行两次读写操作， 即发出两个transaction， 这两个transaction对应的读写操作的地址从0x05一直递增到0x06。 
     4. 将counter作为一个整体时， 可以一次性地访问它：
           ~~~
           class case0_cfg_vseq extends uvm_sequence;
               ...
               virtual task body();
               ...
                   p_sequencer.p_rm.counter.read(status, value, UVM_FRONTDOOR);
                   `uvm_info("case0_cfg_vseq", $sformatf("counter's initial value(FRONTDOOR) is %0h", value), UVM_LOW)
                   p_sequencer.p_rm.counter.poke(status, 32'h1FFFD);
                   p_sequencer.p_rm.counter.read(status, value, UVM_FRONTDOOR);
                   `uvm_info("case0_cfg_vseq", $sformatf("after poke, counter's value(FRONTDOOR) is %0h", value), UVM_LOW)
               ...
               endtask
           endclass
           ~~~


#### 5. 加入存储器
1. 存储器
- DUT中还存在大量的存储器。 这些存储器有些被分配了地址空间， 有些没有。 验证人员有时需要在仿真过程中得到存放在这些存储器中数据的值， 从而与期望的值比较并给出结果。
2. eg,示例背景
- 一个DUT的功能是接收一种数据， 它经过一些相当复杂的处理（ 操作A） 后将数据存储在存储器中， 这块存储器是DUT内部的存储器， 并没有为其分配地址。 
- 当存储器中的数据达到一定量时， 将它们读出， 并再另外做一些复杂处理（ 如封装成另外一种形式的帧， 操作B） 后发送出去。
- 在验证平台中如果只是将DUT输出接口的数据与期望值相比较， 当数据不匹配情况出现时， 则无法确定问题是出在操作A还是操作B中， 如图7-8a所示。 此时， 如果在输出接口之前再增加一级比较， 就可以快速地定位问题所在了， 如图7-8b所示
3. 寄存器模型中加入存储器非常容易。
   - demo
        ~~~
        class my_memory extends uvm_mem;
            function new(string name="my_memory");
                super.new(name, 1024, 16);
            endfunction

            `uvm_object_utils(my_memory)
        endclass


        class reg_model extends uvm_reg_block;
            ...
            rand my_memory mm;

            virtual function void build();
            ...
                mm = my_memory::type_id::create("mm", , get_full_name());
                //参数2：是此块存储器的hdl路径。
                mm.configure(this, "stat_blk.ram1024x16_inst.array");
                //有map才能前门访问
                default_map.add_mem(mm, 'h100);
            endfunction
        endclass
        ~~~

   - 分析
     1. 由uvm_mem派生一个类my_memory， 在其new函数中调用super.new函数。 这个函数有三个参数， 第一个是名字， 第二个是存储器的深度， 第三个是宽度。 
     2. 在reg_model的build函数中， 将存储器实例化， 调用其configure函数， 第一个参数是所在reg_block的指针， 第二个参数是此块存储器的hdl路径。 
     3. 最后调用default_map.add_mem函数， 
        - 将此块存储器加入default_map中， 从而可以对其进行前门访问操作。 
        - 如果没有对此块存储器分配地址空间， 那么这里可以不将其加入default_map中。 在这种情况下，只能使用后门访问的方式对其进行访问。
4. 通过调用read、 write、 peek、 poke实现对此存储器进行读写，
 - 这四个任务/函数在调用的时候需要额外加入一个offset的参数， 说明读取此存储器的哪个地址。
5. 假如存储器的宽度大于系统总线位宽时， 情况会略有不同。 如在一个16位的系统中加入512×32的存储器
 - demo
      ~~~
      src/ch7/section7.4/7.4.5/ram512x32/reg_model.sv
      class my_memory extends uvm_mem;
          function new(string name="my_memory");
              super.new(name, 512, 32);
          endfunction

          `uvm_object_utils(my_memory)
      endclass
      ~~~
 - 分析
     1. 在派生my_memory时， 就要在其new函数中指明其宽度为32bit， 在my_block中加入此memory的方法与前面的相同。 
     2. 这里加入的存储器的一个单元占据两个物理地址， 共占据1024个地址。 那么当使用read、 write、 peek、 poke时， 输入的参数offset代表实际的物理地址偏移还是某一个存储单元偏移呢？ 答案是存储单元偏移。 在访问这块512×32的存储器时， offset的最大值是511， 而不是1023。 
     3. 当指定一个offset， 使用前门访问操作读写时， 由于一个offset对应的是两个物理地址， 所以寄存器模型会在总线上进行两次读写操作。



### 5. 寄存器模型对DUT的模拟
#### 1. 期望值与镜像值
1. 基础：
   - 于DUT中寄存器的值可能是实时变更的， 寄存器模型并不能实时地知道这种变更， 因此， 寄存器模型中的寄存器的值有时与DUT中相关寄存器的值并不一致
   - mirrored value： 对于任意一个寄存器， 寄存器模型中都会有一个专门的变量用于最大可能地与DUT保持同步， 这个变量在寄存器模型中称为DUT的镜像值（ mirrored value）
     - 通过get函数可以得到寄存器的期望值， 通过get_mirrored_value可以得到镜像值
   -  desired value：如目前DUT中invert的值为'h0， 寄存器模型中的镜像值也为'h0， 但是希望向此寄存器中写入一个'h1， 
     - 一种方法是直接调用前面介绍的write任务， 将'h1写入， 期望值与镜像值都更新为'h1； 
     - 另外一种方法是通过**set&update**
       - set函数将期望值设置为'h1（ 此时镜像值依然为0） ， 
       - 之后调用update任务，update任务会检查期望值和镜像值是否一致， 
       - 如果不一致， 那么将会把期望值写入DUT中， 并且更新镜像值
   - 对于存储器来说， 并不存在期望值和镜像值。 寄存器模型*不对**存储器进行任何模拟。 若要得到存储器中某个存储单元的值，只能使用read、 write、 peek、 poke四种操作
2. eg
    ~~~
    class case0_cfg_vseq extends uvm_sequence;
    ...
    virtual task body();
    ...
        value = p_sequencer.p_rm.invert.get();
        `uvm_info("case0_cfg_vseq", $sformatf("invert's desired value is %0h", value), UVM_LOW)
        value = p_sequencer.p_rm.invert.get_mirrored_value(); //得到镜像值
        `uvm_info("case0_cfg_vseq", $sformatf("invert's mirrored value is %0h", value), UVM_LOW)
        p_sequencer.p_rm.invert.peek(status, value);
        `uvm_info("case0_cfg_vseq", $sformatf("invert's actual value is %0h", value), UVM_LOW)
        if(starting_phase != null) 
            starting_phase.drop_objection(this);
    endtask

    endclass
    ~~~

#### 2. 常用操作及其对期望值和镜像值的影响
1. read&write操作： 无论通过后门/前门 读写寄存器， 在操作完成后， 寄存器模型都会根据读写的结果更新期望值和镜像值（ 二者相等） 。
2. peek&poke操作：在操作完成后， 寄存器模型会根据操作的结果更新期望值和镜像值（ 二者相等） 。
1. get&set操作： 
   - set操作会更新期望值， 但是镜像值不会改变。 
   - get操作会返回寄存器模型中当前寄存器的期望值。
2. update操作： 这个操作会检查寄存器的期望值和镜像值是否一致， 
   - 如果不一致， 那么就会将期望值写入DUT中， 并且更新镜像值， 使其与期望值一致。 
   - 每个由uvm_reg派生来的类都会有update操作。 
   - 每个由uvm_reg_block派生来的类也有update操作， 它会递归地调用所有加入此reg_block的寄存器的update任务。
3. randomize操作： 寄存器模型提供randomize接口。 
   - randomize之后， 期望值将会变为随机出的数值， 镜像值不会改变。 
   - 但是并不是寄存器模型中所有寄存器都支持此函数。 
   - 如果不支持， 则randomize调用后其期望值不变。 
   - 若要关闭随机化功能，在reg_invert的build中调用reg_data.configure时将其第八个参数设置为0即可。 
   - 一般， randomize不会单独使用而是和update一起。 如在DUT上电复位后， 需要配置一些寄存器的值。 这些寄存器的值通过randomize获得， 并使用update任务配置到DUT中。 关于randomize和update

### 6. 内建的sequence
#### 1.检查后门访问中hdl路径的sequence
1. uvm_reg_mem_hdl_paths_seq，检查hdl路径的正确性,寄存器&存储器
2. 如果某个寄存器/存储器在加入寄存器模型时没有指定其hdl路径， 那么此sequence在检查时会跳过这个寄存器/存储器
3. 原型
    ~~~
    class uvm_reg_mem_hdl_paths_seq extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item))
    ~~~
4. 依赖：
    运行依赖于在基类uvm_sequence中定义的一个变量uvm_reg_block model，在启动此sequence时必须给model赋值
5. 运行条件：在任意的sequence中， 可以启动此sequence：
6. eg：
     - 在调用这个sequence的start任务时， 传入的sequencer参数为null。 因为它正常工作不依赖于这个sequencer， 而依赖于model变量。
     - 这个sequence会试图读取hdl所指向的寄存器， 如果无法读取， 则给出错误提示
     - demo
        ~~~
        文件： src/ch7/section7.6/7.6.1/my_case0.sv
        class case0_cfg_vseq extends uvm_sequence;
            ...
            virtual task body();
                ...
                uvm_reg_mem_hdl_paths_seq ckseq;
                ...
                ckseq = new("ckseq");
                ckseq.model = p_sequencer.p_rm;
                ckseq.start(null);
                ...
            endtask
            ...
        endclass
     ~~~


#### 2.检查默认值的sequence
1. uvm_reg_hw_reset_seq用于检查上电复位后寄存器模型与DUT中寄存器的默认值是否相同
2. 原型
    ~~~
    class uvm_reg_hw_reset_seq extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item));
    ~~~
3. 默认值& 复位值
   - 对于DUT来说， 在复位完成后， 其值就是默认值。 
   - 但是对于寄存器模型来说， 如果只是将它集成在验证平台上， 而不做任何处理， 那么它所有寄存器的值为0， 
   - 此时需要调用reset函数来使其内寄存器的值变为默认值（ 复位值） 
4. 该sequence在其检查前会调用model的reset函数， 所以即使在集成到验证平台时没有调用reset函数， 这个sequence也能正常
工作
5. 作用：
   - 该sequence所做的事情就是使用前门访问的方式读取所有寄存器的值， 
   - 并将其与寄存器模型中的比较
6. 忽略检查：
   - 如果想跳过某个寄存器的检查， 可以行的在启动此sequence前使用resource_db设置不检查此寄存器。
   - resource_db机制与config_db机制的底层实现是一样的， uvm_config_db类就是从uvm_resource_db类派生而来的。 
   - 由于在寄存器模型的sequence中， get操作是通过resource_db来进， 所以这里使用resource_db来进行设置：
   - demo1 
       ~~~
       文件： src/ch7/section7.6/7.6.2/my_case0.sv
       function void my_case0::build_phase(uvm_phase phase);
           …
           uvm_resource_db#(bit)::set({"REG::",rm.invert.get_full_name(),".*"},"NO_REG_TESTS", 1, this);
           …
       endfunction
       ~~~

   - demo2
       ~~~
       文件： src/ch7/section7.6/7.6.2/my_case0.sv
       function void my_case0::build_phase(uvm_phase phase);
           …
           uvm_resource_db#(bit)::set({"REG::",rm.invert.get_full_name(),".*"}, "NO_REG_HW_RESET_TEST", 1, this);
       endfunction
       ~~~


#### 3. 检查读写功能的sequence
##### 1. 寄存器
1.  uvm_reg_access_seq用于检查寄存器的读写
2.  原型，使用此sequence也需要指定其model变量
    ~~~
    class uvm_reg_access_seq extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_it em))
    ~~~
3. 作用：
   - 该sequence，使用前门 给 所有寄存器写数据， 然后使用后门 读回， 并比较结果。
   - 最后把这个过程反过来，使用后门方式写入数据， 再用前门访问读回。
4. 注意事项：这个sequence要正常工作必须为所有的寄存器设置好hdl路径
5. 跳过寄存器检查，下一方式，2选1
    ~~~
    文件： src/ch7/section7.6/7.6.3/my_case0.sv
    function void my_case0::build_phase(uvm_phase phase);
        …
        //set for reg access sequence
        uvm_resource_db#(bit)::set({"REG::",rm.invert.get_full_name(),".*"},    "NO_REG_TESTS", 1, this);
        uvm_resource_db#(bit)::set({"REG::",rm.invert.get_full_name(),".*"},    "NO_REG_ACCESS_TEST", 1, this);
        …
    endfunction
    ~~~
##### 2. 存储器
1. uvm_mem_access_seq用于检查存储器的读写，
2. 原型，启动此sequence同样需要指定其model变量。
    ~~~
    class uvm_mem_access_seq extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_it em)
    ~~~
3. 作用
- 这个sequence会通过使用前门访问的方式向所有存储器写数据， 然后使用后门访问的方式读回， 并比较结果。
-  最后把这个过程反过来， 使用后门访问的方式写入数据， 再用前门访问读回。 
4. 注意事项
   这个sequence要正常工作必须为所有的存储器设置好HDL路径。   
5. 如果要跳过某块存储器的检查，下一方式，3选1
    ~~~
    文件： src/ch7/section7.6/7.6.3/my_case0.sv
    function void my_case0::build_phase(uvm_phase phase);
        ...
        …
        //set for mem access sequence
        uvm_resource_db#(bit)::set({"REG::",rm.get_full_name(),".*"},    "NO_REG_TESTS", 1, this);
        uvm_resource_db#(bit)::set({"REG::",rm.get_full_name(),".*"},    "NO_MEM_TESTS", 1, this);
        uvm_resource_db#(bit)::set({"REG::",rm.invert.get_full_name(),".*"},
        "NO_MEM_ACCESS_TEST", 1, this);
    endfunction
    ~~~


### 7. 高级用法
#### 1. 使用reg_predictor
##### 1. set_auto_predict(1)
1. 特点：
-  依赖于driver
-  driver将读取值返回后， 寄存器模型会更新寄存器的镜像值和期望值   
2. 使能
    ~~~
    rm.default_map.set_auto_predict(1)
    ~~~  
3. 框图：
   - ![image](https://github.com/user-attachments/assets/4dc8901b-e493-493d-b919-e86a7a1e0ea0)

##### 2. set_auto_predict(0)
1. 特点：
   - 是由monitor将从总线上收集到的transaction交给寄存器模型， 后者更新相应寄存器的值
2. 使能
    ~~~
    rm.default_map.set_auto_predict(0)
    ~~~  
3. 使用
- 需要实例化一个reg_predictor， 并为这个reg_predictor实例化一个adapter
- 在connect_phase中， 需要将reg_predictor和bus_agt的ap口连接在一起， 并设置reg_predictor的adapter和map
- 只有设置了map后， 才能将predictor和寄存器模型关联在一起
- 如下demo事实上存在着两条更新寄存器模型的路径： 
  - 一是图下图虚线所示的自动预测途径， 
  - 二是经由predictor的途径。 如果要彻底关掉虚线的更新路径,则需``rm.default_map.set_auto_predict(0);``
  - demo
    ~~~
    文件： src/ch7/section7.7/7.7.1/base_test.sv
    class base_test extends uvm_test;
        …
        reg_model rm;
        my_adapter reg_sqr_adapter;
        my_adapter mon_reg_adapter;

        uvm_reg_predictor#(bus_transaction) reg_predictor;
        …
    endclass

    function void base_test::build_phase(uvm_phase phase);
        …
        rm = reg_model::type_id::create("rm", this);
        rm.configure(null, "");
        rm.build();
        rm.lock_model();
        rm.reset();
        reg_sqr_adapter = new("reg_sqr_adapter");
        mon_reg_adapter = new("mon_reg_adapter");
        reg_predictor = new("reg_predictor", this); //例化
        env.p_rm = this.rm;
    endfunction

    function void base_test::connect_phase(uvm_phase phase);
        …
        rm.default_map.set_sequencer(env.bus_agt.sqr, reg_sqr_adapter);
        rm.default_map.set_auto_predict(1); //打开
        reg_predictor.map = rm.default_map;
        reg_predictor.adapter = mon_reg_adapter;
        env.bus_agt.ap.connect(reg_predictor.bus_in);
    endfunction
    ~~~ 
4. 框图：
   - ![image](https://github.com/user-attachments/assets/93bc71c7-27df-48c1-a8cc-d11cfde69a0e)

##### 3. set_auto_predict(0)，set_auto_predict(1) 对比
- 当总线上只有一个主设备（ master） 时， 则图7-9的左图和右图是完全等价的。 
- 如果有多个主设备， 则左图会漏掉某些trasaction。


#### 2. 使用UVM_PREDICT_DIRECT功能与mirror操作
##### 1. mirror
1. mirror:用于读取DUT中寄存器的值并将它们更新到寄存器模型中
2. 函数原型:
   - 有多个参数， 但是常用的只有前三个。 
   - 其中第二个参数指的是如果发现DUT中寄存器的值与寄存器模型中的镜像值不一致， 那么在更新寄存器模型之前是否给出错误提示。 
   - 其可选的值为UVM_CHECK和UVM_NO_CHECK。
    ~~~
    task uvm_reg::mirror(output uvm_status_e status,
                        input uvm_check_e check = UVM_NO_CHECK,
                        input uvm_path_e path = UVM_DEFAULT_PATH,
                        …);
    ~~~
3. 2种场景
   - 一是在仿真中不断地调用它， 使得到整个寄存器模型的值与DUT中寄存器的值保持一致， 此时check选项是关闭的。
   - 仿真即将结束时， 检查DUT中寄存器的值与寄存器模型中寄存器的镜像值是否一致， 这种情况下， check选项是
打开的
4. 本质
   - mirror操作会更新期望值和镜像值。 
   - 同update操作类似， mirror操作既可以在uvm_reg级别被调用， 也可以在uvm_reg_block级别被调用
   - 当调用一个uvm_reg_block的mirror时， 其实质是调用加入其中的所有寄存器的mirror。
5. 仿真应用
    一般的， 会在仿真即将结束时使用mirror操作检查这些计数器的值是否与预期值一致。

##### 2. 累计统计计数器
1. 背景：
   在通信系统中存在大量的计数器。 当网络出现异常时， 借助这些计数器能够快速地找出问题所在， 所以必须要保证这些计数器的正确性
2. 问题：
   在DUT中的计数器是不断累加的， 但是寄存器模型中的计数器则保持静止
3. 现状
   前文中介绍的所有的操作都无法完成这个事情， 无论是set， 还是write， 或是poke； 无论是后门访问还是前门访问
4. 思路
   人为地更新镜像值， 但是同时又不要对DUT进行任何操作。
5. 解决方案 -- UVM提供predict操作来实现
   - 参数
       - 第一个参数表示要预测的值， 
       - 第二个参数是byte_en， 默认-1的意思是全部有效， 
       - 第三个参数是预测的类型，有如下可选项
            ~~~
            来源： UVM源代码
            typedef enum {
                    UVM_PREDICT_DIRECT,
                    UVM_PREDICT_READ,
                    UVM_PREDICT_WRITE
                    } uvm_predict_e;
            ~~~  
       - 第四个参数是后门访问或者是前门访问。 
   - 原型：
        ~~~
        function bit uvm_reg::predict (uvm_reg_data_t value,
                            uvm_reg_byte_en_t be = -1,
                            uvm_predict_e kind = UVM_PREDICT_DIRECT,
                            uvm_path_e path = UVM_FRONTDOOR,
        …);
        ~~~
6. read/peek和write/poke操作在对DUT完成读写后， 也会调用predict函数， 只是它们给出的参数是UVM_PREDICT_READ和UVM_PREDICT_WRITE
7. 要实现在参考模型中更新寄存器模型而又不影响DUT的值， 需要使用UVM_PREDICT_DIRECT， 即默认值：
   - 在my_model中， 每得到一个新的transaction， 就先从寄存器模型中得到counter的期望值（ 此时与镜像值一致） ， 之后将新的transaction的长度加到counter中， 最后使用predict函数将新的counter值更新到寄存器模型中。
   - predict操作会更新镜像值和期望值
   - demo
        ~~~
        task my_model::main_phase(uvm_phase phase);
            …
            p_rm.invert.read(status, value, UVM_FRONTDOOR);
            while(1) begin
                port.get(tr);
                …
                if(value)
                invert_tr(new_tr);
                counter = p_rm.counter.get();
                length = new_tr.pload.size() + 18;
                counter = counter + length;
                p_rm.counter.predict(counter);
                ap.write(new_tr);
            end
        endtask
        ~~~
    - 在测试用例中， 仿真完成后可以检查DUT中counter的值是否与寄存器模型中的counter值一致：
        ~~~
        class case0_vseq extends uvm_sequence;
            …
            virtual task body();
                …
                dseq = case0_sequence::type_id::create("dseq");
                dseq.start(p_sequencer.p_my_sqr);
                #100000;
                p_sequencer.p_rm.counter.mirror(status, UVM_CHECK, UVM_FRONTDOOR);
                …
            endtask

        endclass
        ~~~

#### 3. 寄存器模型的随机化与update
##### 1. register_model/uvm_reg_block/uvm_reg级来说， 都支持randomize操作。
        ~~~
        assert(rm.randomize());
        assert(rm.invert.randomize());
        assert(rm.invert.reg_data.randomize());
        ~~~
##### 2. 使某个field能够随机化， 
1. 寄存器模型的rand类型,
    ~~~
    //uvm_reg中加入uvm_reg_field时， 是将加入的uvm_reg_field定义为rand类型
    class reg_invert extends uvm_reg;
        rand uvm_reg_field reg_data;
        … 
    endclass

    ...
    // 在将uvm_reg加入uvm_reg_block中时， 同样定义为rand类型
    class reg_model extends uvm_reg_block;
        rand reg_invert invert;
        … 
    endclass
    ~~~
2. 在每个reg_field加入uvm_reg时， 要调用其configure函数：
    - 这个函数的第八个参数即决定此field是否会在randomize时被随机化。 
    - 但是即使此参数为1， 也不一定能够保证此field被随机化。 
    - 当一个field的类型中**没有写操作时， 此参数设置是无效的**。
    - 换言之， 此参数只在此field类型为RW、 WRC、 WRS、 WO、W1、 WO1时才有效。
    - demo
        ~~~
        // parameter: parent, size, lsb_pos, access, volatile, reset value, has_reset,
        is_rand, individually accessible
        reg_data.configure(this, 1, 0, "RW", 1, 0, 1, 1, 0);
        ~~~
##### 3. 避免一个field被随机化，以下方法3选1
1. 当在uvm_reg中定义此field时， 不要设置为rand类型。
2. 在调用此field的configure函数时， 第八个参数设置为0。
3. 设置此field的类型为RO、 RC、 RS、 WC、 WS、 W1C、 W1S、 W1T、 W0C、 W0S、 W0T、 W1SRC、 W1CRS、 W0SRC、
W0CRS、 WSRC、 WCRS、 WOC、 WOS中的一种
4. 总结：
   - 其中第一种方式也适用于关闭某个uvm_reg或者某个uvm_reg_block的randomize功能。
   - 既然存在randomize， 那么也可以为它们定义constraint，修改默认值
       ~~~
       class reg_invert extends uvm_reg;
           rand uvm_reg_field reg_data;
           constraint cons{
           reg_data.value == 0;
           }
           … 
       endclass
       ~~~
   - 在施加约束时， 要深入reg_field的value变量
   - randomize会更新寄存器模型中的预期值：
       ~~~
       function void uvm_reg_field::post_randomize();
           m_desired = value;
       endfunction: post_randomiz
       ~~~
5. 应用
   - 与set函数类似。 因此可以在randomize完成后调用update任务， 将随机化后的参数更新到DUT中。
   - 这特别适用于在仿真开始时随机化并配置参数


#### 4. 扩展位宽
1. 如下寄存器模型定义，调用super.new时的第二个参数是16， 这个数字一般表示系统总线的宽度， 它可以是32、64、 128等。 
2. 但是在寄存器模型中， 这个数字的默认最大值是64
3. 它是通过一个宏来控制
    ~~~
    `ifndef UVM_REG_DATA_WIDTH
        `define UVM_REG_DATA_WIDTH 64
    `endif
    ~~~
4. 如果想要扩展系统总线的位宽， 可以通过重新定义这个宏来扩展。
5. 与数据位宽相似的是地址位宽也有默认最大值限制， 其默认值也是64
6. 在默认情况下， 字选择信号的位宽等于数据位宽除以8， 它通过如下的宏来控制：
    ~~~
    `ifndef UVM_REG_BYTENABLE_WIDTH
        //兼容性的写法，
        //if宏==63,(63-1)/8+1=8,
        //if宏==64,(64-1)/8+1=8,
        //if宏==65,(65-1)/8+1=9,
        `define UVM_REG_BYTENABLE_WIDTH ((`UVM_REG_DATA_WIDTH-1)/8+1)  
    `endif
    ~~~
7. 寄存器模型
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
            super.new(name, 16, UVM_NO_COVERAGE); //16: 这个数字一般表示系统总线的宽度
        endfunction
    endclass
    ~~~

### 8. 其他常用函数
#### 1. get_root_blocks
##### 1. 在某处,使用寄存器模型，2个方法
1. 须将寄存器模型的指针传递过去， 如在virtual sequence中使用， 需要传递给virtual sequencer
    ~~~
    function void base_test::connect_phase(uvm_phase phase);
        …
        v_sqr.p_rm = this.rm;
    endfunction
    ~~~
2. get_root_blocks，在不使用指针传递的情况下得到寄存器模型的指针
   - get_root_blocks函数得到验证平台上所有的根块（ root block） 。 根块指最顶层的reg_block
   - 在使用get_root_blocks函数得到reg_block的指针后， 要使用cast将其转化为目标reg_block形式（ 示例中为reg_model） 。 以后就可以直接使用p_rm来进行寄存器操作， 而不必使用p_sequencer.p_rm。
   - 原型
       ~~~
       function void uvm_reg_block::get_root_blocks(ref uvm_reg_block blks[$]);
       ~~~
    - deomo
        ~~~
        src/ch7/section7.8/7.8.1/my_case0.sv
        class case0_cfg_vseq extends uvm_sequence;
            …
            virtual task body();
                uvm_status_e status;
                uvm_reg_data_t value;
                bit[31:0] counter;
                uvm_reg_block blks[$];
                reg_model p_rm;
                …
                uvm_reg_block::get_root_blocks(blks);//获取寄存器模型的跟块
                if(blks.size() == 0)
                    `uvm_fatal("case0_cfg_vseq", "can't find root blocks")
                else begin
                    if(!$cast(p_rm, blks[0])) //向下转换
                    `uvm_fatal("case0_cfg_vseq", "can't cast to reg_model")
                end

                p_rm.invert.read(status, value, UVM_FRONTDOOR);
                …
            endtask
        endclass
        ~~~

#### 2.get_reg_by_offset函数
##### 1. 2中方式访问寄存器模型
1. 直接通过层次引用的方式访问寄存器
    ~~~
    rm.invert.read(...);
    ~~~
2. get_reg_by_offset后通过地址访问
   - 使用get_reg_by_offset函数通过寄存器的地址得到一个uvm_reg的指针，
   - 再调用此uvm_reg的read或者write就可以进行读写操作
   - 通过调用最顶层的reg_block的get_reg_by_offset， 即可以得到任一寄存器的指针
   - 从最顶层的reg_block的get_reg_by_offset也可以得到子reg_block中的寄存器
   - 即假如buf_blk的地址偏移是'h1000， 其中有偏移为'h3的寄存器（ 即此寄存器的实际物理地址是'h1003） ， 那么可以直接由p_rm.get_reg_by_offset（ 'h1003） 得到此寄存器， 而不必使用p_rm.buf_blk.get_reg_by_offset（ 'h3）。
   - demo
    ~~~
    文件： src/ch7/section7.8/7.8.2/my_case0.sv
    virtual task read_reg(input bit[15:0] addr, output bit[15:0] value);
        uvm_status_e status;
        uvm_reg target;
        uvm_reg_data_t data;
        uvm_reg_addr_t addrs[];
        target = p_sequencer.p_rm.default_map.get_reg_by_offset(addr); //offseth获取寄存器

        if(target == null)
            `uvm_error("case0_cfg_vseq", $sformatf("can't find reg in register model with address: 'h%
        target.read(status, data, UVM_FRONTDOOR); //读

        void'(target.get_addresses(null,addrs)); // 当存在多个地址，通过get_addresses函数可以得到这个函数的所有地址， 其返回值是一个动态数组addrs, 其中无论是大端还是小端， addrs[0]是LSB对应的地址
        if(addrs.size() == 1)
            value = data[15:0];
            else begin
            int index;
            for(int i = 0; i < addrs.size(); i++) begin
                if(addrs[i] == addr) begin
                    data = data >> (16*(addrs.size() - i));
                    value = data[15:0];
                    break;
                end
            end
        end
    endtask
    ~~~

### 8.  传送门
   1. [《UVM实战》学习笔记——第七章 UVM中的寄存器模型2——期望值/镜像值、自动/显示预测、操作方式](https://blog.csdn.net/qq_42135020/article/details/130345407)
   2. [《UVM实战》学习笔记——第七章 UVM中的寄存器模型1——寄存器模型介绍、前门/后门访问](https://blog.csdn.net/qq_42135020/article/details/129400177?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522172230019916800172565637%2522%252C%2522scm%2522%253A%252220140713.130102334.pc%255Fall.%2522%257D&request_id=172230019916800172565637&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~first_rank_ecpm_v1~rank_v31_ecpm-2-129400177-null-null.142^v100^control&utm_term=%E7%AC%AC%E4%B8%83%E7%AB%A0%20UVM%E4%B8%AD%E7%9A%84%E5%AF%84%E5%AD%98%E5%99%A8%E6%A8%A1%E5%9E%8B&spm=1018.2226.3001.4187)
