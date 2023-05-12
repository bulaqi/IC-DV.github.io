### 参考
https://blog.csdn.net/hh199203/article/details/114981486
### 方法
#### 1. testbench中控制dump fsdb
 1. testbench中加入的代码
   ~~~
   initial
	    if($test$plusargs("DUMP_FSDB"))
	    begin
	    	$fsdbDumpfile("testname.fsdb");  //记录波形，波形名字testname.fsdb
	    	$fsdbDumpvars("+all");  //+all参数，dump SV中的struct结构体
	    	$fsdbDumpSVA();   //将assertion的结果存在fsdb中
	    	$fsdbDumpMDA(0, top);  //dump memory arrays
	    	//0: 当前级及其下面所有层级，如top.A, top.A.a，所有在top下面的多维数组均会被dump
	    	//1: 仅仅dump当前组，也就是说，只dump top这一层的多维数组。
	    end
   end
   ~~~
 2. 开启记录波形
    只需要在仿真命令后面加上如下命令即可，这里的DUMP_FSDB字符串，要和上面代码if中判断条件的字符串保持一致。
    ~~~
    vcs +DUMP_FSDB
    ~~~


#### 2. vcs仿真命令控制dump fsdb
有的时候，我们不想去改变testbench的代码，或者说，我们想根据不同的case去dump不同层次结构下的fsdb波形，这时候就可以采用vcs的仿真命令，去控制dump波形。\
直接在仿真命令后面加上“ -ucli -i dump_fsdb_vcs.tcl ”，如下所示：
~~~
com:
	vcs -sverilog -debug_acc+all -LDFLAGS -rdynamic -full64 \
	    -P $(VERDI_HOME)/share/PLI/VCS/$(PLATFORM)/novas.tab \
	       $(VERDI_HOME)/share/PLI/VCS/$(PLATFORM)/pli.a \
	    -f tb_top.f \
	    +vcs+lic+wait \
	    -l com_vcs.log
sim:
    	./simv +ntb_random_seed=$(SEED) \
	-ucli -i dump_fsdb_vcs.tcl \
	+fsdb+autoflush \
	-l sim_vcs.log 

~~~
其中，-ucli 使能UCLI命令；-i 指定一个VCS执行仿真时包含CLI命令的文件，一般与-ucli配合；dump_fsdb_vcs.tcl 是一个tcl文件。
其中，tcl文件的格式如下所示：
~~~
global env                             # tcl脚本引用环境变量，Makefile中通过export定义   
fsdbDumpfile "test.fsdb"    # 设置波形文件名，受环境变量env(demo_name)控制   # demo_name在makefile中使用export demo_name=demo_fifo  
fsdbDumpvars 0 "tb_top"                # 设置波形的顶层和层次，表示将tb_top作为顶层，Dump所有层次
run                                    # 设置完dump信息，启动仿真（此时仿真器被ucli控制） 可以run 100ns会在仿真100ns的时候停下来下来
~~~

#### 3. irun仿真命令控制dump fsdb
irun的仿真命令，去控制dump波形
~~~
com:
	irun -elaborate -access +r \
	-f tb_top.f \
	-top tb_top \
	-licqueue \
	-l com_irun.log


sim:
	irun -R \
	-input dump_fsdb_irun.tcl \
        +fsdb+autoflush \
	-licqueue \
	-l sim_irun.log
~~~

tcl文件如下
~~~
global env
call fsdbAutoSwitchDumpfile 500 "test.fsdb" 50  #500M一个文件，最多50个
#call fsdbDumpfile "test.fsdb"  # 需要使用call,与vcs区别之一
call  fsdbDumpvars 0 tb_top "+all"
run 10us   #起始dump 10us的波形
call fsdbDumpoff     #关闭波形打印
run  13ms     # 13ms处开启波形打印
call fsdbDumpon
run 1ms    #打印1ms长度的波形
call fsdbDumpoff
run 10us
quit                                      # 需要使用quit，irun不自动结束
~~~