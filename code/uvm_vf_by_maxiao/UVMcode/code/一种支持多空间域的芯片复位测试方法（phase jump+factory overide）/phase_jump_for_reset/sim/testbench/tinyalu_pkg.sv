
package tinyalu_pkg;
   import uvm_pkg::*;
`include "uvm_macros.svh"
      typedef enum bit[2:0] {no_op  = 3'b000,
                             add_op = 3'b001, 
                             and_op = 3'b010,
                             xor_op = 3'b011,
                             mul_op = 3'b100} operation_t;

      typedef enum{bus_rd, bus_wr} bus_op_t;

//transaction
`include "sequence_item.svh"   
`include "reset_item.svh"   
`include "result_transaction.svh"
`include "bus_transaction.svh"

//register
`include "ctrl_reg.svh"
`include "status_reg.svh"
`include "reg_model.svh"
`include "adapter.svh"
`include "bus_sequencer.svh"   
`include "predictor.svh"   

//sequence
`include "random_sequence.svh"
`include "reset_sequence.svh"
`include "extra_sequence.svh"
`include "bus_sequence.svh"
`include "reg_access_sequence.svh"

//component
`include "reset_config.svh"   
`include "reset_monitor.svh"   
`include "reset_driver.svh"   
`include "reset_sequencer.svh"   
`include "reset_agent.svh"   
`include "sequencer.svh"   
`include "scoreboard.svh"
`include "driver.svh"
`include "bus_driver.svh"
`include "command_monitor.svh"
`include "result_monitor.svh"
`include "bus_monitor.svh"
`include "agent.svh"
`include "bus_agent.svh"
`include "env.svh"

`include "virtual_sequence.svh"

//test
`include "base_test.svh"
`include "demo_test.svh"

endpackage : tinyalu_pkg
   
