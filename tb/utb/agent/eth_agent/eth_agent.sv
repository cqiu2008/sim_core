//`include "uvm_macros.svh"
//import uvm_pkg::*;

class eth_agent extends uvm_agent;
    eth_input_sequencer sqr;
    eth_input_driver drv;
    eth_output_monitor mon;

    extern function new (string name,uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

    uvm_analysis_port#(eth_seq_item) ap;

//	uvm_blocking_get_port#(eth_seq_item) port;

    `uvm_component_utils_begin(eth_agent)
        `uvm_field_object(sqr,UVM_ALL_ON)
        `uvm_field_object(drv,UVM_ALL_ON)
        `uvm_field_object(mon,UVM_ALL_ON)
    `uvm_component_utils_end
endclass

function eth_agent::new(string name ,uvm_component parent);
    super.new(name,parent);
endfunction

function void eth_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(is_active == UVM_ACTIVE) begin
        sqr = eth_input_sequencer::type_id::create("sqr",this);
        drv = eth_input_driver::type_id::create("drv",this);
    end
    else begin
        mon = eth_output_monitor::type_id::create("mon",this);
    end
endfunction

function void eth_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(is_active == UVM_ACTIVE) begin
        drv.seq_item_port.connect(sqr.seq_item_export);
        this.ap = drv.ap;
    end
    else begin
        this.ap = mon.ap;
		//mon.port = this.port;
		//this.port = mon.port;
		//mon.port = this.port;
    end
endfunction
