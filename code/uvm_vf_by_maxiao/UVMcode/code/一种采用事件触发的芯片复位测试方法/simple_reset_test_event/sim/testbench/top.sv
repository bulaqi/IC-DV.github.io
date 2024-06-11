module top;
    import uvm_pkg::*;
`include "uvm_macros.svh"

    import   tinyalu_pkg::*;

    reset_interface   reset_bfm();
    tinyalu_bfm       bfm(.clk(reset_bfm.clk),.rst_n(reset_bfm.rst));
    simple_bus_bfm    bus_bfm(.clk(reset_bfm.clk),
                              .rst_n(reset_bfm.rst));
    tinyalu DUT (.A(bfm.A), 
                 .B(bfm.B), 
                 .op(bfm.op), 
                 .clk(reset_bfm.clk), 
                 .reset_n(reset_bfm.rst), 
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
      uvm_config_db #(virtual reset_interface)::set(null, "*", "reset_bfm", reset_bfm);
      run_test();
    end

    initial begin
      $vcdpluson;
    end

endmodule : top

     
   
