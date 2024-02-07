[TOC]
###  一.静态变量和静态方法
#### 1.0 背景
verilog 建立初,目的是描述硬件的,所以所有对象都是静态分配的,子程序参数和局部变量是存在固定位置的,不像其他语言放在堆栈区.
#### 1.1 静态变量
#### 1.1.1 静态变量基础
对于普通的实例类属性，每一个类实例的每一个变量都有自己的copy（单独的内存空间），相互独立。但是有时会要求一个类的所有实例都共享变量的一个版本，也就是说所有实例都共享同一个copy，该变量对所有实例都是可见并相同的。
这样的类属性就是静态属性（静态变量），使用关键字static产生。通过下面的例子可以清楚的看见静态属性的特点
~~~
class Packet;
  bit [15:0]   addr;
  bit [7:0]   data;
  static int   static_ctr = 0;
       int   ctr = 0;
 
  function new (bit [15:0] ad, bit [7:0] d);
    addr = ad;
    data = d;
    static_ctr++;
    ctr++;
    $display ("static_ctr=%0d ctr=%0d addr=0x%0h data=0x%0h", static_ctr, ctr, addr, data);
  endfunction
endclass
 
module tb;
  initial begin
    Packet   p1, p2, p3;
    p1 = new (16'hdead, 8'h12);
    p2 = new (16'hface, 8'hab);
    p3 = new (16'hcafe, 8'hfc);
  end
endmodule
~~~

~~~
ncsim> run
static_ctr=1 ctr=1 addr=0xdead data=0x12
static_ctr=2 ctr=1 addr=0xface data=0xab
static_ctr=3 ctr=1 addr=0xcafe data=0xfc
ncsim: *W,RNQUIE: Simulation is complete.
~~~
静态属性还有一个重要的特点是其类无需实例化，就可直接使用静态属性。需要利用范围操作符::
#### 1.1.2 静态变量缺省声明时的区别:
- **在模块、begin...end、fork...join以及非动态的任务和函数中，缺省时为静态变量(默认)**
- **在动态的任务和函数中，缺省时为动态变量**
- 模块一级的变量必须是静态变量
#### 1.1.3 变量的初始化
- 在Verilog中:Verilog只有模块级声明的变量可以内嵌初始化
- 在SV中:SV在Verilog的基础上，允许任务和函数声明的变量有内嵌初始化
#### 1.1.4 静态变量和动态变量初始化的区别
静态变量初始化是不可综合的，动态变量的初始化可以综合
静态变量在仿真开始前便完成初始化，动态变量是在被调用时进行初始化
静态变量在下一次被调用时会保持上一次调用后的值，动态变量在下一次调用时会开辟新的存储空间，并重新初始化
#### 1.1.5 静态变量和动态变量使用原则
- 在always和initial块中，需要内嵌初始化就声明为动态变量，不需要内嵌初始化用静态变量
-如果任务或函数是可重入的，应设置被动态的，其内的变量也应是动态的
- 如果任务或函数用来描述独立的硬件部分，且不可重入，应该设置为静态的，其内的变量也应为静态的


#### 1.2 静态方法
使用关键字static 可以类方法声明成静态方法。
一个静态方法遵守所有的类范围和访问规则，但是**它可以在类的外部被调用，即使没有该类的实例**。外部调用的方法同样需要使用范围操作符::。
**一个静态方法不能访问非静态的属性或方法，但是可以直接访问静态属性，或者调用同一个类中的静态方法**，原因很简单因为静态属性和静态方法可以在类没有实例化时被调用，具有**全局**的静态生命周期，而普通的非静态成员无法做到这点。
在一个静态方法内部访问非静态成员或者使用this句柄都是非法的。
静态方法不能是虚拟的。
~~~
class Packet;
  static int ctr=0;
 
   function new ();
      ctr++;
   endfunction
 
  static function get_pkt_ctr ();
    $display ("ctr=%0d", ctr);
  endfunction
 
endclass
 
module tb;
  Packet pkt [6];
  initial begin
    for (int i = 0; i < $size(pkt); i++) begin
      pkt[i] = new;
    end
    Packet::get_pkt_ctr();   // Static call using :: operator
    pkt[5].get_pkt_ctr();   // Normal call using instance
  end
endmodule
~~~
~~~
ncsim> run
ctr=6
ctr=6
ncsim: *W,RNQUIE: Simulation is complete.
~~~
注意上述代码中对get_pkc_ctr()的调用方式，一种是使用范围操作符::，一种是使用普通的层次化引用方式。两者结果没有区别，并且pkt[]的6个成员的调用结果都会是一样的（操作对象是只有一个copy的静态属性）。


###  二.生命周期属性
在上面的静态属性和静态方法声明中，都使用到了关键字static，但是SystemVerilog还有另外一个含义的static，它与automatic一起用来决定数据的生命周期属性。
static声明的数据（并不是类属性）具有静态的生命周期（在整个确立和仿真时间中存在）\
automatic具有调用期或者激活期类的声明周期。

在类外使用static声明的数据和在类内部使用static声明的类属性都有着静态生命周期（无需实例化分配内存），这两者的声明方式**没有区别**都是在数据前面加上static。①前者如果是全局作用范围（即在模块，接口，函数和任务外声明的），那么其使用方式就是直接使用，② 但是静态类属性也可以全局范围内引用，不过需要使用范围操作符::。

static和automatic可以将一**个任务或者函数显式**地声明成静态或者自动的：**一个自动任务、函数或块内声明的数据缺省情况下具有调用期或激活期内的生命周期，并且具有本地的作用范围； 一个静态任务、函数或块内声明的数据缺省情况下具有静态生命周期并具有本地的作用范围**。
此外静态任务或函数或块内的数据可以被显式地声明成自动的，而自动的任务、函数或块内的数据也可以被显式地声明成静态的。
其实将一个任务函数或块声明成static或者automatic还是为了决定其内部数据的生命周期属性，这与静态方法的static有本质上的不同。而且两者的声明方式也有区别：
如果想声明一个静态的任务函数或块：
~~~
class test；
	task static bar(); …… endtask //具有静态变量生命周期的非静态方法
endclass
~~~
如果想声明一个静态方法：
~~~
class test;
	static task bar(); …… endtask //具有自动变量生命周期的静态方法
endclss
~~~
由上可见两个static不仅含义不同，声明方式也不同。
注意第二句话"具有自动变量生命周期的静态方法"，也就是说这个任务虽然是静态任务，但是其内部数据的缺省情况下的生命周期是自动的，这是因为**对于模块、接口或程序中定义的任务函数或块可以用生命限定符static和automatic来指定其中声明的所有变量的缺省生命周期，默认的生命限定符是static， 然而对类方法以及for循环声明的循环变量缺省的生命限定符是自动的automatic**。举个例子
~~~
program automatic test;
	int i;		        // 由于没有在一个过程块中，所以i还是静态的
	task foo(int a); // 在foo内的自变量和变量是自动的
	...
	endtask
endmodule
~~~
补充两点：
- 在模块、接口、任务或函数外声明的任何数据都有全局的作用范围和静态生命周期
- 在模块或接口内但是在任务、函数或进程外声明的数据具有本地的作用范围，并具有静态生命周期。