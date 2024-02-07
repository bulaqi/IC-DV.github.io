[TOC]
### rand 类型的变量只能定义在类内,不能定义到类的函数内
如果在函数中定义变量,使用过程需要随机值,不需要变量为rand类型
~~~
task xxx::mian_phase(uvm_phase pashe) 
int one_burst_size;
...
   std::randomize(one_burst_size) with(one_burst_size inside{[1:31]};); //注意,randomize后有括号,括号内包含one_burst_size,然后with 约束
...
endtask
~~~
