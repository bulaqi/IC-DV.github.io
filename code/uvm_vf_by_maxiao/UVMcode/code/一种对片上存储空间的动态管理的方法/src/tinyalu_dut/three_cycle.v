
module three_cycle(A, B, clk, reset_n, start, done_mult, result_mult);
   input [7:0]      A;
   input [7:0]      B;
   input            clk;
   input            reset_n;
   input            start;
   output           done_mult;
   output reg[15:0]    result_mult;
   
   reg [7:0]        a_int;
   reg [7:0]        b_int;
   reg [15:0]       mult1;
   reg [15:0]       mult2;
   reg              done3;
   reg              done2;
   reg              done1;
   reg              done_mult_int;
   
   //multiplier
   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         done_mult_int <= 1'b0;
         done3 <= 1'b0;
         done2 <= 1'b0;
         done1 <= 1'b0;
         
         a_int <= 8'd0;
         b_int <= 8'd0;
         mult1 <= 16'd0;
         mult2 <= 16'd0;
         result_mult <= 16'd0;
      end
      else begin
         a_int <= A;
         b_int <= B;
         mult1 <= a_int * b_int;
         mult2 <= mult1;
         result_mult <= mult2;
         done3 <= start & ((~done_mult_int));
         done2 <= done3 & ((~done_mult_int));
         done1 <= done2 & ((~done_mult_int));
         done_mult_int <= done1 & ((~done_mult_int));
      end
   end
   assign done_mult = done_mult_int;
   
endmodule
