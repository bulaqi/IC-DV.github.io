
class result_transaction extends uvm_transaction;

   bit[15:0] result;

   function new(string name="");
      super.new(name);
   endfunction : new


   function void do_copy(uvm_object rhs);
      result_transaction RHS;

      if(rhs == null) 
        `uvm_fatal("RESULT TRANSACTION", "Tried to copy from a null pointer")
      if(!$cast(RHS,rhs))
        `uvm_fatal("RESULT TRANSACTION", "Tried to copy wrong type.")
      super.do_copy(rhs); // copy all parent class data
      result = RHS.result;
   endfunction : do_copy

   function string convert2string();
      string s;
      s = $sformatf("result: %4h",result);
      return s;
   endfunction : convert2string

   function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      result_transaction RHS;
      bit    same;

      if (rhs==null) 
        `uvm_fatal("RESULT TRANSACTION","Tried to do comparison to a null pointer");
      if (!$cast(RHS,rhs))
        same = 0;
      else
        same = super.do_compare(rhs, comparer) && 
               (RHS.result== result);
      return same;
   endfunction : do_compare
endclass : result_transaction

      
        
