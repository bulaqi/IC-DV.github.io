###  总结
#### 1. define中的参数如果替代发生在""之中，是不能直接被替代的
~~~
`define H(x)　　"Hello, X"
应用$display(`H(world))；  打印出Hello, X
其中的参数X并不会被替代为world
~~~

#### 2. 在双引号内部有宏引用的时候，双引号需要加`转义
~~~
`define  msg(x,y)  `"x: y`"   
应用$display (`msg(left_side, right_side));   打印出 $display("left_side",  righ_side)
~~~

#### 3. define的参数，需要和其他的字符还进行拼接，则必须加``，如果需要前后都需要加
~~~
`define   append(f)   f``_master   省略了之前的``，因为之前没有字符
应用`append(clock)   等价于clock_master
~~~

#### 4.  内部包含其他define，所以双引号转义，内部f是一个完整宏的替换，所以加一个`
~~~
内部包含其他define，所以双引号转义，内部f是一个完整宏的替换，所以加一个`
如果define的宏中，需要加入反斜杠这样的字符，需要`转义，  `\
~~~

#### 5.  默认参数赋值的
~~~
`define  Macros(a=5, b="B",  c)  $display(a, b , c);
应用`Macros ( ,2,3)  等同于 $display(5, 2, 3);
~~~

### part2:
#### 1. 条件选择的宏定义语句
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
 ~~~
 
 #### 2. 使用宏定义构造常用函数或者常用语句
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
 #### 3.在SV中可以使用``符号来充当连接符的作用将传入的参数与其他表示式连接起来，example：
 ~~~
 `define TARGET_SIG(_SIG,_BIT,_MSK) \
    rtl_warp.module``_SIG``0 & {_BIT{_MSK[0]}
 
`TARGET_SIG(PAC, 1, p_mask)
即表示: rtl_wrap.modulePAC0 & {1{p_mask[0]}
 ~~~
 #### 4.define只能传入常量，不能传入变量


### 传送门
https://www.cnblogs.com/-9-8/p/7909612.html \
https://blog.csdn.net/re_call/article/details/120955805 \
https://blog.csdn.net/ohuo666/article/details/120524107
