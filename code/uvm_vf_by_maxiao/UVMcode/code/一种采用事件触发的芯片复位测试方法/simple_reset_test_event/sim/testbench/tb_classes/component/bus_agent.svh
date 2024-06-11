
class bus_agent extends uvm_agent;
    `uvm_component_utils(bus_agent)
    
    bus_sequencer       sequencer_h;
    bus_driver          driver_h;
    bus_monitor         monitor_h;
    
    uvm_analysis_port #(bus_transaction) bus_trans_ap;

    function new (string name, uvm_component parent);
       super.new(name,parent);
    endfunction : new  
    
    function void build_phase(uvm_phase phase);
       //stimulus
       if (is_active == UVM_ACTIVE) begin
          sequencer_h  = bus_sequencer::type_id::create("sequencer_h",this);
          driver_h     = bus_driver::type_id::create("driver_h",this);
       end
       //monitors
          monitor_h   = bus_monitor::type_id::create("monitor_h",this);
    endfunction : build_phase
    
    function void connect_phase(uvm_phase phase);
       if (is_active == UVM_ACTIVE) begin
       //connect driver & sequencer
            driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
       end
    
       bus_trans_ap = monitor_h.ap;      
    endfunction : connect_phase

endclass : bus_agent

