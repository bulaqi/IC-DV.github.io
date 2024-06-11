
class out_trans#(int addr_o_width = 8, data_o_width = 16) extends uvm_sequence_item;
   `uvm_object_utils(out_trans#(addr_o_width,data_o_width))

   rand logic vld_o;
   rand logic[3:0] result;
   rand logic[addr_o_width-1:0] addr_o;
   rand logic[data_o_width-1:0] data_o;

   function new(string name="");
      super.new(name);
   endfunction : new

   function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      out_trans RHS;
      bit    same;

      if (rhs==null) 
        `uvm_fatal("RESULT TRANSACTION","Tried to do comparison to a null pointer");
      if (!$cast(RHS,rhs))
        same = 0;
      else
        same = super.do_compare(rhs, comparer) && 
               (RHS.vld_o== vld_o) &&
               (RHS.result== result);
      return same;
   endfunction : do_compare

   function string convert2string();
      string s;
      s = $sformatf("vld_o: %b, result : %0d, addr_o: %0h, data_o: %0h",vld_o,result,addr_o,data_o);
      return s;
   endfunction : convert2string
endclass : out_trans

      
        
