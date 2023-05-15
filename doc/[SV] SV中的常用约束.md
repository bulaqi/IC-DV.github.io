[TOC]

### 1. Randomization 随机化
类中的变量可以使用关键字rand和randc来随机化取值；SV中以下的几种类型数据可以被rand和randc修饰：
- 整数型变量；
- 数组；
- 数组大小；
- 对象句柄；
#### 1. rand
~~~
rand bit [3:0] addr;//随机化范围根据位宽为0~15
~~~
#### 2. randc  (random cyclic)
~~~
randc bit   wr_rd;
~~~
#### 3. randomize()方法
用来对象的随机化，格式如下
~~~
object.randomize();//如果随机化成功，则返回1，否则返回0
~~~
下面举例说明：
~~~
//class
class packet;
  rand  bit [2:0] addr1;
  randc bit [2:0] addr2;
endclass
 
module rand_methods;
  initial begin
    packet pkt;
    pkt = new();
    repeat(10) begin
      pkt.randomize();
      $display("\taddr1 = %0d \t addr2 = %0d",pkt.addr1,pkt.addr2);
    end
  end
endmodule
~~~
addr1的随机类型为rand， addr2的随机类型为randc，输出结果如下：
#### 4. rand_mode()
通过修改rand_mode（）的参数值，可以允许或禁止随机化；默认情况下的参数为1；语法格式如下
~~~
 addr.rand_mode(0); //参数为0表示禁止随机化
 packet.addr.rand_mode(0);
 
对象名.成员名.rand_mode(0);//关闭成员的随机化
对象名.rand_mode(0);//关闭所有成员的随机化
~~~

~~~
class Fruits;
  rand bit [3:0] var1;
  rand bit [1:0] var2;
endclass
 
module tb;
  initial begin
    Fruits f = new(); 
    $display ("Before randomization var1=%0d var2=%0d", f.var1, f.var2);
    
    
    f.var1.rand_mode (0);// 关闭var1的随机化
    
    // Print if var1 has randomization enabled/disabled
    if (f.var1.rand_mode())
      $display ("Randomization of var1 enabled");
    else
      $display ("Randomization of var1 disabled");
    
    f.randomize();
    
    $display ("After randomization var1=%0d var2=%0d", f.var1, f.var2);
  end
endmodule
~~~

~~~
// Create a class that contains random variables
class Fruits;
  rand bit [3:0] var1;
  rand bit [1:0] var2;
endclass
 
module tb;
 
  initial begin
    Fruits f = new(); 
    $display ("Before randomization var1=%0d var2=%0d", f.var1, f.var2);
 
    // Turns off randomization for all variables
    f.rand_mode (0); //不带成员变量名后关闭的是所有成员变量的随机化   
 
    if (! f.var1.rand_mode())
      if (! f.var2.rand_mode())
        $display ("Randomization of all variables disabled");
 
    f.randomize();
 
    $display ("After randomization var1=%0d var2=%0d", f.var1, f.var2);
  end
endmodule
~~~

因为关闭了随机化，所以两个变量都是默认值.

#### 2. Randomization Methods  随机化方法
- 随机化方法randomize( )是一个虚方法，在遵守有效约束的情况下为对象的所有随机化变量产生随机值；如果随机化成功，该方法会返回1，否则返回0
- 每个类都包括内建的pre_randomize()和post_randomize()方法.一旦调用randomize( )，会在随机化的前后分别调用pre_randomize()和post_randomize()方法.用户可以自定义这两个方法以覆盖内建的方法，这两个方法虽然不是虚方法，但是表现和虚方法类似，当你试图在这两个方法前加上virtual关键字时会报错
- pre_randomize()可以用来在随机化之前设置一些随机化的条件，例如阻止某些随机变量的随机化；pre_randomize()可以用来在随机化之后检查对象随机化之后的后置条件，如打印随机化的值或者覆盖随机化的值等。
- 
看下面的例子，包括两个随机化变量addr 和wr_rd.
约定：wr_rd=0，执行读操作；wr_rd=1，执行写操作；
为了在读操作之后写入读操作的同一个地址，addr的随机化被wr_rd的前一个随机值所控制
~~~
//class
class packet;
  rand  bit [7:0] addr;
  randc bit       wr_rd;
  bit       tmp_wr_rd;    
 
  //pre randomization function - 控制addr是否随机化
  //if the prevoius operation is write.
  function void pre_randomize();
    if(tmp_wr_rd==1) addr.rand_mode(0);//如果前一个操作是写，则阻止随机化addr
    else                 addr.rand_mode(1);
  endfunction
 
  //post randomization function - 将wr_rd的值存入tmp_wr_rd，并打印
  function void post_randomize();
    tmp_wr_rd = wr_rd;
    $display("POST_RANDOMIZATION:: Addr = %0h,wr_rd = %0h",addr,wr_rd);
  endfunction
