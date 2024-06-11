module top;
    import uvm_pkg::*;
`include "uvm_macros.svh"

    import   tinyalu_pkg::*;

    tinyalu_bfm       bfm();
    simple_bus_bfm    bus_bfm(.clk(bfm.clk),
                              .rst_n(bfm.rst_n));
    tinyalu DUT (.A(bfm.A), 
                 .B(bfm.B), 
                 .op(bfm.op), 
                 .clk(bfm.clk), 
                 .reset_n(bfm.rst_n), 
                 .start(bfm.start), 
                 .done(bfm.done), 
                 .result(bfm.result),
                 .bus_valid(bus_bfm.bus_valid),
                 .bus_op(bus_bfm.bus_op),
                 .bus_addr(bus_bfm.bus_addr),
                 .bus_wr_data(bus_bfm.bus_wr_data),
                 .bus_rd_data(bus_bfm.bus_rd_data));

    initial begin
      uvm_config_db #(virtual tinyalu_bfm)::set(null, "*", "bfm", bfm);
      uvm_config_db #(virtual simple_bus_bfm)::set(null, "*", "bus_bfm", bus_bfm);
      run_test();
    end

    initial begin
      $vcdpluson;
    end

endmodule : top

     
   
