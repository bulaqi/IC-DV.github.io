
class driver extends uvm_driver #(in_trans);
   `uvm_component_utils(driver)
   virtual demo_interface vif;
 
   function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(virtual demo_interface)::get(null, "*","vif", vif))
        `uvm_fatal("DRIVER", "Failed to get VIF")
   endfunction : build_phase

   task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.try_next_item(req);
      if(req!=null)begin
        //`uvm_info(this.get_name(),$sformatf("drive bus item is %s",req.convert2string),UVM_LOW)
        @(vif.drv);
        vif.drv.vld_i <= req.vld_i;
        seq_item_port.item_done();
      end
      else begin
        @(vif.drv);
        vif.init();
      end
    end
   endtask : run_phase
   
   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new
endclass : driver


