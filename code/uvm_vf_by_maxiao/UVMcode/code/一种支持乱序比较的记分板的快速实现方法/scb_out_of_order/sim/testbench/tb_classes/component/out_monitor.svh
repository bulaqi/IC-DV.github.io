
class out_monitor extends uvm_monitor;
   `uvm_component_utils(out_monitor)

   virtual demo_interface vif;
   uvm_analysis_port #(out_trans) ap;

   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(virtual demo_interface)::get(null, "*","vif", vif))
	      `uvm_fatal("RESULT MONITOR", "Failed to get intf")
      ap  = new("ap",this);
   endfunction : build_phase

   virtual task run_phase(uvm_phase phase);
    out_trans tr;

    forever begin
      @(vif.mon);
      if(vif.mon.vld_o)begin
        tr = new("tr");
        tr.vld_o = vif.mon.vld_o;
        tr.result = vif.mon.result;
        ap.write(tr);
        `uvm_info("OUT MONITOR",$sformatf("out trans is %s",tr.convert2string),UVM_LOW)
      end
    end
   endtask
   
endclass : out_monitor






