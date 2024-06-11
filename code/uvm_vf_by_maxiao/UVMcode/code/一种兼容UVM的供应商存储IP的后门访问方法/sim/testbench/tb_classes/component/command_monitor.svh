
class command_monitor extends uvm_monitor;
   `uvm_component_utils(command_monitor)

   virtual tinyalu_bfm bfm;

   uvm_analysis_port #(sequence_item) ap;

   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(virtual tinyalu_bfm)::get(null, "*","bfm", bfm))
	    `uvm_fatal("COMMAND MONITOR", "Failed to get BFM")
      ap  = new("ap",this);
   endfunction : build_phase

   task run_phase(uvm_phase phase);
     sequence_item cmd;

     forever begin
      @(bfm.mon);
      if(bfm.mon.done)begin
        cmd = new("cmd");
        cmd.op = op2enum(bfm.mon.op);
        cmd.A = bfm.mon.A;
        cmd.B = bfm.mon.B;
        ap.write(cmd);
        `uvm_info("COMMAND MONITOR",cmd.convert2string(), UVM_MEDIUM);
      end
     end
   endtask

   function operation_t op2enum(logic[2:0] op);
     case(op)
             3'b000 : return no_op;
             3'b001 : return add_op;
             3'b010 : return and_op;
             3'b011 : return xor_op;
             3'b100 : return mul_op;
             3'b111 : return rst_op;
     endcase
   endfunction

endclass : command_monitor
