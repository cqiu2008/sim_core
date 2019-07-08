//`include "uvm_macros.svh"
//import uvm_pkg::*;

class localbus_agent extends uvm_agent;
	localbus_input_sequencer sqr;
	localbus_input_driver drv;
	extern function new(string name,uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	uvm_analysis_port#(localbus_seq_item) ap;
	`uvm_component_utils_begin(localbus_agent)
		`uvm_field_object(sqr,UVM_ALL_ON)
		`uvm_field_object(drv,UVM_ALL_ON)
	`uvm_component_utils_end
endclass

function localbus_agent::new(string name,uvm_component parent);
	super.new(name,parent);
endfunction

function void localbus_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(is_active == UVM_ACTIVE) begin
		sqr = localbus_input_sequencer::type_id::create("sqr",this);
		drv = localbus_input_driver::type_id::create("drv",this);
	end
endfunction

function void localbus_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	if(is_active == UVM_ACTIVE)begin
		drv.seq_item_port.connect(sqr.seq_item_export);
		this.ap = drv.ap;
	end
endfunction


