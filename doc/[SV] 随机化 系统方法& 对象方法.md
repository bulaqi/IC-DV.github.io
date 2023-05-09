[TOC]
### 1. 概述
- $random —— 系统随机化调用函数，返回32bit有符号数；
- $urandom() —— 系统随机化调用函数，返回32bit无符号数；
- $urandom_range()—— 系统随机化调用函数，返回指定范围内的无符号随机整数；
- srandom() —— 对象和线程（手动添加种子seed）的随机化方法；
- randomize() —— 对象的随机化方法；
  
### 2. $random——系统方法，返回32bit的有符号伪随机数
语法如下：
   ~~~
   random(seed)
   /种子变量seed是可选的。
   ~~~
$random产生一个32bit的有符号随机数，可以是正数、也可以是负数。其种子变量（必须是reg类型、整型或时间型变量）。
1. $random%b; b为一个大于0的整数，表达式给出了一个范围在[-b+1 ： b-1]之间的随机数
   ~~~
   int randval;
   randval = $random % 60;      //随机产生一个-59~59之间的有符号数
   ~~~
2. **{ }化为无符号数**,{\$random%b};拼接操作符{ }将$random返回的有符号数转换成了无符号数。
   ~~~
   int randval;
   randval = {$random % 60};      //随机产生一个0~59之间的无符号数
   ~~~

### 3. $urandom——系统方法，返回32bit的无符号伪随机数
语法如下
~~~
function int unsigned $urandom(int seed);
//种子seed是可选参数，决定了生成的随机数值。相同的种子生成的随机数值也相同
~~~
示例
~~~
bit[64:1]   addr;
bit [3:0]   number;

addr[32:1] = $urandom(254) ;      //初始化随机数发生器（RNG），获得一个32bit的随机数

addr = {$urandom, $urandom};     //产生一个64bit的随机数
number = $urandom & 15;          //产生一个4bit的随机数
~~~

### 4. $urandom_range()——系统方法，返回指定范围内的无符号随机整数
语法如下：
~~~
function int unsigned $urandom_range(int unsigned maxval,
                                     int unsigned minval = 0);
//参数最小值min是可以省略的 ， 且最大值与最小值的位置是可以互换的。
~~~
下述三个随机值都在0~7的范围内，示例：
~~~
val1 = $urandom_range(7,0) ;
val2 = $urandom_range(7) ;
val3 = $urandom_range(0, 7) ;
~~~

### 5. srandom()——对象方法，在类方法内/外为随机数据发生器（RNG）添加随机种子
语法如下：
~~~
function void srandom(int seed);
//种子seed需要手动添加，来初始化随机数据发生器（RNG）
~~~
示例1：类内添加seed
~~~
class Packet;
  rand bit[15:0]  header;

  function new(int seed) ;
    this.srandom(seed) ;
    ...
  endfunction
endclass
~~~

示例2：类外添加seed
~~~
Packet p=new(200) ;    //通过种子200，创建对象p
p.srandom(300) ;       //通过种子300，重新创建p
~~~

### 6. randomize() —— 对象方法，为对象中的随机化变量随机赋值
语法如下：
~~~
virtual function int randomize();
//该方法是一个虚方法，会为对象中的所有随机变量产生随机值。如果randomize()成功的为对象中的所有随机变量赋随机值，则返回1，否则返回0.
~~~

示例1：成功赋值返回值为1
~~~
class SimpleSum;
  rand bit[7:0]  x, y, z;
  constraint c{ z== x+y}; 
endclass

SimpleSum p=new() ;
int success=p.randomize() ;      //随机化成功，则返回1，即success为1
if(success==1) ...

~~~

示例2：内嵌约束randomize() with{ }
~~~
class SimpleSum;
  rand bit[7:0]  x, y, z;
  constraint c{ z== x+y}; 
endclass

task InlineConstraintDemo(SimpleSum p) ;
  int success;
  success = p.randomize() with {x<y;} ;      //随机化成功，则返回1，即success为1
endtask

~~~
### 7. 传送门
  https://blog.csdn.net/weixin_46022434/article/details/107722106