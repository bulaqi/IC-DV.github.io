
module memory(clk, reset_n, bus_valid, bus_op, bus_addr, bus_wr_data, bus_rd_data);
   input               clk;
   input               reset_n;
   input               bus_valid;
   input               bus_op;
   input [15:0]        bus_addr;
   input [15:0]        bus_wr_data;
   output reg[15:0]    bus_rd_data;
   
   reg [10][15:0]   data;
  
   //bus write
   always @(posedge clk)begin
       if(!reset_n)begin
           data[0] <= 16'h0;
           data[1] <= 16'h0;
           data[2] <= 16'h0;
           data[3] <= 16'h0;
           data[4] <= 16'h0;
           data[5] <= 16'h0;
           data[6] <= 16'h0;
           data[7] <= 16'h0;
           data[8] <= 16'h0;
           data[9] <= 16'h0;
       end
       else if(bus_valid && bus_op)begin
           case(bus_addr)
               16'h10:begin
                   data[0] <= bus_wr_data;
               end
               16'h11:begin
                   data[1] <= bus_wr_data;
               end
               16'h12:begin
                   data[2] <= bus_wr_data;
               end
               16'h13:begin
                   data[3] <= bus_wr_data;
               end
               16'h14:begin
                   data[4] <= bus_wr_data;
               end
               16'h15:begin
                   data[5] <= bus_wr_data;
               end
               16'h16:begin
                   data[6] <= bus_wr_data;
               end
               16'h17:begin
                   data[7] <= bus_wr_data;
               end
               16'h18:begin
                   data[8] <= bus_wr_data;
               end
               16'h19:begin
                   data[9] <= bus_wr_data;
               end
               default:;
           endcase
       end
   end

   //bus read
   always @(posedge clk)begin
       if(!reset_n)
           bus_rd_data <= 16'h0;
       else if(bus_valid && !bus_op)begin
           case(bus_addr)
               16'h10:begin
                   bus_rd_data <= data[0];
               end
               16'h11:begin
                   bus_rd_data <= data[1];
               end
               16'h12:begin
                   bus_rd_data <= data[2];
               end
               16'h13:begin
                   bus_rd_data <= data[3];
               end
               16'h14:begin
                   bus_rd_data <= data[4];
               end
               16'h15:begin
                   bus_rd_data <= data[5];
               end
               16'h16:begin
                   bus_rd_data <= data[6];
               end
               16'h17:begin
                   bus_rd_data <= data[7];
               end
               16'h18:begin
                   bus_rd_data <= data[8];
               end
               16'h19:begin
                   bus_rd_data <= data[9];
               end
               default:begin
                   bus_rd_data <= 16'h0;
               end
           endcase
       end
   end

   task write_api(integer offset, reg[15:0] wdata);
     data[offset] = wdata;
     $display("mem write_api offset %0d, wdata %0h",offset,wdata);
   endtask

   task read_api(integer offset, output reg[15:0] rdata);
     rdata = data[offset];
     $display("mem read_api offset %0d, rdata %0h",offset,rdata);
   endtask

endmodule