endclass
 
module rand_methods;
  initial begin
    packet pkt;
    pkt = new();
 
    repeat(4) pkt.randomize();
  end
endmodule
~~~
 运行结果如下：
 当前一个wr_rd为1时，addr不进行随机化；

### 3. Array Randomization 数组随机化 
SV可以对定宽数组、动态数组、队列进行随机化.
#### 1. 定宽数组 
~~~
class Packet;
  rand bit [3:0]   s_array [7];   // Declare a static array with "rand"
endclass
 
module tb;
  Packet pkt;
 
  // Create a new packet, randomize it and display contents
  initial begin
    pkt = new();
    pkt.randomize();//调用随机方法
    $display("queue = %p", pkt.s_array);
  end 
endmodule
~~~
#### 2. 动态数组
~~~
class Packet;
  rand bit [3:0]   d_array [];   // Declare a dynamic array with "rand"
 
  // Constrain size of dynamic array between 5 and 10  约束动态数组的长度
  constraint c_array { d_array.size() > 5; d_array.size() < 10; }
 
  // Constrain value at each index to be equal to the index itself
  constraint c_val   { foreach (d_array[i]) 
              d_array[i] == i; 
                     }//对数组元素的约束，要对每一个元素约束
 
  // Utility function to display dynamic array contents
  function void display();
    foreach (d_array[i]) 
      $display ("d_array[%0d] = 0x%0h", i, d_array[i]);
  endfunction
endclass
 
module tb;
  Packet pkt;
 
  // Create a new packet, randomize it and display contents
  initial begin
    pkt = new();
    pkt.randomize();//在调用随机化函数时默认对动态数组new
    pkt.display();
  end 
endmodule
~~~
 结果：
#### 3. 队列
~~~
class Packet;
  rand bit [3:0]   queue [$];   // Declare a queue with "rand"
 
  // Constrain size of queue between 5 and 10   约束队列的长度
  constraint c_array { queue.size() == 4; }//约束中不允许存在赋值，约束内部的赋值用"=="代替
endclass
 
module tb;
  Packet pkt;
 
  // Create a new packet, randomize it and display contents
  initial begin
    pkt = new();
    pkt.randomize();
 
    // Tip : Use %p to display arrays
    $display("queue = %p", pkt.queue);
  end 
endmodule
~~~
结果：


### 1. Constraint Blocks 约束块
#### 1. 内部约束块
随机变量可以通过随机化获得随机值，通过对随机变量添加约束可以得到特定范围内的随机值 ；约束必须写在约束块中.

约束块是类的成员，就像成员变量和成员方法一样，类里面的每一个约束块都要有唯一的块名，如：
~~~
constraint addr_range { addr > 5; }
~~~
adde_range是约束块名，约束的所有语句都被大括号{ }包围起来（这与语句块不同，语句块为begin...end），每条语句后面都要加分号"；"。约束的通用格式如下：
~~~
constraint  [name_of_constraint] {  [expression 1];
                                      [expression N]; 
                                 }
~~~
看下面例子：
~~~
class packet;
  rand  bit [3:0] addr;
 
  constraint addr_range { addr > 5; }//限定addr的值大于5
endclass
 
module constr_blocks;
  initial begin
    packet pkt;
    pkt = new();
    repeat(10) begin
      pkt.randomize();
      $display("\taddr = %0d",pkt.addr);
    end
  end
endmodule
~~~
 结果如下：

### 5. External Constraint blocks  外部约束块
约束可以像方法一样，在类的内部声明，而在类的外部定义，要使用作用域操作符"::"。
~~~
class packet;
  rand  bit [3:0] addr;
//constraint block declaration
  constraint addr_range;
endclass
 
