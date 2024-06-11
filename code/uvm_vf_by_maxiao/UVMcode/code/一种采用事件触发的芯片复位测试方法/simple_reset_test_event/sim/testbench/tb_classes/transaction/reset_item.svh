
class reset_item extends uvm_sequence_item;
   `uvm_object_utils(reset_item)

   rand int unsigned pre_rst_duration;
   rand int unsigned rst_duration;

   constraint duration_c {pre_rst_duration < 100;rst_duration < 100;}

   function new(string name="");
      super.new(name);
   endfunction : new
endclass : reset_item
