module top;
    import uvm_pkg::*;
`include "uvm_macros.svh"

    import   tinyalu_pkg::*;

    reset_interface   reset_bfm_a();
    tinyalu_bfm       bfm_a(.clk(reset_bfm_a.clk),.rst_n(reset_bfm_a.rst));
    simple_bus_bfm    bus_bfm_a(.clk(reset_bfm_a.clk),
                              .rst_n(reset_bfm_a.rst));
    reset_interface   reset_bfm_b();
    tinyalu_bfm       bfm_b(.clk(reset_bfm_b.clk),.rst_n(reset_bfm_b.rst));
    simple_bus_bfm    bus_bfm_b(.clk(reset_bfm_b.clk),
                              .rst_n(reset_bfm_b.rst));
    dual_tinyalu DUT (.A_a(bfm_a.A), 
                      .B_a(bfm_a.B), 
                      .op_a(bfm_a.op), 
                      .clk_a(reset_bfm_a.clk), 
                      .reset_n_a(reset_bfm_a.rst), 
                      .start_a(bfm_a.start), 
                      .done_a(bfm_a.done), 
                      .result_a(bfm_a.result),
                      .bus_valid_a(bus_bfm_a.bus_valid),
                      .bus_op_a(bus_bfm_a.bus_op),
                      .bus_addr_a(bus_bfm_a.bus_addr),
                      .bus_wr_data_a(bus_bfm_a.bus_wr_data),
                      .bus_rd_data_a(bus_bfm_a.bus_rd_data),
                      .A_b(bfm_b.A), 
                      .B_b(bfm_b.B), 
                      .op_b(bfm_b.op), 
                      .clk_b(reset_bfm_b.clk), 
                      .reset_n_b(reset_bfm_b.rst), 
                      .start_b(bfm_b.start), 
                      .done_b(bfm_b.done), 
                      .result_b(bfm_b.result),
                      .bus_valid_b(bus_bfm_b.bus_valid),
                      .bus_op_b(bus_bfm_b.bus_op),
                      .bus_addr_b(bus_bfm_b.bus_addr),
                      .bus_wr_data_b(bus_bfm_b.bus_wr_data),
                      .bus_rd_data_b(bus_bfm_b.bus_rd_data)
                      );

    initial begin
      uvm_config_db #(virtual tinyalu_bfm)::set(null, "uvm_test_top.top_env_h.env_h_a.*", "bfm", bfm_a);
      uvm_config_db #(virtual simple_bus_bfm)::set(null, "uvm_test_top.top_env_h.env_h_a.*", "bus_bfm", bus_bfm_a);
      uvm_config_db #(virtual reset_interface)::set(null, "uvm_test_top.top_env_h.env_h_a.*", "reset_bfm", reset_bfm_a);
      uvm_config_db #(virtual tinyalu_bfm)::set(null, "uvm_test_top.top_env_h.env_h_b.*", "bfm", bfm_b);
      uvm_config_db #(virtual simple_bus_bfm)::set(null, "uvm_test_top.top_env_h.env_h_b.*", "bus_bfm", bus_bfm_b);
      uvm_config_db #(virtual reset_interface)::set(null, "uvm_test_top.top_env_h.env_h_b.*", "reset_bfm", reset_bfm_b);
      run_test();
    end

    initial begin
      $vcdpluson;
    end

endmodule : top

     
   
