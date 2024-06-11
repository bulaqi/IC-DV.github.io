
class bus_sequence extends uvm_sequence #(bus_transaction);
   `uvm_object_utils(bus_sequence)
   `uvm_declare_p_sequencer(bus_sequencer)

   function new(string name = "bus_sequence");
      super.new(name);
   endfunction : new

   task body();
        uvm_status_e status;
        uvm_reg_data_t value;

        //access regA~C 
        p_sequencer.reg_model_h.reg_A_h.write(status, 16'h1111,UVM_FRONTDOOR);
        p_sequencer.reg_model_h.reg_A_h.read(status, value,UVM_FRONTDOOR);
        `uvm_info("BUS SEQ", $sformatf("reg_A value is %4h", value),UVM_MEDIUM)
        p_sequencer.reg_model_h.reg_B_h.write(status, 16'h2222,UVM_FRONTDOOR);
        p_sequencer.reg_model_h.reg_B_h.read(status, value,UVM_FRONTDOOR);
        `uvm_info("BUS SEQ", $sformatf("reg_B value is %4h", value),UVM_MEDIUM)
        p_sequencer.reg_model_h.reg_C_h.write(status, 16'h3333,UVM_FRONTDOOR);
        p_sequencer.reg_model_h.reg_C_h.read(status, value,UVM_FRONTDOOR);
        `uvm_info("BUS SEQ", $sformatf("reg_C value is %4h", value),UVM_MEDIUM)

        //change reg map state
        p_sequencer.reg_model_h.reg_state_h.write(status, 16'h1,UVM_FRONTDOOR);
        p_sequencer.reg_model_h.reg_state_h.read(status, value,UVM_FRONTDOOR);
        `uvm_info("BUS SEQ", $sformatf("reg_state value is %4h", value),UVM_MEDIUM)

        //re map reg model
        p_sequencer.reg_model_h.re_map(0);

        //access regA~C again
        p_sequencer.reg_model_h.reg_A_h.write(status, 16'h4444,UVM_FRONTDOOR);
        p_sequencer.reg_model_h.reg_A_h.read(status, value,UVM_FRONTDOOR);
        `uvm_info("BUS SEQ", $sformatf("reg_A value is %4h", value),UVM_MEDIUM)
        p_sequencer.reg_model_h.reg_B_h.write(status, 16'h5555,UVM_FRONTDOOR);
        p_sequencer.reg_model_h.reg_B_h.read(status, value,UVM_FRONTDOOR);
        `uvm_info("BUS SEQ", $sformatf("reg_B value is %4h", value),UVM_MEDIUM)
        p_sequencer.reg_model_h.reg_C_h.write(status, 16'h6666,UVM_FRONTDOOR);
        p_sequencer.reg_model_h.reg_C_h.read(status, value,UVM_FRONTDOOR);
        `uvm_info("BUS SEQ", $sformatf("reg_C value is %4h", value),UVM_MEDIUM)
   endtask : body
endclass : bus_sequence











