### 1. 基础知识

#### 1. 命令行输入
  参数形式上与其他仿真器参数不同，因为它们以加号(+)字符开头
#### 2. $test$plusargs (string)  -- 用于只输入字符串时
1. 说明
   - 子符串在系统函数的参数中指定为字符串或被解释为字符串的非实数变量
   - $test$plusargs执行的是从输入字符串开头开始的部分匹配。
3. eg1 :
   - code
   ~~~
   `timescale 1ns/1ps  
   module test ();
   initial begin
       if ($test$plusargs("HELLO")) $display("Hello argument found.");
       if ($test$plusargs("HE")) $display("The HE subset string is detected.");
       if ($test$plusargs("H")) $display("Argument starting with H found.");
       if ($test$plusargs("HELLO_HERE"))$display("Long argument.");
       if ($test$plusargs("HI")) $display("Simple greeting.");
       if ($test$plusargs("LO")) $display("Does not match.");
   end 
   endmodule
   ~~~
   - 结果
      ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/374f4767-134a-48b4-a803-96871bce8530)
4. eg2
   - code
   ~~~
     执行仿真时在命令后增加+HELLO会产生下面的输出：
   ~~~
   - 结果
   ~~~
   Hello argument found.:
   The HE subset string is detected.
   Argument starting with H found.
   ~~~
5. 可以输入多个参数：
   ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/b6fa01f6-87b4-45b1-b148-55c808aa6f3d)

  
  
#### 3. $value$plusargs (user_string, variable)  -- 既可以输入字符串也可以输入各种进制的参数
1. 说明
   - 子符串在系统函数的第一个参数中指定为字符串或被解释为字符串的非实数变量。
   - 这个字符串不包含命令行参数的前导加号。
   - 按照提供的顺序搜索命令行上的plusargs
   - 如果提供的一个plusargs的前缀匹配提供的字符串中的所有字符，函数将返回一个非零整数，字符串的其余部分将转换为user_string中指定的类型，并将结果值存储在提供的变量中。
   - 如果没有找到匹配的字符串，函数将返回整数值0，并且不修改提供的变量。当函数返回0(0)时不会产生任何警告。

2. eg
   - code
     ~~~
     `timescale 1ns/1ps  
     module test ();
     reg     [255:0]                 testname;
     reg     [7:0]                   num;
     initial begin
        if ($value$plusargs("TESTNAME=%s", testname)) 
            $display("Running test {%0s}......", testname);
        if ($value$plusargs("num=%d", num)) 
            $display("num= {%0d}......", num);
     end 
     endmodule
     ~~~
   - 仿真结果
     ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/a4c1c62e-e3a5-4589-93f0-2fc1eba6dd46)
   - 说明
     可以看到我们输入参数+TESTNAME=dma_test0 +num=1后代码$value$plusargs("TESTNAME=%s", testname)对TESTNAME=进行匹配，然后将剩余的字符串按格式进行转换。

### 3. 传送门
1. [verilog系统函数：$value$plusargs、$test$plusargs](https://blog.csdn.net/lum250/article/details/120919673)
