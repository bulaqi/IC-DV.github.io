
class reset_driver extends uvm_driver #(reset_item);
   `uvm_component_utils(reset_driver)
   virtual reset_interface bfm;

   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new
 
   function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(virtual reset_interface)::get(this, "","reset_bfm", bfm))
        `uvm_fatal("DRIVER", "Failed to get BFM")
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      forever begin
         seq_item_port.try_next_item(req);
         if(req!=null)begin
          this.drive_bfm(req);
          seq_item_port.item_done();
         end
         else begin
          @(bfm.drv)
          bfm.init();
         end
      end
   endtask : run_phase

  task drive_bfm(REQ req); 
    repeat(req.pre_rst_duration)begin
      @(bfm.drv);
    end
    @(bfm.drv);
    bfm.drv.rst <= 0;
    repeat(req.rst_duration)begin
      @(bfm.drv);
    end
    @(bfm.drv);
    bfm.drv.rst <= 1;
  endtask
endclass : reset_driver


