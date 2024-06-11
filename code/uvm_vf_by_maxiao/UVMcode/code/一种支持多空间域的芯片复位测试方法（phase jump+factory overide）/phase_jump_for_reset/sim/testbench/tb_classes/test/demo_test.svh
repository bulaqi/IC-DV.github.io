
class demo_test extends base_test;
  `uvm_component_utils(demo_test)
  bit traffic_complete = 0;
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
    uvm_top.set_timeout(50000ns,0);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    set_inst_override_by_type("top_env_h.env_h_a", env::get_type(), env_for_reset::get_type());
    set_inst_override_by_type("top_env_h.env_h_b", env::get_type(), env_for_reset::get_type());
  endfunction  
  
  function void connect_phase(uvm_phase phase);
    top_env_h.env_h_a.bus_agent_h.sequencer_h.reg_model_h = top_env_h.reg_model_h_a;
    top_env_h.env_h_a.scoreboard_h.reg_model_h = top_env_h.reg_model_h_a;
    top_env_h.env_h_b.bus_agent_h.sequencer_h.reg_model_h = top_env_h.reg_model_h_b;
    top_env_h.env_h_b.scoreboard_h.reg_model_h = top_env_h.reg_model_h_b;
  endfunction
  
  task configure_phase(uvm_phase phase);
    int reset_num_a;
    int reset_num_b;

    std::randomize(reset_num_a) with {reset_num_a >= 1;reset_num_a <= 3;};
    std::randomize(reset_num_b) with {reset_num_b >= 1;reset_num_b <= 3;};
    top_env_h.env_h_a.reset_agent_h.config_h.reset_num = reset_num_a;
    top_env_h.env_h_b.reset_agent_h.config_h.reset_num = reset_num_b;
  endtask

endclass


