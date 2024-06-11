
class mem_bdr extends uvm_reg_backdoor;
    `uvm_object_utils(mem_bdr)

    virtual mem_bdr_intf vif;
    
    function new(string name = "mem_bdr");
        super.new(name);
        if(!uvm_config_db#(virtual mem_bdr_intf)::get(null,"","mem_bdr_intf",vif))
          `uvm_fatal(this.get_name(),$sformatf("Failed to get mem_bdr_intf! Please check!"))
    endfunction

    task write(uvm_reg_item rw);
        //bit ok;
        //backdoor write hdl path
        //ok = uvm_hdl_deposit($sformatf("top.DUT.mem.data[%0d]",rw.offset), rw.value[0]);
        //assert(ok);
        vif.write_mem(rw.offset,rw.value[0]);
        rw.status = UVM_IS_OK;
    endtask

    task read(uvm_reg_item rw);
        //bit ok;
        //backdoor read hdl path
        //ok = uvm_hdl_read($sformatf("top.DUT.mem.data[%0d]",rw.offset), rw.value[0]);
        //assert(ok);
        vif.read_mem(rw.offset,rw.value[0]);
        rw.status = UVM_IS_OK;
    endtask

endclass

