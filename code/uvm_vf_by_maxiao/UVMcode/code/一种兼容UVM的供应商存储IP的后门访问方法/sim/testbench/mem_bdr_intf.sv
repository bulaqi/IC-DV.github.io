

`define set_mem_bdr_intf \
  mem_bdr_intf mem_bdr_intf_h(); \
  initial begin \
    uvm_config_db#(virtual mem_bdr_intf)::set(null,"*",`"mem_bdr_intf`",top.mem_bdr_intf_h); \
  end \

  interface mem_bdr_intf();

    task write_mem;
      input int unsigned offset;
      input logic[15:0] wdata;

      $root.top.DUT.mem.write_api(offset,wdata);
    endtask

    task read_mem;
      input int unsigned offset;
      output logic[15:0] rdata;

      $root.top.DUT.mem.read_api(offset,rdata);
    endtask

  endinterface
