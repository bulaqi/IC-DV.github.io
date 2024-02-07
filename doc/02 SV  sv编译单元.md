[TOC]
### 1. SV $unit编译单元
#### 1.1 SV中增加了编译单元的概念，就是SV源文件编译的时候，**一起编译**的所有源文件
- 当多个源文件一起编译时，只有一个$unit域，包导入$unit域中的所有子项对这些源文件都是可见的
- 当多个源文件单独编译时，会产生多个$unit域，一个$unit中导入的包对其他$unit是不可见的
#### 1.2 认识$unit
![image](https://user-images.githubusercontent.com/55919713/236125145-c6707725-eb29-44fb-b86c-758c521182f1.png)
#### 1.3 编译单元
SystemVerilog源文件编译的时候，一起编译的不管是单文件还是多文件，一起编译就把它叫做一个编译单元，即如果1个文件单独编译，那这个文件就是1个编译单元，10个文件一起编译，这10个文件就是1个编译单元。

（SV手册建议编译器应该要留一个选项，允许指定文件是每个文件一个编译单元或者是所有一起编译文件一个共同编译单元。当然这个各位如果感兴趣可以后续研究下你用的编译工具有没有这样做哈）
**通常我们往往都是多文件一起编译，形成唯一1个编译单元。**

#### 1.4 编译单元域
这个叫编译单元的东西和module其实一样，也有一个作用范围，常叫做“编译单元域”，这个区域就是我们前面提到的神秘空间。
它是不在其他任何范围之内的（例如module、interface、program等），但是一起编译的其他范围都对它可见！
这就是前文为什么我们常常把一些常用的package import到编译单元域里面，一次导入一起编译的文件都可见。
#### 1.5 $unit是什么？
其实就是这个编译单元的显示名字，就像前文module的名字tb_top一样。
有了这个名字，我们便可以对编译单元域中的内容显示访问。
从相识到相知，从相知到……
到现在为止，Jerry相信大家对我们一直追寻的神秘空间有一个清楚的认知了吧～
说到这里想顺便提上一句，我们常用的编译器指令，即SystemVerilog中以重音符号开始的标识符，如`define等，他们的作用范围是什么？
有人说是全局？
其实不是！他的作用范围就是所在的编译单元域！
因为我们通常多文件一起编译且形成同1个编译单元，所以给我们一种编译器指令是全局生效的幻觉，如果每个文件一个编译单元，那编译器指令也只是某个文件中生效而已～



### 2.编译单元域搜索规则
编译单元域在搜索顺序中排第三位

举个栗子
~~~
package a_dpk;  //创建一个名为a_dpk的包
    function print();
        $display("\t This is in a_dpk!");
    endfunction
endpackage

package b_dpk;  //创建一个名为b_dpk的包
    function print();
        $display("\t This is in b_dpk!");
    endfunction
endpackage

import b_dpk:: *; //导入$unit编译单元域

module test_tb;
    
    import a_dpk:: *; //通配符导入

    function print();
        $display("\t This is in module!");
    endfunction

    initial begin
        $display("\t**********************");
        print;
        $display("\t***********End*********");
    end
endmodule
~~~
这里我们创建了两个包（a_dpk和b_dpk），两个包中的都只有一个打印函数，同时module中也有一个打印函数，（打印函数用于指示所在位置）

打印结果如下：\
![image](https://user-images.githubusercontent.com/55919713/236121273-52cdf477-a6c4-4e69-8165-d5ee717ebbbf.png) \
从打印结果可以看出，当三者都存在时，打印的是module中声明的函数

那么如果把module中声明的函数注释掉会打印哪个函数呢？
~~~
package a_dpk;  //创建一个名为a_dpk的包
    function print();
        $display("\t This is in a_dpk!");
    endfunction
endpackage

package b_dpk;  //创建一个名为b_dpk的包
    function print();
        $display("\t This is in b_dpk!");
    endfunction
endpackage

import b_dpk:: *; //导入$unit编译单元域

module test_tb;
    
    import a_dpk:: *; //通配符导入

    //function print();
    //    $display("\t This is in module!");
    //endfunction

    initial begin
        $display("\t**********************");
        print;
        $display("\t***********End*********");
    end
endmodule
~~~
运行结果如下：\
![image](https://user-images.githubusercontent.com/55919713/236121359-7ead2eb2-addc-419c-a791-78d4c55afe6d.png) \
可以看到此时打印的是在module中导入的包

那么接下来我们把在module中导入的包注释掉，即把import a_dpk::*;注释掉
~~~
package a_dpk;  //创建一个名为a_dpk的包
    function print();
        $display("\t This is in a_dpk!");
    endfunction
endpackage

package b_dpk;  //创建一个名为b_dpk的包
    function print();
        $display("\t This is in b_dpk!");
    endfunction
endpackage

import b_dpk:: *; //导入$unit编译单元域

module test_tb;
    
   // import a_dpk:: *; //通配符导入

    //function print();
    //    $display("\t This is in module!");
    //endfunction

    initial begin
        $display("\t**********************");
        print;
        $display("\t***********End*********");
    end
endmodule
~~~
下面运行结果：\
![image](https://user-images.githubusercontent.com/55919713/236121473-4f52bdf8-a8a6-4fe6-bda5-1d88914f9983.png)\
此时终于把导入$unit编译单元域的内容打印出来了

通过这个过程不难发现，在运行过程中，**先从module内部找有没有声明，如果没有声明再从module内部import的包找，如果还是没有才会在module外部import的包中找**
这也就是为什么 编译单元域在搜索规则中排第三
那么为什么编译单元域叫$unit呢？我们可以再把代码更改一下

~~~
package a_dpk;  //创建一个名为a_dpk的包
    function print();
        $display("\t This is in a_dpk!");
    endfunction
endpackage

//package b_dpk;  //创建一个名为b_dpk的包
//    function print();
//        $display("\t This is in b_dpk!");
//    endfunction
//endpackage

import b_dpk:: *; //导入$unit编译单元域

module test_tb;
    
   // import a_dpk:: *; //通配符导入

    //function print();
    //    $display("\t This is in module!");
    //endfunction

    initial begin
        $display("\t**********************");
        print;
        $display("\t***********End*********");
    end
endmodule
~~~

我们把b_dpk注释掉，但依旧将其导入，看看运行结果
![image](https://user-images.githubusercontent.com/55919713/236121547-14d9e10f-3182-4b79-9429-6732963b7494.png)
这里直接显示错误在 $unit，或许$unit只是一个名称，就好像上例中module命名为test_tb一样
### 2.单独编译将包导入到$unit中（条件编译）
格式为：
~~~
`ifndef xxx
	`define xxx
`endif
~~~

这是C语言中常用的技巧，如果第一次遇到导入语句将其编译到$unit中，再次出现则不会编译

下面我们将上篇笔记中的包用这种方式仿真一下，先给出上篇笔记中包的内容
~~~
package definitions;
    parameter	version = "1.1";
    
    typedef enum {ADD, SUB, MUL} opcodes_t;

    typedef struct {
        logic	[31:0]	a, b;
        opcodes_t	opcode;	//声明的opcode中包含 ADD, SUB和MUL
    } instruction_t;
    
    function	automatic	[31:0]	multiplier	(input	[31:0]	a, b);
        return a * b;
    endfunction
endpackage 
~~~

我们将文件名命名为definitions.dpk，其中后缀.dpk是随便起的
~~~
`ifndef	PACK
	`define	PACK
	package	definitions;
        parameter	version = "1.1";
        
        typedef enum {ADD, SUB, MUL} opcodes_t;
        
        typedef struct {
            logic	[31:0]	a, b;
            opcodes_t	opcode;	//声明的opcode中包含 ADD, SUB和MUL
             } instruction_t;
        
        function	automatic	[31:0]	multiplier	(input	[31:0]	a, b);
            return a * b;
        endfunction
    endpackage

	import	definitions:: *;	//将包导入到$unit中
`endif
~~~

下面是源码和测试文件
~~~
`include "definitions.dpk"	//编译包文件

module ALU (
	input	instruction_t	IW,
    input	logic	clk,
    output	logic	[31:0]	result
);
    always @ (posedge clk) begin
        case(IW.opcode)
            ADD	:	result = IW.a + IW.b;
            SUB	:	result = IW.a - IW.b;
            MUL	:	result = multiplier(IW.a, IW.b);
        endcase
    end

endmodule
~~~

~~~
`include "definitions.dpk"	//编译包文件

module ALUtb;
    instruction_t	IW;
    logic				clk = 1;
	logic	[31:0]	result;
    
    always #10 clk = ~clk;	//生成时钟，周期为20ns
    
    initial begin
        IW.a = 'd10;
        IW.b = 'd5;
        IW.opcode = ADD;

        repeat(2)  @(negedge clk);
        	IW.a = 'd3;
        	IW.b = 'd7;
        	IW.opcode = MUL;
    
        repeat(2) @(negedge clk);
        	IW.a = 'd5;
        	IW.b = 'd1;
        	IW.opcode = SUB;
        
        repeat(3) @(negedge clk);
        	$finish; 
    end
    
    initial begin
        $monitor ($time, ,"a->%d, b->%d, opcode->%s, result->%d",IW.a, IW.b, IW.opcode, result);
    end

    ALU tb(.IW(IW), .result(result), .clk(clk));    //例化
endmodule
~~~

运行结果如下 \
![image](https://user-images.githubusercontent.com/55919713/236121791-a3ae4b8e-a117-44ee-a774-488a6fb106b6.png)

### 参考:
[\$unit人人都会用到，但是大部分人不清楚是什么的神秘空间](https://baijiahao.baidu.com/s?id=1676456339510762099&wfr=spider&for=pc)
[SV中$unit编译单元](https://blog.csdn.net/I_learn_code/article/details/121984648)

