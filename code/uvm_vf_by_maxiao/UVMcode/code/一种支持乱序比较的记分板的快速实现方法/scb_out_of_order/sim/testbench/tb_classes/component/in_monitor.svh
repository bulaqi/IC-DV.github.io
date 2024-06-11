
class in_monitor extends uvm_monitor;
   `uvm_component_utils(in_monitor)

   virtual demo_interface vif;
   uvm_analysis_port #(in_trans) ap;

   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(virtual demo_interface)::get(null, "*","vif", vif))
	      `uvm_fatal("COMMAND MONITOR", "Failed to get intf")
      ap  = new("ap",this);
   endfunction : build_phase

   virtual task run_phase(uvm_phase phase);
    in_trans tr;

    forever begin
      @(vif.mon);
      if(vif.mon.vld_i)begin
        tr = new("tr");
        tr.vld_i = vif.mon.vld_i;
        ap.write(tr);
        `uvm_info("IN MONITOR",$sformatf("in trans is %s",tr.convert2string),UVM_LOW)
      end
    end
   endtask

endclass : in_monitor
