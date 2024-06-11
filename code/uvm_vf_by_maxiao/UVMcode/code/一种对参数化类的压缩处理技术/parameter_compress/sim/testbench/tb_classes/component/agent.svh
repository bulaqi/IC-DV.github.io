
class agent #(int addr_i_width = 8,data_i_width = 16,addr_o_width = 8,data_o_width = 16)extends uvm_agent;
    `uvm_component_param_utils(agent#(addr_i_width,data_i_width,addr_o_width,data_o_width))
    
    sequencer#(addr_i_width,data_i_width)    sequencer_h;
    driver#(addr_i_width,data_i_width,addr_o_width,data_o_width)       driver_h;
    in_monitor#(addr_i_width,data_i_width,addr_o_width,data_o_width)   in_monitor_h;
    out_monitor#(addr_i_width,data_i_width,addr_o_width,data_o_width)  out_monitor_h;
    
    uvm_analysis_port #(in_trans#(addr_i_width,data_i_width))  in_ap;
    uvm_analysis_port #(out_trans#(addr_o_width,data_o_width)) out_ap;

    function new (string name, uvm_component parent);
       super.new(name,parent);
    endfunction : new  
    
    function void build_phase(uvm_phase phase);
       //stimulus
       if (is_active == UVM_ACTIVE) begin
          sequencer_h  = sequencer#(addr_i_width,data_i_width)::type_id::create("sequencer_h",this);
          driver_h     = driver#(addr_i_width,data_i_width,addr_o_width,data_o_width)::type_id::create("driver_h",this);
       end
       //monitors
          in_monitor_h   = in_monitor#(addr_i_width,data_i_width,addr_o_width,data_o_width)::type_id::create("in_monitor_h",this);
          out_monitor_h  = out_monitor#(addr_i_width,data_i_width,addr_o_width,data_o_width)::type_id::create("out_monitor_h",this);
    endfunction : build_phase
    
    function void connect_phase(uvm_phase phase);
       if (is_active == UVM_ACTIVE) begin
       //connect driver & sequencer
            driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
       end
    
       in_ap  = in_monitor_h.ap;      
       out_ap = out_monitor_h.ap;      
    endfunction : connect_phase

endclass : agent

