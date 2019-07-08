//`include "uvm_macros.svh"
//import uvm_pkg::*;

class e1_input_sequencer extends uvm_sequencer #(e1_seq_item);
	bit[1:0] sync_ctrl_seq		;
	e1_output_monitor out_mon 	; //// this pointer point to the instance of e1_output_monitor
								  //// in order to detect the "sync_ctrl_mon" signal
	e1_config e1_cfg			;
    //Component
    extern function new (string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
   //extern task main_phase(uvm_phase phase);

    //Register
    `uvm_component_utils_begin(e1_input_sequencer)
		`uvm_field_object(e1_cfg,UVM_ALL_ON | UVM_REFERENCE)
	`uvm_component_utils_end
endclass

function e1_input_sequencer::new(string name , uvm_component parent);
    super.new(name,parent);
	sync_ctrl_seq = 2'b01;
	out_mon = null;
	e1_cfg	= e1_config::type_id::create("e1_cfg");
endfunction

function void e1_input_sequencer::build_phase(uvm_phase phase);
    super.build_phase(phase);
	//uvm_config_db#(bit[1:0])::get(this,"","sync_ctrl_seq",sync_ctrl_seq); // by cqiu 
    // === use the methord of no "uvm_config_db get function"
	uvm_config_db#(e1_config)::get(this,"","e1_cfg",e1_cfg); // by cqiu 
endfunction

//e1_input_sequencer是一个参数化的类，其参数是e1_seq_item,用于表明这个
//sequencer只能产生e1_seq_item类型的数据

/*
task e1_input_sequencer::main_phase(uvm_phase phase);//sequence通过如下方式启动
	e1_input_seq my_seq;
    super.main_phase(phase);
    my_seq = new("my_seq");//调用my_seq的start参数，传入的参数是input_agt.sqr,
    //需要指明这个sequence会向那个sequencer发送数据，
    my_seq.starting_phase = phase;
    my_seq.start(this);//my_seq的body开始执行
endtask
*/


