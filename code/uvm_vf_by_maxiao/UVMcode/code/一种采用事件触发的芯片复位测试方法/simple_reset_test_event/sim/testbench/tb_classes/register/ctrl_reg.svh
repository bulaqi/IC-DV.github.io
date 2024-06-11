
class ctrl_reg extends uvm_reg;
    `uvm_object_utils(ctrl_reg)

    rand uvm_reg_field invert_field;
    rand uvm_reg_field border_field;
    uvm_reg_field reserved_field;

    function new(string name="ctrl_reg");
        super.new(name, 16, UVM_NO_COVERAGE);
    endfunction

    function void build();
        invert_field = uvm_reg_field::type_id::create("invert_field");
        invert_field.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 0);
        border_field = uvm_reg_field::type_id::create("border_field");
        border_field.configure(this, 1, 1, "RW", 0, 1'b0, 1, 1, 0);
        reserved_field = uvm_reg_field::type_id::create("reserved_field");
        reserved_field.configure(this, 14, 2, "RW", 0, 14'h0000, 1, 0, 0);
    endfunction
endclass

