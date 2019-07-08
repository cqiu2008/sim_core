
class e1_input_monitor extends uvm_monitor;
	//==== virtual interface
	virtual dut_intf vintf;
	bit [15:0] ch_num ;

	bit checks_enable ;
	bit coverage_enable ;

	//====用于从driver 获取数据
	//uvm_blocking_get_port #(e1_seq_item) drv_port;


	extern function new(string name,uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);

	//// covergroup
	covergroup sim_e1_cov ;//@(negedge vintf.sim_e1_clk[ch_num]);
	//covergroup sim_e1_cov ; 
		E1_SIM_BIT: coverpoint vintf.sim_e1_bit[ch_num] 
		{
			bins hit_ones  = {1};
			bins hit_zeros = {0};
		}
	endgroup

	//====register
	`uvm_component_utils (e1_input_monitor)

endclass

function e1_input_monitor::new(string name,uvm_component parent);
	super.new(name,parent);
	//// covergroup
	sim_e1_cov = new();
	coverage_enable = 1;
	ch_num = 16'h0;
endfunction

function void  e1_input_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
		//drv_port = new("drv_port",this);
	if(!uvm_config_db#(virtual dut_intf)::get(this,"","dut_intf",vintf))
		`uvm_fatal("e1_input_monitor","Error in Geting Interface");
	//==== get the ch_num from the testcase
	uvm_config_db#(bit[15:0])::get(this,"","ch_num",ch_num);

//	if(!uvm_config_db#(virtual dut_intf)::get(this,"","dut_intf",vintf))
//		`uvm_fatal("e1_input_driver","Error in Getting interface");
endfunction

task e1_input_monitor::main_phase(uvm_phase phase);
	super.main_phase(phase);

	while(coverage_enable)
	begin
		@(negedge vintf.sim_e1_clk[ch_num]);
		sim_e1_cov.sample();
	end

endtask




