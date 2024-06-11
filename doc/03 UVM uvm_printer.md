### 1. 基础知识
#### 1. 概念
1. uvm自带了打印类UVM_RPINTER，它是一个virtual class，必须继承之后才可以使用.
2. 子类包含了
   - uvm_default_tree_printer
   - uvm_default_line_printer
   - uvm_default_table_printer.
3. 在uvm_object_globals中定义了uvm_default_printer变量，它的值是uvm_default_table_printer.


#### 2. uvm_printer_knobs
uvm_printer_knobs为特定的printer提供了相应的knobs变量.里面部分变量的描述如下：
- header:   当print an object时是否会调用print_header函数.
- footer:   printe an object时是否调用print_footer函数.
- full_name:print变量的full name还是the leaf name.
- depth:    递归打印的深度，默认值-1,代表打印全部的变量, 参加传送门,参考文献2
- mcd：     文件句柄，默认是系统标出输出，修改此，可以将数据打印到指定文件

#### 3.uvm_printer使用示例
1. 在调用uvm_top.print_topology()函数（拓扑）时,可以不指定uvm_printer参数;
2. 在不指定uvm_printer参数的情况下,会使用uvm_default_table_printer;
3. 如果有需要指定uvm_printer参数,可以指定为其他参数,如uvm_default_tree_printer, uvm_default_line_printer或其他用户自定义的printer;


### 2. 经验
#### 1. uvm_printer_knobs.cmd的使用
- 自定义printer
   ~~~
   class tx_data_printer extends uvm_table_printer;
      function new(string fileName="cp_date.txt")
      super.new();
      knobs.mcd = $fopen(fileName,"+W")
   endclass
   ~~~
- 使用
   - eg,scb 类内声明该printer
   ~~~
   tx_data_printer u_tx_data_printer;
   ~~~
   - 使用
   ~~~
   rm_file_name = $sformatf("./log/ref/tx_ref_%x",cid);
   u_tx_data_printer = new(rm_file_name);
   tx_trans.sprint(u_tx_data_printer);//打印，采用自定义printer
   $fflush(u_tx_data_printer,knobs.mcb);// 及时刷新文件
   $fclose(u_tx_data_printer,knobs.mcb);// 及时刷新文件
   ~~~
### 3. 传送门
1. [uvm_printer及使用](https://www.cnblogs.com/csjt/p/16206598.html)
2. [uvm_table_printer的用法_全部数组值打印](https://www.cnblogs.com/Alfred-HOO/articles/17524269.html)
