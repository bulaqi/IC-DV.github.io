
typedef bus_sequencer;
class reg_state extends uvm_reg;
    `uvm_object_utils(reg_state)

    rand uvm_reg_field demo_field1;
    rand uvm_reg_field demo_field2;
    rand uvm_reg_field demo_field3;

    function new(string name="reg_state");
        super.new(name, 16, UVM_NO_COVERAGE);
    endfunction

    function void build();
        demo_field1 = uvm_reg_field::type_id::create("demo_field1");
        demo_field1.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 0);
        demo_field2 = uvm_reg_field::type_id::create("demo_field2");
        demo_field2.configure(this, 1, 1, "RW", 0, 1'b0, 1, 1, 0);
        demo_field3 = uvm_reg_field::type_id::create("demo_field3");
        demo_field3.configure(this, 14, 2, "RW", 0, 14'h0, 1, 0, 0);
    endfunction
endclass

class reg_A extends uvm_reg;
    `uvm_object_utils(reg_A)

    rand uvm_reg_field demo_field1;
    rand uvm_reg_field demo_field2;
    rand uvm_reg_field demo_field3;

    function new(string name="reg_A");
        super.new(name, 16, UVM_NO_COVERAGE);
    endfunction

    function void build();
        demo_field1 = uvm_reg_field::type_id::create("demo_field1");
        demo_field1.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 0);
        demo_field2 = uvm_reg_field::type_id::create("demo_field2");
        demo_field2.configure(this, 1, 1, "RW", 0, 1'b0, 1, 1, 0);
        demo_field3 = uvm_reg_field::type_id::create("demo_field3");
        demo_field3.configure(this, 14, 2, "RW", 0, 14'h0, 1, 0, 0);
    endfunction
endclass

class reg_B extends uvm_reg;
    `uvm_object_utils(reg_B)

    rand uvm_reg_field demo_field1;
    rand uvm_reg_field demo_field2;
    rand uvm_reg_field demo_field3;

    function new(string name="reg_B");
        super.new(name, 16, UVM_NO_COVERAGE);
    endfunction

    function void build();
        demo_field1 = uvm_reg_field::type_id::create("demo_field1");
        demo_field1.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 0);
        demo_field2 = uvm_reg_field::type_id::create("demo_field2");
        demo_field2.configure(this, 1, 1, "RW", 0, 1'b0, 1, 1, 0);
        demo_field3 = uvm_reg_field::type_id::create("demo_field3");
        demo_field3.configure(this, 14, 2, "RW", 0, 14'h0, 1, 0, 0);
    endfunction
endclass

class reg_C extends uvm_reg;
    `uvm_object_utils(reg_C)

    rand uvm_reg_field demo_field1;
    rand uvm_reg_field demo_field2;
    rand uvm_reg_field demo_field3;

    function new(string name="reg_C");
        super.new(name, 16, UVM_NO_COVERAGE);
    endfunction

    function void build();
        demo_field1 = uvm_reg_field::type_id::create("demo_field1");
        demo_field1.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 0);
        demo_field2 = uvm_reg_field::type_id::create("demo_field2");
        demo_field2.configure(this, 1, 1, "RW", 0, 1'b0, 1, 1, 0);
        demo_field3 = uvm_reg_field::type_id::create("demo_field3");
        demo_field3.configure(this, 14, 2, "RW", 0, 14'h0, 1, 0, 0);
    endfunction
endclass

class reg_model extends uvm_reg_block;
    `uvm_object_utils(reg_model)

    rand reg_state  reg_state_h;
    rand reg_A      reg_A_h;
    rand reg_B      reg_B_h;
    rand reg_C      reg_C_h;

    bus_sequencer     sequencer_h;

    function new(string name="reg_model");
        super.new(name, UVM_NO_COVERAGE);
    endfunction

    function void build();
        reg_state_h = reg_state::type_id::create("reg_state_h");
        reg_state_h.configure(this);
        reg_state_h.build();

        reg_A_h = reg_A::type_id::create("reg_A_h");
        reg_A_h.configure(this);
        reg_A_h.build();

        reg_B_h = reg_B::type_id::create("reg_B_h");
        reg_B_h.configure(this);
        reg_B_h.build();

        reg_C_h = reg_C::type_id::create("reg_C_h");
        reg_C_h.configure(this);
        reg_C_h.build();

        map_default_state();
        lock_model();
    endfunction

    function void re_map(bit is_default_state);
      unlock_model();
      unregister(default_map);
      default_map = null;
      if(is_default_state)
        map_default_state();
      else 
        map_other_state();
      lock_model();
      default_map.set_sequencer(sequencer_h, sequencer_h.adapter_h);
    endfunction

    function void map_default_state();
        default_map = create_map("default_map", 'h0, 2, UVM_LITTLE_ENDIAN);
        default_map.add_reg(reg_state_h, 16'h0, "RW");
        default_map.add_reg(reg_A_h, 16'h1, "RW");
        default_map.add_reg(reg_B_h, 16'h2, "RW");
        default_map.add_reg(reg_C_h, 16'h3, "RW");
    endfunction

    function void map_other_state();
        default_map = create_map("default_map", 'h0, 2, UVM_LITTLE_ENDIAN);
        default_map.add_reg(reg_state_h, 16'h0, "RW");
        default_map.add_reg(reg_A_h, 16'h8, "RW");
        default_map.add_reg(reg_B_h, 16'h9, "RW");
        default_map.add_reg(reg_C_h, 16'ha, "RW");
    endfunction
endclass
