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

#### 4.uvm_event相关function/task
1. uvm_event主要有三类function:
~~~
1. trigger函数： 如trigger(), get_trigger_data(), get_trigger_time()等,
2. 状态函数： is_on(),is_off(),reset(), get_num_waiters()等),
3. callback函数： add_callback(), delete_callback()等
~~~
2. 常用函数列举
~~~
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
~~~

##### 5. uvm_event_pool
1. 不同的组件可以共享同一个uvm_event，这不需要通过跨层次传递uvm_event对象句柄来实现共享的，因为这并不符合组件环境封闭的原则。这种共享同一个uvm_event对象是通过uvm_event_pool这一全局资源池来实现的。

2. uvm_event_pool这个资源池类是uvm_object_string_pool #(T)的子类，它可以生成和获取通过字符串来索引的uvm_event对象。通过全局资源池对象（唯一的），在环境中任何一个地方的组件都可以从资源池中获取共同的对象，这就避免了组件之间的互相依赖。

##### 5. uvm_event_callback  
1. 可以从uvm_event_callback进行类的派生,并实现pre_trigger与post_trigger函数,之后将该派生类通过add_callback函数添加到uvm_event中;

2. pre_trigger()有返回值，如果返回值为1，则表示uvm_event不会被trigger，也不会再执行post_trigger()方法；如果返回值为0，则会继续trigger该事件对象。

3. 对于uvm_event的callback而言,不用采用示例2中通用的callback机制方法,可以直接使用uvm_event已经实现好的函数(如add_callback等);
4. eg1
~~~
//示例1
class edata extends uvm_object;
    `uvm_object_utils(edata)
    int data;
    ...
endclass

class ecb extends uvm_event_callback;
    `uvm_object_utils(ecb)
    ...
    function bit pre_trigger(uvm_event e, uvm_object data=null);
        `uvm_info("EPRETRIG",$sformatf("before trigger event %s", e.get_name()),UVM_NONE)
        return 0;
    endfunction

    function void post_trigger();
        `uvm_info("EPOSTTRIG",$sformatf("after trigger event %s", e.get_name()),UVM_NONE)
    endfunction
endclass

class comp1 extends uvm_component;
    `uvm_component_utils(comp1)
    uvm_event e1;
    ...
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        e1=uvm_event_pool::get_global("e1");
    endfunction

    task run_phase(uvm_phase phase);
        edata d=new();
        ecb  cb=new();
        d.data=100;
        #10ns;
        e1.add_callback(cb);
        e1.trigger(d);
    endtask
endclass

class comp2 extends uvm_component;
    `uvm_component_utils(comp2)
    uvm_event e1;
    ...
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        e1=uvm_event_pool::get_global("e1");
    endfunction

    task run_phase(uvm_phase phase);
        uvm_object tmp;
        edata d;
        e1.wait_trigger_data(tmp);
        void'($cast(d,tmp));
    endtask
endclass

class env1 extends uvm_env;
    comp1 c1;
    comp2 c2;
    ...
endclass
~~~

4. eg2
~~~
//示例2
//step1.create event callback class;
class int_event_callbacks extends uvm_event_callback;
    function new(string name="int_event_callbacks");
        super.new(name);
    endfunction

    virtual function bit pre_trigger(uvm_event e, uvm_object data=null);
        `uvm_info("UVM_EVENT_CALLBACK",$sformatf("UVM EVENT pre_trigger callback triggered"),UVM_LOW)
    endfunction

    virtual function void post_trigger(uvm_event e, uvm_object data=null);
        `uvm_info("UVM_EVENT_CALLBACK",$sformatf("UVM EVENT post_trigger callback triggered"),UVM_LOW)
    endfunction
endclass

//step2.instantiate callback class;
typedef uvm_callbacks #(uvm_event, int_event_callbacks) cbs;
int_event_callbacks interrupt_event_cbk=new("interrupt_event_cbk");

//step3.register callback class;
uvm_config_db#(uvm_event)::set(null,"","transmit_b",transmit_barrier_ev);
cbs::add(transmit_barrier_ev, interrupt_event_cbk);
~~~

### 2. UVM_event扩展,示例说明
#### 1. 基础uvm_event 举例
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



### 3. 传送门
1. [uvm通信-uvm_event & uvm_event_pool & uvm_event_callback](https://www.cnblogs.com/csjt/p/15561286.html)
1. [uvm_event的使用总结](https://blog.csdn.net/zyj0oo0/article/details/120264318)
2. [事件.pptx](https://github.com/bulaqi/IC-DV.github.io/files/12486444/default.pptx)
   
