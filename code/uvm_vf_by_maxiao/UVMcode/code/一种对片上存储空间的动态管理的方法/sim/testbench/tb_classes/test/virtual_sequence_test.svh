
class virtual_sequence_test extends base_test;
   `uvm_component_utils(virtual_sequence_test)

   virtual_sequence virtual_sequence_h;
      
   function new(string name, uvm_component parent);
      super.new(name,parent);
      virtual_sequence_h = virtual_sequence::type_id::create("virtual_sequence_h");
   endfunction : new

   function void connect_phase(uvm_phase phase);
        virtual_sequence_h.sequencer_h = env_h.agent_h.sequencer_h;
        virtual_sequence_h.bus_sequencer_h = env_h.bus_agent_h.sequencer_h;
        env_h.bus_agent_h.sequencer_h.reg_model_h = env_h.reg_model_h;
        env_h.scoreboard_h.reg_model_h = env_h.reg_model_h;
   endfunction

   task main_phase(uvm_phase phase);
    phase.raise_objection(this);

		  allocate_using_mam(1000, 1024*1024*1024);
		  //allocate_using_mam_new(5000, 1024*1024*1024);

    phase.drop_objection(this);
   endtask

	task allocate_using_mam_new(int alloc_num,longint memory_size);
		int allocs_to_do = alloc_num/3;
		int remain_allocs_to_do = alloc_num - allocs_to_do - allocs_to_do;
		longint start_time, finish_time;
    uvm_mem_region alloc_region;
    uvm_mem_region alloc_region_q[$];
    uvm_mem_mam_policy alloc =new();
		uvm_mem_mam_cfg_new my_cfg= new();
		uvm_mem my_mem = new("my_mem", memory_size, 32);
		uvm_mem_mam_new my_mam = new("my_mam", my_cfg, my_mem);
    bit[63:0] min_offset;
    bit[63:0] max_offset;
    bit[63:0] max_offset_tmp=0;
		my_cfg.n_bytes = 1;
		my_cfg.start_offset = 0;
		my_cfg.end_offset = memory_size;

    record_time(start_time);

		my_cfg.new_mode = MANUAL_FIT;
    for(int i=0;i<allocs_to_do;i++)begin
      std::randomize(min_offset, max_offset) with{
        min_offset > (max_offset_tmp + 'd100*i);
        min_offset < (max_offset_tmp + 'd100*i + 'd100);
        (max_offset - min_offset) > 'd0;
        (max_offset - min_offset) < 'd100;
      };
      //`uvm_info(this.get_name(),$sformatf("min offset is %0d, max ofset is %0d",min_offset,max_offset),UVM_LOW)
      max_offset_tmp = max_offset;
      alloc.min_offset = min_offset;
      alloc.max_offset = max_offset;
      alloc_region = my_mam.request_region_new(100,alloc);
		  if(alloc_region == null)
		  	`uvm_error("DEMO_TEST", "Failed to allocate a mem region")
      else begin
        alloc_region_q.push_back(alloc_region);
        `uvm_info("MAM_NEW -> MANUAL_FIT",$sformatf("alloc_region start_offset:'h%8h - end_offset:'h%8h, len -> %0d",alloc_region.get_start_offset(),alloc_region.get_end_offset(),alloc_region.get_len()),UVM_LOW)
      //my_mam.print_region_q();
      end
    end

		my_cfg.new_mode = FIRST_FIT;
		while(allocs_to_do--) begin
      alloc_region = my_mam.request_region_new(100);
			if(alloc_region == null)
				`uvm_error("DEMO_TEST", "Failed to allocate a mem region")
      else begin
        alloc_region_q.push_back(alloc_region);
        `uvm_info("MAM_NEW -> FIRST_FIT",$sformatf("alloc_region start_offset:'h%8h - end_offset:'h%8h, len -> %0d",alloc_region.get_start_offset(),alloc_region.get_end_offset(),alloc_region.get_len()),UVM_LOW)
      //my_mam.print_region_q();
      end
		end

		my_cfg.new_mode = BEST_FIT;
		while(remain_allocs_to_do--) begin
      alloc_region = my_mam.request_region_new(100);
			if(alloc_region == null)
				`uvm_error("DEMO_TEST", "Failed to allocate a mem region")
      else begin
        alloc_region_q.push_back(alloc_region);
        `uvm_info("MAM_NEW -> BEST_FIT",$sformatf("alloc_region start_offset:'h%8h - end_offset:'h%8h, len -> %0d",alloc_region.get_start_offset(),alloc_region.get_end_offset(),alloc_region.get_len()),UVM_LOW)
      //my_mam.print_region_q();
      end
		end
    
    //`uvm_info(this.get_name(),$sformatf("alloc_region_q size is %0d",alloc_region_q.size()),UVM_LOW)
    foreach(alloc_region_q[idx])begin
      //`uvm_info(this.get_name(),$sformatf("release of alloc_region_q[%0d] start offset is 'h%8h, size is 'd%0d",idx,alloc_region_q[idx].get_start_offset(),alloc_region_q[idx].get_len()),UVM_LOW)
      my_mam.release_region_new(alloc_region_q[idx]);
    end
      my_mam.print_region_q();

    record_time(finish_time);
    report_performance("MAM_NEW",alloc_num,start_time,finish_time);
	endtask

	task allocate_using_mam(int alloc_num,longint memory_size);
		int allocs_to_do = alloc_num;
    uvm_mem_region alloc_region;
    uvm_mem_region alloc_region_q[$];
		longint start_time, finish_time;

		uvm_mem_mam_cfg my_cfg= new();
		uvm_mem my_mem = new("my_mem", memory_size, 32);
		uvm_mem_mam my_mam = new("my_mam", my_cfg, my_mem);
		my_cfg.n_bytes = 1;
		my_cfg.start_offset = 0;
		my_cfg.end_offset = memory_size;

    record_time(start_time);
		while(allocs_to_do--) begin
      alloc_region = my_mam.request_region(100);
      alloc_region_q.push_back(alloc_region);
			if(alloc_region == null)
				`uvm_error("DEMO_TEST", "Failed to allocate a mem region")
      else
        `uvm_info("MAM",$sformatf("alloc_region start_offset:'h%8h - end_offset:'h%8h, len -> %0d",alloc_region.get_start_offset(),alloc_region.get_end_offset(),alloc_region.get_len()),UVM_LOW)
		end

    foreach(alloc_region_q[idx])begin
      my_mam.release_region(alloc_region_q.pop_front());
    end

    record_time(finish_time);
    report_performance("MAM",alloc_num,start_time,finish_time);

	endtask

  task record_time(output longint delta_time);
		int fd;
		$system("date +\"%s\" > time_log");
		fd = $fopen("time_log","r");
		$fscanf(fd,"%d",delta_time);
		$fclose(fd);
  endtask

  task report_performance(string test_type,int alloc_num,longint start_time,longint finish_time);
    longint delta_time;
		delta_time = finish_time - start_time;
		`uvm_info("DEMO_TEST", $sformatf("Time taken for %d allocations using %s: %d seconds", alloc_num, test_type, delta_time), UVM_NONE)
  endtask

endclass


