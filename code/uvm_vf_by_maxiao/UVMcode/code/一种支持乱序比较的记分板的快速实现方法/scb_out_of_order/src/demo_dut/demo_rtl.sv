
module demo_rtl(
 clk,
 rst_n,
 vld_i,
 vld_o,
 result
);
   input            clk;
   input            rst_n;
   input            vld_i;
   output reg       vld_o;
   output reg [3:0] result;

   bit[3:0] result_q[$];

   initial begin
    for(bit[3:0] i=1;i<='d10;i++)begin
      result_q.push_back(i);
    end
    forever begin
      @(posedge clk);
      if(!rst_n)begin
         vld_o  <= 0;
         result <= 0;
      end
      else if(vld_i)begin
        if(result_q.size())begin
          result_q.shuffle();
          result <= result_q.pop_front();
          vld_o  <= 1;
        end
        else begin
         vld_o  <= 0;
         result <= 0;
        end
      end
      else begin
        vld_o  <= 0;
        result <= 0;
      end
    end
   end
   //always@(posedge clk)begin
   // if(!rst_n)begin
   //   vld_o <= 0;
   //   result <= 0;
   // end
   // else begin
   //   vld_o <= 1;
   //   result <= result + 1;
   // end
   //end
endmodule

