`ifndef MY_DRIVER__SV //
`define MY_DRIVER__SV //
class my_driver extends uvm_driver;

   function new(string name = "my_driver", uvm_component parent = null);
      super.new(name, parent); //一个是string类型的name，uvm_component的parent.
   endfunction
   extern virtual task main_phase(uvm_phase phase); // 是uvm_driver设定好的任务
endclass

task my_driver::main_phase(uvm_phase phase);  // 实现phase就是实现driver
   top_tb.rxd <= 8'b0; 
   top_tb.rx_dv <= 1'b0;
   while(!top_tb.rst_n)
      @(posedge top_tb.clk);
   for(int i = 0; i < 256; i++)begin
      @(posedge top_tb.clk);
      top_tb.rxd <= $urandom_range(0, 255); //
      top_tb.rx_dv <= 1'b1;
      `uvm_info("my_driver", "data is drived", UVM_LOW) //打印的信息归类，具体打印的信息，冗余。
	  //重要程度LOW>MEDIUM>HIGH.  INFO 一般类似display
   end
   @(posedge top_tb.clk);
   top_tb.rx_dv <= 1'b0;
endtask
`endif
