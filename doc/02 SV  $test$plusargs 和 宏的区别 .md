### 1.基础知识
#### 1. 概述
  1. 生效的阶段不同
  2. 启动的方式不同.$test$plusargs是+参数, 宏是 +define+参数
#### 2. $test$plusargs
1. eg
~~~
initial
if ($test$plusargs("postprocess"))
begin
	$vcdpluson(0,design_1);
	$vcdplusdeltacycleon;
	$vcdplusglitchon;
end
~~~
2. 运行
~~~
simv +postprocess // 注意是+postprocess 
~~~

#### 3.宏传递, 是运行选项
1. eg
~~~
module test;
 
    `ifdef A
        parameter num = 123;
        //XXX
    `elsif B
        parameter num = 456;
        //XXX
    `else
        parameter num = 789;
        //XXX
    `endif
 
    initial begin
        $display("num is %0d",num);
    end
endmodule
~~~
2. 运行, +define+ X
~~~
在编译命令行中加入+define+A时，num打印值为123，+define+B时为456，定义其他或者不加+define+时打印789，XXX可以为自己的一些代码。
~~~
  
  
### 3. 传送门:
  1. [认识系统函数$test$plusargs与$value$plusargs](https://blog.csdn.net/kevindas/article/details/80380144)
  2. [vcs +define+ 简单用法](https://blog.csdn.net/Kizuna_AI/article/details/130103029)
  3. [关于sv中宏定义`define的增强使用](https://blog.csdn.net/qq_26330025/article/details/124845367?spm=1001.2101.3001.6650.1&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-124845367-blog-130103029.235%5Ev38%5Epc_relevant_yljh&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-124845367-blog-130103029.235%5Ev38%5Epc_relevant_yljh&utm_relevant_index=2)
