
class transformer#(int addr_i_width = 8,data_i_width = 16,addr_o_width = 8,data_o_width = 16) extends uvm_component;
  `uvm_component_param_utils(transformer#(addr_i_width,data_i_width,addr_o_width,data_o_width))
  
  bit[3:0] result_q[$];
  
  function new (string name, uvm_component parent);
    super.new(name, parent);
    for(bit[3:0] i=1;i<='d10;i++)begin
      result_q.push_back(i);
    end
    result_q.shuffle();
  endfunction : new
  
  function out_trans#(addr_o_width,data_o_width) transform(in_trans#(addr_i_width,data_i_width) in_tr,output bit vld);
    out_trans#(addr_o_width,data_o_width) out_tr;;
    out_tr = new("out_tr");

    if(in_tr.vld_i)begin
      if(result_q.size())begin
        out_tr.vld_o = 1;
        out_tr.result = result_q.pop_front();
      end
      else begin
        out_tr.vld_o = 0;
        out_tr.result = 0;
      end
      out_tr.addr_o = in_tr.addr_i;
      out_tr.data_o = in_tr.data_i;
    end
    else begin
      out_tr.vld_o  = 0;
      out_tr.result = 0;
      out_tr.addr_o = 0;
      out_tr.data_o = 0;
    end
    `uvm_info("TRANSFORMER",$sformatf("predict out trans is %s",out_tr.convert2string),UVM_LOW)
    if(out_tr.vld_o)begin
      vld = 1;
      return out_tr;
    end
    else begin
      vld = 0;
      return null;
    end
  endfunction
endclass 


