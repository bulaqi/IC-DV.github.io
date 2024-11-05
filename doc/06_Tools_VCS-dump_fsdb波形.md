1. ### 理论方法
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

   ~~~
   initial
	    if($test$plusargs("dumpfsdb=%d",dump_fsdb))
	    begin
		#dump_fsdb;
		//$fsdbAutoSwitchDumpfile(1024*10,"inter.fsdb",10, "inter.fsdb.log"); //根据大小切割波形，最大1024*10M,最大10个波形文件
		$fsdbAutoSwitchDumpfile(200,"inter.fsdb",10, "+by_sim_period+us"); //根据仿真时间dump 波形，每200 us dump 一个fsdb文件，最大10个波形文件
		$fsdbDumpvarsToFile("dump.list"); // 运行模块下有dump.list文件指定dump范围
	    	$fsdbDumpon; 
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

### 2. ucli 调用tcl 经验
#### 1. dump 波形
~~~
dump -add {aem_top_tb} -depth 0 -scope "." --aggregate
~~~
#### 2. 加载其他debug_tcl.do 文件
~~~
if {[file exit debug_tcl.do] == 1 } {
   do debug_tcl.do
}
~~~
#### 3. TCL 仿真的3中模式
1. verdi_mode / ve_mode  batch_mode
2. [info command stateVerdiChangeCB == "stateVerdiChangeCB"], 通过参数确认进入的是那种方式,见参考资料2

### 3. 传送门
1. [VCS dump fsdb 波形](https://blog.csdn.net/hh199203/article/details/114981486)
2. [TCL学习之info命令](https://blog.csdn.net/iamsarah/article/details/70920625)
3. [常用UCLI 命令汇总](https://blog.csdn.net/qq_16423857/article/details/123508360?spm=1001.2101.3001.6661.1&utm_medium=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-123508360-blog-123585226.235%5Ev43%5Epc_blog_bottom_relevance_base5&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-123508360-blog-123585226.235%5Ev43%5Epc_blog_bottom_relevance_base5&utm_relevant_index=1)
4. [如何按照时间自动切割FSDB文件](https://www.bilibili.com/video/BV14j411d73J/?spm_id_from=333.337.search-card.all.click&vd_source=4961046a0ef4f6531d203062fb9d2390)
