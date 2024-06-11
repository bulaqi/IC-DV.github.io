
class env extends uvm_env;
   `uvm_component_utils(env)

   agent         agent_h;
   reset_agent   reset_agent_h;
   scoreboard    scoreboard_h;
   bus_agent     bus_agent_h;

   uvm_tlm_analysis_fifo #(sequence_item) command_mon_cov_fifo;
   uvm_tlm_analysis_fifo #(sequence_item) command_mon_scb_fifo;
   uvm_tlm_analysis_fifo #(result_transaction) result_mon_scb_fifo;

   function void build_phase(uvm_phase phase);
      agent_h   = agent::type_id::create ("agent_h",this);
      agent_h.is_active = UVM_ACTIVE;
      reset_agent_h   = reset_agent::type_id::create ("reset_agent_h",this);
      reset_agent_h.is_active = UVM_ACTIVE;
      bus_agent_h   = bus_agent::type_id::create ("bus_agent_h",this);
      bus_agent_h.is_active = UVM_ACTIVE;

   //analysis
      scoreboard_h = scoreboard::type_id::create("scoreboard_h",this);
   //fifos
      command_mon_cov_fifo = new("command_mon_cov_fifo",this);
      command_mon_scb_fifo = new("command_mon_scb_fifo",this);
      result_mon_scb_fifo = new("result_mon_scb_fifo",this);
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
        agent_h.cmd_ap.connect(command_mon_cov_fifo.analysis_export);

        agent_h.cmd_ap.connect(command_mon_scb_fifo.analysis_export);
        scoreboard_h.cmd_port.connect(command_mon_scb_fifo.blocking_get_export);

        agent_h.result_ap.connect(result_mon_scb_fifo.analysis_export);
        scoreboard_h.result_port.connect(result_mon_scb_fifo.blocking_get_export);
   endfunction : connect_phase

   function void end_of_elaboration_phase(uvm_phase phase);
        scoreboard_h.set_report_verbosity_level_hier(UVM_HIGH);
        agent_h.set_report_verbosity_level_hier(UVM_MEDIUM);
   endfunction

   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new

endclass

class env_for_reset extends env;
   `uvm_component_utils(env_for_reset)

    task main_phase(uvm_phase phase);
      super.main_phase(phase);
      phase.raise_objection(this);
      send_traffic_and_wait_complete();
      #1000ns;
      phase.drop_objection(this);
    endtask

    task send_traffic_and_wait_complete();
      int traffic_item_num;

      //send traffic
      random_sequence random_seq = random_sequence::type_id::create("random_seq");
      std::randomize(traffic_item_num) with {traffic_item_num >= 100;traffic_item_num <= 300;};
      `uvm_info(this.get_name(),$sformatf("send_traffic_and_wait_complete_a -> traffic item num is %0d",traffic_item_num),UVM_LOW)
      random_seq.item_num = traffic_item_num;
      random_seq.start(agent_h.sequencer_h);
      //wait rtl complete
      wait(scoreboard_h.item_num == traffic_item_num);
    endtask

   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new

endclass
   
class top_env extends uvm_env;
   `uvm_component_utils(top_env)
   env       env_h_a;
   env       env_h_b;
   uvm_domain new_domain;

   reg_model reg_model_h_a;
   adapter adapter_h_a;
   predictor predictor_h_a;

   reg_model reg_model_h_b;
   adapter adapter_h_b;
   predictor predictor_h_b;
   
   function void build_phase(uvm_phase phase);
      env_h_a = env::type_id::create("env_h_a",this);
      env_h_b = env::type_id::create("env_h_b",this);
      new_domain = new("new_domain");
      env_h_b.set_domain(new_domain,1);

      reg_model_h_a  = reg_model::type_id::create ("reg_model_h_a");
      reg_model_h_a.configure();
      reg_model_h_a.build();
      reg_model_h_a.lock_model();
      reg_model_h_a.reset();
      adapter_h_a   = adapter::type_id::create ("adapter_h_a");
      predictor_h_a   = predictor::type_id::create ("predictor_h_a",this);

      reg_model_h_b  = reg_model::type_id::create ("reg_model_h_b");
      reg_model_h_b.configure();
      reg_model_h_b.build();
      reg_model_h_b.lock_model();
      reg_model_h_b.reset();
      adapter_h_b   = adapter::type_id::create ("adapter_h_b");
      predictor_h_b   = predictor::type_id::create ("predictor_h_b",this);
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
        reg_model_h_a.default_map.set_sequencer(env_h_a.bus_agent_h.sequencer_h, adapter_h_a);
        predictor_h_a.map = reg_model_h_a.default_map;
        predictor_h_a.adapter = adapter_h_a;
        env_h_a.bus_agent_h.bus_trans_ap.connect(predictor_h_a.bus_in);

        reg_model_h_b.default_map.set_sequencer(env_h_b.bus_agent_h.sequencer_h, adapter_h_b);
        predictor_h_b.map = reg_model_h_b.default_map;
        predictor_h_b.adapter = adapter_h_b;
        env_h_b.bus_agent_h.bus_trans_ap.connect(predictor_h_b.bus_in);
   endfunction : connect_phase

   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new
endclass
