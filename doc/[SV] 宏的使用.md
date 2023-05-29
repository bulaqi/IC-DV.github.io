### 传送门
https://www.cnblogs.com/-9-8/p/7909612.html \
https://blog.csdn.net/re_call/article/details/120955805 \
https://blog.csdn.net/ohuo666/article/details/120524107

 ### 1. 条件选择的宏定义语句
 ~~~
 `ifdef TEST_1
    `include "test_case_1"
`elsif TEST_2
    `include "test_case_2"
`endif
 
`ifndef POST_SIM
    value_a = 32'hF;
`else
    value_a = 32'h3;
`endif
 
 
 ### 2. 使用宏定义构造常用函数或者常用语句
 ~~~
 `define STRING(x) `"x`"
`"或者`\是对 " 或者 \进行转义，"也可以不转义，直接使用
example:
`STRING(tb_top.dut.u_cluster)即相当于是"tb_top.dut.u_cluster"
给define传入的参数需要用（）括起来，然后用，分隔开
传入的参数不能传入到字符串中，example：
module main;
    `define H(x) "Hello,x"
    initial begin
        $display(`H(world));
    end
endmodule
will print : Hello,x
但是上述情况可以用`"来解决，example：
`define H(x) `"Hello,x`" 这样就能打印 Hello,world
 ~~~
 ### 3.在SV中可以使用``符号来充当连接符的作用将传入的参数与其他表示式连接起来，example：
 ~~~
 `define TARGET_SIG(_SIG,_BIT,_MSK) \
    rtl_warp.module``_SIG``0 & {_BIT{_MSK[0]}
 
`TARGET_SIG(PAC, 1, p_mask)
即表示: rtl_wrap.modulePAC0 & {1{p_mask[0]}
 ~~~
 ### 4.define只能传入常量，不能传入变量
 
