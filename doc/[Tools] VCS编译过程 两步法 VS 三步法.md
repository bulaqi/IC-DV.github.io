[TOC]
### 背景,两步法 vs 三步法
通常情况下vcs的仿真分为两步，先用vcs编译生成一个sim文件，再执行这个sim文件进行仿真。这样的仿真方式存在两个问题：问题一，当设计比较大的时候，每次都要全部重新编译一遍，比较浪费时间；问题二，当设计中存在VHDL文件时，两步法就无法使用，因为VHDL文件需要单独处理。
本文主要介绍VCS的三步编译法，包括：
- Analysis(新增)
- Elaboration
- Simulation


### 一、Analysis,vlogan先分析verilog代码
代码如下所示，make vlog分析verilog代码，make vhdl分析vhdl的代码。
~~~
vlog:
	vlogan -l vlogan.log -sverilog -assert svaext +v2k -loc -F verilog.f
vhdl:
	vhdlan -l vhdlan.log -F vhdl.f	
~~~

### 二、Elaboration
代码如下所示，
- make uvm分析并生成uvm的库文件；
- make testbench分析并生成顶层testbench的库文件,tb文件在 tb.f文件内；
- make elab编译生成simv文件(默认名称)，其中如果环境中用到了VIP，需要指定VIP自带的so库文件
~~~
uvm:
	vlogan -l uvm.log -ntb_opts uvm -full64 +define+UVM_NO_DPI +define+UVM_NO_DEPRECATED
testbench:
	vlogan -l testbench.log -ntb_opts uvm -full64 -sverilog -debug_pp +define+UVM_NO_DPI 	+define+NSYS_UVM +plusarg_save +v2k -lca -F tb.f  
elab:
	vcs -l elab.log -full64 -debug_pp -debug_all -lca -fsdb -timescale=1ns/1ps ./vip/common/	latest/C/lib/amd64/VipCommonNtb.so -top ${top_name}
~~~

其中tb.f文件如下所示:
~~~
./top_tb.sv
-F ./vip/latest/sim/vip.f    #vip的filelist
~~~
其中top_tb.sv文件如下所示：
	~~~
	`include "uvm_pkg.sv"
	`include "vip.sv"     //VIP的env文件

	module top_tb();
	    `include "uvm_macros.svh"
	    import uvm_pkg::*;

	    `include "vip_testbench.sv"  //VIP的testbench文件

		***
		***
		***	
	endmodule
	~~~
### 三、Simulation
代码如下所示，执行仿真。
~~~
run:
	./simv -l run.log +UVM_VERBOSITY=UVM_FULL +UVM_TESTNAME=${testname}
~~~

### 四、传送门
https://blog.csdn.net/hh199203/article/details/120165288