
class virtual_sequence_test extends base_test;
   `uvm_component_utils(virtual_sequence_test)

   virtual_sequence virtual_sequence_h;
      
   function new(string name, uvm_component parent);
      super.new(name,parent);
      virtual_sequence_h = virtual_sequence::type_id::create("virtual_sequence_h");
   endfunction : new

   function void connect_phase(uvm_phase phase);
        virtual_sequence_h.sequencer_h = env_h.agent_h.sequencer_h;
        virtual_sequence_h.bus_sequencer_h = env_h.bus_agent_h.sequencer_h;
        env_h.scoreboard_h.reg_model_h = env_h.reg_model_h;
   endfunction

   task main_phase(uvm_phase phase);
      phase.raise_objection(this);
      virtual_sequence_h.start(null);
      phase.drop_objection(this);
   endtask

endclass


