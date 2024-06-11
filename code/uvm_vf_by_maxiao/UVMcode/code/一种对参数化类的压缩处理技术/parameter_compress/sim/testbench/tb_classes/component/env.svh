
class env extends uvm_env;
  `uvm_component_utils(env)
  
  agent#(8,16,8,16)         agent_h;
  
  uvm_algorithmic_comparator #(in_trans#(8,16), out_trans#(8,16), transformer) comparator;
  transformer transf;
  
  function void build_phase(uvm_phase phase);
    agent_h   = agent#(8,16,8,16)::type_id::create ("agent_h",this);
    agent_h.is_active = UVM_ACTIVE;
    
    transf = new("transf",this);
    comparator = new("comparator",this, transf);
    comparator.cfg_comparator_mode(UVM_COMPARATOR_OUT_OF_ORDER);
  endfunction : build_phase
  
  function void connect_phase(uvm_phase phase);
    agent_h.in_ap.connect(comparator.before_export);
    agent_h.out_ap.connect(comparator.after_export);
  endfunction : connect_phase
  
  function new (string name, uvm_component parent);
    super.new(name,parent);
  endfunction : new

endclass
   
   
