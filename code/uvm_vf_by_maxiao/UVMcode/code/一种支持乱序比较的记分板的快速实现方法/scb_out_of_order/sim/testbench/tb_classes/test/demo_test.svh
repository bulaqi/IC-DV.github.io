
class demo_test extends base_test;
   `uvm_component_utils(demo_test)

   random_sequence random_seq;
      
   function new(string name, uvm_component parent);
      super.new(name,parent);
      random_seq = random_sequence::type_id::create("random_seq");
   endfunction : new

   task main_phase(uvm_phase phase);
      phase.raise_objection(this);
   	  random_seq.start(env_h.agent_h.sequencer_h);
      #100;
      phase.drop_objection(this);
   endtask

endclass


