[TOC]
# 1. 常用简单的
~~~
`define uvm_field_int(ARG,FLAG) //整数
`define uvm_field_real(ARG,FLAG)  //实数
`define uvm_field_enum(T,ARG,FLAG) //枚举类型,3个参数
`define uvm_field_object(ARG,FLAG)  //直接或间接派生自uvm_object的类型
`define uvm_field_event(ARG,FLAG)  //事件
`define uvm_field_string(ARG,FLAG)  //字符串类型
~~~
对于枚举类型来说， 需要有三个参数。 假如有枚举类型tb_bool_e， 同时有变量tb_flag， 那么在使用field automation机制时应该使用如下方式实现
~~~
typedef enum {TB_TRUE, TB_FALSE} tb_bool_e;
…tb_bool_e tb_flag;
…
`uvm_field_enum(tb_bool_e, tb_flag, UVM_ALL_ON)
~~~


# 2. 与动态数组有关的uvm_field系列宏有：
~~~
`define uvm_field_array_enum(ARG,FLAG)
`define uvm_field_array_int(ARG,FLAG)
`define uvm_field_array_object(ARG,FLAG)
`define uvm_field_array_string(ARG,FLAG)
~~~
这里只有4种， 相比于前面的uvm_field系列宏少了event类型和real类型。 另外一个重要的变化是enum类型的数组里也只有两个参数。

# 3. 静态数组相关的uvm_field系列宏有
~~~
`define uvm_field_sarray_int(ARG,FLAG)
`define uvm_field_sarray_enum(ARG,FLAG)
`define uvm_field_sarray_object(ARG,FLAG)
`define uvm_field_sarray_string(ARG,FLAG）
~~~

# 4. 与队列相关的uvm_field系列宏有
~~~
`define uvm_field_queue_enum(ARG,FLAG)
`define uvm_field_queue_int(ARG,FLAG)
`define uvm_field_queue_object(ARG,FLAG)
`define uvm_field_queue_string(ARG,FLAG)
~~~
这里也是4种， 且对于enum类型来说， 也只需要两个参数。

# 5. 联合数组
~~~
`define uvm_field_aa_int_string(ARG, FLAG)
`define uvm_field_aa_string_string(ARG, FLAG)
`define uvm_field_aa_object_string(ARG, FLAG)
`define uvm_field_aa_int_int(ARG, FLAG)
`define uvm_field_aa_int_int_unsigned(ARG, FLAG)
`define uvm_field_aa_int_integer(ARG, FLAG)
`define uvm_field_aa_int_integer_unsigned(ARG, FLAG)
`define uvm_field_aa_int_byte(ARG, FLAG)
`define uvm_field_aa_int_byte_unsigned(ARG, FLAG)
`define uvm_field_aa_int_shortint(ARG, FLAG)
`define uvm_field_aa_int_shortint_unsigned(ARG, FLAG)
`define uvm_field_aa_int_longint(ARG, FLAG)
`define uvm_field_aa_int_longint_unsigned(ARG, FLAG)
`define uvm_field_aa_string_int(ARG, FLAG)
`define uvm_field_aa_object_int(ARG, FLAG)
~~~

共出现了15种。 联合数组有两大识别标志， 一是索引的类型， 二是存储数据的类型。 在这一系列uvm_field系列宏中，出现的第一个类型是存储数据类型， 第二个类型是索引类型， 如uvm_field_aa_int_string用于声明那些存储的数据是int， 而其索引是string类型的联合数组。