
package demo_pkg;
   import uvm_pkg::*;
`include "uvm_macros.svh"

//transaction
`include "in_trans.svh"   
`include "out_trans.svh"

//sequence
`include "random_sequence.svh"

//component
`include "transformer.svh"   
`include "sequencer.svh"   
`include "driver.svh"
`include "in_monitor.svh"
`include "out_monitor.svh"
`include "agent.svh"
`include "env.svh"

//test
`include "base_test.svh"
`include "demo_test.svh"

endpackage 
   
