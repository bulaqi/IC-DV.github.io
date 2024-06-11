
interface tinyalu_bfm;
   import tinyalu_pkg::*;
   import uvm_mem_manager_pkg::*;

   command_monitor command_monitor_h;
   result_monitor  result_monitor_h;

   byte         unsigned        A;
   byte         unsigned        B;
   bit          clk;
   bit          reset_n;
   wire [2:0]   op;
   bit          start;
   wire         done;
   wire [15:0]  result;
   operation_t  op_set;

   assign op = op_set;

   initial begin
      clk = 0;
      forever begin
         #10;
         clk = ~clk;
      end
   end

   task reset_alu();
      reset_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
      reset_n = 1'b1;
      start = 1'b0;
   endtask : reset_alu
   
  task send_op(input byte iA, input byte iB, input operation_t iop, output shortint alu_result);
         @(posedge clk);
         op_set = iop;
         A = iA;
         B = iB;
         start = 1'b1;
         case(op_set)
            no_op: begin
                @(posedge clk);
                start = 1'b0;
            end
            rst_op: begin
                reset_n = 1'b0;
                start = 1'b0;
                @(negedge clk);
                reset_n = 1'b1;
            end
            default: begin
                wait(done);
                @(posedge clk);
                start = 1'b0;
            end
         endcase
         alu_result = result;
   endtask : send_op

   always @(posedge clk) begin : cmd_monitor
      bit new_command;
      if (!start) 
        new_command = 1;
      else
        if (new_command) begin 
           command_monitor_h.write_to_monitor(A, B, op2enum());
           new_command = 0;
        end 
   end : cmd_monitor

   always @(negedge reset_n) begin : rst_monitor
      if (command_monitor_h != null) //guard against VCS time 0 negedge
         command_monitor_h.write_to_monitor(A, B, rst_op);
   end : rst_monitor

   always @(posedge clk) begin : rslt_monitor
         if (done) 
           result_monitor_h.write_to_monitor(result);
   end : rslt_monitor

   function operation_t op2enum();
          case(op_set)
                  3'b000 : return no_op;
                  3'b001 : return add_op;
                  3'b010 : return and_op;
                  3'b011 : return xor_op;
                  3'b100 : return mul_op;
                  3'b111 : return rst_op;
                  default : $fatal("Illegal operation on op bus");
          endcase
   endfunction

endinterface : tinyalu_bfm

   
