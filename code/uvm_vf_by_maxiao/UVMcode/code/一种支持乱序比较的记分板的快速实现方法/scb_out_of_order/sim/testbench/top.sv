module top;
    import uvm_pkg::*;
`include "uvm_macros.svh"

    import   demo_pkg::*;

    bit clk,rst_n;

    demo_interface       intf();
    demo_rtl DUT (
                  .clk(intf.clk), 
                  .rst_n(intf.rst_n), 
                  .vld_i(intf.vld_i), 
                  .vld_o(intf.vld_o), 
                  .result(intf.result)
                 );

    initial begin
      uvm_config_db #(virtual demo_interface)::set(null, "*", "vif", intf);
      run_test();
    end
    initial begin
      $vcdpluson;
    end

endmodule : top

     
   
