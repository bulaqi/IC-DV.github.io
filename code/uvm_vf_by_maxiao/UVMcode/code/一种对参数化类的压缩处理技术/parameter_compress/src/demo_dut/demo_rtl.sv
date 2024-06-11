
module demo_rtl #(
  parameter ADDR_I_WIDTH = 8,
  parameter DATA_I_WIDTH = 16,
  parameter ADDR_O_WIDTH = 8,
  parameter DATA_O_WIDTH = 16
)(
 clk,
 rst_n,
 vld_i,
 vld_o,
 result,
 addr_i,
 data_i,
 addr_o,
 data_o
);
   input            clk;
   input            rst_n;
   input            vld_i;
   output reg       vld_o;
   output reg [3:0] result;

   input[ADDR_I_WIDTH-1:0]  addr_i;
   input[DATA_I_WIDTH-1:0]  data_i;
   output reg[ADDR_O_WIDTH-1:0] addr_o;
   output reg[DATA_O_WIDTH-1:0] data_o;

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
         addr_o <= 0;
         data_o <= 0;
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
        addr_o <= addr_i;
        data_o <= data_i;
      end
      else begin
        vld_o  <= 0;
        result <= 0;
        addr_o <= 0;
        data_o <= 0;
      end
    end
   end
endmodule

