
class driver#(int addr_i_width = 8,data_i_width = 16,addr_o_width = 8,data_o_width = 16) extends uvm_driver #(in_trans#(addr_i_width,data_i_width));
   `uvm_component_param_utils(driver#(addr_i_width,data_i_width,addr_o_width,data_o_width))
   virtual demo_interface#(addr_i_width,data_i_width,addr_o_width,data_o_width) vif;
 
   function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(virtual demo_interface#(addr_i_width,data_i_width,addr_o_width,data_o_width))::get(null, "*","vif", vif))
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


