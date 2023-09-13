### 1. 常用自定义类型
~~~
typedef int WIDTH_TYPE
~~~
### 2. 前置定义
常用在要用的class还没有定义时，提前typedef一下
~~~
typedef class B;//typedef B
class A；
    B b;
    int xx;
endclass

class B;
    A a;
    logic tmp;
endclass
~~~
如上在定义class A时，使用了class B，但B还没有定义，可以在前面先 typedef class B.也可以直接用typedef B，表示后面会有B的定义。
### 3.定义参数化类
~~~
typedef XYZ;
 
module top;
  XYZ #(8'h3f, real)              xyz0;   // positional parameter override
  XYZ #(.ADDR(8'h60), .T(real))   xyz1;    // named parameter override
endmodule
 
class XYZ #(parameter ADDR = 8'h00, type T = int);
endclass
~~~
### 4.定义带比特位类型
~~~
typedef bit [3:0] bit4;
typedef logic [2:0] logic3;
typedef reg [1:0]  reg2;
~~~
### 5.定义数组或队列
~~~
typedef int m_int_q[100];
 
m_int_q m_int；
 
typedef short m_sh_q[$];
m_sh_q m_sh;

typedef class aem_plus_nvme_ral_model aem_plus_nvme_ral_model_arr[5]; //编译报错,不要用修饰词class
typedef aem_plus_nvme_ral_model aem_plus_nvme_ral_model_arr[5];

~~~
定义了一个100个元素的int数组 m_int；

定义了一个数据类型为short的m_sh队列；
### 6.队列的关联数组
当关联数组的元素是一个队列的时候，有两种定义方式：
~~~
方式一：
int map[string][$]; //map是一个关联数组，下标元素是string，存储元素是int[$]
方式二：
typedef int Queue_INT[$]; Queue_INT map[$];
~~~
### 7.在config db的应用
当使用uvm_config_db在UVM平台中传递信息时，假设需要传递一个数组，这时候uvm_config_db#()括号中的类型该怎么写？

1) 将数组封装在一个类中，uvm_config_db#()的括号中填这个类，这个稍微麻烦了点；

2) 定义一个数组类型，然后就可以这样写
~~~
uvm_config_db#(Array_INT)::set(null,”yy”,”zz”,arr)
uvm_config_db#(Array_INT)::get(null,”yy”,”zz”,arr_recv)
~~~
其中arr和arr_recv都是Array_INT类型的变量；typedef int Array_INT[100];

### 8.传送门
[typedef：定义一个类型](https://link.csdn.net/?target=https%3A%2F%2Fzhuanlan.zhihu.com%2Fp%2F370616107)
