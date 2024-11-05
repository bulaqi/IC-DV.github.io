[TOC]
### 1. 前言
我们在进行verilog仿真时，经常喜欢采用宏定义，来做条件判断，但是通过宏定义做条件判断的这种方法，存在很大的**弊端，就是条件改变的时候，需要重新编译**，这样会导致，在项目后期进行回归测试和后仿的时候，很多时间都浪费在重复编译上面，效率非常低下。

为了提高仿真效率，建议采用系统函数 $test$plusargs和$value$plusargs来实现，仿真命令到仿真环境之间的，条件判断和参数的传递。

### 2. 使用宏定义的条件编译
宏定义的条件编译代码示例如下
~~~
initial
begin
	`ifdef dump_fsdb
		$dumpfile("test.fsdb");
		$dumpvars;
	`endif
end
~~~
需要开启宏定义条件编译的功能时，在编译的命令中，加上-define选项，如下代码所示：
~~~
<compile-option> -define dump_fsdb
~~~
### 3. 条件编译函数\$test$plusargs(推荐)
使用条件编译函数$test$plusargs的代码如下所示
~~~
initial
	begin
	if($test$plusargs("test1")
		$readmemh("test1.dat",mem1);
	if($test$plusargs("test2")
		$readmemh("test2.dat",mem2);
	end
~~~
在使用的时候，只需要在仿真运行命令中加上如下选项，如果仿真不需要test1,只需要将test1从运行命令中删除即可。
~~~
<run-options> +test1 +test2
~~~
### 4. 参数传递函数\$value$plusargs (推荐)
\$value$plusargs可以将运行命令（run-options）中的参数值，传递给指定的信号或者字符，其语法格式如下：
~~~
$value$plusargs(“string”,signalname);
~~~
使用的示例代码如下：
~~~
if($value$plusargs("finish=%d", finish))
begin
	repeat(finish); 
	$display("finish=%d", finish);
	$finish;
end

if($value$plusargs("freq=%f",frequency))
begin
	$display("freq=%f", frequency);
end

if($value$plusargs("testname=%s"testname))
begin
	$display("testname=%s",testname);
end
~~~

仿真运行命令为：
~~~
<run-options> +finish=1000 +freq=7.212 +testname=test1
~~~

仿真结果为：
~~~
finish=1000
freq=7.212
testname=test1
~~~

### 5. 总结
总的来说推荐使用，条件编译函数$test$plusargs和参数传递函数$value$plusargs，这两个系统函数，来实现仿真命令到仿真环境之间的参数传递。
### 6. 传送门
https://blog.csdn.net/hh199203/article/details/113182651