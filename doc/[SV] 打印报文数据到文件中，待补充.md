[TOC]
### 一.uvm_printer/uvm_printer_knobs  （暂未搞清楚）
https://blog.sina.com.cn/s/blog_466496f30100xodg.html  
具体可以参考cp_build ：cp_env_plus/aem_cp_monioter.sv 中的dump_cp函数的实现  

### 二.读写文件，格式自行处理
SV的格式化输出  
https://blog.csdn.net/CLL_caicai/article/details/106927931

Integer是int的包装类；int是基本数据类型；
 示例
~~~
`timescale 1ns / 1ps
 
module file_test(
 
    );
reg [3:0]data[0:15];
reg [3:0]data2[0:15];
integer handle1;
integer i=0;
initial
begin
    $readmemb("F:/vivado_files/num.txt",data);
 
    handle1 = $fopen("F:/vivado_files/num2.txt","w");
    repeat(16)
    begin
        $fwrite(handle1,"%d\n",data[15-i]);
        i = i+1;
    end
    $fclose(handle1);
end
endmodule
~~~