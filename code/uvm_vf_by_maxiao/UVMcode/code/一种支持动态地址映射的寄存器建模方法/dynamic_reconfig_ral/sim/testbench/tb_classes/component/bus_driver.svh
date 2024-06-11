
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

      seq_item_port.try_next_item(req);
      if(req!=null)begin
        bus_bfm.send_op(req,rd_data);
        req.rd_data = rd_data;
        `uvm_info(this.get_name(),$sformatf("drive bus item is %s",req.convert2string),UVM_LOW)
        seq_item_port.item_done();
      end
      else begin
        @(bus_bfm.drv)
        bus_bfm.init();
      end
    end
  endtask : run_phase
   
   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new
endclass : bus_driver


