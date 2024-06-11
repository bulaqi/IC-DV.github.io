
class bus_sequence extends uvm_sequence #(bus_transaction);
   `uvm_object_utils(bus_sequence)
   `uvm_declare_p_sequencer(bus_sequencer)

   function new(string name = "bus_sequence");
      super.new(name);
   endfunction : new

   task body();
        uvm_status_e status;
        uvm_reg_data_t value;

        for(int i=0;i<10;i++)begin
          p_sequencer.reg_model_h.mem_h.write(status, i, 16'h1111*i, UVM_BACKDOOR);
          `uvm_info("BUS SEQ",$sformatf("Write mem[%0d] -> %4h Completed!",i,16'h1111*i), UVM_MEDIUM)
          p_sequencer.reg_model_h.mem_h.read(status, i, value, UVM_BACKDOOR);
          `uvm_info("BUS SEQ", $sformatf("Read mem[%0d] value is %4h",i,value), UVM_MEDIUM)
        end

   endtask : body
endclass : bus_sequence











