
interface simple_bus_bfm(input clk, input reset_n);
   import tinyalu_pkg::*;

   bus_monitor bus_monitor_h;

   bit        bus_valid;
   bit        bus_op;
   bit [15:0] bus_wr_data;
   bit [15:0] bus_addr;
   wire[15:0] bus_rd_data;


  task send_op(input bit[15:0] i_wr_data, input bit[15:0] i_addr, input bus_op_t i_bus_op, output bit[15:0] o_rd_data);
         @(posedge clk);
         bus_valid = 1'b1;
         bus_op = (i_bus_op == bus_rd) ? 1'b0 : 1'b1;
         bus_addr = i_addr;
         bus_wr_data = (i_bus_op == bus_rd) ? 16'h0 : i_wr_data;

         @(posedge clk);
         bus_valid = 1'b0;
         bus_op = 1'b0;
         bus_addr = 16'h0;
         bus_wr_data = 16'h0;

         @(posedge clk);
         if(i_bus_op == bus_rd)begin
            o_rd_data = bus_rd_data;
         end
         $display($sformatf("reg bus send_op -> i_bus_op is %s, addr is %0h, wr_data is %0g, rd_data is %0h",i_bus_op.name(),i_addr,i_wr_data,o_rd_data));
   endtask : send_op

   always @(posedge clk) begin : bus_op_monitor
         if (bus_valid) 
           bus_monitor_h.write_to_monitor(op2enum(), bus_addr, bus_wr_data);
   end : bus_op_monitor

   function bus_op_t op2enum();
          case(bus_op)
                  1'b0 : return bus_rd;
                  1'b1 : return bus_wr;
                  default : $fatal("Illegal operation on bus_op bus");
          endcase
   endfunction

endinterface : simple_bus_bfm

   
