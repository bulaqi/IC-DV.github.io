
package uvm_mem_manager_pkg;
	
		`include "uvm_macros.svh"
		import uvm_pkg::*;
	
  typedef enum {FIRST_FIT=0, BEST_FIT=1, MANUAL_FIT=3} new_alloc_mode_e;

	`include "uvm_mem_mam_cfg_new.svh"
	`include "uvm_mem_mam_new.svh"
endpackage
