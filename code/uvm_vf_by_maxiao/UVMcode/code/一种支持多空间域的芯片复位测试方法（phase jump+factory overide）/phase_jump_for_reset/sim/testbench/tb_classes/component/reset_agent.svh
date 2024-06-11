
class reset_agent extends uvm_agent;
    `uvm_component_utils(reset_agent)
    
    reset_sequencer sequencer_h;
    reset_driver    driver_h;
    reset_monitor   monitor_h;
    reset_config    config_h;
    int reset_cnt = 0;
    
    function new (string name, uvm_component parent);
       super.new(name,parent);
    endfunction : new  
    
    function void build_phase(uvm_phase phase);
       config_h = reset_config::type_id::create("config_h",this);
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

    task reset_phase(uvm_phase phase);
      phase.raise_objection(this);
       if (is_active == UVM_ACTIVE) begin
          initiate_reset();
       end
      phase.drop_objection(this);
    endtask

    task initiate_reset();
      reset_sequence reset_seq = reset_sequence::type_id::create("reset_seq");
      reset_seq.start(sequencer_h);
      reset_cnt++;
    endtask

  function void phase_ready_to_end(uvm_phase phase);
    super.phase_ready_to_end(phase);
    if(phase.get_imp() == uvm_shutdown_phase::get()) begin
      if (reset_cnt < config_h.reset_num)
        phase.jump(uvm_reset_phase::get());
    end 
  endfunction

endclass : reset_agent

