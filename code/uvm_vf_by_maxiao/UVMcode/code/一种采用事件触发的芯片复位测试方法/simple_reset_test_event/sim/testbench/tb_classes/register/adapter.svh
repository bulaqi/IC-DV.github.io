
class adapter extends uvm_reg_adapter;
    `uvm_object_utils(adapter)

    function new(string name = "bus_adapter");
        super.new(name);
        supports_byte_enable = 0;
        provides_responses = 0;
    endfunction

    function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        bus_transaction bus_trans;
        bus_trans = bus_transaction::type_id::create("bus_trans");
        bus_trans.addr = rw.addr;
        bus_trans.bus_op = (rw.kind == UVM_READ)? bus_rd: bus_wr;
        if (bus_trans.bus_op == bus_wr)
            bus_trans.wr_data = rw.data;
        return bus_trans;
    endfunction

    function void bus2reg(uvm_sequence_item bus_item,ref uvm_reg_bus_op rw);
        bus_transaction bus_trans;
        if (!$cast(bus_trans, bus_item)) begin
            `uvm_fatal("NOT_BUS_TYPE","Provided bus_item is not of the correct type")
            return;
        end
        rw.kind = (bus_trans.bus_op == bus_rd)? UVM_READ : UVM_WRITE;
        rw.addr = bus_trans.addr;
        rw.data = (bus_trans.bus_op == bus_rd)? bus_trans.rd_data : bus_trans.wr_data;
        rw.status = UVM_IS_OK;
    endfunction

endclass

