### 1. 基础知识
#### 1. 产生进程的方式
1. 线程 VS 进程基础概念
- process，也就是进程，它是资源分配的最小单位；
- thread，线程，它是cpu调度的最小单位。
2. 区别,为了加深大家的理解，我这里把进程比喻成一辆火车，线程比喻成一节车厢
- 线程必须在进程下执行，这句话怎么理解呢，大家都知道光有车厢肯定不行，必须得先有火车是吧 ，而火车是由一节一节车厢组成的。
- 不同进程间的数据很难共享，但是同一进程下的线程很容易共享某个数据。这句话又是什么意思呢？当我坐上一辆火车时，想要进行换乘就很麻烦，还得下车然后走换乘通道，但是要进入不同的车厢就很简单啦，你只需要往前走或者往后走就能跨越不同的车厢。
3. thread 官方解释
initial…begin…end，final…begin…end，4个always procedure，3个fork procedure和dynamic process都可以产生线程  
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/3cdb2a08-2dec-455f-ba9b-3d0733017fed)

4. final和initial含义差不多，只是initial是在仿真0时刻自动执行，而final procedure刚好相反，是在仿真结束的时候才会执行
- final和initial含义差不多，只是initial是在仿真0时刻自动执行，而final procedure刚好相反，是在仿真结束的时候才会执行。
- final procedure是不消耗仿真时间的，且可以有多个final procedure，多个final procedure的执行顺序是随机的，我们来看个例子
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/fa84574f-f708-43e6-94d5-7d8ef8baf8d5)
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/0f5ac277-3ecc-4ba5-8843-11431e27d07d)

5. 死循环
- 下面两个例子都是典型的infinity loop，这种错误几乎每一个初学者都会碰到过，但是大家都清楚造成死循环的根本原因吗？
- 解析:
  1. 仿真器也是有时间片，每个process要执行也是要获取时间片的。
  2. 但是，不同点在于process获取到时间片后就会一直执行，时间片不会消耗完毕，而是要等到触发消耗时间的语句：#,@,wait等才会释放时间片给别的process。
-eg
   ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/aec9f6ad-e954-4149-a2b2-b5421cae45f5)

 6.  总结
 - SystemVerilog中不区分process和thread，统一为process；
 - process和thread的区别，即process和子process的区别；
 - 产生子process的多种方式；
 - final进程的含义；
 - 仿真其实是基于event的，而不是时间；
 - 编写代码时避免造成死循环

#### 2. 进程的控制
1. Named block
- Block，也就是语句块，SystemVerilog提供了两种类型的语句块，分别是begin…end为代表的顺序语句块，还有以fork…join为代表的并发语句块。
- block也是可以命名的，就像我们每个人的名字一样，名字是我们每个人的一个标识
- 通过这个标识，我们可以访问block中的变量、parameter
- 在block的开头和结束编写上标识名，也可以只在开头进行编写
- 如果是在block的开头和结束都有对应的标识名，则这两标识名必须相同，否则会编译报错
- 如果需要访问block中的变量或者parameter，则需要给block进行命名，并且，block中的变量、parameter都是相互独立的
- eg
  - ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/6624e7e6-32ba-4a30-8836-312dd2438353)

2. wait_order、wait fork
- SystemVerilog提供了两大类process的控制方式，分别为wait和disable。
- wait中又包含了三小类：wait、wait_order、wait fork。
- wait中另外一个重要的用法是wait fork，关于它的用法，黄鸭哥总结了三句话：
  1. wait fork会引起调用进程阻塞，直到它的所有子进程结束；
  2. wait fork的目的是用来确保所有子进程执行结束；
  3. wait fork作用父进程下的子进程，而不包括子进程下的子进程。
  4. eg 
     - ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/1ec0ef83-7583-4897-8ec1-dbb0e033434d)
     - ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/7896b2a5-706b-48b6-af91-6b9abf8dc8af)
  6. 解析
     ~~~
     图4中initial语句块包含4个子进程，proc_1~proc_4。
     其中，proc_4子进程中还含有一个子进程proc_4_1，此进程就是initial语句块的子进程的子进程。
     按照上面黄鸭哥总结的三点来看，wait fork应该只需要等待到第2个子进程：proc_2执行结束，因为wait fork只会作用到子进程，不会作用到子进程的子进程（不论是fork…join,fork…join_any还是fork…join_none产生的进程）。
     wait fork只等待到proc_2，在第200个timeunit就打印出了“wait fork finish”。
     ~~~



4. disable 、disable fork
   disable语句常用的多种方式包括：disable named_block、disable task_name和disable fork等，调用disable语句将会终止指定的进程。
   
6. 内建类：process
- SystemVerilog中内建了一种class，可以对进程进行访问和控制，此种class就是process，我们先来看下process类的原型：
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/2ebfbf8e-5beb-40ff-8329-5b4231903936)
- 几种task和function
     ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/a85eda73-6335-4a26-b9ec-ecee6ae216e0)
- 常用的几个method：self（），status（），kill（）
     ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/44a5c84e-6306-4a22-a577-59935d9dba82)
     ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/811a397f-6f80-4cf4-90ce-1b27b15a4485)
- 解析
    ~~~
    图9展示了这三个method的用法，通过self()获取进程的句柄，然后传递给定义的两个process类；
    调用status()可以获取到process_1和process_2进程的执行状态，在100个timeunit的时候，process_1已经执行结束，而process_2则处于阻塞状态；
    当再次经过100个timeunit时，调用kill()终止了process_2的继续执行，从这里可以看出，要终止一个进程，除了disable、disable fork之外，还可以调用process.kill()。
    ~~~

8. 总结
- block可以进行命名，命名之后就可以通过标识名访问block内部的变量和parameter，还可以通过disable named_block终止此block。
- 进程的两大控制方式：wait、disable。
- SystemVerilog内建类，process类，可以通过process类访问进程和控制进程。
- 三种终止进程的方式：disable、disable fork、process.kill()。



### 2. 传送门
1. [SystemVerilog中的Process（1）--- 产生进程的方式](https://zhuanlan.zhihu.com/p/304603657)
2. [SystemVerilog中的Process（2）--- 进程的控制](https://zhuanlan.zhihu.com/p/304608054)
2. [systemverilog语法_system verilog中的process类分析](https://zhuanlan.zhihu.com/p/304603657)
