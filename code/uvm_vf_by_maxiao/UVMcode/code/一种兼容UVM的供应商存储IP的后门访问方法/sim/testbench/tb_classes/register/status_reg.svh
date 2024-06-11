
class status_reg extends uvm_reg;
    `uvm_object_utils(status_reg)

    rand uvm_reg_field all_one_field;
    rand uvm_reg_field all_zero_field;
    uvm_reg_field reserved_field;

    function new(string name="status_reg");
        super.new(name, 16, UVM_NO_COVERAGE);
    endfunction

    function void build();
        all_one_field = uvm_reg_field::type_id::create("all_one_field");
        all_one_field.configure(this, 2, 0, "RO", 0, 2'b00, 1, 1, 0);
        all_zero_field = uvm_reg_field::type_id::create("all_zero_field");
        all_zero_field.configure(this, 2, 2, "RO", 0, 2'b00, 1, 1, 0);
        reserved_field = uvm_reg_field::type_id::create("reserved_field");
        reserved_field.configure(this, 12, 4, "RO", 0, 12'h000, 1, 0, 0);
    endfunction
endclass

