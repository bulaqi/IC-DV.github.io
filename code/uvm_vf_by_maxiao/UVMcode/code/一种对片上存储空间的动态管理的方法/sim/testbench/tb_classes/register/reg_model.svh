
class reg_model extends uvm_reg_block;
    `uvm_object_utils(reg_model)

    rand ctrl_reg   ctrl_reg_h;
    rand status_reg status_reg_h;

    function new(string name="reg_model");
        super.new(name, UVM_NO_COVERAGE);
    endfunction

    function void build();
        default_map = create_map("default_map", 'h0, 2, UVM_LITTLE_ENDIAN);
        ctrl_reg_h = ctrl_reg::type_id::create("ctrl_reg_h");
        ctrl_reg_h.configure(this);
        ctrl_reg_h.build();
        default_map.add_reg(ctrl_reg_h, 16'h8, "RW");

        status_reg_h = status_reg::type_id::create("status_reg_h");
        status_reg_h.configure(this);
        status_reg_h.build();
        default_map.add_reg(status_reg_h, 16'h9, "RO");
    endfunction
endclass
