
`timescale 1ns/1ns
import uvm_pkg::*;
import e1_pkg::*;

class e1_scoreboard extends  uvm_scoreboard;
	virtual dut_intf vif;
	bit [15:0] ch_num;
	e1_seq_item q_expect[$];
	//====用于从reference_model获取数据
	uvm_blocking_get_port #(e1_seq_item) exp_port;

	//====用于从monitor的ap获取数据
	uvm_blocking_get_port #(e1_seq_item) act_port;

	`uvm_component_utils(e1_scoreboard)

	extern function new(string name,uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);

endclass

function e1_scoreboard::new(string name,uvm_component parent);
	super.new(name,parent);
endfunction

function void e1_scoreboard::build_phase(uvm_phase phase);
	super.build_phase(phase);
	exp_port = new("exp_port",this);
	act_port = new("act_port",this);
	if(!uvm_config_db#(virtual dut_intf)::get(this,"","dut_intf",vif))
        `uvm_fatal("e1_scoreboard","Error in Geting interface");
	//==== get the ch_num from the testcase
	uvm_config_db#(bit[15:0])::get(this,"","ch_num",ch_num);


endfunction

task e1_scoreboard::main_phase(uvm_phase phase);
	e1_seq_item get_export,get_actual,tmp_tran;
	bit result;
	vif.e1_chk_edge[ch_num] = 1'b0;

	super.main_phase(phase);

	fork
	//====从reference model中获取数据
	while(1) 
	begin
		exp_port.get(get_export);
		//get_export.print();
		q_expect.push_back(get_export);
		//$display("QIU CHAO q_expect\n");
	end

	//====从monitor中获取数据
	while(1)
	begin
		//#30ns ;
		act_port.get(get_actual);
		if(q_expect.size()>0)
		begin
			//===pop_front属于队列内建函数，与uvm无关
			tmp_tran = q_expect.pop_front();
			result = get_actual.compare(tmp_tran);
			vif.e1_chk_result[ch_num] = result;
			if(result)
			begin
				$display("E1 channel %d Compare Successfully",ch_num);
			end
			else
			begin
				$display("E1 channel %d Compare Failed",ch_num);
				$display("The channel %d expect pkg is",ch_num);
				tmp_tran.print();
				$display("The channel %d actual pkg is",ch_num);
				get_actual.print();
			end
			vif.e1_chk_edge[ch_num] = ~vif.e1_chk_edge[ch_num]; 

		end
		else
		begin
			$display("ERROR::Received from DUT,while Expect Queue is Empty");
			get_actual.print();
		end
	end
	join
endtask
