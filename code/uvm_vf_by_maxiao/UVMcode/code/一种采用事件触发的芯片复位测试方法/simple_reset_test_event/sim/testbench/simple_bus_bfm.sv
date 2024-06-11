
interface simple_bus_bfm(input clk, input rst_n);
   import tinyalu_pkg::*;
   parameter tsu = 1ps;
   parameter tco = 0ps;

   logic        bus_valid;
   logic        bus_op;
   logic [15:0] bus_wr_data;
   logic [15:0] bus_addr;
   logic [15:0] bus_rd_data;

   clocking drv@(posedge clk);
    output #tco bus_valid;
    output #tco bus_op;
    output #tco bus_wr_data;
    output #tco bus_addr;
    output #tco bus_rd_data;
   endclocking

   clocking mon@(posedge clk);
    input #tsu bus_valid;
    input #tsu bus_op;
    input #tsu bus_wr_data;
    input #tsu bus_addr;
    input #tsu bus_rd_data;
   endclocking

  task send_op(input bus_transaction req, output bit[15:0] o_rd_data);
         @(drv);
         drv.bus_valid <= 1'b1;
         case(req.bus_op.name())
          "bus_wr":   drv.bus_op <= 1'b1;
          "bus_rd":   drv.bus_op <= 1'b0;
         endcase
         drv.bus_addr <= req.addr;
         case(req.bus_op.name())
          "bus_rd":   drv.bus_wr_data <= 16'h0;
          "bus_wr":   drv.bus_wr_data <= req.wr_data;
         endcase

         @(drv);
         drv.bus_valid <= 1'b0;
         drv.bus_op <= 1'b0;
         drv.bus_addr <= 16'h0;
         drv.bus_wr_data <= 16'h0;

         @(mon);
         if(req.bus_op.name()=="bus_rd")begin
          o_rd_data = mon.bus_rd_data;
         end
   endtask : send_op

   task init();
     bus_valid <= 0;
     bus_op <= 'dx;
     bus_wr_data <= 'dx;
     bus_addr <= 'dx;
   endtask

   function bus_op_t op2enum();
     case(bus_op)
       1'b0 : return bus_rd;
       1'b1 : return bus_wr;
       default : $fatal("Illegal operation on bus_op bus");
     endcase
   endfunction

  task wait_reset;
    @(posedge rst_n);
  endtask

endinterface : simple_bus_bfm

   
