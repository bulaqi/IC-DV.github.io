### 1.背景
用例dut_cfg完成后，才运行rm 读取dut的配置组件

### 2.说明
1. sv基础用法,在单文件内，可以之间定义event 变量，然后->  @ 触发和等待事件
2. UVM扩展,跨组件事件同步，必须利用env_poll，实现全局变量，具体用法见参考

### 3. UVM扩展,示例说明
1.组件A 定义事件，并触发：
~~~
class my_component extends uvm_comopnent;
 
    ...
    ...
    ...
    uvm_event my_event ;
    
    `uvm_component_utils(my_component)
 
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        my_event = uvm_event_pool::get_global("my_event"); 
    endfunction
 
    task  main_phase(uvm_phase phase);
        ...
        ...
        ...
        set_trigger();     
        ...
        ...
        ...
    endtask
 
    task set_trigger();
        my_event.trigger();
 
    endtask
 
endclass
~~~

2.组件B 等待事件：
~~~
class get_component extends uvm_comopnent;
 
    ...
    ...
    ...
    uvm_event get_my_event ;
    
    `uvm_component_utils(get_component)
 
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        get_my_event = uvm_event_pool::get_global("my_event"); // 此处关联event，特别注意，新建的是要等待的事件，即上述要等待的事件
    endfunction
 
    task  main_phase(uvm_phase phase);
        ...
        ...
        ...
        set_trigger();     
        ...
        ...
        ...
    endtask
 
    task set_trigger();
        ...
        get_my_event.wait_trigger();
        ...
    endtask
 
endclass
~~~
3.补充说明
 通过 my_event = uvm_event_pool::get_global("my_event") 这种方法将my_event 注册到event_pool中；在set_component中将uvm_event放到event_pool中，并设置好触发条件，在get_component中，从uvm_event_pool中取出来，通过wait_trigger捕获这次事件。（这里用component只是作为例子使用，实际上在object中也可以这么做）。


### - 参考
1. [uvm_event的使用总结](https://blog.csdn.net/zyj0oo0/article/details/120264318)
2. [事件.pptx](https://github.com/bulaqi/IC-DV.github.io/files/12486444/default.pptx)
