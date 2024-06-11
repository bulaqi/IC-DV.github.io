
class base_test extends uvm_test;
   `uvm_component_utils(base_test)
   top_env       top_env_h;
   
   function void build_phase(uvm_phase phase);
      top_env_h = top_env::type_id::create("top_env_h",this);
   endfunction : build_phase

   function void end_of_elaboration_phase(uvm_phase phase);
      uvm_top.print_topology();
   endfunction : end_of_elaboration_phase

   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new
endclass
   
   
   
