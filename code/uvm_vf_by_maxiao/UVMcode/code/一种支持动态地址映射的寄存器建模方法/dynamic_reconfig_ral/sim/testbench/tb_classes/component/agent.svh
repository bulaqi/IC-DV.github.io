
class agent extends uvm_agent;
    `uvm_component_utils(agent)
    
    sequencer sequencer_h;
    driver          driver_h;
    command_monitor command_monitor_h;
    result_monitor  result_monitor_h;
    
    uvm_analysis_port #(sequence_item) cmd_ap;
    uvm_analysis_port #(result_transaction) result_ap;

    function new (string name, uvm_component parent);
       super.new(name,parent);
    endfunction : new  
    
    function void build_phase(uvm_phase phase);
       //stimulus
       if (is_active == UVM_ACTIVE) begin
          sequencer_h  = sequencer::type_id::create("sequencer_h",this);
          driver_h     = driver::type_id::create("driver_h",this);
       end
       //monitors
          command_monitor_h   = command_monitor::type_id::create("command_monitor_h",this);
          result_monitor_h = result_monitor::type_id::create("result_monitor_h",this);
    endfunction : build_phase
    
    function void connect_phase(uvm_phase phase);
       if (is_active == UVM_ACTIVE) begin
       //connect driver & sequencer
            driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
       end
    
       cmd_ap=command_monitor_h.ap;      
       result_ap=result_monitor_h.ap;      
    
    endfunction : connect_phase

endclass : agent

