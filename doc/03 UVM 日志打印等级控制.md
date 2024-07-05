### 1. 基础知识
#### 1. 日志等级概念
	~~~
	typedef enum
	{
		UVM_NONE = 0,
		UVM_LOW = 100,
		UVM_MEDIUM = 200,
		UVM_HIGH = 300,
		UVM_FULL = 400,
		UVM_DEBUG = 500
	} uvm_verbosity;
	~~~
	
#### 2. 设置日志等级方法
仿真参数设置
~~~
<sim command> +UVM_VERBOSITY=UVM_HIGH
~~~


#### 3. 常用方法
1. get_report_verbosity_level
   得到某个component的冗余度阈值：
   
2. set_report_verbosity_level/set_report_id_verbosity(区分不同的ID的冗余度阈值)
   - 功能：来设置某个特定component的默认冗余度阈值
   - 注意事项：
     1. set_report_verbosity_level只对某个特定的component起作用
     2. 由于需要牵扯到层次引用， 所以需要在connect_phase及以后的phase才能调用这个函数。
     3. 如果不牵扯到任何层次引用， 如设置当前component的冗余度阈值， 那么可以在connect_phase之前调用
  - eg,全部组件:
    ~~~
    //src/ch3/section3.4/3.4.1/base_test.sv
    …
    virtual function void connect_phase(uvm_phase phase);
    env.i_agt.drv.set_report_verbosity_level(UVM_HIGH);
    …
    endfunction
    ~~~
  - eg：by_id
    ~~~
    env.i_agt.drv.set_report_id_verbosity("ID1", UVM_HIGH)
    ~~~
	
3. 递归的设置函数set_report_verbosity_level_hier， 
   - 注意事项：
     set_report_verbosity_level会对某个component内**所有**的uvm_info宏显示的信息产生影响
   - 全部组件，eg：
        ~~~
        // 如把env.i_agt及其下所有的component的冗余度阈值设置为UVM_HIGH的代码为：
        env.i_agt.set_report_verbosity_level_hier(UVM_HIGH);
        ~~~
   - by_id，eg：
        ~~~
        env.i_agt.set_report_id_verbosity_hier("ID1", UVM_HIGH);
        ~~~

#### 4. set_report_severity_override/set_report_severity_id_override，重载打印信息的严重性

1. 背景：UVM默认有四种信息严重性： UVM_INFO、 UVM_WARNING、 UVM_ERROR、UVM_FATAL。 这四种严重性可以互相重载。
2. 如果要把driver中所有的UVM_WARNING显示为UVM_ERROR， 可以使用如下的函数：
3. 重载函数，eg:    
    ~~~
    virtual function void connect_phase(uvm_phase phase);
     env.i_agt.drv.set_report_severity_override(UVM_WARNING, UVM_ERROR);
     //env.i_agt.drv.set_report_severity_id_override(UVM_WARNING, "my_driver", UVM_ERROR);
    endfunction
    ~~~
    
3. eg，不加上述的设置
    - 范例代码
    ~~~
    //my_driver.sv的语句
    `uvm_warning("my_driver", "this information is warning, but prints as UVM_ERROR")
    ~~~
    - 不加set_report_severity_override代码
    ~~~
    UVM_WARNING my_driver.sv(29) @ 1100000: uvm_test_top.env.i_agt.drv [my_driver]this information is warni
    ~~~ 
    - 加set_report_severity_override代码后, 效果:UVM_WARNING-->UVM_ERROR
    ~~~
    UVM_ERROR my_driver.sv(29) @ 1100000: uvm_test_top.env.i_agt.drv [my_driver] this information is warnin
    ~~~

#### 4. UVM_ERROR到达一定数量结束仿真
  1. set_report_max_quit_count,UVM_ERROR达到一定数量时结束仿真
  2. get_max_quit_count,用于查询当前的退出阈值,如果返回值为0则表示无论出现多少个,UVM_ERROR都不会退出仿真
  3. 命令行设置，可以在命令行中设置退出阈值
    - 其中第一个参数6表示退出阈值， 而第二个参数NO表示此值是不可以被后面的设置语句重载， 其值还可以是YES。
        ~~~
        <sim command> +UVM_MAX_QUIT_COUNT=6,NO
        ~~~
  5. eg:
        ~~~
        //src/ch3/section3.4/3.4.3/base_test.sv
        function void base_test::build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = my_env::type_id::create("env", this);
            set_report_max_quit_count(5);
        endfunction
        ~~~


### 2. 经验总结

### 3. 传送门
