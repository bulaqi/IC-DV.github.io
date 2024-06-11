
class reset_monitor extends uvm_monitor;
   `uvm_component_utils(reset_monitor)

  virtual reset_interface vif;

  uvm_analysis_port #(reset_item) ap;

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(virtual reset_interface)::get(null, "*","reset_bfm", vif))
	    `uvm_fatal("RESET MONITOR", "Failed to get VIF")
      ap  = new("ap",this);
  endfunction

  task run_phase(uvm_phase phase);
     reset_item item;
     int unsigned pre_rst_duration = 0;
     int unsigned rst_duration = 0;
     bit rst_prv;

     @(vif.mon);
     rst_prv = vif.mon.rst;
     forever begin
      @(vif.mon);
      if(vif.mon.rst==0)begin
        rst_duration++;
        pre_rst_duration = 0;
      end
      else begin
        pre_rst_duration++;
        rst_duration = 0;
      end
      if(rst_prv != vif.mon.rst)begin
        item = new("item");
        item.pre_rst_duration = pre_rst_duration;
        item.rst_duration = rst_duration;
        ap.write(item);
      end
     end
  endtask

endclass
