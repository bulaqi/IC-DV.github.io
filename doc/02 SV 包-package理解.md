### 引:为什么引入包?  
在verilog中，变量、任务和函数的声明都在module..endmodule之间，声明的对象都是局部的。不能全局声明。如果一个声明在多个设计块中用到，必须在每个块中声明。

Systemverilog可以使用typedef用户自定义类型，会在多个模块中使用这个类型，verilog需要在多个模块中使用这个类型。引入了包的概念。

### 1.1 包的定义


可以使多个模块共享用户自定义类型。在package和endpackage之间定义。

包中可综合的结构有

①paramater和 localparam 常量定义(不能被重新定义，在包中，parameter和localparam是相同的)

②const变量定义

③typedef用户定义

④task和function定义

⑤从其他包中import语句

⑥操作符重载定义
~~~
package definitions;
    parameter VERSION = '1.1';
    typedef enum {ADD,SUB,MUL} opcodes_t;
 
    typedef struct{
        logic[31:0] a,b;
        opcodes_t opcode;
    }instruction_t;
 
    function automatic[31:0] multiplier(input [31:0] a,b);
    return a*b;
    endfunction
 
endpackage
~~~
### 1.2 引用包的内容

#### ①使用作用域解析操作符 “：：”

可以通过包的名称直接引用包，选择包中特定的定义或声明
~~~
module ALU(
    input definitions::instruction_t IW,
    input logic clock,
    output logic[31:0] result
);
 
always_ff @(posedge clock)
    case(IW.code)
    definitions::ADD:result=IW.a + IW.b;
    definitions::SUB:result=IW.a - IW.b;
    definitions::MUL:result=definitions::multiplier(IW.a,IW.b);
    endcase
endmodule
~~~
当包中的一项或者多项在模块中多次引用，每次显式地引用包的名称太麻烦。
#### ②导入包中的特定子项

import语句导入特定子项。
~~~
import definitions::ADD;
import definitions::multiplier;
 
case(IW.code)
    ADD:result = IW.a + IW.b;
    MUL:result = multiplier(IW.a,IW.b);
endcase
~~~
但是导入枚举类型并不导入里面的元素。

例如：import definitions::opcode_t;会使用户定义的类型opcode_t在模块中可见，但是它不会时其使用的枚举元素可见。每个枚举元素必须显式导入。

为此，使用通配符导入更实用。
#### ③包中子项的通配符导入
~~~
import definations::*
~~~
通配符导入并不能自动导入包中所有内容（只有在模块或接口中实际使用的子项才会被真正导入，没被引用的包中的定义和声明不会被导入）
~~~
import definition::*;
 
always_comb 
    case(IW.opcode)
        ADD:result=;
    endcase
~~~
对于模块端口IW，包名必须显式引用，因为不能在module和端口定义之间加入一个import语句。
可以使用$unit声明域

综合：
为了能够综合，包中定义的任务和函数必须声明为automatic,并且不能包含静态变量。