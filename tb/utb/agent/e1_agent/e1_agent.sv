//`include "uvm_macros.svh"
import uvm_pkg::*;

class e1_agent extends uvm_agent;
    e1_input_sequencer sqr;
    e1_input_driver drv;
    e1_output_monitor mon;
	e1_input_monitor mon_in;

    extern function new (string name,uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);


    uvm_analysis_port#(e1_seq_item) ap;

    `uvm_component_utils_begin(e1_agent)
        `uvm_field_object(sqr,UVM_ALL_ON)
        `uvm_field_object(drv,UVM_ALL_ON)
        `uvm_field_object(mon,UVM_ALL_ON)
        `uvm_field_object(mon_in,UVM_ALL_ON)
    `uvm_component_utils_end
endclass

function e1_agent::new(string name ,uvm_component parent);
	super.new(name,parent);
endfunction

function void e1_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(is_active == UVM_ACTIVE) begin
        sqr = e1_input_sequencer::type_id::create("sqr",this);
        drv = e1_input_driver::type_id::create("drv",this);
        mon_in= e1_input_monitor::type_id::create("mon_in",this);
    end
    else begin
        mon = e1_output_monitor::type_id::create("mon",this);

		//uvm_config_db#(bit[1:0])::set(this,"*.sqr.*","sync_ctrl_seq",mon.sync_ctrl_mon);

	end
endfunction

function void e1_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(is_active == UVM_ACTIVE) begin
        drv.seq_item_port.connect(sqr.seq_item_export);
        this.ap = drv.drv2refm_port;
    end
    else begin
        this.ap = mon.tx_mon2scb_port;
    end
endfunction
