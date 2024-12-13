
class scoreboard extends uvm_scoreboard;
   `uvm_component_utils(scoreboard)
   virtual tinyalu_bfm bfm;

   uvm_blocking_get_port #(sequence_item) cmd_port;
   uvm_blocking_get_port #(result_transaction) result_port;

   reg_model reg_model_h;
   int item_num;

   function new (string name, uvm_component parent);
      super.new(name, parent);
      clean_up();
   endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cmd_port = new("cmd_port",this);
        result_port = new("result_port",this);
        if(!uvm_config_db #(virtual tinyalu_bfm)::get(this, "","bfm", bfm))
          `uvm_fatal("DRIVER", "Failed to get BFM")
    endfunction : build_phase

    function result_transaction predict_result(sequence_item cmd, bit is_invert);
       result_transaction predicted;
       shortint result;
       predicted = new("predicted");
          
       case (cmd.op)
         add_op: result = cmd.A + cmd.B;
         and_op: result = cmd.A & cmd.B;
         xor_op: result = cmd.A ^ cmd.B;
         mul_op: result = cmd.A * cmd.B;
       endcase // case (op_set)

       if(is_invert) 
         predicted.result = ~result;
       else
         predicted.result = result;
       `uvm_info("SCOREBOARD",$sformatf(" op is %s, A is %h, B is %h, exp_result is %h",cmd.op.name(),cmd.A,cmd.B,predicted.result),UVM_HIGH);
       return predicted;
    endfunction : predict_result

   task run_phase(uvm_phase phase);
    forever begin
      fork
        begin
          predict_and_check();
        end
        begin
          bfm.wait_rst_active();
          clean_up();
        end
      join_any
      disable fork;
      bfm.wait_rst_release();
    end
   endtask : run_phase

   function void clean_up();
    `uvm_info(this.get_name(),$sformatf("clean scoreboard logic here"),UVM_LOW)
   item_num = 0;
   endfunction

   task predict_and_check();
      string data_str;
      sequence_item cmd;
      result_transaction exp_result;
      result_transaction act_result;
      result_transaction exp_queue[$];
      result_transaction act_queue[$];
      result_transaction exp_result_tmp;
      result_transaction act_result_tmp;
      uvm_status_e status;
      uvm_reg_data_t value = 0;

      //reg_model_h.ctrl_reg_h.write(status, 16'h1, UVM_FRONTDOOR);
      //reg_model_h.ctrl_reg_h.read(status, value, UVM_FRONTDOOR);
      //`uvm_info("SCOREBOARD", $sformatf("ctrl_reg value is %4h", value),UVM_MEDIUM)

      fork
        forever begin
            cmd_port.get(cmd);
            `uvm_info(this.get_name(),$sformatf("scoreboard get cmd is %s",cmd.convert2string()),UVM_LOW)

            exp_result = predict_result(cmd, value[0]);
            if((cmd.op!=no_op))
                exp_queue.push_back(exp_result);
        end
        forever begin
            if((exp_queue.size()>0) &&(act_queue.size()>0))begin
                exp_result_tmp = exp_queue.pop_front();
                act_result_tmp = act_queue.pop_front();
                data_str = {                cmd.convert2string(), 
                            " ==>  Actual ",act_result_tmp.convert2string(), 
                            "/Predicted ",  exp_result_tmp.convert2string()};

                if (!exp_result_tmp.compare(act_result_tmp))
                    `uvm_error("SELF CHECKER", {"FAIL: ",data_str})
                else
                    `uvm_info ("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)
            end
            else begin
                result_port.get(act_result);
                item_num++;
                `uvm_info(this.get_name(),$sformatf("item num in scoreboard is %0d",item_num),UVM_LOW)
                if(act_result.is_nop==0)begin
                  act_queue.push_back(act_result);
                end
            end
        end
      join
   endtask
endclass : scoreboard

