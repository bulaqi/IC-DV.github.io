
class bus_driver extends uvm_driver #(bus_transaction);
   `uvm_component_utils(bus_driver)
   virtual simple_bus_bfm bus_bfm;
 
   function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(virtual simple_bus_bfm)::get(null, "*","bus_bfm", bus_bfm))
        `uvm_fatal("BUS DRIVER", "Failed to get BFM")
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      forever begin
         bit[15:0] rd_data;

         seq_item_port.get_next_item(req);
         bus_bfm.send_op(req.wr_data, req.addr, req.bus_op, rd_data);
         req.rd_data = rd_data;
         seq_item_port.item_done();
      end
   endtask : run_phase
   
   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new
endclass : bus_driver


