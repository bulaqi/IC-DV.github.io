
class in_trans#(int addr_i_width = 8, data_i_width = 16) extends uvm_sequence_item;
   `uvm_object_utils(in_trans#(addr_i_width,data_i_width))

   rand logic vld_i;
   rand logic[addr_i_width-1:0] addr_i;
   rand logic[data_i_width-1:0] data_i;

   function new(string name="");
      super.new(name);
   endfunction : new

   function string convert2string();
      string s;
      s = $sformatf("vld_i: %b, addr_i: %0h, data_i: %0h",vld_i,addr_i,data_i);
      return s;
   endfunction : convert2string

endclass : in_trans
