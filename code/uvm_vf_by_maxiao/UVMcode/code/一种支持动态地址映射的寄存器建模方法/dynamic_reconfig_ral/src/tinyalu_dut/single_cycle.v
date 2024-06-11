
module single_cycle(A, B, clk, op, reset_n, start, done_aax, result_aax);
   input [7:0]      A;
   input [7:0]      B;
   input            clk;
   input [2:0]      op;
   input            reset_n;
   input            start;
   output reg          done_aax;
   output reg[15:0]     result_aax;
   
   
   //single_cycle_ops
   always @(posedge clk) begin
       if(!reset_n)
           result_aax <= 16'd0;
       else begin
           if (start == 1'b1)begin
               case (op)
                  3'b001 :
                     result_aax <= ({8'b00000000, A}) + ({8'b00000000, B});
                  3'b010 :
                     result_aax <= (({8'b00000000, A}) & ({8'b00000000, B}));
                  3'b011 :
                     result_aax <= (({8'b00000000, A}) ^ ({8'b00000000, B}));
                  default :
                    ;
               endcase
            end
            else ;
        end
   end
   
   //set_done
   always @(posedge clk or negedge reset_n) begin
      if (!reset_n)
         done_aax <= 1'b0;
      else begin
         if ((start == 1'b1) && (op != 3'b000) && (done_aax == 1'b0))
            done_aax <= 1'b1;
         else
            done_aax <= 1'b0;
      end
   end
   
endmodule


