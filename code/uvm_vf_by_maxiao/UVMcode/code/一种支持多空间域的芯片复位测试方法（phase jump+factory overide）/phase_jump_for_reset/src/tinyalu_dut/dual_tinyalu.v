
module dual_tinyalu(
  A_a, 
  B_a, 
  clk_a, 
  op_a, 
  reset_n_a, 
  start_a, 
  done_a, 
  result_a, 
  bus_valid_a, 
  bus_op_a, 
  bus_addr_a, 
  bus_wr_data_a, 
  bus_rd_data_a,
  A_b, 
  B_b, 
  clk_b, 
  op_b, 
  reset_n_b, 
  start_b, 
  done_b, 
  result_b, 
  bus_valid_b, 
  bus_op_b, 
  bus_addr_b, 
  bus_wr_data_b, 
  bus_rd_data_b
);
   input [7:0]      A_a;
   input [7:0]      B_a;
   input            clk_a;
   input [2:0]      op_a;
   input            reset_n_a;
   input            start_a;
   output           done_a;
   output [15:0]    result_a;

   input            bus_valid_a;
   input            bus_op_a;
   input [15:0]     bus_addr_a;
   input [15:0]     bus_wr_data_a;
   output reg[15:0]    bus_rd_data_a;

   input [7:0]      A_b;
   input [7:0]      B_b;
   input            clk_b;
   input [2:0]      op_b;
   input            reset_n_b;
   input            start_b;
   output           done_b;
   output [15:0]    result_b;

   input            bus_valid_b;
   input            bus_op_b;
   input [15:0]     bus_addr_b;
   input [15:0]     bus_wr_data_b;
   output reg[15:0]    bus_rd_data_b;

   tinyalu tinyalu_a(
     .A(A_a), 
     .B(B_a), 
     .clk(clk_a), 
     .op(op_a), 
     .reset_n(reset_n_a), 
     .start(start_a), 
     .done(done_a), 
     .result(result_a), 
     .bus_valid(bus_valid_a), 
     .bus_op(bus_op_a), 
     .bus_addr(bus_addr_a), 
     .bus_wr_data(bus_wr_data_a), 
     .bus_rd_data(bus_rd_data_a)
   );

   tinyalu tinyalu_b(
     .A(A_b), 
     .B(B_b), 
     .clk(clk_b), 
     .op(op_b), 
     .reset_n(reset_n_b), 
     .start(start_b), 
     .done(done_b), 
     .result(result_b), 
     .bus_valid(bus_valid_b), 
     .bus_op(bus_op_b), 
     .bus_addr(bus_addr_b), 
     .bus_wr_data(bus_wr_data_b), 
     .bus_rd_data(bus_rd_data_b)
   );

endmodule

