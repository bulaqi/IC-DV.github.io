
class out_monitor#(int addr_i_width = 8,data_i_width = 16,addr_o_width = 8,data_o_width = 16) extends uvm_monitor;
   `uvm_component_param_utils(out_monitor#(addr_i_width,data_i_width,addr_o_width,data_o_width))

   virtual demo_interface#(addr_i_width,data_i_width,addr_o_width,data_o_width) vif;
   uvm_analysis_port #(out_trans#(addr_o_width,data_o_width)) ap;

   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(virtual demo_interface#(addr_i_width,data_i_width,addr_o_width,data_o_width))::get(null, "*","vif", vif))
	      `uvm_fatal("RESULT MONITOR", "Failed to get intf")
      ap  = new("ap",this);
   endfunction : build_phase

   virtual task run_phase(uvm_phase phase);
    out_trans#(addr_o_width,data_o_width) tr;

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






