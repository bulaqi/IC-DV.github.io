
class driver extends uvm_driver #(sequence_item);
   `uvm_component_utils(driver)
   virtual tinyalu_bfm bfm;
 
   function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(virtual tinyalu_bfm)::get(null, "*","bfm", bfm))
        `uvm_fatal("DRIVER", "Failed to get BFM")
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      forever begin : cmd_loop
         shortint unsigned result;
         seq_item_port.get_next_item(req);
         bfm.send_op(req.A, req.B, req.op, result);
         req.result = result;
         seq_item_port.item_done();
      end : cmd_loop
   endtask : run_phase
   
   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new
endclass : driver


