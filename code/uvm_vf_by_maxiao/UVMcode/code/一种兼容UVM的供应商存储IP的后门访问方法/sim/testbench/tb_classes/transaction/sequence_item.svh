
class sequence_item extends uvm_sequence_item;
   `uvm_object_utils(sequence_item)

   function new(string name="");
      super.new(name);
   endfunction : new
   
   rand bit[7:0]        A;
   rand bit[7:0]        B;
   rand operation_t     op;
   bit[15:0]            result;

   constraint op_con {op dist {no_op := 1, add_op := 5, and_op:=5, 
                               xor_op:=5,mul_op:=5, rst_op:=1};}
   constraint data { A dist {8'h00:=1, [8'h01 : 8'hFE]:=1, 8'hFF:=1};
                     B dist {8'h00:=1, [8'h01 : 8'hFE]:=1, 8'hFF:=1};} 
   
   function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      sequence_item RHS;
      bit same;
      
      if (rhs==null) 
        `uvm_fatal("SEQUENCE ITEM","Tried to do comparison to a null pointer");
      if (!$cast(RHS,rhs))
        same = 0;
      else
        same = super.do_compare(rhs, comparer) && 
               (RHS.A == A) && 
               (RHS.B == B) &&
               (RHS.op == op) &&
               (RHS.result == result);
      return same;
   endfunction : do_compare

   function void do_copy(uvm_object rhs);
      sequence_item RHS;

      if(rhs == null) 
        `uvm_fatal("SEQUENCE ITEM", "Tried to copy from a null pointer")
      if(!$cast(RHS,rhs))
        `uvm_fatal("SEQUENCE ITEM", "Tried to copy wrong type.")
      super.do_copy(rhs); // copy all parent class data

      A = RHS.A;
      B = RHS.B;
      op = RHS.op;
      result = RHS.result;
   endfunction : do_copy

   function string convert2string();
      string            s;
      s = $sformatf("A: %2h  B: %2h   op: %s = %4h",
                    A, B, op.name(), result);
      return s;
   endfunction : convert2string

endclass : sequence_item
