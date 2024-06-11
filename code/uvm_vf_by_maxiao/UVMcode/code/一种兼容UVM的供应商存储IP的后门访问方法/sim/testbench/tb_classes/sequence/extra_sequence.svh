
class extra_sequence extends uvm_sequence #(sequence_item);
   `uvm_object_utils(extra_sequence)
   
   sequence_item command;

   function new(string name = "extra_sequence");
      super.new(name);
   endfunction : new

   task body();
         command = sequence_item::type_id::create("command");
         //add_FF
         start_item(command);
         command.A=8'hff;
         command.B=8'hff;
         command.op=add_op;
         finish_item(command);
         `uvm_info("EXTRA SEQ", $sformatf("random command: %s", command.convert2string), UVM_HIGH)

         //and_FF
         start_item(command);
         command.A=8'hff;
         command.B=8'hff;
         command.op=and_op;
         finish_item(command);
         `uvm_info("EXTRA SEQ", $sformatf("random command: %s", command.convert2string), UVM_HIGH)

         //mul_FF
         start_item(command);
         command.A=8'hff;
         command.op=mul_op;
         finish_item(command);
         `uvm_info("EXTRA SEQ", $sformatf("random command: %s", command.convert2string), UVM_HIGH)

         //mul_max
         start_item(command);
         command.A=8'hff;
         command.B=8'hff;
         command.op=mul_op;
         finish_item(command);
         `uvm_info("EXTRA SEQ", $sformatf("random command: %s", command.convert2string), UVM_HIGH)
   endtask : body
endclass : extra_sequence



