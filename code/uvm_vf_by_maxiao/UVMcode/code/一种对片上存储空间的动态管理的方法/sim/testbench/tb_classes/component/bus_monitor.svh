
class bus_monitor extends uvm_monitor;
   `uvm_component_utils(bus_monitor)

   virtual simple_bus_bfm bus_bfm;

   uvm_analysis_port #(bus_transaction) ap;

   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(virtual simple_bus_bfm)::get(null, "*","bus_bfm", bus_bfm))
	    `uvm_fatal("BUS MONITOR", "Failed to get BFM")
      bus_bfm.bus_monitor_h = this;
      ap  = new("ap",this);
   endfunction : build_phase

   function void write_to_monitor(bus_op_t bus_op, bit[15:0] bus_addr, bit[15:0] bus_wr_data);
     bus_transaction bus_trans;
     bus_trans = new("bus_trans");
     bus_trans.bus_op = bus_op;
     bus_trans.addr = bus_addr;
     bus_trans.wr_data = bus_wr_data;
     ap.write(bus_trans);
     `uvm_info("BUS MONITOR",bus_trans.convert2string(), UVM_MEDIUM);
   endfunction : write_to_monitor
endclass : bus_monitor
