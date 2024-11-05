### 1. TCL基本入门
TCL解释器对一个命令的求值分为了：分析和执行
分析：把命令分解为独立的单词，进行必要的置换动作。
执行：把第一个单词当做命令，查看这个命令是否有定义，有的话激活其对应的内部动作。

置换分了了三种：
- 1、变量置换 $
- 2、命令置换 [ ]
- 3、反斜杠置换
解释：
~~~
%set x 10
%set y [expr $x + 100]
~~~
y的值是110，当TCL解释器遇到字符 [ ，它就会把随后expr作为一个命令名，从而激活expr对应的动作，如果我们去掉[]，TCL会报错，正常情况下只把命令行中的第一个单词作为命令，注意[]中必须是一个合法的TCL脚本，长度不限。[]中的脚本的值为最后一个命令的返回值。
~~~
%set y [expr $x+100;set b 300]//y 的值为300
~~~
反斜杠置换中，在单词符号中插入换行符、空格、【、$等被TCL解释器当做特殊符号对待的字符。

双引号和花括号：
TCL解释器对双引号中的各种分隔符将不做处理，但是对换行符、以及$ 和[]两种置换符会照常处理。
~~~
%set x 100
100
%set y "$x ddd"
100 ddd
~~~
在花括号中，所有特殊字符都将被成为普通字符，失去特殊意义。
~~~
%set y {/n$x [expr 10 +100]}
/n$x [expr 10 +100]
~~~
数组

数组不需要声明，直接赋值即可，也不必按照顺序来：
set i(1) 123 ; set i(16) hi
当然也支持任意维数的数组：
set i(1,2,3) hi
引用的时候直接$i(1,2,3)即可

set与unset
一个是设置变量，一个删除变量

### 2. append的用法
append的目的是将新的单词追加到原来旧的变量后面，而不是像set那样去替换原来这个旧的变量。
~~~
1）
% set x hello
hello
% set y world
world
% set x "$x$y"
helloworld
2）
% set x hello
hello
% set y world
world
% append x $y
helloworld
~~~
所以我们常可以看到dc里面设置search_path的时候，我们会用append，而不是用set去替换。

### 3. incr的用法
incr后面跟两个数，第一个参数为变量名，第二个参数为整数（默认为1），incr的目的就是将这个整数的值加到这个变量名的值上面，然后将结果存储到这个变量名中。
相当于a=a+number，值得一提的是不管是a还是number都必须要是整数，不可以为小数。
~~~
（1）
% set a 16
16
% incr a 2
18
% incr a -5
13
% incr a
14
% incr a 011
23
% incr a 0x11
40
（2）
% incr x 5
5
% incr y
1
（3）
% incr x 2.3
expected integer but got "2.3"
% set x 2.3
2.3
% incr x 2
expected integer but got "2.3"
解析：incr 的第一个参数必须是整数变量，第二个参数必须是整数。
~~~
### 4. 常见列表
列表作为TCL中的一种重要的数据结构：
- 列表创建方式  
1．使用{ }创建
~~~
%set a {Hello FPGA!}
Hello FPGA!
~~~
  2．通过list进行创建
因为list本身就是一个TCL，因此与set一起使用的时候就要用到命令置换符[]
~~~
%set b [list Hello FPGA!]
Hello FPGA!
~~~
  3．通过contact命令创建列表
contact的参数可以使任意多个列表，从而实现列表的拼接
~~~
set c [contact $a $b]
Hello FPGA！ Hello FPGA!
~~~
~~~
%set  d [contact {} {b c} {d}]
b c d
~~~

  4．通过lrepeat命令创建列表
lrepeat命令接收两个参数，第一个参数是重复次数，第二个参数是重复值。

~~~
%set m [lrepeat 4 "**"]
** ** ** **
~~~


  5．创建空的列表
空的列表不包含任何值，通常用于列表的初始化。可以通过{}，也可以通过list创建空列表。
~~~
%set p {}
llength $p
0
set q [list]
llength $q
0
~~~
创建列表的方法有很多种，但list是最常见的。\
另外上面介绍的列表除了创建一个新的列表，还有基于列表为元素的，这里我将其分开。\
基于单词元素和列表元素的有： { } 、list、lrepeat \
其余都是基于列表元素

list与contact的区别：\
　　concat是去掉了一层列表结构后，再组合所有的元素 \
　　![image](https://user-images.githubusercontent.com/55919713/232241918-c2a50ddc-79aa-4f97-bec8-1b9a73d97c92.png)

- llength:返回一个列表的元素个数
  llength list \
    ![image](https://user-images.githubusercontent.com/55919713/232241944-9a49f956-2927-4374-992f-41252a0af1ea.png)

- lindex ：返回索引值对应的列表元素
  元素的下标从0开始算起。如果没有index参数就返回整个列表，如果index对应的元素还是一个列表就返回对应子列表中的元素。\
  ![image](https://user-images.githubusercontent.com/55919713/232241961-9002f78e-0838-4f11-895c-ac3d606fee01.png)

- lrange：-返回指定区间的列表元素
  ~~~
  lrange list first last
  ~~~
  返回列表list一个区间的元素，区间由first和last指定\
  ![image](https://user-images.githubusercontent.com/55919713/232241983-67b4c17a-7aec-4c7a-b47a-2185c5d45bf5.png)


- lassign：将列表元素赋值给变量 \
  ![image](https://user-images.githubusercontent.com/55919713/232241992-eb0c73bb-4341-416b-aa7d-ea601ace85b7.png)

- lappend 在原列表后面添加元素
  lappend命令接收一个变量名（列表名），将元素添加到原列表后面\
  ![image](https://user-images.githubusercontent.com/55919713/232242007-e4228e16-1bbf-4106-83ac-c066d8843f3c.png)

- lreplace列表元素替换 \
  ![image](https://user-images.githubusercontent.com/55919713/232242019-8ff30c5e-95b3-47e8-89f0-48dcee9c8c17.png)

- lset 列表元素设置
  lset和lappend一样接收一个变量名作为参数，也会修改变量的值，将列表中的指定索引元素修改为指定的新值，如果不指定索引项就把整个列表换成新值。\
  ![image](https://user-images.githubusercontent.com/55919713/232242029-9f8af1ae-c7aa-4931-8e0d-1c74c91b89df.png)

- linsert 在指定索引值的列表中插入新值
  在索引位index的前面插入元素，产生一个新的列表\
  ![image](https://user-images.githubusercontent.com/55919713/232242036-2bfe60db-640c-4140-8630-818c786185b9.png)

- lsort：对列表内的元素排序
  ~~~
  lsort ?options?list
  ~~~
  ![image](https://user-images.githubusercontent.com/55919713/232242052-0ff8c75e-825b-41e5-9e3a-2271be581ba5.png)  
  1.按照ASCII码的顺序排序，是默认状态  
  2.按照字典顺序排序。  
  3.按照浮点数排序，要求列表里面的元素都能够正确的转化为浮点数   　
  4.按照整数排序，要求列表里面的元素都能够正确转化为整数        
　　　![image](https://user-images.githubusercontent.com/55919713/232242085-cd2d11d5-2393-4da1-a0f8-de9c8f141ffa.png)  
  * increasing 按照升序排列
  * decreasing 按照降序排列
  * indices 返回排序后的元素在原列表中的索引
  * nocase 忽略大小写
- lreverse：反向列表
返回一个列表，新的列表为原列表的反序形式。

### 5. TCL控制流
- if命令
- 循环命令：while、for、foreach
- eval命令
### 6. source -e -v
### 7. 提示
### 8.参考文章:
https://blog.csdn.net/ciscomonkey/article/details/112623310
————————————————
版权声明：本文为CSDN博主「ciscomonkey」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/ciscomonkey/article/details/112623310