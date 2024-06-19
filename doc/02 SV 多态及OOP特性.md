- [一、封装](#一封装)
- [二、继承](#二继承)
- [三、多态](#三多态)
	- [一、虚方法：父指针指向子对象，实现子对象的方法](#一虚方法父指针指向子对象实现子对象的方法)
	- [二、类型转换(也是多态的一种形式)](#二类型转换也是多态的一种形式)

### 一、封装
封装只是一个概念，指的是把对象的属性和行为包在一起的思想，好处是保证了类内部数据结构的完整性，类外面只能执行该类允许公开的数据。

### 二、继承
类的继承指子类继承父类的成员变量和成员方法，使用关键字extends指明，SV中一个子类不能有两个及以上的父类，一个父类可以有多个子类。示例：

~~~
typedef enum {RED,WHITE,BLACK} color_t;
class cat;
	//protect color_t color;
	color_t color;
	string name;
	//local bit is_good;
	bit is_good;
	
	function new();//若未自己定义new函数，则会自动调用super.new();函数
		this.is_good = 0;
		this.color = RED;
	endfunction
	
	function set_good(string ss,bit is_good);
		this.is_good = is_good;
		$display("%s is_good is %d",ss,this.is_good);
	endfunction
 
endclass
 
class black_cat extends cat;
	function new(string s1);
		this.name  = s1	  ;
		this.color = BLACK;
		$display("cat name is %s",name);
	endfunction
endclass
 
class white_cat extends cat;
	function new(string name);
		this.name  = name ;
		this.color = WHITE;
		$display("cat name is %s",this.name);
	endfunction
 
endclass
 
module test14;
	black_cat bk;
	white_cat wt;
	string s1 = "black_cat";
	string s2 = "white_cat";
	initial begin
		bk=black_cat::new(s1);
		wt=new(s2);
		bk.set_good(s1,1);
		wt.set_good(s2,1);
		$display("cat color is %s",bk.color);
		$display("cat color is %s",wt.color);
	end
endmodule
 
运行结果：
cat name is black_cat
cat name is white_cat
black_cat is_good is 1
white_cat is_good is 1
cat color is BLACK
cat color is WHITE
~~~

### 三、多态
多态：对方法同一种调用方式产生不同的结果，即当一个类派生出子类的时候，基类中的一些方法可能需要被重写，同名的方法。多态常见形式：虚方法、类型转换

#### 一、虚方法：<font color=red>父指针指向子对象，实现子对象的方法</font>
关键字：virtual
在派生类中,重写该方法的时候必须采用 一致的参数和返回值
虚方法可以重写其所有基类中的方法,而普通的方法被重写后只能在本身及其派生类中有效。
在多层继承关系的类中实现了同一方法的虚方法,该虚方法只在最后一个派生类中有效。
~~~
class packet;
	int a =1;
	int b =2;
 
function void display_a;
	$display("packet::a is %0d",a);
endfunction
 
virtual function void display_b(bit [3:0] num1);
	$display("num1 is %0d",num1);
	$display("packet::b is %0d",b);
endfunction
endclass
 
class my_packet extends packet;
	int a =3;
	int b =4;
	
function void display_a;
	$display("my_packet::a is %0d",a);
endfunction
 
virtual function void display_b(bit [3:0] num2);
	$display("num2 is %5d",num2);
	$display("my_packet::b is %0d",b);
endfunction
endclass
 
module top;
	packet p1;
	my_packet p2;
initial begin
	p1=new();
	p2=new();
	p1 = p2;
	p1.display_a;
	p1.display_b(12);
end
endmodule
 
打印结果：
packet::a is 1
num2 is    12
my_packet::b is 4 
~~~
说明：

   p1.display_a;display_a是普通方法，直接调用结束；p1.display_b;display_b是虚方法，调用 重写后的方法

#### 二、类型转换(也是多态的一种形式)
父类句柄指向子类，也就是子类转换为父类，是向上类型的转换

子类句柄指向父类，也就是父类转换为子类，是向下类型的转换

向上类型转换是安全的，向下类型转换是不安全的，因为父类本来在内存里就划好了一小块地盘，但是因为子类含有比父类更丰富的属性，它很有可能会访问父类并不包含的资源，所以会造成内存溢出。

- 向上类型转换
~~~
class father;
	string m_name;
	
function new (string name);
	m_name = name;
endfunction
function void print ();
	$display("Hello %s", m_name);
endfunction
 
endclass : father
 
class child0 extends father;
	string car = "car";
	
function new (string name);
	super.new(name);
endfunction
 
endclass : child0
 
class child1 extends father;
	string plane = "plane";
	
function new (string name);
	super.new(name);
endfunction
 
endclass : child1
 
module top;
	father f;
	child0 c0;
	child1 c1;
initial begin
	f  = new("father");
	f.print();  //调用打印函数
	c0 = new("child0");
	f  = c0;   //父类指针指向子类
	f.print(); //调用同样的打印函数
	c1 = new("child1");
	f  = c1;   //父类指针指向子类
	f.print(); //调用同样的打印函数
end
endmodule : top
 
打印结果：
Hello father
Hello child0
Hello child1
~~~
说明：

把父类指针指向子类，由于子类初始化变量的不同，所以printf函数，打印表现出不同的结果

- #### 向下类型转换：
不能直接转换，可以通过动态类型转换函数$cast转换，但只有当前父类指针指向的对象和待转换对象的类型一致时，cast才会成功
~~~
class father;
	string m_name;
	
	function new (string name);
		m_name = name;
	endfunction

	function void print ();
		$display("Hello %s", m_name);
	endfunction
 
endclass : father
 
class child0 extends father;
	string car = "car";
	
	function new (string name);
		super.new(name);
	endfunction
 
endclass : child0
 
class child1 extends father;
	string plane = "plane";
	
	function new (string name);
		super.new(name);
	endfunction
 
endclass : child1
 
module top;
	father f;
	child0 c0;
	child1 c1;
	child1 c2;

	initial begin
		f = new("father");
		f.print();
		c0 = new("child0");
		f = c0;
		f.print();
		c1 = new("child1");
		f = c1;
		f.print();
		c1.plane="big_plane";
		$cast(c2,f);//向下类型转换
		f.print();
		$write(", has %s",c2.plane);
	end
endmodule : top
~~~
说明：
cast用于扩展内存空间，避免内存溢出，因为c2与c1类型相同，f指向了c1，所以最终c2是指向了c1，c2没有new过，所以在类型转换之前没有分配内存空间




————————————————
版权声明：本文为CSDN博主「小白菜~」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/Hqy123_/article/details/127480308