//constraint implementation outside class body 约束在类外部定义时，注意添加类名和作用域操作符
constraint packet::addr_range { addr > 5; }
 
module extern_constr;
  initial begin
    packet pkt;
    pkt = new();
 
    repeat(10) begin
      pkt.randomize();
      $display("\taddr = %0d",pkt.addr);
    end
  end
endmodule
~~~
运行结果：

### 6. Constraint Inheritance  约束的继承
与类的成员一样，类的约束一样能被子类继承和覆盖重写.
~~~
class packet;
  rand  bit [3:0] addr;
  constraint addr_range { addr > 5; }
endclass
 
class packet2 extends packet;
  constraint addr_range { addr < 5; } //同名约束，覆盖了父类的约束；要重写同名约束，约束的内容要与父类中的同名约束不同。函数也是如此
 //constraint addr_range1 { addr < 5; } //非同名约束，与父类的原有约束叠加
endclass
 
module const_inhe;
  initial begin
    packet pkt1;
    packet2 pkt2;
 
    pkt1 = new();
    pkt2 = new();
 
    $display("------------------------------------");
    repeat(5) begin
      pkt1.randomize();
      $display("\tpkt1:: addr = %0d",pkt1.addr);
    end
 
    $display("------------------------------------");
    repeat(5) begin
      pkt2.randomize();
      $display("\tpkt2:: addr = %0d",pkt2.addr);
    end
    $display("------------------------------------");
  end
endmodule
~~~
运行结果：


### 7. inside操作符
可以用inside操作符产生一个随机数的集合，随机变量的取值在这个集合里面选取，且每个值取到的概率均等.如下
~~~
constraint addr_range  { addr inside {1,3,5,7,9}; }
constraint addr_range  { addr inside {[5:10]}; }
constraint addr_range  { addr inside {1,3,[5:10],12,[13:15]}; }
constraint addr_range  { addr !(inside {[5:10]}); }//对范围取反
~~~
集合可以是范围，也可以是多个数的列举，还可以对范围进行取反操作等等.  
~~~
 rand bit [3:0] start_addr;
 rand bit [3:0] end_addr;
 rand bit [3:0] addr;
 constraint  addr_range  { addr inside {[start_addr:end_addr]}; }//范围的边界也可以是随机值
~~~
看下面例子：
~~~
class packet;
  rand bit [3:0] addr_1;
  rand bit [3:0] addr_2;
  rand bit [3:0] start_addr;
  rand bit [3:0] end_addr;
  constraint addr_1_range {   addr_1 inside {[start_addr:end_addr]}; }
  constraint addr_2_range { !(addr_2 inside {[start_addr:end_addr]}); }
endclass
 
module constr_inside;
  initial begin
    packet pkt;
    pkt = new();
 
    $display("------------------------------------");
    repeat(3) begin
      pkt.randomize();
      $display("\tstart_addr = %0d,end_addr = %0d",pkt.start_addr,pkt.end_addr);
      $display("\taddr_1 = %0d",pkt.addr_1);
      $display("\taddr_2 = %0d",pkt.addr_2);
      $display("------------------------------------");
    end
  end
endmodule
~~~
结果如下：

### 8. Weighted Distribution 权重分布
dist操作符允许产生随机数的权重分布，这样不同的值选取的概率就会不同 。dist操作符带有一个值的列表以及相应的权重，中间用:=或:/分开.值或权重可以是常数或者变量，值也可以是一个数或范围，如[lo,hi]。权重不用百分比表示，权重的和也不必是100。:=操作符表示值范围内的每个值的权重是相同的，:/表示权重要均分到每个值.
1. 普通场景
~~~
addr dist { 2 := 5, [10:12] := 8 };
         //addr = 2 , weight 5
        // addr = 10, weight 8
         //addr = 11, weight 8
         //addr = 12, weight 8
 addr dist { 2 :/ 5, [10:12] :/ 8 };
         //addr = 2 , weight 5
        // addr = 10, weight 8/3
        // addr = 11, weight 8/3
         //addr = 12, weight 8/3
~~~
看下面例子：
~~~
class packet;
  rand bit [3:0] addr;
 
  constraint addr_range { addr dist { 2 := 5, 7 := 8, 10 := 12 }; }
endclass
 
