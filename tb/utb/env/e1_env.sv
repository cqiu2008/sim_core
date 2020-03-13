`include "utb/scoreboard/e1_scoreboard.sv"
`include "utb/refm/e1_refm.sv"
class e1_env extends uvm_env;
	e1_agent input_agt[16];//用于向DUT发送数据在实例化中，配置为ACTIVE模式
	e1_agent output_agt[16];//用于向DUT接收数据，配置为PASSIVE模式
	e1_refm  my_e1_refm[16];//实例化model和scoreboard
	e1_scoreboard my_e1_scb[16];
	//bit [15:0] ch_num;

	//====定义了三个fifo，用于连接scoreboard的两个接口
	//====还有reference model的一个接口
	uvm_tlm_analysis_fifo #(e1_seq_item) agt_scb_fifo[16];//o_agt-->scb
	uvm_tlm_analysis_fifo #(e1_seq_item) agt_mdl_fifo[16];//i_agt-->ref
	uvm_tlm_analysis_fifo #(e1_seq_item) mdl_scb_fifo[16];//ref -->scb

	extern function new(string name,uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);

//	virtual function set_e1_ch_num(bit [15:0] ch_num=16'h0);
//		this.ch_num = ch_num;
//	endfunction 


	//====register
	`uvm_component_utils(e1_env)

endclass

function e1_env::new(string name,uvm_component parent);
	super.new(name,parent);

endfunction


function void e1_env::build_phase(uvm_phase phase);
	string i_str;
	super.build_phase(phase);
	
	
	for(int i=0;i<16;i=i+1)
	begin
		i_str = $psprintf("[%0d]",i);
		//i_str = $psprintf("input_agt[%0d]",i); 
		input_agt[i]  = new({"input_agt",i_str},this);
		output_agt[i] = new({"output_agt",i_str},this);
		input_agt[i].is_active = UVM_ACTIVE;//配置input_agent为ACTIVE模式
		output_agt[i].is_active = UVM_PASSIVE;//配置output_agent为PASSIVE模式

		my_e1_refm[i] = new({"my_e1_refm",i_str},this);
		my_e1_scb[i]  = new({"my_e1_scb",i_str},this);

		agt_scb_fifo[i] = new({"agt_scb_fifo",i_str},this); 
		agt_mdl_fifo[i] = new({"agt_mdl_fifo",i_str},this);
		mdl_scb_fifo[i] = new({"mdl_scb_fifo",i_str},this);

		uvm_config_db#(bit[15:0])::set(this,{"input_agt",i_str,".drv"},"ch_num",i);
		uvm_config_db#(bit[15:0])::set(this,{"input_agt",i_str,".mon_in"},"ch_num",i);
		uvm_config_db#(bit[15:0])::set(this,{"output_agt",i_str,".mon"},"ch_num",i);
		uvm_config_db#(bit[15:0])::set(this,{"my_e1_scb",i_str},"ch_num",i);
//my_e1_scb
		

	end

//		uvm_config_db#(bit[15:0])::set(this,{i_str,".input_agt.mon_in"},"ch_num",i);
//		uvm_config_db#(bit[15:0])::set(this,{i_str,".output_agt.mon"},"ch_num",i);
	//set_e1_ch_num(ch_num);
	//uvm_config_db#(bit[1:0])::set(this,"input_agt.sqr","sync_ctrl_seq",output_agt.mon.sync_ctrl_mon);
	//uvm_config_db#(bit[1:0])::set(this,"input_agt.sqr","sync_ctrl_seq",2'b11);
	//uvm_config_db#(bit[1:0])::set(this,"*","sync_ctrl_seq",sync_ctrl_mon);

	//	uvm_config_db#(bit[15:0])::set(this,{i_str,".input_agt.drv"},"ch_num",i);
	//	uvm_config_db#(bit[15:0])::set(this,{i_str,".input_agt.mon_in"},"ch_num",i);
	//	uvm_config_db#(bit[15:0])::set(this,{i_str,".output_agt.mon"},"ch_num",i);

	

endfunction


//==== this most important thing
function void e1_env::connect_phase(uvm_phase phase);
	super.connect_phase(phase);

	for(int i=0;i<16;i=i+1)
	begin
	//====(1)
	//====i_agt ---> fifo
	input_agt[i].ap.connect(agt_mdl_fifo[i].analysis_export);
	//====fifo agent (driver)--> mdl (referenct model) 
	my_e1_refm[i].port.connect(agt_mdl_fifo[i].blocking_get_export);

	//====(2)fifo mdl --> scb
	my_e1_refm[i].ap.connect(mdl_scb_fifo[i].analysis_export);
	my_e1_scb[i].exp_port.connect(mdl_scb_fifo[i].blocking_get_export);

	//====(3)fifo agt (monitor) --> scb
	output_agt[i].ap.connect(agt_scb_fifo[i].analysis_export);
	my_e1_scb[i].act_port.connect(agt_scb_fifo[i].blocking_get_export);

	////=== pointer
	input_agt[i].sqr.out_mon = output_agt[i].mon;
	end

endfunction

