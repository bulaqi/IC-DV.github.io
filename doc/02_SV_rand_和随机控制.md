### 1. 基础
#### 1. 变量的随机控制：rand_mode()
- rand_mode() 方法可用于控制随机变量是活跃还是不活跃。
- 当随机变量处于非活动状态时，它的处理方式与未声明 rand 或 randc 相同。 非活动变量不会被 randomize() 方法随机化，它们的值被求解器视为状态变量。 
-  所有随机变量最初都是活跃的。
-  eg
    ~~~
    class Packet;
        rand integer source_value, dest_value;
    endclass
    int ret;
    Packet packet_a = new;
    packet_a.rand_mode(0);  //关闭packet_a内所有变量随机化，所有变量被当作静态变量

    packet_a.source_value.rand_mode(1);   //开启source_value的随机化

    ret = packet_a.dest_value.rand_mode();
    ~~~

#### 2. 约束的随机控制：constraint_mode()
- constraint_mode() 方法可用于控制 约束  是活动的还是非活动的。 
- 当约束处于非活动状态时，randomize() 方法不会考虑它。
-  所有约束最初都是活动的。
- eg
    ~~~
    class Packet;
        rand integer source_value;
        constraint filter1 { source_value > 2 * m; }
    endclass

    function integer toggle_rand( Packet p );
        //p.constraint_mode(0)            //关闭 类 的随机
        if ( p.filter1.constraint_mode() )
            p.filter1.constraint_mode(0);   //关闭 约束块  filter1的约束，随机时不考虑该约束
        else
            p.filter1.constraint_mode(1);   //开启 约束块  filter1的约束，随机时需要考虑该约束
        toggle_rand = p.randomize();
    endfunction
    ~~~

#### 3. randomize变量随机控制
- randomize() 方法可用于 临时 控制类实例或对象中的 随机变量 和 状态变量集（没有被rand/randc 修饰）。 
- 不指定参数：当调用不带参数的 randomize() 方法时，对象中的所有随机变量（声明为 rand 或 randc 的随机变量）分配新值
- 参数指定该对象： 指定该对象内的完整随机变量集；对象中的所有其他变量都被视为状态变量。
- 此机制在调用randomize()期间控制一组活动随机变量，这在概念上等同于对 rand_mode()方法进行一组调用以禁用或启用相应的随机变量。
- 使用参数调用 randomize()允许更改任何类属性的随机模式，即使是那些未声明为 rand 或 randc 的属性。
- 然而，这种机制并不影响循环随机模式；它不能将非随机变量变为循环随机变量（randc），也不能将循环随机变量变为非循环随机变量（从randc变为rand）。
- randomize()方法的参数范围是对象类。参数仅限于调用对象的属性名称；不允许是表达式。
- 本地类成员的随机模式只有在调用randomize()可以访问这些属性时才能更改，即在声明本地成员的类的范围内。

- eg 
    ~~~    
    class CA;
        rand byte x, y;
        byte v, w;
        constraint c1 { x < v && y > w );
    endclass
    
    CA a = new;
    a.randomize();      //随机x，y, rand 和randc 类型
    a.randomize(x);     //随机x
    a.randomize(v,w);   //随机v，w,  对状态变量集随机
    a.randomize(w,x);   //随机x，w， 对指定的 随机变量 +状态变量集 混合参数随机
    ~~~
- eg2:
  ~~~
  success = a.randomize(null);  
  //不随机内部变量，仅检查内部变量是否满足所有约束
  ~~~

### 2. 经验

### 3. 传送门
1. [systemverilog随机化控制方法](https://blog.csdn.net/muyiwushui/article/details/127248626#%E5%88%A9%E7%94%A8rand_mode()%E4%BD%BF%E8%83%BD%E5%92%8C%E5%85%B3%E9%97%AD%E5%8F%98%E9%87%8F%E9%9A%8F%E6%9C%BA)


