
class random_sequence extends uvm_sequence #(in_trans);
   `uvm_object_utils(random_sequence)
   
   in_trans tr;

   function new(string name = "random_sequence");
      super.new(name);
   endfunction : new

   virtual task body();
      repeat (10) begin
         tr = in_trans::type_id::create("tr");
         tr.vld_i = 1;
         start_item(tr);
         finish_item(tr);
         `uvm_info("RANDOM SEQ", $sformatf("random tr: %s", tr.convert2string), UVM_LOW)
      end 
      repeat (10) begin
         tr = in_trans::type_id::create("tr");
         start_item(tr);
         assert(tr.randomize());
         finish_item(tr);
         `uvm_info("RANDOM SEQ", $sformatf("random tr: %s", tr.convert2string), UVM_LOW)
      end 
   endtask : body
endclass : random_sequence











