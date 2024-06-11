
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
     result_transaction result_t;

     forever begin
      @(bfm.mon);
      if(bfm.mon.done)begin
        result_t = new("result_t");
        result_t.result = bfm.mon.result;
        ap.write(result_t);
        `uvm_info("RESULT MONITOR",$sformatf("MONITOR: result: %h",result_t.result),UVM_HIGH);
      end
     end
   endtask

endclass : result_monitor






