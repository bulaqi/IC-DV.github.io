
class base_test extends uvm_test;
   `uvm_component_utils(base_test)
   env       env_h;
   
   function void build_phase(uvm_phase phase);
      env_h = env::type_id::create("env_h",this);
   endfunction : build_phase

   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new
endclass
   
   
   
