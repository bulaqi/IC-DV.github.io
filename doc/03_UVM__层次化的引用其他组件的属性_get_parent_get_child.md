### 1. get_parent
在组件A内通过父节点访问兄弟组件B的属性
1. 首先声明父组件
   ~~~
   cq_env u_cq_env;
   ~~~
   补充:如果cq_env未声明,需要前置声明,在A类外,宏定义内,typedef class cq_env
2. 声明句柄
   ~~~
   cq_env u_cq_env;
   ~~~
3. get_parent获取父组件的句柄后,cast类型转换
   ~~~
   $cast(u_cq_env,get_parent());
   ~~~
4. 查看该组件名称,因get_parent返回的是组件句柄,需要用调用get_full_name()函数实现
   ~~~
      $cast(u_cq_env,get_parent());
      $cast(env,u_cq_env.get_parent()); //逐层调
      `uvm_info(this.get_full_name(),sformatf("env pwd=%s",eng.get_full_name()),UVM_MEDIUM);
   ~~~
   
### 2. get_child
### 
### 传送门
1. [UVM 怎么层次化引用其他component类中的属性](https://www.cnblogs.com/liutang2010/p/15870606.html)
2. [层次化相关函数](https://blog.csdn.net/tingtang13/article/details/46441873)
