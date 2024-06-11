
interface demo_interface;
   parameter tsu = 1ps;
   parameter tco = 0ps;

   logic        clk;
   logic        vld_i;
   logic        vld_o;
   logic[3:0]   result;

   logic        rst_n;

   clocking drv@(posedge clk iff rst_n);
    output #tco vld_i;
    output #tco vld_o;
    output #tco result;
   endclocking

   clocking mon@(posedge clk iff rst_n);
    input #tsu vld_i;
    input #tsu vld_o;
    input #tsu result;
   endclocking

   task init();
     vld_i  <= 0;
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

   
