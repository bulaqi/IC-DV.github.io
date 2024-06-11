
class bus_transaction extends uvm_sequence_item;
   `uvm_object_utils(bus_transaction)

   function new(string name="bus_transaction");
      super.new(name);
   endfunction : new
   
   rand bit[15:0]   wr_data;
   rand bit[15:0]   addr;
   rand bus_op_t    bus_op;
   bit[15:0]   rd_data;

   function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      bus_transaction RHS;
      bit same;
      
      if (rhs==null) 
        `uvm_fatal("BUS TRANS","Tried to do comparison to a null pointer");
      if (!$cast(RHS,rhs))
        same = 0;
      else
        same = super.do_compare(rhs, comparer) && 
               (RHS.rd_data == rd_data) && 
               (RHS.wr_data == wr_data) &&
               (RHS.addr == addr) &&
               (RHS.bus_op == bus_op);
      return same;
   endfunction : do_compare

   function void do_copy(uvm_object rhs);
      bus_transaction RHS;

      if(rhs == null) 
        `uvm_fatal("BUS TRANS", "Tried to copy from a null pointer")
      if(!$cast(RHS,rhs))
        `uvm_fatal("BUS TRANS", "Tried to copy wrong type.")
      super.do_copy(rhs); // copy all parent class data

      rd_data = RHS.rd_data;
      wr_data = RHS.wr_data;
      addr = RHS.addr;
      bus_op = RHS.bus_op;
   endfunction : do_copy

   function string convert2string();
      string    s;
      s = $sformatf("bus_op: %s   addr: %2h   rd_data: %4h    wr_data: %4h",
                    bus_op.name(), addr, rd_data, wr_data);
      return s;
   endfunction : convert2string

endclass : bus_transaction
