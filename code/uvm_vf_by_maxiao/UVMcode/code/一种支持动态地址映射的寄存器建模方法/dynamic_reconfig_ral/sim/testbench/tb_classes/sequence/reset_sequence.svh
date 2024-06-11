
class reset_sequence extends uvm_sequence #(sequence_item);
   `uvm_object_utils(reset_sequence)
   sequence_item command;

   function new(string name = "reset");
      super.new(name);
   endfunction : new

   task body();
      command = sequence_item::type_id::create("command");
      start_item(command);
      command.op = rst_op;
      finish_item(command);
      `uvm_info("RESET SEQ","Reset completed ! ",UVM_MEDIUM);
   endtask : body
endclass : reset_sequence












