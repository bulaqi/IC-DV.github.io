
class bus_sequence extends uvm_sequence #(bus_transaction);
   `uvm_object_utils(bus_sequence)
   `uvm_declare_p_sequencer(bus_sequencer)

   function new(string name = "bus_sequence");
      super.new(name);
   endfunction : new

   task body();
        uvm_status_e status;
        uvm_reg_data_t value;

        //p_sequencer.reg_model_h.ctrl_reg_h.write(status, 16'h1, UVM_FRONTDOOR);
        //p_sequencer.reg_model_h.ctrl_reg_h.read(status, value, UVM_FRONTDOOR);
        //p_sequencer.reg_model_h.ctrl_reg_h.write(status, 16'h1,UVM_FRONTDOOR);
        //p_sequencer.reg_model_h.ctrl_reg_h.read(status, value,UVM_FRONTDOOR);
        //`uvm_info("BUS SEQ", $sformatf("ctrl_reg value is %4h", value),UVM_MEDIUM)
        //value = p_sequencer.reg_model_h.ctrl_reg_h.get_mirrored_value();
        //`uvm_info("BUS SEQ", $sformatf("ctrl_reg mirror value is %0h", value),UVM_MEDIUM)

        p_sequencer.reg_model_h.ctrl_reg_h.write(status, 16'h2222,UVM_FRONTDOOR);
        p_sequencer.reg_model_h.ctrl_reg_h.read(status, value,UVM_FRONTDOOR);
        `uvm_info("BUS SEQ", $sformatf("ctrl_reg value is %4h", value),UVM_MEDIUM)
        value = p_sequencer.reg_model_h.ctrl_reg_h.get_mirrored_value();
        `uvm_info("BUS SEQ", $sformatf("ctrl_reg mirror value is %0h", value),UVM_MEDIUM)
   endtask : body
endclass : bus_sequence











