//`include "uvm_macros.svh"
//import uvm_pkg::*;

class eth_input_sequencer extends uvm_sequencer #(eth_seq_item);
    //Component
	eth_private_config eth_private_cfg[16]; //// config
	eth_public_config  eth_public_cfg; //// config
	eth_output_monitor out_mon; //// this pointer point to the instance of eth_output_monitor
								  	   //// in order to detect the "sync_ctrl_mon" signal
	bit [1:0] sync_sqr_state ;


    extern function new (string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    //extern task eth_input_sequencer::main_phase(uvm_phase phase);

    //Register
    `uvm_component_utils_begin(eth_input_sequencer)
		`uvm_field_object(eth_private_cfg[0],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[1],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[2],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[3],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[4],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[5],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[6],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[7],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[8],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[9],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[10],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[11],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[12],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[13],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[14],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[15],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_public_cfg	 ,UVM_ALL_ON | UVM_REFERENCE)
	`uvm_component_utils_end
endclass

function eth_input_sequencer::new(string name , uvm_component parent);
	string i_str ;
    super.new(name,parent);
	out_mon = null;
	sync_sqr_state = 2'b00;
	for(int i=0;i<16;i++)
	begin
		i_str = $psprintf("[%0d]",i);
		eth_private_cfg[i] = eth_private_config::type_id::create({"eth_private_cfg",i_str});
	end
		eth_public_cfg	   = eth_public_config::type_id::create("eth_public_cfg");
endfunction
/*task eth_input_sequencer::main_phase(uvm_phase phase);//sequence通过如下方式启动
    hello_sequence my_seq;//实例化一个sequence
    super.main_phase(phase);
    my_seq = new("my_seq");//调用my_seq的start参数，传入的参数是input_agt.sqr,
    //需要指明这个sequence会向那个sequencer发送数据，
    my_seq.starting_phase = phase;
    my_seq.start(this);//my_seq的body开始执行
endtask*/
function void eth_input_sequencer::build_phase(uvm_phase phase);
	string i_str;
    super.build_phase(phase);
	for(int i=0;i<16;i++)
	begin
		i_str = $psprintf("[%0d]",i);
		uvm_config_db#(eth_private_config)::get(this,"",{"eth_private_cfg",i_str},eth_private_cfg[i]); // by cqiu 
	end
		uvm_config_db#(eth_public_config)::get(this,"","eth_public_cfg",eth_public_cfg); // by cqiu 
endfunction
//eth_input_sequencer是一个参数化的类，其参数是eth_seq_item,用于表明这个
//sequencer只能产生eth_seq_item类型的数据
