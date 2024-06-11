
module tinyalu(A, B, clk, op, reset_n, start, done, result, bus_valid, bus_op, bus_addr, bus_wr_data, bus_rd_data);
   input [7:0]      A;
   input [7:0]      B;
   input            clk;
   input [2:0]      op;
   input            reset_n;
   input            start;
   output           done;
   output [15:0]    result;

   input            bus_valid;
   input            bus_op;
   input [15:0]     bus_addr;
   input [15:0]     bus_wr_data;
   output[15:0]     bus_rd_data;
   
   
   wire             done_aax;
   wire             done_mult;
   wire [15:0]      result_aax;
   wire [15:0]      result_mult;
   reg              start_single;
   reg              start_mult;
   reg              done_internal;
   reg[15:0]        result_internal;

   reg [15:0]       ctrl_reg;
   reg [15:0]       status_reg;

   //start_demux
   always @(op[2] or start) begin
      case (op[2])
         1'b0 :
            begin
               start_single <= start;
               start_mult <= 1'b0;
            end
         1'b1 :
            begin
               start_single <= 1'b0;
               start_mult <= start;
            end
         default :
            ;
      endcase
   end
   
   //result_mux
   always @(result_aax or result_mult or op) begin
      case (op[2])
         1'b0 :
            result_internal <= result_aax;
         1'b1 :
            result_internal <= result_mult;
         default :
            result_internal <= {16{1'bx}};
      endcase
   end
   
   //done_mux
   always @(done_aax or done_mult or op) begin
      case (op[2])
         1'b0 :
            done_internal <= done_aax;
         1'b1 :
            done_internal <= done_mult;
         default :
            done_internal <= 1'bx;
      endcase
   end

   single_cycle add_and_xor(.A(A), .B(B), .clk(clk), .op(op), .reset_n(reset_n), .start(start_single), .done_aax(done_aax), .result_aax(result_aax));
   
   three_cycle mult(.A(A), .B(B), .clk(clk), .reset_n(reset_n), .start(start_mult), .done_mult(done_mult), .result_mult(result_mult));

   memory mem(.clk(clk), .reset_n(reset_n), .bus_valid(bus_valid), .bus_op(bus_op), .bus_addr(bus_addr), .bus_wr_data(bus_wr_data), .bus_rd_data(bus_rd_data));
   
   assign result = (ctrl_reg[0])? ~result_internal : result_internal;
   assign done = done_internal;
   
endmodule

