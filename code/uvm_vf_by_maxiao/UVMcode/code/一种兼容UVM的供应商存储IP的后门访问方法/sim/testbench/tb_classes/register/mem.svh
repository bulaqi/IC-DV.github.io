
class mem extends uvm_mem;
    `uvm_object_utils(mem)
    
    function new(string name = "mem");
        super.new(name, 10, 16);
    endfunction

endclass
