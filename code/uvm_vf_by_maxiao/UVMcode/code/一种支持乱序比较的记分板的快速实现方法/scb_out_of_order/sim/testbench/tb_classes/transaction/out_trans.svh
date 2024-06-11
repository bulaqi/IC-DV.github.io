
class out_trans extends uvm_sequence_item;
   `uvm_object_utils(out_trans)

   rand logic vld_o;
   rand logic[3:0] result;

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
      s = $sformatf("vld_o: %b, result : %0d",vld_o,result);
      return s;
   endfunction : convert2string
endclass : out_trans

      
        
