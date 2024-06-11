
class demo_test extends base_test;
   `uvm_component_utils(demo_test)
   int reset_item_num;
   int traffic_item_num;
   bit traffic_complete = 0;
   int reset_cnt = 0;

   function new(string name, uvm_component parent);
      super.new(name,parent);
      uvm_top.set_timeout(30000ns,0);
   endfunction : new

   function void connect_phase(uvm_phase phase);
        env_h.bus_agent_h.sequencer_h.reg_model_h = env_h.reg_model_h;
        env_h.scoreboard_h.reg_model_h = env_h.reg_model_h;
   endfunction

   task main_phase(uvm_phase phase);
      phase.raise_objection(this);
      initiate_reset();
      std::randomize(reset_item_num) with {reset_item_num >= 3;reset_item_num <= 5;};
      std::randomize(traffic_item_num) with {traffic_item_num >= 100;traffic_item_num <= 300;};
      `uvm_info(this.get_name(),$sformatf("traffic item num is %0d",traffic_item_num),UVM_LOW)
      do begin
        fork
          begin
            if(reset_cnt < reset_item_num)begin
              initiate_reset();
            end
            else begin
              wait(0);
            end
          end
          begin
            send_traffic_and_wait_complete();
          end
        join_any
        disable fork;
      end while(traffic_complete == 0);
      phase.drop_objection(this);
   endtask

   task initiate_reset();
    reset_sequence reset_seq = reset_sequence::type_id::create("reset_seq");
   	reset_seq.start(env_h.reset_agent_h.sequencer_h);
    reset_cnt++;
   endtask

   task send_traffic_and_wait_complete();
    //send traffic
    random_sequence random_seq = random_sequence::type_id::create("random_seq");
    random_seq.item_num = traffic_item_num;
   	random_seq.start(env_h.agent_h.sequencer_h);
    //wait rtl complete
    wait(env_h.scoreboard_h.item_num == traffic_item_num);
    traffic_complete = 1;
   endtask

endclass