module constr_dist;
  initial begin
    packet pkt;
    pkt = new();
    $display("------------------------------------");
    repeat(10) begin
      pkt.randomize();
      $display("\taddr = %0d",pkt.addr);
    end
    $display("------------------------------------");
  end
endmodule
~~~
输出结果：
~~~
class packet;
  rand bit [3:0] addr_1;
  rand bit [3:0] addr_2;
 
  constraint addr_1_range {   addr_1 dist { 2 := 5, [10:12] := 8 }; }
  constraint addr_2_range {   addr_2 dist { 2 :/ 5, [10:12] :/ 8 }; }
endclass
 
module constr_dist;
  initial begin
    packet pkt;
    pkt = new();
 
    $display("------------------------------------");
    repeat(10) begin
      pkt.randomize();
      $display("\taddr_1 = %0d",pkt.addr_1);
    end
    $display("------------------------------------");
    $display("------------------------------------");
    repeat(10) begin
      pkt.randomize();
      $display("\taddr_2 = %0d",pkt.addr_2);
    end
    $display("------------------------------------");
  end
endmodule
~~~
输出结果：
2. 通过solve...before改变权重
   ~~~
   class ABC;
  rand  bit      a;
  rand  bit [1:0]   b;
 
  constraint c_ab { a -> b == 3'h3; }
endclass
 
module tb;
  initial begin
    ABC abc = new;
    for (int i = 0; i < 8; i++) begin
      abc.randomize();
      $display ("a=%0d b=%0d", abc.a, abc.b);
    end
  end
endmodule
   ~~~
   各种值的概率：
在约束中加上solve..before的情况：  
~~~
class ABC;
  rand  bit      a;
  rand  bit [1:0]   b;
 
  constraint c_ab { a -> b == 3'h3; 
 
            // Tells the solver that "a" has
            // to be solved before attempting "b"
            // Hence value of "a" determines value 
            // of "b" here
                    solve a before b;
                  }
endclass
 
module tb;
  initial begin
    ABC abc = new;
    for (int i = 0; i < 8; i++) begin
      abc.randomize();
      $display ("a=%0d b=%0d", abc.a, abc.b);
    end
  end
endmodule
~~~ 
取值概率：

### 9. conditional constrain 条件约束
#### 1. -> 操作符
语法格式：
~~~
expression -> constraint
//如果表达式为真，则执行约束
~~~
举例：
~~~
class packet;
  rand bit [3:0] addr;
       string    addr_range;
  constraint address_range { (addr_range == "small") -> (addr < 8);}// irun好像不支持在约束中使用字符串，改为枚举就OK了
endclass
 
module constr_implication;
  initial begin
    packet pkt;
    pkt = new();
 
    pkt.addr_range = "small";
    $display("------------------------------------");
    repeat(4) begin
      pkt.randomize();
      $display("\taddr_range = %s addr = %0d",pkt.addr_range,pkt.addr);
    end
    $display("------------------------------------");
  end
endmodule
~~~
运行结果：
~~~
class ABC;
  rand bit [2:0] mode;
  rand bit [3:0] len;
 
  constraint c_mode { mode == 2 -> len > 10; }//如果mode为2，则len>10
endclass
 
module tb;
  initial begin
    ABC abc = new;
    for(int i = 0; i < 10; i++) begin
      abc.randomize();
      $display ("mode=%0d len=%0d", abc.mode, abc.len);
    end
  end
endmodule
~~~
结果：
#### 2. if...else
与->操作符类似，看例子：
~~~
class packet;
  rand bit [3:0] addr;
       string    addr_range;
 
  constraint address_range { if(addr_range == "small")
                                addr < 8;
                             else
                                addr > 8;
                           }
endclass
 
module constr_if_else;
  initial begin
    packet pkt;
    pkt = new();
    pkt.addr_range = "small";
    $display("------------------------------------");
    repeat(3) begin
      pkt.randomize();
      $display("\taddr_range = %s addr = %0d",pkt.addr_range,pkt.addr);
    end
    $display("------------------------------------");
 
    pkt.addr_range = "high";
    $display("------------------------------------");
    repeat(3) begin
      pkt.randomize();
      $display("\taddr_range = %s addr = %0d",pkt.addr_range,pkt.addr);
    end
    $display("------------------------------------");
  end
endmodule
~~~
结果：

### 10. 静态约束
与静态成员一样，约束同样可以定义为static。静态约束在所有类的对象之间共享，也就是说如果某个对象关闭了静态约束，那么其他对象的静态约束也被关闭。静态约束格式如下：
~~~
class [class_name];
  ...
 
  static constraint [constraint_name] [definition]
endclass
~~~
看下面例子：
~~~
class ABC;
  rand bit [3:0]  a;
 
  // "c1" is non-static, but "c2" is static
  constraint c1 { a > 5; }//非静态约束
  static constraint c2 { a < 12; }//静态约束
endclass
 
module tb;
  initial begin
    ABC obj1 = new;
    ABC obj2 = new;
 
    // Turn off non-static constraint
    obj1.c1.constraint_mode(0);//关闭obj1的非静态约束
 
    for (int i = 0; i < 5; i++) begin
      obj1.randomize();
      obj2.randomize();
      $display ("obj1.a = %0d, obj2.a = %0d", obj1.a, obj2.a);
    end
  end
endmodule
~~~
 由于关闭了obj1对象的非静态约束，所以obj1.a的值被限定在a<12的范围内，输出结果如下：

~~~
class ABC;
  rand bit [3:0]  a;
 
  // "c1" is non-static, but "c2" is static
  constraint c1 { a > 5; }
  static constraint c2 { a < 12; }
endclass
 
module tb;
  initial begin
    ABC obj1 = new;
    ABC obj2 = new;
 
    // Turn non-static constraint
    obj1.c2.constraint_mode(0);//关闭静态约束
 
    for (int i = 0; i < 5; i++) begin
      obj1.randomize();
      obj2.randomize();
      $display ("obj1.a = %0d, obj2.a = %0d", obj1.a, obj2.a);
    end
  end
endmodule
~~~
由于obj2对象关闭了静态约束，所以obj1和obj2都只激活了c1约束，也就是a>5，所以结果如下：



### 11. Iterative in Constraint Blocks 迭代约束
迭代约束允许使用循环变量和索引表达式约束数组变量，如：
~~~
rand byte addr [];
     rand byte data [];
 
     constraint avalues { foreach ( addr[i] ) addr[i] inside {4,8,12,16}; }//遍历数组来设置每个数组元素的约束
     constraint dvalues { foreach ( data[j] ) data[j] > 4 * j; }
     constraint asize    { addr.size < 4; }//设置数组大小的约束
     constraint dsize    { data.size == addr.size; }
~~~
例子
~~~
class packet;
  rand byte addr [];
  rand byte data [];
 
  constraint avalues { foreach( addr[i] ) addr[i] inside {4,8,12,16}; }
  constraint dvalues { foreach( data[j] ) data[j] > 4 * j; }
  constraint asize   { addr.size < 4; }//如果改为大于4，irun会报错？这里发现数组深度的约束只能是小于某一个特定值，若改为大于则会报错，不知道原因;之后在写数组深度的约束时，需要设定一个深度上限，否则很可能会报错
  constraint dsize   { data.size == addr.size; } //在约束中，== 表示赋值
endclass
 
module constr_iteration;
  initial begin
    packet pkt;
    pkt = new();
 
    $display("------------------------------------");
    repeat(2) begin
      pkt.randomize();
      $display("\taddr-size = %0d data-size = %0d",pkt.addr.size(),pkt.data.size());
      foreach(pkt.addr[i]) $display("\taddr = %0d data = %0d",pkt.addr[i],pkt.data[i]);
      $display("------------------------------------");
    end
  end
endmodule
~~~
结果：
### 12. constraint_mode( )
constraint_mode()方法可以用来禁止约束，默认情况下该方法的参数值为1，表示约束有效；参数为0时，表示约束无效.
~~~
addr_range.constraint_mode(0); //设置约束无效
packet.addr_range.constraint_mode(0);//packet为类名
~~~
~~~
class Fruits;
  rand bit[3:0]  num; 				// Declare a 4-bit variable that can be randomized
  
  constraint c_num { num > 4;  		// Constraint is by default enabled, and applied
                    num < 9; }; 	// during randomization giving num a value between 4 and 9
endclass
 
module tb;
  initial begin
    Fruits f = new ();
    $display ("Before randomization num = %0d", f.num); 	
    
    // Disable constraint 
    f.c_num.constraint_mode(0);//关闭约束
    
    if (f.c_num.constraint_mode ())
      $display ("Constraint c_num is enabled");
    else
      $display ("Constraint c_num is disabled");
      
    // Randomize the variable and display
    f.randomize ();
    $display ("After randomization num = %0d", f.num);    
  end
endmodule
~~~
由于关闭了约束，所以随机化后num=15.\
也可以设置静态约束，只需要在约束前加上static关键字 ，这是任何对约束的改变都会反映到类例化的每一个对象上，例如禁止某一对象的约束有效，其余对象的约束也同时无效
~~~
static constraint addr_range { addr > 5; }
~~~
例子
~~~
class packet;
  rand  bit [3:0] addr;
 
  static constraint addr_range { addr > 5; }
endclass
 
module static_constr;
  initial begin
    packet pkt1;
    packet pkt2;
 
    pkt1 = new();
    pkt2 = new();
 
    pkt1.randomize();
    $display("\taddr = %0d",pkt1.addr);
    pkt1.addr_range.constraint_mode(0);
    $display("\tAfter disabling constraint");
    pkt1.randomize();
    $display("\taddr = %0d",pkt1.addr);
    pkt2.randomize();
    $display("\taddr = %0d",pkt2.addr);
  end
endmodule
~~~
结果：
### 13. Inline Constraints 附加约束
#### 1. 附加约束
允许在调用随机函数的时候添加约束，此时要将定义在类中的约束也与添加约束一起考虑 ，添加的约束叫做附加约束.附加的约束不能和原始约束发生冲突，否则随机化会失败！
~~~
class packet;
  rand bit [3:0] addr;
endclass
 
module inline_constr;
  initial begin
    packet pkt;
    pkt = new();
 
    repeat(2) begin
      pkt.randomize() with { addr == 8;};//在调用randomize方法时添加约束
      $display("\taddr = %0d",pkt.addr);
    end
  end
endmodule
~~~
结果：
~~~
class packet;
  rand bit [3:0] addr;
  rand bit [3:0] data;
 
  constraint data_range { data > 0;
                          data < 10; }
endclass
 
module inline_constr;
  initial begin
    packet pkt;
    pkt = new();
    repeat(2) begin
      pkt.randomize() with { addr == 8;};//要将添加的约束与类中的约束一起考虑
      $display("\taddr = %0d data = %0d",pkt.addr,pkt.data);
    end
  end
endmodule
~~~
结果：
#### 2. 附加的约束函数
~~~
class packet;
  rand bit [3:0] start_addr;
  rand bit [3:0] end_addr;
 
  constraint end_addr_c { end_addr == e_addr(start_addr); }//调用约束函数
 
  function bit [3:0] e_addr(bit [3:0] s_addr);
    if(s_addr<0)
      e_addr = 0;
    else
        e_addr = s_addr * 2;
  endfunction
endclass
 
module func_constr;
  initial begin
    packet pkt;
    pkt = new();
 
    repeat(3) begin
      pkt.randomize();
      $display("\tstart_addr = %0d end_addr =",pkt.start_addr,pkt.end_addr);
    end
  end
endmodule
~~~
结果：
### 14. Soft Constraints  软约束
举个例子，父类中的约束为constraining a < 10，子类中的约束为 constraining a > 10，这样两个约束会发生互斥而导致随机化的失败.解决这一问题的方法就是使用软约束，格式如下：
~~~
constraint c_name { soft variable { condition }; }
~~~
例子
~~~
class packet;
  rand bit [3:0] addr;
  constraint addr_range { addr > 6; }
endclass
 
module soft_constr;
  initial begin
    packet pkt;
    pkt = new();
 
    repeat(2) begin
      pkt.randomize() with { addr < 6;};//内嵌约束与类中的约束矛盾，会导致随机化失败
      $display("\taddr = %0d",pkt.addr);
    end
  end
endmodule
~~~
结果：
报错后，addr被赋予默认值.
~~~
class packet;
  rand bit [3:0] addr;
  constraint addr_range { soft addr > 6; }//类中的约束为软约束
endclass
 
module soft_constr;
  initial begin
    packet pkt;
    pkt = new();
 
    repeat(2) begin
      pkt.randomize() with { addr < 6;};//两个约束发生矛盾时，此时正常约束会覆盖掉软约束
      $display("\taddr = %0d",pkt.addr);
    end
  end
endmodule
~~~
结果：
当正常约束与软约束发生矛盾时，软约束被正常约束抑制 .


### 15. Unique Constraint 唯一约束
在随机化过程中，可以使用唯一约束生成变量集或数组中唯一元素的唯一值 .
唯一约束允许：
- 跨变量生成唯一值；
- 在数组中生成唯一元素
例子：
~~~
class unique_elements;
  rand bit [3:0] var_1,var_2,var_3;
  rand bit [7:0] array[6];
   
  constraint array_c {unique {array};}//唯一约束，关键字unique
   
  function void display();
    $display("var_1 = %p",var_1);
    $display("var_2 = %p",var_2);
    $display("var_3 = %p",var_3);
    $display("array = %p",array);
  endfunction
endclass
 
program unique_elements_randomization;
  unique_elements pkt;
 
  initial begin
    pkt = new();
    pkt.randomize();
    pkt.display();  
  end
endprogram
~~~ 
结果：

### 16. Bidirectional Constraints 双向约束
SV对约束的处理是双向的，也就是说所有约束的执行是并行的；约束求解器将考虑所有的约束条件来选择所有随机变量的值，因为一个变量的约束值可能取决于其他变量的值，而其他变量的值可能会再次受到约束。
~~~
class packet;
  rand bit [3:0] a;
  rand bit [3:0] b;
  rand bit [3:0] c;
 
  constraint a_value { a == b + c; }
  constraint b_value { b > 6; }
  constraint c_value { c < 8; }
endclass
 
module bidirectional_constr;
  initial begin
    packet pkt;
    pkt = new();
    repeat(5) begin
      pkt.randomize();
      $display("Value of a = %0d \tb = %0d \tc =%0d",pkt.a,pkt.b,pkt.c);
    end
  end
endmodule
~~~
结果：
第二组 a 已经溢出

~~~
class packet;
  rand bit a;
  rand bit b;
 
  constraint a_value { a == 1; }
  constraint b_value { if(a == 0) b == 1;
                       else       b == 0; }
endclass
 
module bidirectional_const;
  initial begin
    packet pkt;
    pkt = new();
    pkt.randomize() with { b == 1; };//内嵌约束与前面的约束发生矛盾
    $display("Value of a = %0d \tb = %0d",pkt.a,pkt.b);
  end
endmodule
~~~
结果：
由于约束发生矛盾，所以报错.

### 17. Random System Methods SV中的随机化函数
#### 1. $urandom( ) 
$urandom( ) 方法返回一个32bit的无符号整型数据，格式如下：
~~~
variable = $urandom(seed);//seed种子是个可选项
~~~
~~~
bit [31:0] addr1;
   bit [31:0] addr2;
   bit [64:0] addr3;
   bit [31:0] data;
 
   addr1 = $urandom();
   addr2 = $urandom(89);
   addr3 = {$urandom(),$urandom()};
   data  = $urandom * 6;
~~~
#### 2. $random( )
和$urandom( )类似，但是返回的是带符号数据.
#### 3. $urandom_range( )
返回一定范围的无符号数据，格式如下：
~~~
 $urandom_range( int unsigned maxval, int unsigned minval = 0 );
~~~

~~~
addr1 = $urandom_range(30,20);
addr2 = $urandom_range(20); //默认最小值为0
addr3 = $urandom_range(20,30); //considers max value as '30' and min value as '20'
~~~

例子：
~~~
module system_funcations;
  bit [31:0] addr1;
  bit [31:0] addr2;
  bit [64:0] addr3;
  bit [31:0] data;
 
  initial begin
    addr1 = $urandom();
    addr2 = $urandom(89);//89 表示seed
    addr3 = {$urandom(),$urandom()};
    data  = $urandom * 6;
 
    $display("addr1=%0d, addr2=%0d, addr3=%0d, data=%0d",addr1,addr2,addr3,data);
  
    addr1 = $urandom_range(30,20);
    addr2 = $urandom_range(20); //takes max value as '0'
    addr3 = $urandom_range(20,30); //considers max value as '30' and min value as '20'
    $display("addr1=%0d, addr2=%0d, addr3=%0d",addr1,addr2,addr3);
  end
endmodule
~~~
结果:

### 18. 传送门
[SV之随机化和约束](https://blog.csdn.net/bleauchat/article/details/90381532)