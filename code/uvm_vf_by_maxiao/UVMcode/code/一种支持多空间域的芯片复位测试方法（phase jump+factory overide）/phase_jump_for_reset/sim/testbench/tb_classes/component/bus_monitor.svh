
class bus_monitor extends uvm_monitor;
   `uvm_component_utils(bus_monitor)

   virtual simple_bus_bfm bus_bfm;

   uvm_analysis_port #(bus_transaction) ap;

   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(virtual simple_bus_bfm)::get(this, "","bus_bfm", bus_bfm))
	    `uvm_fatal("BUS MONITOR", "Failed to get BFM")
      ap  = new("ap",this);
   endfunction : build_phase

   task run_phase(uvm_phase phase);
     bus_transaction bus_trans;

     forever begin
      @(bus_bfm.mon);
      if(bus_bfm.mon.bus_valid)begin
        bus_trans = new("bus_trans");
        case(op2enum(bus_bfm.mon.bus_op))
          bus_rd: begin
            bus_trans.bus_op = op2enum(bus_bfm.mon.bus_op);
            bus_trans.addr = bus_bfm.mon.bus_addr;
            bus_trans.wr_data = bus_bfm.mon.bus_wr_data;
            @(bus_bfm.mon);
            bus_trans.rd_data = bus_bfm.mon.bus_rd_data;
          end
          bus_wr: begin
            bus_trans.bus_op = op2enum(bus_bfm.mon.bus_op);
            bus_trans.addr = bus_bfm.mon.bus_addr;
            bus_trans.wr_data = bus_bfm.mon.bus_wr_data;
            bus_trans.rd_data = bus_bfm.mon.bus_rd_data;
          end
        endcase
        ap.write(bus_trans);
        //`uvm_info("BUS MONITOR",bus_trans.convert2string(), UVM_MEDIUM);
      end
     end
   endtask

   function bus_op_t op2enum(logic bus_op);
     case(bus_op)
       1'b0 : return bus_rd;
       1'b1 : return bus_wr;
     endcase
   endfunction
endclass : bus_monitor
