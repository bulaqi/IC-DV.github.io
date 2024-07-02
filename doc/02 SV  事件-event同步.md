### 1.基础知识
#### 1. sv与uvm中同步的方法 
1. 在sv中,用于同步的方法有event, semaphore和mailbox;
2. 在UVM中,用于同步的方法为uvm_event(uvm_event派生于uvm_object);
3.  uvm_event不仅能实现不同组件进程间同步的功能,还能像TLM通信一样传递数据,并且作用范围更广(TLM通信只能局限于uvm_component之间,而uvm_event不限于此);

#### 2.什么情况下会使用uvm_event呢
1. 组件之间的常规的数据流向是通过TLM通信方法实现的，比如sequencer与driver之间，或者monitor与scoreboard之间。
2. 然而有些时候，数据的传输的偶然触发的，并且需要立即响应，这个时候uvm_event就是得力的助手了。
3. uvm_event 解决 uvm_object和uvm_component对象之间如果要发生同步，TLM传输无法实现，因为TLM传输必须是在组件（component）和组件之间进行的。
4. 如果在sequence与sequence之间要进行同步，或者sequence与driver之间要进行同步，都可以借助uvm_event来实现。

#### 3. sv与uvm event 比较
1. uvm_event的基础是event,只不过对event的触发与等待进行了扩展;
2. 触发方式：
   - event被->触发后,会触发用@/wait(event.triggered())等待该事件的对象;
   - uvm_event通过trigger()来触发,会触发使用wait_trigger()/wait_ptrigger()/wait_trigger_data()/wait_ptrigger_data()等待的对象;
3. 如果再次触发事件,
   - event ：只需使用->来触发;
   - uvm_event： 需要先通过reset()方法重置初始状态,再使用trigger()来触发;
4. 是否可以携带信息：
   - event无法携带更多的信息;
   - uvm_event可以通过trigger(uvm_event data=null)的可选参数,将要伴随触发的数据对象都写到该触发事件中,而等待该事件的对象可以通过方法wait_trigger_data(output uvm_object data)来获取事件触发时写入的数据对象;
   - 注1:如果uvm_event.trigger不传递参数,不传递额外的信息,则等待该事件的对象可以调用wait_trigger,而不是wait_trigger_data;
   - 补充：![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/a966d0b7-11f0-4531-aa63-abd9ee979a2d)

5. 触发回调函数：
   - event触发时无法直接触发回调函数;
   - uvm_event可通过add_callback函数来添加回调函数;
6. 获取进程数目：
   - event无法直接获取等待它的进程数目
   - uvm_event可以通过get_num_waiters()来获取等待它的进程数目;

#### 5.uvm_event相关function/task
##### 3.1 uvm_event主要有三类function:
   1. trigger函数： 如trigger(), get_trigger_data(), get_trigger_time()等,
   2. 状态函数： is_on(),is_off(),reset(), get_num_waiters()等),
   3. callback函数： add_callback(), delete_callback()等
##### 3.2 常用函数
1. wait_on
 - 等待事件处于activated状态,如果事件已经被触发,这个task会立即返回;一旦事件被触发,它将一直保持"on"状态直到事件reset;
2. wait_off
   - 如果事件已经被触发,并且处于"on"状态,该task会等待该事件通过调用reset而关掉;
   - 如果事件没有被触发,该task会立即返回;
3. trigger
4. wait_trigger
   - 等待事件被触发;
5. wait_trigger_data
6. wait_ptrigger
7. wait_ptrigger_data
8. reset
9. is_on
10. is_off
11. get_trigger_time


### 3. UVM_event扩展,示例说明
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
1. [uvm通信-uvm_event & uvm_event_pool & uvm_event_callback](https://www.cnblogs.com/csjt/p/15561286.html)
1. [uvm_event的使用总结](https://blog.csdn.net/zyj0oo0/article/details/120264318)
2. [事件.pptx](https://github.com/bulaqi/IC-DV.github.io/files/12486444/default.pptx)
   
