
class bus_sequencer extends uvm_sequencer #(bus_transaction);
    `uvm_component_utils(bus_sequencer)

    reg_model reg_model_h;

    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction
endclass

