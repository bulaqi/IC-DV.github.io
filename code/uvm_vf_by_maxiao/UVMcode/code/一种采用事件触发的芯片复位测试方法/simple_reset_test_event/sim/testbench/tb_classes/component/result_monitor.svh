
class result_monitor extends uvm_monitor;
   `uvm_component_utils(result_monitor)

   virtual tinyalu_bfm bfm;
   uvm_analysis_port #(result_transaction) ap;

   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
    if(!uvm_config_db #(virtual tinyalu_bfm)::get(null, "*","bfm", bfm))
        `uvm_fatal("RESULT MONITOR", "Failed to get BFM")
      ap  = new("ap",this);
   endfunction : build_phase

   task run_phase(uvm_phase phase);
     forever begin
       fork
         begin
           mon_trans();
         end
         begin
           bfm.wait_rst_active();
         end
       join_any
       disable fork;
       bfm.wait_rst_release();
     end
   endtask

   task mon_trans();
     result_transaction result_t;

     @(bfm.mon);
     if(bfm.mon.done)begin
       result_t = new("result_t");
       result_t.result = bfm.mon.result;
       result_t.is_nop = 0;
       ap.write(result_t);
       `uvm_info("RESULT MONITOR",$sformatf("MONITOR: result: %h",result_t.result),UVM_HIGH);
     end
     if((bfm.mon.op=='d0) && (bfm.mon.start))begin
       result_t = new("result_t");
       result_t.result = 'd0;
       result_t.is_nop = 1;
       ap.write(result_t);
     end
   endtask

endclass : result_monitor






