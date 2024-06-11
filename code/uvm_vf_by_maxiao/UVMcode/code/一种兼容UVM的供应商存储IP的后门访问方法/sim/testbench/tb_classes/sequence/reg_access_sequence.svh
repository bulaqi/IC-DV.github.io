
class reg_access_sequence extends uvm_sequence #(bus_transaction);
   `uvm_object_utils(reg_access_sequence)
   
   bus_transaction bus_trans;
   bit[15:0] addr;
   bit[15:0] wr_data;
   bit[15:0] rd_data;
   bus_op_t bus_op;

   function new(string name = "reg_access_sequence");
      super.new(name);
   endfunction : new

   task body();
         bus_trans = bus_transaction::type_id::create("bus_trans");
         start_item(bus_trans);
         assert(bus_trans.randomize());
         bus_trans.addr=this.addr;
         bus_trans.wr_data=this.wr_data;
         bus_trans.bus_op=this.bus_op;
         finish_item(bus_trans);
         this.rd_data=bus_trans.rd_data;
         `uvm_info("REG ACCESS SEQ",bus_trans.convert2string(), UVM_MEDIUM);
   endtask : body
endclass : reg_access_sequence


