
interface reset_interface();
  parameter tsu = 1ps;
  parameter tco = 0ps;

  logic clk;
  logic rst;

  clocking drv@(posedge clk);
   output #tco rst;
  endclocking

  clocking mon@(posedge clk);
   input #tsu rst;
  endclocking

  task init();
    rst <= 1;
  endtask

  initial begin
    clk = 0;
    forever begin
       #10;
       clk = ~clk;
    end
  end

endinterface
