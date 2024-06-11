
class in_trans extends uvm_sequence_item;
   `uvm_object_utils(in_trans)

   rand logic vld_i;

   function new(string name="");
      super.new(name);
   endfunction : new

   //function bit do_compare(uvm_object rhs, uvm_comparer comparer);
   //   in_trans RHS;
   //   bit same;
   //   
   //   if (rhs==null) 
   //     `uvm_fatal("SEQUENCE ITEM","Tried to do comparison to a null pointer");
   //   if (!$cast(RHS,rhs))
   //     same = 0;
   //   else
   //     same = super.do_compare(rhs, comparer) && 
   //            (RHS.vld_i == vld_i);
   //   return same;
   //endfunction : do_compare

   function string convert2string();
      string s;
      s = $sformatf("vld_i: %b",vld_i);
      return s;
   endfunction : convert2string

endclass : in_trans
