
class sequencer#(int addr_i_width = 8,data_i_width = 16) extends uvm_sequencer #(in_trans#(addr_i_width,data_i_width));
    `uvm_component_param_utils(sequencer#(addr_i_width,data_i_width))

    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction
endclass

