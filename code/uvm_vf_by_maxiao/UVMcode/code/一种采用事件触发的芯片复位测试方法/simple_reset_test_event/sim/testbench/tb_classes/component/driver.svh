
class driver extends uvm_driver #(sequence_item);
   `uvm_component_utils(driver)
   virtual tinyalu_bfm bfm;
 
   function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(virtual tinyalu_bfm)::get(null, "*","bfm", bfm))
        `uvm_fatal("DRIVER", "Failed to get BFM")
   endfunction : build_phase

  task run_phase(uvm_phase phase);
    forever begin
      fork
        begin
          get_and_drive();
        end
        begin
          bfm.wait_rst_active();
        end
      join_any
      disable fork;
      bfm.init();
      bfm.wait_rst_release();
    end
  endtask : run_phase

  task get_and_drive();
    bit[15:0] result;

    seq_item_port.try_next_item(req);
    if(req!=null)begin
      bfm.send_op(req,result);
      req.result = result;
      seq_item_port.item_done();
    end
    else begin
      @(bfm.drv)
      bfm.init();
    end
  endtask
   
   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new
endclass : driver


