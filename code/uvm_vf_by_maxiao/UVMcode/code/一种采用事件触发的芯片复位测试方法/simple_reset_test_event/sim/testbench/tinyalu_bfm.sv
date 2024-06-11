
interface tinyalu_bfm(input clk, input rst_n);
   import tinyalu_pkg::*;
   parameter tsu = 1ps;
   parameter tco = 0ps;

   logic[7:0]    A;
   logic[7:0]    B;
   logic[2:0]    op;
   logic         start;
   logic         done;
   logic [15:0]  result;

   clocking drv@(posedge clk);
    output #tco A;
    output #tco B;
    output #tco op;
    output #tco start;
    output #tco done;
    output #tco result;
   endclocking

   clocking mon@(posedge clk);
    input #tsu A;
    input #tsu B;
    input #tsu op;
    input #tsu start;
    input #tsu done;
    input #tsu result;
   endclocking


  task send_op(input sequence_item req, output bit[15:0] alu_result);
         case(req.op.name())
          "no_op": begin
            @(drv);
            drv.start <= 1'b1;
            @(drv);
            drv.start <= 1'b0;
            @(mon);
            alu_result = mon.result;
          end
          "mul_op": begin
            @(drv);
            drv.op    <= enum2op(req.op);
            drv.A     <= req.A;
            drv.B     <= req.B;
            drv.start <= 1'b1;
            repeat(3) begin
              @(mon);
            end
            @(mon);
            alu_result = mon.result;
            @(drv);
            drv.start <= 1'b0;
          end
           default: begin
            @(drv);
            drv.op    <= enum2op(req.op);
            drv.A     <= req.A;
            drv.B     <= req.B;
            drv.start <= 1'b1;
            @(mon);
            alu_result = mon.result;
            @(drv);
            drv.start <= 1'b0;
           end
         endcase
   endtask : send_op

   task init();
     start <= 0;
     A     <= 'dx;
     B     <= 'dx;
     op    <= 'd0;
   endtask

   task automatic wait_rst_active();
    @(negedge rst_n);
   endtask

   task automatic wait_rst_release();
    wait(rst_n == 1);
   endtask

   function logic[2:0] enum2op(operation_t op);
     case(op)
        no_op  : return 3'b000; 
        add_op : return 3'b001;
        and_op : return 3'b010;
        xor_op : return 3'b011;
        mul_op : return 3'b100;
     endcase
   endfunction

endinterface : tinyalu_bfm

   
