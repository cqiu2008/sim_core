
//`ifndef LOCALBUS_PKG_DEF 
//`define LOCALBUS_PKG_DEF
package localbus_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	`include "utb/config/localbus_config.sv"
	`include "utb/agent/localbus_agent/localbus_seq_item.sv"
	`include "utb/agent/localbus_agent/localbus_input_sequencer.sv"
	`include "utb/agent/localbus_agent/localbus_input_seq.sv"
	`include "utb/agent/localbus_agent/localbus_input_driver.sv"
	`include "utb/agent/localbus_agent/localbus_agent.sv"
	//`include "testbench/env/localbus_env.sv"
	//`include "testbench/agent/localbus_output_monitor.sv"

endpackage
//`endif
