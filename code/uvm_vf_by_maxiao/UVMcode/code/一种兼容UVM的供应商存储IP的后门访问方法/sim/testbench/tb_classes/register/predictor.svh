class predictor extends uvm_reg_predictor #(bus_transaction);
   `uvm_component_utils(predictor)

   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new
endclass
