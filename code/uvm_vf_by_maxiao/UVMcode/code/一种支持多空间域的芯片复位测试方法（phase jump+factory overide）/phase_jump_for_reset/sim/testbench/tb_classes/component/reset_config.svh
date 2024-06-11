
class reset_config extends uvm_object;
   `uvm_object_utils(reset_config)

   int reset_num = 1;

   function new(string name="");
      super.new(name);
   endfunction : new
endclass : reset_config
