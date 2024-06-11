
`ifndef UVM_MEM_MAM_NEW
`define UVM_MEM_MAM_NEW

class uvm_mem_mam_new extends uvm_mem_mam;
  local uvm_mem_mam_cfg_new new_cfg;
  local uvm_mem_region in_free[$];
  local uvm_mem_region in_use[$];

  int unsigned size;
  int first_idx;
  int last_idx;

	function new(string name, uvm_mem_mam_cfg_new new_cfg, uvm_mem mem=null);
    uvm_mem_region first_free;
		super.new(name,new_cfg,mem);
    this.new_cfg = new_cfg;
    first_free = new(0,mem.get_size()-1,mem.get_size(),mem.get_n_bits(),this);
    in_free.push_back(first_free);
	endfunction

  function uvm_mem_region request_region_new(int unsigned n_bytes, uvm_mem_mam_policy alloc = null);
    uvm_mem_region free_region_handle;
    int in_free_idx;
    first_idx = 0;
    last_idx = in_free.size()-1;

    case(new_cfg.new_mode)
      uvm_mem_manager_pkg::FIRST_FIT:begin
        free_region_handle = in_free[last_idx];
        return reserve_region_new(0,free_region_handle,n_bytes);
      end
      uvm_mem_manager_pkg::BEST_FIT:begin
        free_region_handle = get_free_region_handle(n_bytes,in_free_idx);
        return reserve_region_new(in_free_idx,free_region_handle,n_bytes);
      end
      uvm_mem_manager_pkg::MANUAL_FIT:begin
        if(alloc == null) alloc = this.default_alloc;
        if(!alloc.randomize())begin
          `uvm_error("RegModel","Unable to randomize policy")
          return null;
        end
        free_region_handle = get_free_region_handle_for_manual(n_bytes,alloc.start_offset,in_free_idx);
        if(free_region_handle == null)begin
          `uvm_error("RegModel","Failed to get free region")
          return null;
        end
        else begin
          return reserve_region_new_for_manual(in_free_idx,free_region_handle,n_bytes,alloc.start_offset);
        end
      end
      default:;//add more allocate mode, todo...
    endcase
  endfunction

  //just get a free_region, which size >= n_bytes, and start_offset <= policy's start_ofset , end_offset >= policy's start_offset + n_bytes -1
  function uvm_mem_region get_free_region_handle_for_manual(int unsigned n_bytes, bit[63:0] start_offset,output int in_free_idx);
    int mid_idx;
    int last_in_use_idx;
    int last_in_free_idx = in_free.size()-1;
    first_idx = 0;
    last_idx = in_use.size()-1;
    in_free_idx = 0;
    if(in_use.size()!=0)begin
      last_in_use_idx = in_use.size()-1 ;
    end
    if((in_free[0].get_len() < n_bytes) || (start_offset > this.get_memory().get_size()))begin
      `uvm_error("RegModel","Failed to get free region")
      return null;
    end

    case(in_use.size())
      0:begin
        in_free_idx = 0;
        return in_free[0];
      end
      1,2:begin
        for(int i=0;i<in_free.size();i++)begin //in_free size max is 2, 3
          if((in_free[i].get_len() >= n_bytes) && (in_free[i].get_start_offset() <= start_offset) && (in_free[i].get_end_offset() >= (start_offset+n_bytes-1)))begin
            in_free_idx = i;
            return in_free[i];
          end
        end
        `uvm_error("RegModel","Failed to get free region")
        return null;
      end
      default:begin
        while(1)begin
          mid_idx = (first_idx + last_idx)/2;
          if(start_offset > in_use[mid_idx].get_start_offset())begin
            if(start_offset <= in_use[mid_idx+1].get_start_offset())begin
              return search_free_region_handle_for_manual(n_bytes,start_offset,in_use[mid_idx],in_use[mid_idx+1],in_free_idx);
            end
            else begin
              if((mid_idx+1) == (in_use.size()-1))begin
                if(start_offset <= in_use[mid_idx+1].get_end_offset())begin
                  `uvm_error("RegModel","Failed to get free region")
                  return null;
                end
                else begin
                  if((in_free[last_in_free_idx].get_len()>=n_bytes) && (in_free[last_in_free_idx].get_start_offset()<=start_offset) && (in_free[last_in_free_idx].get_end_offset()>=(start_offset+n_bytes-1)))begin
                    in_free_idx = last_in_free_idx;
                    return in_free[last_in_free_idx];
                  end
                  else begin
                    `uvm_error("RegModel","Failed to get free region")
                    return null;
                  end
                end
              end
              else begin
                first_idx = mid_idx;
                continue;
              end
            end
          end
          else if(start_offset == in_use[mid_idx].get_start_offset())begin
            `uvm_error("RegModel","Failed to get free region")
            return null;
          end
          else begin//mean start_offset < in_use[mid_idx].get_start_offset()
            if(start_offset >= in_use[mid_idx-1].get_start_offset())begin
              return search_free_region_handle_for_manual(n_bytes,start_offset,in_use[mid_idx-1],in_use[mid_idx],in_free_idx);
            end
            else begin
              if((mid_idx-1) == 0)begin
                if(start_offset <= in_use[mid_idx-1].get_end_offset())begin
                  `uvm_error("RegModel","Failed to get free region")
                  return null;
                end
                else begin
                  if((in_free[0].get_len()>=n_bytes) && (in_free[0].get_start_offset()<=start_offset) && (in_free[0].get_end_offset()>=(start_offset+n_bytes-1)))begin
                    in_free_idx = 0;
                    return in_free[0];
                  end
                  else begin
                    `uvm_error("RegModel","Failed to get free region")
                    return null;
                  end
                end
              end
              else begin
                last_idx = mid_idx;
                continue;
              end
            end
          end
        end
      end
    endcase
  endfunction

  function uvm_mem_region search_free_region_handle_for_manual(int unsigned n_bytes, bit[63:0] start_offset, uvm_mem_region up_use_region, uvm_mem_region down_use_region, output int in_free_idx);
    int unsigned free_region_size = down_use_region.get_start_offset() - up_use_region.get_end_offset -1;
    bit[63:0] free_region_start_offset = up_use_region.get_end_offset +1;
    int mid_idx;
    first_idx = 0;
    last_idx = in_free.size()-1;

    if(start_offset <= up_use_region.get_end_offset())begin
      `uvm_error("RegModel","Failed to get free region")
      return null;
    end
    if((start_offset+n_bytes-1) >= down_use_region.get_start_offset())begin
      `uvm_error("RegModel","Failed to get free region")
      return null;
    end
    //search free region in in_free for which size is (in_use[mid_idx+1].start_offset - in_use[mid_idx].end_offset -1), and start_offset is (in_use[mid_idx].end_offset + 1)
    case(in_free.size())
      0,1,2,3:begin
        `uvm_error("RegModel","Failed to get free region")
        return null;
      end
      default:begin
        while(1)begin
          mid_idx = (first_idx + last_idx)/2;
          if(free_region_size > in_free[mid_idx].get_len())begin
            if(free_region_size == in_free[mid_idx+1].get_len())begin
              while(1)begin
                if(free_region_start_offset == in_free[mid_idx+1].get_start_offset())begin
                  in_free_idx = mid_idx+1;
                  return in_free[mid_idx+1];
                end
                if(((mid_idx+1) == (in_free.size()-1)) ||  (in_free[mid_idx+1].get_len() > free_region_size))begin
                  `uvm_error("RegModel","Failed to get free region")
                  return null;
                end
                mid_idx++;
              end
            end
            else begin//mean free_region_size > in_free[mid_idx+1].get_len()
              first_idx = mid_idx;
              continue;
            end
          end
          else if(free_region_size == in_free[mid_idx].get_len())begin
            if(free_region_start_offset == in_free[mid_idx].get_start_offset())begin
              in_free_idx = mid_idx;
              return in_free[mid_idx];
            end
            else begin
              int mid_idx_tmp = mid_idx;
              while(1)begin
                mid_idx_tmp++;
                if(free_region_start_offset == in_free[mid_idx_tmp].get_start_offset())begin
                  in_free_idx = mid_idx_tmp;
                  return in_free[mid_idx_tmp];
                end
                if((mid_idx_tmp == (in_free.size()-1)) ||  (in_free[mid_idx_tmp].get_len() > free_region_size))begin
                  mid_idx_tmp = mid_idx;
                  while(1)begin
                    mid_idx_tmp--;
                    if(free_region_start_offset == in_free[mid_idx_tmp].get_start_offset())begin
                      in_free_idx = mid_idx_tmp;
                      return in_free[mid_idx_tmp];
                    end
                    if((mid_idx_tmp == 0) ||  (in_free[mid_idx_tmp].get_len() < free_region_size))begin
                      `uvm_error("RegModel","Failed to get free region")
                      return null;
                    end
                  end
                end
              end
            end
          end
          else begin//mean free_region_size < in_free[mid_idx].get_len()
            if(free_region_size == in_free[mid_idx-1].get_len())begin
              while(1)begin
                if(free_region_start_offset == in_free[mid_idx-1].get_start_offset())begin
                  in_free_idx = mid_idx-1;
                  return in_free[mid_idx-1];
                end
                if(((mid_idx-1) == 0) ||  (in_free[mid_idx-1].get_len() < free_region_size))begin
                  `uvm_error("RegModel","Failed to get free region")
                  return null;
                end
                mid_idx--;
              end
            end
            else begin
              last_idx = mid_idx;
              continue;
            end
          end
        end
      end
    endcase
  endfunction

  function uvm_mem_region reserve_region_new_for_manual(int in_free_idx,uvm_mem_region free_region_handle,int unsigned n_bytes,bit[63:0] start_offset);
    uvm_mem_region alloc_region;
    uvm_mem_region rest_free_region;
    if(free_region_handle.get_len() > n_bytes)begin
      if(free_region_handle.get_start_offset() == start_offset)begin
        alloc_region = new(start_offset,start_offset+n_bytes-1,n_bytes,this.get_memory().get_n_bits(),this);
        rest_free_region = new(alloc_region.get_end_offset()+1,free_region_handle.get_end_offset(),free_region_handle.get_len()-n_bytes,this.get_memory().get_n_bits(),this);
        in_free.delete(in_free_idx);
        add_region_to_in_free(rest_free_region);
        add_region_to_in_use(alloc_region);
        return alloc_region;
      end
      else begin //start_offset > free_region_handle.get_start_offset(),mean here exist at least two reset free region need to be write into the in_free
        if((free_region_handle.get_end_offset() - start_offset + 1) > n_bytes)begin
          in_free.delete(in_free_idx);
          rest_free_region = new(free_region_handle.get_start_offset(),start_offset-1,start_offset-free_region_handle.get_start_offset(),this.get_memory().get_n_bits(),this);
          add_region_to_in_free(rest_free_region);
          alloc_region = new(start_offset,start_offset+n_bytes-1,n_bytes,this.get_memory().get_n_bits(),this);
          add_region_to_in_use(alloc_region);
          rest_free_region = new(start_offset+n_bytes,free_region_handle.get_end_offset(),free_region_handle.get_end_offset()-alloc_region.get_end_offset(),this.get_memory().get_n_bits(),this);
          add_region_to_in_free(rest_free_region);
          return alloc_region;
        end
        else if((free_region_handle.get_end_offset() - start_offset + 1) < n_bytes)begin
          `uvm_error("RegModel","Failed to allocate mem region")
          return null;
        end
        else begin
          in_free.delete(in_free_idx);
          rest_free_region = new(free_region_handle.get_start_offset(),start_offset-1,start_offset-free_region_handle.get_start_offset(),this.get_memory().get_n_bits(),this);
          add_region_to_in_free(rest_free_region);
          alloc_region = new(start_offset,start_offset+n_bytes-1,n_bytes,this.get_memory().get_n_bits(),this);
          add_region_to_in_use(alloc_region);
          return alloc_region;
        end
      end
    end
    else if(free_region_handle.get_len() < n_bytes)begin
      `uvm_error("RegModel","Failed to allocate mem region")
      return null;
    end
    else begin
      alloc_region = new(free_region_handle.get_start_offset(),free_region_handle.get_end_offset(),n_bytes,this.get_memory().get_n_bits(),this);
      in_free.delete(in_free_idx);
      add_region_to_in_use(alloc_region);
      return alloc_region;
    end
  endfunction

  function uvm_mem_region reserve_region_new(int in_free_idx,uvm_mem_region free_region_handle,int unsigned n_bytes);
    uvm_mem_region alloc_region;
    uvm_mem_region rest_free_region;
    if(free_region_handle.get_len() > n_bytes)begin
      alloc_region = new(free_region_handle.get_start_offset(),free_region_handle.get_start_offset()+n_bytes-1,n_bytes,this.get_memory().get_n_bits(),this);
      rest_free_region = new(alloc_region.get_end_offset()+1,free_region_handle.get_end_offset(),free_region_handle.get_len()-n_bytes,this.get_memory().get_n_bits(),this);
      if(new_cfg.new_mode == uvm_mem_manager_pkg::FIRST_FIT)
        in_free.delete(last_idx);
      else
        in_free.delete(in_free_idx);
      add_region_to_in_free(rest_free_region);
      add_region_to_in_use(alloc_region);
      return alloc_region;
    end
    else if(free_region_handle.get_len() < n_bytes)begin
      `uvm_error("RegModel","Failed to allocate mem region")
      return null;
    end
    else begin
      alloc_region = new(free_region_handle.get_start_offset(),free_region_handle.get_end_offset(),n_bytes,this.get_memory().get_n_bits(),this);
      if(new_cfg.new_mode == uvm_mem_manager_pkg::FIRST_FIT)
        in_free.delete(last_idx);
      else
        in_free.delete(in_free_idx);
      add_region_to_in_use(alloc_region);
      return alloc_region;
    end
  endfunction

  function uvm_mem_region get_free_region_handle(int unsigned n_bytes, output int in_free_idx);
    int mid_idx;
    first_idx = 0;
    last_idx = in_free.size()-1;
    in_free_idx = 0;
    case(in_free.size())
      0:begin
        `uvm_error("RegModel","Failed to get free region")
        return null;
      end
      1:begin
        if(in_free[0].get_len() >= n_bytes)begin
          in_free_idx = 0;
          return in_free[0];
        end
        else begin
          `uvm_error("RegModel","Failed to get free region")
          return null;
        end
      end
      2:begin
        if(in_free[0].get_len() >= n_bytes)begin
          in_free_idx = 0;
          return in_free[0];
        end
        else begin
          if(in_free[1].get_len() >= n_bytes)begin
            in_free_idx = 1;
            return in_free[1];
          end
          else begin
            `uvm_error("RegModel","Failed to get free region")
            return null;
          end
        end
      end
      default:begin
        while(1)begin
          mid_idx = (first_idx + last_idx)/2;
          if(in_free[mid_idx].get_len() > n_bytes)begin
            if(in_free[mid_idx-1].get_len() <= n_bytes)begin
              in_free_idx = mid_idx;
              return in_free[mid_idx];
            end
            else begin
              if((mid_idx-1) == 0)begin
                in_free_idx = 0;
                return in_free[0];
              end
              else begin
                last_idx = mid_idx;
                continue;
              end
            end
          end
          else if(in_free[mid_idx].get_len() == n_bytes)begin
            in_free_idx = mid_idx;
            return in_free[mid_idx];
          end
          else begin
            if(in_free[mid_idx+1].get_len() >= n_bytes)begin
              in_free_idx = mid_idx+1;
              return in_free[mid_idx+1];
            end
            else begin
              if((mid_idx+1) == (in_free.size()-1))begin
                `uvm_error("RegModel","Failed to get free region")
                return null;
              end
              else begin
                first_idx = mid_idx;
                continue;
              end
            end
          end
        end
      end
    endcase
  endfunction

  function void add_region_to_in_free(uvm_mem_region region);
    int mid_idx;
    first_idx = 0;
    last_idx = in_free.size()-1;
    case(in_free.size())
      0:begin
        in_free.push_back(region);
      end
      1:begin
        if(region.get_len() <= in_free[0].get_len())
          in_free.insert(0,region);
        else
          in_free.push_back(region);
      end
      2:begin
        if(region.get_len() <= in_free[0].get_len())
          in_free.insert(0,region);
        else begin
          if(region.get_len() <= in_free[1].get_len())
            in_free.insert(1,region);
          else
            in_free.push_back(region);
        end
      end
      default:begin
        while(1)begin
          mid_idx = (first_idx + last_idx)/2;
          if(region.get_len() > in_free[mid_idx].get_len())begin
            if(region.get_len() <= in_free[mid_idx+1].get_len())begin
              in_free.insert(mid_idx+1,region);
              break;
            end
            else begin
              if((mid_idx+1) == (in_free.size()-1))begin
                in_free.push_back(region);
                break;
              end
              else begin
                first_idx = mid_idx;
                continue;
              end
            end
          end
          else if(region.get_len() == in_free[mid_idx].get_len())begin
            in_free.insert(mid_idx,region);
            break;
          end
          else begin
            if(region.get_len() >= in_free[mid_idx-1].get_len())begin
              in_free.insert(mid_idx,region);
              break;
            end
            else begin
              if((mid_idx-1) == 0)begin
                in_free.insert(0,region);
                break;
              end
              else begin
                last_idx = mid_idx;
                continue;
              end
            end
          end
        end
      end
    endcase
  endfunction

  function void add_region_to_in_use(uvm_mem_region region);
    int mid_idx;
    first_idx = 0;
    last_idx = in_use.size()-1;
    case(in_use.size())
      0:begin
        in_use.push_back(region);
      end
      1:begin
        if(region.get_start_offset() <= in_use[0].get_start_offset())
          in_use.insert(0,region);
        else
          in_use.push_back(region);
      end
      2:begin
        if(region.get_start_offset() <= in_use[0].get_start_offset())
          in_use.insert(0,region);
        else begin
          if(region.get_start_offset() <= in_use[1].get_start_offset())
            in_use.insert(1,region);
          else
            in_use.push_back(region);
        end
      end
      default:begin
        while(1)begin
          mid_idx = (first_idx + last_idx)/2;
          if(region.get_start_offset() > in_use[mid_idx].get_start_offset())begin
            if(region.get_start_offset() <= in_use[mid_idx+1].get_start_offset())begin
              in_use.insert(mid_idx+1,region);
              break;
            end
            else begin
              if((mid_idx+1) == (in_use.size()-1))begin
                in_use.push_back(region);
                break;
              end
              else begin
                first_idx = mid_idx;
                continue;
              end
            end
          end
          else if(region.get_start_offset() == in_use[mid_idx].get_start_offset())begin
            in_use.insert(mid_idx,region);
            break;
          end
          else begin
            if(region.get_start_offset() >= in_use[mid_idx-1].get_start_offset())begin
              in_use.insert(mid_idx,region);
              break;
            end
            else begin
              if((mid_idx-1) == 0)begin
                in_use.insert(0,region);
                break;
              end
              else begin
                last_idx = mid_idx;
                continue;
              end
            end
          end
        end
      end
    endcase
  endfunction

  function void release_region_new(uvm_mem_region region);
    int unsigned up_size,down_size;
    bit[63:0] up_start_offset,down_start_offset;
    bit[1:0] exist_adjoin;

    //delete alloc_region form in_use
    release_region_of_in_use(region,up_size,up_start_offset,down_size,down_start_offset,exist_adjoin);
    //add or merge region to in_free
    release_region_of_in_free(region,up_size,up_start_offset,down_size,down_start_offset,exist_adjoin);
  endfunction

  function void release_region_of_in_free(uvm_mem_region region,int unsigned up_size,bit[63:0] up_start_offset,int unsigned down_size,bit[63:0] down_start_offset,bit[1:0] exist_adjoin);// exist_adjoin[1] is 1 mean exist up free region,other mean exist down free region
    uvm_mem_region merge_region;
    case(exist_adjoin)
      2'b00:begin
        add_region_to_in_free(region);
      end
      2'b01:begin
        //search and delete adjoin region
        if(!search_delete_free_region_for_release(down_size,down_start_offset))begin
          `uvm_fatal("RegModel","Fail to search and delete the adjoin free regon of in_free")
        end
        //create & merge & add to in_free
        merge_region = new(region.get_start_offset(),down_start_offset+down_size-1,region.get_len()+down_size,this.get_memory().get_n_bits(),this);
        add_region_to_in_free(merge_region);
      end
      2'b10:begin
        if(!search_delete_free_region_for_release(up_size,up_start_offset))begin
          `uvm_fatal("RegModel","Fail to search and delete the adjoin free regon of in_free")
        end
        merge_region = new(up_start_offset,region.get_end_offset(),region.get_len()+up_size,this.get_memory().get_n_bits(),this);
        add_region_to_in_free(merge_region);
      end
      2'b11:begin
        if(!search_delete_free_region_for_release(up_size,up_start_offset))begin
          `uvm_fatal("RegModel","Fail to search and delete the adjoin free regon of in_free")
        end
        if(!search_delete_free_region_for_release(down_size,down_start_offset))begin
          `uvm_fatal("RegModel","Fail to search and delete the adjoin free regon of in_free")
        end
        merge_region = new(up_start_offset,down_start_offset+down_size-1,region.get_len()+up_size+down_size,this.get_memory().get_n_bits(),this);
        add_region_to_in_free(merge_region);
      end
    endcase
  endfunction

  function bit search_delete_free_region_for_release(int unsigned free_region_size, bit[63:0] free_region_start_offset);
    int mid_idx;
    first_idx = 0;
    last_idx = in_free.size()-1;
    //search free region in in_free of free_region_size  & free_region_start_offset 
    //`uvm_info("RegModel",$sformatf("free_region_size is %0d, free_region_start_offset is %0h",free_region_size,free_region_start_offset),UVM_LOW)
    case(in_free.size())
      0:begin
        `uvm_error("RegModel","all mem are occupied!")
        return 0;
      end
      1:begin
        if((free_region_size==in_free[0].get_len()) && (free_region_start_offset == in_free[0].get_start_offset()))begin
          in_free.delete();
          return 1;
        end
        else begin
          `uvm_error("RegModel","Fail to search and delete the adjoin free regon of in_free")
          return 0;
        end
      end
      2:begin
        if((free_region_size==in_free[0].get_len()) && (free_region_start_offset == in_free[0].get_start_offset()))begin
          in_free.delete(0);
          return 1;
        end
        else if((free_region_size==in_free[1].get_len()) && (free_region_start_offset == in_free[1].get_start_offset()))begin
          in_free.delete(1);
          return 1;
        end
        else begin
          `uvm_error("RegModel","Fail to search and delete the adjoin free regon of in_free")
          return 0;
        end
      end
      default:begin
        while(1)begin
          mid_idx = (first_idx + last_idx)/2;
          if(free_region_size > in_free[mid_idx].get_len())begin
            if(free_region_size == in_free[mid_idx+1].get_len())begin
              while(1)begin
                if(free_region_start_offset == in_free[mid_idx+1].get_start_offset())begin
                  in_free.delete(mid_idx+1);
                  return 1;
                end
                if(((mid_idx+1) == (in_free.size()-1)) ||  (in_free[mid_idx+1].get_len() > free_region_size))begin
                  `uvm_error("RegModel","Fail to search and delete the adjoin free regon of in_free")
                  return 0;
                end
                mid_idx++;
              end
            end
            else begin//mean free_region_size > in_free[mid_idx+1].get_len()
              first_idx = mid_idx;
              continue;
            end
          end
          else if(free_region_size == in_free[mid_idx].get_len())begin
            if(free_region_start_offset == in_free[mid_idx].get_start_offset())begin
              in_free.delete(mid_idx);
              return 1;
            end
            else begin
              int mid_idx_tmp = mid_idx;
              while(1)begin
                mid_idx_tmp++;
                if(free_region_start_offset == in_free[mid_idx_tmp].get_start_offset())begin
                  in_free.delete(mid_idx_tmp);
                  return 1;
                end
                if((mid_idx_tmp == (in_free.size()-1)) ||  (in_free[mid_idx_tmp].get_len() > free_region_size))begin
                  mid_idx_tmp = mid_idx;
                  while(1)begin
                    mid_idx_tmp--;
                    if(free_region_start_offset == in_free[mid_idx_tmp].get_start_offset())begin
                      in_free.delete(mid_idx_tmp);
                      return 1;
                    end
                    if((mid_idx_tmp == 0) ||  (in_free[mid_idx_tmp].get_len() < free_region_size))begin
                      `uvm_error("RegModel","Fail to search and delete the adjoin free regon of in_free")
                      return 0;
                    end
                  end
                end
              end
            end
          end
          else begin//mean free_region_size < in_free[mid_idx].get_len()
            if(free_region_size == in_free[mid_idx-1].get_len())begin
              while(1)begin
                if(free_region_start_offset == in_free[mid_idx-1].get_start_offset())begin
                  in_free.delete(mid_idx-1);
                  return 1;
                end
                if(((mid_idx-1) == 0) ||  (in_free[mid_idx-1].get_len() < free_region_size))begin
                  `uvm_error("RegModel","Fail to search and delete the adjoin free regon of in_free")
                  return 0;
                end
                mid_idx--;
              end
            end
            else begin
              last_idx = mid_idx;
              continue;
            end
          end
        end
      end
    endcase
  endfunction

  function void release_region_of_in_use(uvm_mem_region region, output int unsigned up_size, output bit[63:0] up_start_offset,output int unsigned down_size, output bit[63:0] down_start_offset, output bit[1:0] exist_adjoin);// exist_adjoin[0] is 1 mean exist up free region,other mean exist down free region
    int mid_idx;
    first_idx = 0;
    last_idx = in_use.size()-1;
    exist_adjoin = 'h0;
    up_size = 'd0;
    down_size = 'd0;
    up_start_offset = 'd0;
    down_start_offset = 'd0;

    case(in_use.size())
      0:begin
        `uvm_fatal("RegModel","all mem is already free!")
      end
      1:begin
        in_use.delete(0);
        if((region.get_start_offset()==0) && (region.get_end_offset() < (this.get_memory().get_size()-1)))begin
          down_size = this.get_memory().get_size()-region.get_len();
          down_start_offset = region.get_end_offset()+1;
          exist_adjoin = 2'b01;
          return;
        end
        if((region.get_end_offset()==(this.get_memory().get_size()-1)) && (region.get_start_offset() > 0))begin
          up_size = this.get_memory().get_size()-region.get_len();
          up_start_offset = 0;
          exist_adjoin = 2'b10;
          return;
        end
        if((region.get_start_offset()>0) && (region.get_end_offset() < (this.get_memory().get_size()-1)))begin
          up_size = region.get_start_offset();
          up_start_offset = 0;
          down_size = this.get_memory().get_size()-1-region.get_end_offset();
          down_start_offset = region.get_end_offset()+1;
          exist_adjoin = 2'b11;
          return;
        end
        if((region.get_start_offset()==0) && (region.get_end_offset() == (this.get_memory().get_size()-1)))begin
          exist_adjoin = 2'b00;
          return;
        end
      end
      2:begin
        if(region == in_use[0])begin
          if((in_use[0].get_start_offset()==0) && (in_use[0].get_end_offset()==(in_use[1].get_start_offset()-1)) && (in_use[1].get_end_offset()<(this.get_memory().get_size()-1)))begin
            exist_adjoin = 2'b00;
            in_use.delete(0);
            return;
          end
          if((in_use[0].get_start_offset()==0) && (in_use[0].get_end_offset()<(in_use[1].get_start_offset()-1)) && (in_use[1].get_end_offset()<(this.get_memory().get_size()-1)))begin
            exist_adjoin = 2'b01;
            down_size = in_use[1].get_start_offset()-1-(in_use[0].get_end_offset+1)+1;
            down_start_offset = in_use[0].get_end_offset()+1;
            in_use.delete(0);
            return;
          end
          if((in_use[0].get_start_offset()==0) && (in_use[0].get_end_offset()<(in_use[1].get_start_offset()-1)) && (in_use[1].get_end_offset()==(this.get_memory().get_size()-1)))begin
            exist_adjoin = 2'b01;
            down_size = in_use[1].get_start_offset()-1-(in_use[0].get_end_offset+1)+1;
            down_start_offset = in_use[0].get_end_offset()+1;
            in_use.delete(0);
            return;
          end
          if((in_use[0].get_start_offset()==0) && (in_use[0].get_end_offset()==(in_use[1].get_start_offset()-1)) && (in_use[1].get_end_offset()==(this.get_memory().get_size()-1)))begin
            exist_adjoin = 2'b00;
            in_use.delete(0);
            return;
          end
          if((in_use[0].get_start_offset()>0) && (in_use[0].get_end_offset()==(in_use[1].get_start_offset()-1)) && (in_use[1].get_end_offset()<(this.get_memory().get_size()-1)))begin
            exist_adjoin = 2'b10;
            up_size = in_use[0].get_start_offset();
            up_start_offset = 0;
            in_use.delete(0);
            return;
          end
          if((in_use[0].get_start_offset()>0) && (in_use[0].get_end_offset()<(in_use[1].get_start_offset()-1)) && (in_use[1].get_end_offset()<(this.get_memory().get_size()-1)))begin
            exist_adjoin = 2'b11;
            up_size = in_use[0].get_start_offset();
            up_start_offset = 0;
            down_size = in_use[1].get_start_offset()-1-(in_use[0].get_end_offset()+1)+1;
            down_start_offset = in_use[0].get_end_offset()+1;
            in_use.delete(0);
            return;
          end
          if((in_use[0].get_start_offset()>0) && (in_use[0].get_end_offset()==(in_use[1].get_start_offset()-1)) && (in_use[1].get_end_offset()==(this.get_memory().get_size()-1)))begin
            exist_adjoin = 2'b10;
            up_size = in_use[0].get_start_offset();
            up_start_offset = 0;
            in_use.delete(0);
            return;
          end
          if((in_use[0].get_start_offset()>0) && (in_use[0].get_end_offset()<(in_use[1].get_start_offset()-1)) && (in_use[1].get_end_offset()==(this.get_memory().get_size()-1)))begin
            exist_adjoin = 2'b11;
            up_size = in_use[0].get_start_offset();
            up_start_offset = 0;
            down_size = in_use[1].get_start_offset()-1-(in_use[0].get_end_offset()+1)+1;
            down_start_offset = in_use[0].get_end_offset()+1;
            in_use.delete(0);
            return;
          end
        end
        else begin
          if((in_use[0].get_start_offset()==0) && (in_use[0].get_end_offset()==(in_use[1].get_start_offset()-1)) && (in_use[1].get_end_offset()<(this.get_memory().get_size()-1)))begin
            exist_adjoin = 2'b01;
            down_size = this.get_memory().get_size()-1-in_use[1].get_end_offset();
            down_start_offset = in_use[1].get_end_offset()+1;
            in_use.delete(1);
            return;
          end
          if((in_use[0].get_start_offset()==0) && (in_use[0].get_end_offset()<(in_use[1].get_start_offset()-1)) && (in_use[1].get_end_offset()<(this.get_memory().get_size()-1)))begin
            exist_adjoin = 2'b11;
            up_size = in_use[1].get_start_offset()-1-(in_use[0].get_end_offset()+1)+1;
            up_start_offset = in_use[0].get_end_offset()+1;
            down_size = this.get_memory().get_size()-1-in_use[1].get_end_offset();
            down_start_offset = in_use[1].get_end_offset()+1;
            in_use.delete(1);
            return;
          end
          if((in_use[0].get_start_offset()==0) && (in_use[0].get_end_offset()<(in_use[1].get_start_offset()-1)) && (in_use[1].get_end_offset()==(this.get_memory().get_size()-1)))begin
            exist_adjoin = 2'b10;
            up_size = in_use[1].get_start_offset()-1-(in_use[0].get_end_offset()+1)+1;
            up_start_offset = in_use[0].get_end_offset()+1;
            in_use.delete(1);
            return;
          end
          if((in_use[0].get_start_offset()==0) && (in_use[0].get_end_offset()==(in_use[1].get_start_offset()-1)) && (in_use[1].get_end_offset()==(this.get_memory().get_size()-1)))begin
            exist_adjoin = 2'b00;
            in_use.delete(1);
            return;
          end
          if((in_use[0].get_start_offset()>0) && (in_use[0].get_end_offset()==(in_use[1].get_start_offset()-1)) && (in_use[1].get_end_offset()<(this.get_memory().get_size()-1)))begin
            exist_adjoin = 2'b01;
            down_size = this.get_memory().get_size()-1-in_use[1].get_end_offset();
            down_start_offset = in_use[1].get_end_offset()+1;
            in_use.delete(1);
            return;
          end
          if((in_use[0].get_start_offset()>0) && (in_use[0].get_end_offset()<(in_use[1].get_start_offset()-1)) && (in_use[1].get_end_offset()<(this.get_memory().get_size()-1)))begin
            exist_adjoin = 2'b11;
            up_size = in_use[1].get_start_offset()-1-(in_use[0].get_end_offset()+1)+1;
            up_start_offset = in_use[0].get_end_offset()+1;
            down_size = this.get_memory().get_size()-1-in_use[1].get_end_offset();
            down_start_offset = in_use[1].get_end_offset()+1;
            in_use.delete(1);
            return;
          end
          if((in_use[0].get_start_offset()>0) && (in_use[0].get_end_offset()==(in_use[1].get_start_offset()-1)) && (in_use[1].get_end_offset()==(this.get_memory().get_size()-1)))begin
            exist_adjoin = 2'b00;
            in_use.delete(1);
            return;
          end
          if((in_use[0].get_start_offset()>0) && (in_use[0].get_end_offset()<(in_use[1].get_start_offset()-1)) && (in_use[1].get_end_offset()==(this.get_memory().get_size()-1)))begin
            exist_adjoin = 2'b10;
            up_size = in_use[1].get_start_offset()-1-(in_use[0].get_end_offset()+1)+1;
            up_start_offset = in_use[0].get_end_offset()+1;
            in_use.delete(1);
            return;
          end
        end
      end
      default:begin
        while(1)begin
          mid_idx = (first_idx + last_idx)/2;
          if(region.get_start_offset() > in_use[mid_idx].get_start_offset())begin
            if(region.get_start_offset() == in_use[mid_idx+1].get_start_offset())begin
              if((mid_idx+1) == (in_use.size()-1))begin// object mid_idx+1 at bottom
                if((in_use[mid_idx].get_end_offset()==(in_use[mid_idx+1].get_start_offset()-1)) && (in_use[mid_idx+1].get_end_offset()<(this.get_memory().get_size()-1)))begin
                  exist_adjoin = 2'b01;
                  down_size = this.get_memory().get_size()-1-in_use[mid_idx+1].get_end_offset();
                  down_start_offset = in_use[mid_idx+1].get_end_offset()+1;
                  in_use.delete(mid_idx+1);
                  return;
                end
                if((in_use[mid_idx].get_end_offset()<(in_use[mid_idx+1].get_start_offset()-1)) && (in_use[mid_idx+1].get_end_offset()<(this.get_memory().get_size()-1)))begin
                  exist_adjoin = 2'b11;
                  up_size = in_use[mid_idx+1].get_start_offset()-1-(in_use[mid_idx].get_end_offset()+1)+1;
                  up_start_offset = in_use[mid_idx].get_end_offset()+1;
                  down_size = this.get_memory().get_size()-1-in_use[mid_idx+1].get_end_offset();
                  down_start_offset = in_use[mid_idx+1].get_end_offset()+1;
                  in_use.delete(mid_idx+1);
                  return;
                end
                if((in_use[mid_idx].get_end_offset()<(in_use[mid_idx+1].get_start_offset()-1)) && (in_use[mid_idx+1].get_end_offset()==(this.get_memory().get_size()-1)))begin
                  exist_adjoin = 2'b10;
                  up_size = in_use[mid_idx+1].get_start_offset()-1-(in_use[mid_idx].get_end_offset()+1)+1;
                  up_start_offset = in_use[mid_idx].get_end_offset()+1;
                  in_use.delete(mid_idx+1);
                  return;
                end
                if((in_use[mid_idx].get_end_offset()==(in_use[mid_idx+1].get_start_offset()-1)) && (in_use[mid_idx+1].get_end_offset()==(this.get_memory().get_size()-1)))begin
                  exist_adjoin = 2'b00;
                  in_use.delete(mid_idx+1);
                  return;
                end
              end
              else begin//object mid_idx+1 at middle
                if((in_use[mid_idx].get_end_offset()<(in_use[mid_idx+1].get_start_offset()-1)) && (in_use[mid_idx+1].get_end_offset()<(in_use[mid_idx+2].get_start_offset()-1)))begin
                  exist_adjoin = 2'b11;
                  up_size = in_use[mid_idx+1].get_start_offset()-1-(in_use[mid_idx].get_end_offset()+1)+1;
                  up_start_offset = in_use[mid_idx].get_end_offset()+1;
                  down_size = in_use[mid_idx+2].get_start_offset()-1-in_use[mid_idx+1].get_end_offset();
                  down_start_offset = in_use[mid_idx+1].get_end_offset()+1;
                  in_use.delete(mid_idx+1);
                  return;
                end
                if((in_use[mid_idx].get_end_offset()==(in_use[mid_idx+1].get_start_offset()-1)) && (in_use[mid_idx+1].get_end_offset()<(in_use[mid_idx+2].get_start_offset()-1)))begin
                  exist_adjoin = 2'b01;
                  down_size = in_use[mid_idx+2].get_start_offset()-1-in_use[mid_idx+1].get_end_offset();
                  down_start_offset = in_use[mid_idx+1].get_end_offset()+1;
                  in_use.delete(mid_idx+1);
                  return;
                end
                if((in_use[mid_idx].get_end_offset()<(in_use[mid_idx+1].get_start_offset()-1)) && (in_use[mid_idx+1].get_end_offset()==(in_use[mid_idx+2].get_start_offset()-1)))begin
                  exist_adjoin = 2'b10;
                  up_size = in_use[mid_idx+1].get_start_offset()-1-(in_use[mid_idx].get_end_offset()+1)+1;
                  up_start_offset = in_use[mid_idx].get_end_offset()+1;
                  in_use.delete(mid_idx+1);
                  return;
                end
                if((in_use[mid_idx].get_end_offset()==(in_use[mid_idx+1].get_start_offset()-1)) && (in_use[mid_idx+1].get_end_offset()==(in_use[mid_idx+2].get_start_offset()-1)))begin
                  exist_adjoin = 2'b00;
                  in_use.delete(mid_idx+1);
                  return;
                end
              end
            end
            else begin
              first_idx = mid_idx;
              continue;
            end
          end
          else if(region.get_start_offset() == in_use[mid_idx].get_start_offset())begin
            if((in_use[mid_idx-1].get_end_offset()<(in_use[mid_idx].get_start_offset()-1)) && (in_use[mid_idx].get_end_offset()<(in_use[mid_idx+1].get_start_offset()-1)))begin
              exist_adjoin = 2'b11;
              up_size = in_use[mid_idx].get_start_offset()-1-(in_use[mid_idx-1].get_end_offset()+1)+1;
              up_start_offset = in_use[mid_idx-1].get_end_offset()+1;
              down_size = in_use[mid_idx+1].get_start_offset()-1-in_use[mid_idx].get_end_offset();
              down_start_offset = in_use[mid_idx].get_end_offset()+1;
              in_use.delete(mid_idx);
              return;
            end
            if((in_use[mid_idx-1].get_end_offset()==(in_use[mid_idx].get_start_offset()-1)) && (in_use[mid_idx].get_end_offset()<(in_use[mid_idx+1].get_start_offset()-1)))begin
              exist_adjoin = 2'b01;
              down_size = in_use[mid_idx+1].get_start_offset()-1-in_use[mid_idx].get_end_offset();
              down_start_offset = in_use[mid_idx].get_end_offset()+1;
              in_use.delete(mid_idx);
              return;
            end
            if((in_use[mid_idx-1].get_end_offset()<(in_use[mid_idx].get_start_offset()-1)) && (in_use[mid_idx].get_end_offset()==(in_use[mid_idx+1].get_start_offset()-1)))begin
              exist_adjoin = 2'b10;
              up_size = in_use[mid_idx].get_start_offset()-1-(in_use[mid_idx-1].get_end_offset()+1)+1;
              up_start_offset = in_use[mid_idx-1].get_end_offset()+1;
              in_use.delete(mid_idx);
              return;
            end
            if((in_use[mid_idx-1].get_end_offset()==(in_use[mid_idx].get_start_offset()-1)) && (in_use[mid_idx].get_end_offset()==(in_use[mid_idx+1].get_start_offset()-1)))begin
              exist_adjoin = 2'b00;
              in_use.delete(mid_idx);
              return;
            end
          end
          else begin
            if(region.get_start_offset() == in_use[mid_idx-1].get_start_offset())begin
              if((mid_idx-1) == 0)begin// object mid_idx-1 at top
                if((in_use[mid_idx-1].get_start_offset()>0) && (in_use[mid_idx-1].get_end_offset()<(in_use[mid_idx].get_start_offset()-1)))begin
                  exist_adjoin = 2'b11;
                  up_size = in_use[mid_idx-1].get_start_offset();
                  up_start_offset = 0;
                  down_size = in_use[mid_idx].get_start_offset()-1-in_use[mid_idx-1].get_end_offset();
                  down_start_offset = in_use[mid_idx-1].get_end_offset()+1;
                  in_use.delete(mid_idx-1);
                  return;
                end
                if((in_use[mid_idx-1].get_start_offset()==0) && (in_use[mid_idx-1].get_end_offset()==(in_use[mid_idx].get_start_offset()-1)))begin
                  exist_adjoin = 2'b00;
                  in_use.delete(mid_idx-1);
                  return;
                end
                if((in_use[mid_idx-1].get_start_offset()==0) && (in_use[mid_idx-1].get_end_offset()<(in_use[mid_idx].get_start_offset()-1)))begin
                  exist_adjoin = 2'b01;
                  down_size = in_use[mid_idx].get_start_offset()-1-in_use[mid_idx-1].get_end_offset();
                  down_start_offset = in_use[mid_idx-1].get_end_offset()+1;
                  in_use.delete(mid_idx-1);
                  return;
                end
                if((in_use[mid_idx-1].get_start_offset()>0) && (in_use[mid_idx-1].get_end_offset()==(in_use[mid_idx].get_start_offset()-1)))begin
                  exist_adjoin = 2'b10;
                  up_size = in_use[mid_idx-1].get_start_offset();
                  up_start_offset = 0;
                  in_use.delete(mid_idx-1);
                  return;
                end
              end
              else begin//object mid_idx-1 at middle
                if((in_use[mid_idx-2].get_end_offset()<(in_use[mid_idx-1].get_start_offset()-1)) && (in_use[mid_idx-1].get_end_offset()<(in_use[mid_idx].get_start_offset()-1)))begin
                  exist_adjoin = 2'b11;
                  up_size = in_use[mid_idx-1].get_start_offset()-1-(in_use[mid_idx-2].get_end_offset()+1)+1;
                  up_start_offset = in_use[mid_idx-2].get_end_offset()+1;
                  down_size = in_use[mid_idx].get_start_offset()-1-in_use[mid_idx-1].get_end_offset();
                  down_start_offset = in_use[mid_idx-1].get_end_offset()+1;
                  in_use.delete(mid_idx-1);
                  return;
                end
                if((in_use[mid_idx-2].get_end_offset()==(in_use[mid_idx-1].get_start_offset()-1)) && (in_use[mid_idx-1].get_end_offset()<(in_use[mid_idx].get_start_offset()-1)))begin
                  exist_adjoin = 2'b01;
                  down_size = in_use[mid_idx].get_start_offset()-1-in_use[mid_idx-1].get_end_offset();
                  down_start_offset = in_use[mid_idx-1].get_end_offset()+1;
                  in_use.delete(mid_idx-1);
                  return;
                end
                if((in_use[mid_idx-2].get_end_offset()<(in_use[mid_idx-1].get_start_offset()-1)) && (in_use[mid_idx-1].get_end_offset()==(in_use[mid_idx].get_start_offset()-1)))begin
                  exist_adjoin = 2'b10;
                  up_size = in_use[mid_idx-1].get_start_offset()-1-(in_use[mid_idx-2].get_end_offset()+1)+1;
                  up_start_offset = in_use[mid_idx-2].get_end_offset()+1;
                  in_use.delete(mid_idx-1);
                  return;
                end
                if((in_use[mid_idx-2].get_end_offset()==(in_use[mid_idx-1].get_start_offset()-1)) && (in_use[mid_idx-1].get_end_offset()==(in_use[mid_idx].get_start_offset()-1)))begin
                  exist_adjoin = 2'b00;
                  in_use.delete(mid_idx-1);
                  return;
                end
              end
            end
            else begin
              last_idx = mid_idx;
              continue;
            end
          end
        end
      end
    endcase
  endfunction

  function void print_region_q();
     foreach(in_use[idx])begin
       `uvm_info("RegModel",$sformatf("in_use[%0d] start_offset:'h%8h - end_offset:'h%8h, len -> %0d",idx,in_use[idx].get_start_offset(),in_use[idx].get_end_offset(),in_use[idx].get_len()),UVM_LOW)
     end
     foreach(in_free[idx])begin
       `uvm_info("RegModel",$sformatf("in_free[%0d] start_offset:'h%8h - end_offset:'h%8h, len -> %0d",idx,in_free[idx].get_start_offset(),in_free[idx].get_end_offset(),in_free[idx].get_len()),UVM_LOW)
     end
  endfunction

endclass

`endif
