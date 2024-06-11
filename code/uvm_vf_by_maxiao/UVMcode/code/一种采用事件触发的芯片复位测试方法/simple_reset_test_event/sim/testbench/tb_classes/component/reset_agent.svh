
class reset_agent extends uvm_agent;
    `uvm_component_utils(reset_agent)
    
    reset_sequencer sequencer_h;
    reset_driver    driver_h;
    reset_monitor   monitor_h;
    
    function new (string name, uvm_component parent);
       super.new(name,parent);
    endfunction : new  
    
    function void build_phase(uvm_phase phase);
       //stimulus
       if (is_active == UVM_ACTIVE) begin
          sequencer_h  = reset_sequencer::type_id::create("sequencer_h",this);
          driver_h     = reset_driver::type_id::create("driver_h",this);
       end
       //monitors
          monitor_h = reset_monitor::type_id::create("monitor_h",this);
    endfunction : build_phase
    
    function void connect_phase(uvm_phase phase);
       if (is_active == UVM_ACTIVE) begin
       //connect driver & sequencer
            driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
       end
    endfunction : connect_phase
endclass : reset_agent

