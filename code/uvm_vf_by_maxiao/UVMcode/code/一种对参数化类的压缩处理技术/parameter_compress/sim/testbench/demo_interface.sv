
interface demo_interface #(parameter addr_i_width = 8,data_i_width = 16,addr_o_width = 8,data_o_width = 16);
   parameter tsu = 1ps;
   parameter tco = 0ps;

   logic        clk;
   logic        vld_i;
   logic        vld_o;
   logic[3:0]   result;
   logic[addr_i_width-1:0]   addr_i;
   logic[data_i_width-1:0]   data_i;
   logic[addr_o_width-1:0]   addr_o;
   logic[data_o_width-1:0]   data_o;

   logic        rst_n;

   clocking drv@(posedge clk iff rst_n);
    output #tco vld_i;
    output #tco vld_o;
    output #tco result;
    output #tco addr_i;
    output #tco data_i;
    output #tco addr_o;
    output #tco data_o;
   endclocking

   clocking mon@(posedge clk iff rst_n);
    input #tsu vld_i;
    input #tsu vld_o;
    input #tsu result;
    input #tsu addr_i;
    input #tsu data_i;
    input #tsu addr_o;
    input #tsu data_o;
   endclocking

   task init();
     vld_i  <= 0;
     addr_i <= 'dx;
     data_i <= 'dx;
   endtask

   initial begin
      rst_n = 0;
      #50;
      rst_n = 1;
      #1000;
   end

   initial begin
      clk = 0;
      forever begin
         #10;
         clk = ~clk;
      end
   end

endinterface 

   
