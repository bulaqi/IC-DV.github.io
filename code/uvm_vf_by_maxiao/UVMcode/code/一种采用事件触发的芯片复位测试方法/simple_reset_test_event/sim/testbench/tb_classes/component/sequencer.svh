
class sequencer extends uvm_sequencer #(sequence_item);
   `uvm_component_utils(sequencer)
   virtual tinyalu_bfm bfm;

   function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(virtual tinyalu_bfm)::get(null, "*","bfm", bfm))
        `uvm_fatal("DRIVER", "Failed to get BFM")
   endfunction : build_phase

  task run_phase(uvm_phase phase);
    forever begin
      bfm.wait_rst_active();
      stop_sequences();
      bfm.wait_rst_release();
    end
  endtask : run_phase

    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction
endclass

