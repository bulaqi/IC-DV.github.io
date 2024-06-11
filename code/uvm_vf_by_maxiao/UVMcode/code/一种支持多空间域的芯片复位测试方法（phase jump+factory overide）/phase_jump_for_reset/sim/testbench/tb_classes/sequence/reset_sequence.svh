
class reset_sequence extends uvm_sequence #(sequence_item);
   `uvm_object_utils(reset_sequence)
   reset_item t;

   function new(string name = "reset");
      super.new(name);
   endfunction : new

   task body();
    t = reset_item::type_id::create("t");
    start_item(t);
    assert(t.randomize());
    finish_item(t);
   endtask : body

endclass : reset_sequence












