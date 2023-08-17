### 1. uvm_do宏
   1. 创建一个my_transaction的实例m_trans；
   2. 将其随机化；
   3. 最终将其送给sequencer。 

~~~
class my_sequence extends uvm_sequence #(my_transaction);
   my_transaction m_trans;

   function new(string name= "my_sequence");
      super.new(name);
   endfunction

   virtual task body();
      repeat (10) begin
         `uvm_do(m_trans)
      end
      #1000;
   endtask

   `uvm_object_utils(my_sequence)
endclass
~~~

### 2. uvm_do 宏的替换方案1:uvm_create + randomize + uvm_send
~~~
...
         `uvm_create(m_trans)
         assert(m_trans.randomize());
         p_sz = m_trans.pload.size();
         {m_trans.pload[p_sz - 4], 
          m_trans.pload[p_sz - 3], 
          m_trans.pload[p_sz - 2], 
          m_trans.pload[p_sz - 1]} 
          = num; 
         `uvm_send(m_trans)
...
~~~

### 3. uvm_do 宏的替换方案2: start_item与finish_item
- 不使用宏产生transaction的方式要依赖于两个任务： start_item和finish_item。
- 在使用这两个任务前， 必须要先实例化transaction后才可以调用这两个任务：
~~~
   virtual task body();
      my_transaction tr;
      if(starting_phase != null) 
         starting_phase.raise_objection(this);
      repeat (10) begin
         tr = new("tr");   //替代`uvm_create
         assert(tr.randomize() with {tr.pload.size == 200;});  //替代randomize
         start_item(tr);     //替代`uvm_send  
         finish_item(tr);
      end
      #100;
      if(starting_phase != null) 
         starting_phase.drop_objection(this);
   endtask
~~~


