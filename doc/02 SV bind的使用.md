### 0. 个人理解
   - 新增一组接口,方便扩展使用,常用语断言
### 1. 基础知识
#### 1. 手册
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/56fe5380-3417-4f29-9fd2-cd7a0e028965)
#### 2. 如果不采用bind方式，也可以把sva_module作为一个rtl_module直接例化在环境中，或者例化在module中
~~~
test_sva #(.DATA_WIDTH(8)) U_test_sva(clk, rst_n);
~~~
#### 3. 如果需要内部的信号,可以拉把内部信号的module bind到assert_module 模块

### 2. 注意事项
#### 1. sva_module 把接口 作为参数出入sva_module时候需要待全路径
aem_top_th.sv 文件
~~~
//aem_cq_sva aem_cq_assert (aem_top_if) error
aem_cq_sva aem_cq_assert (aem_top_tb.aem_top_if)
~~~



### 3. 传送门

1. [systemverilog 中的bind 的使用和语法](https://blog.csdn.net/weixin_41994704/article/details/131760770?spm=1001.2101.3001.6661.1&utm_medium=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-131760770-blog-120384388.235%5Ev38%5Epc_relevant_yljh&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-131760770-blog-120384388.235%5Ev38%5Epc_relevant_yljh&utm_relevant_index=1)
2. [SVA——与设计的连接（bind关键字用法）](https://blog.csdn.net/weixin_46022434/article/details/120384388)
3. [【system verilog】并发断言SVA bind RTL module的几种方式](https://blog.csdn.net/moon9999/article/details/106035582?spm=1001.2101.3001.6650.2&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-2-106035582-blog-131760770.235%5Ev38%5Epc_relevant_yljh&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-2-106035582-blog-131760770.235%5Ev38%5Epc_relevant_yljh&utm_relevant_index=3)
4. [bind(优点,语法及使用示例](https://www.cnblogs.com/csjt/p/15573780.html)
5. [SystemVerilog中bind用法总结+送实验源码和脚本](https://zhuanlan.zhihu.com/p/598066374)

