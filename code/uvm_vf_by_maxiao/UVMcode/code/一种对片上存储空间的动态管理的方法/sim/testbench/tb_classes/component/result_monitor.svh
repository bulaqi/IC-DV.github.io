
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
      bfm.result_monitor_h = this;
      ap  = new("ap",this);
   endfunction : build_phase

   function void write_to_monitor(shortint r);
      result_transaction result_t;
      result_t = new("result_t");
      result_t.result = r;
      ap.write(result_t);
     `uvm_info("RESULT MONITOR",$sformatf("MONITOR: result: %h",r),UVM_HIGH);
   endfunction : write_to_monitor
   
endclass : result_monitor






