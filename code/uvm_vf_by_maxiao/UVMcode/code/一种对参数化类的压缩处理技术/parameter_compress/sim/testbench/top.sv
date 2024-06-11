module top;
    import uvm_pkg::*;
`include "uvm_macros.svh"

    import   demo_pkg::*;

    bit clk,rst_n;

    demo_interface#(8,16,8,16)       intf();
    demo_rtl DUT (
                  .clk(intf.clk), 
                  .rst_n(intf.rst_n), 
                  .vld_i(intf.vld_i), 
                  .vld_o(intf.vld_o), 
                  .result(intf.result),
                  .addr_i(intf.addr_i),
                  .data_i(intf.data_i),
                  .addr_o(intf.addr_o),
                  .data_o(intf.data_o)
                 );

    initial begin
      uvm_config_db #(virtual demo_interface#(8,16,8,16))::set(null, "*", "vif", intf);
      run_test();
    end
    initial begin
      $vcdpluson;
    end

endmodule : top

     
   
