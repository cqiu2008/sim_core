`include "utb/env/eth_env.sv"
`include "utb/env/localbus_env.sv"
`include "utc/qst_vrd_uvm_vvd1602_ddr3_tc3_qclzw/intf/initial_signal_drive_tc.sv"
import uvm_pkg::*;
import eth_pkg::*;
import localbus_pkg::*;

class tc_base extends uvm_test;
	eth_env env_eth;
	localbus_env env_localbus;
	extern function new(string name = "tc_base",uvm_component parent=null);
	extern virtual function void build_phase(uvm_phase phase);
	`uvm_component_utils(tc_base)
endclass

function tc_base::new(string name= "tc_base",uvm_component parent = null);
	super.new(name,parent);
	env_eth = new("env_eth",this);
	env_localbus = new("env_localbus",this);
	initial_signal_drive_tc();
endfunction

function void tc_base::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

class qst_vrd_uvm_vvd1602_ddr3_tc3_qclzw extends tc_base;
	eth_private_config eth_private_cfg[16];
	eth_public_config  eth_public_cfg	  ;
	localbus_config	localbus_cfg[2]	;
	bit [7:0] eth_cfg_mem[0:32767];
	extern function new(string name="qst_vrd_uvm_vvd1602_ddr3_tc3_qclzw",uvm_component parent = null);
	extern virtual function void build_phase(uvm_phase phase);
	`uvm_component_utils(qst_vrd_uvm_vvd1602_ddr3_tc3_qclzw);
endclass

function qst_vrd_uvm_vvd1602_ddr3_tc3_qclzw::new(string name = "qst_vrd_uvm_vvd1602_ddr3_tc3_qclzw",uvm_component parent = null);
	super.new(name,parent);
endfunction

function void qst_vrd_uvm_vvd1602_ddr3_tc3_qclzw::build_phase(uvm_phase phase);
	string i_str;
	int bs_ad; /// the base address of the memory
	bit [0:7][31:0]eth_private_cfg_vlan_word_mem;
	bit [0:511][7:0]eth_private_cfg_sub_head_mem;
	super.build_phase(phase);
	for(int i=0;i<16;i++)
	begin
		i_str = $psprintf("[%0d]",i);		
		eth_private_cfg[i]	= eth_private_config::type_id::create({"eth_private_cfg",i_str});
	end
	eth_public_cfg	= eth_public_config::type_id::create("eth_public_cfg");
	for(int i=0;i<2;i++)
	begin
		i_str = $psprintf("[%0d]",i);
		localbus_cfg[i] = localbus_config::type_id::create({"localbus_cfg",i_str});
	end
	$readmemh("../../tb/utc/qst_vrd_uvm_vvd1602_ddr3_tc3_qclzw/config_data/SIM_FPGA_CFG_TOP/SIM_ETH/SimEthStream.dat",eth_cfg_mem);	
	//$readmemh("../../../tb/utc/qst_vrd_uvm_vvd1602_ddr3_tc3_qclzw/config_data/SIM_FPGA_CFG_TOP/DUT_FPGA_CFG/FPGA.dat",localbus_cfg_mem);	
	//(1) public stream config
	//==== common config
		eth_public_cfg.stream_num				= eth_cfg_mem[0];
		eth_public_cfg.pck_num					= {	eth_cfg_mem[1],eth_cfg_mem[2],
													eth_cfg_mem[3],eth_cfg_mem[4] };
		eth_public_cfg.pck_speed				= {eth_cfg_mem[5],eth_cfg_mem[6]};
		eth_public_cfg.burst_num				= {eth_cfg_mem[7],eth_cfg_mem[8]};
		eth_public_cfg.burst_begin_num			= {	eth_cfg_mem[9],eth_cfg_mem[10],
													eth_cfg_mem[11],eth_cfg_mem[12]};
		eth_public_cfg.burst_end_num			= {	eth_cfg_mem[13],eth_cfg_mem[14],
													eth_cfg_mem[15],eth_cfg_mem[16]};
		eth_public_cfg.vif_mode					= 8'h00;//0:10g32b,1:10g64b,2:1g8b,3:2g5,4:100m,5:10m
		eth_public_cfg.refm_chk					= 8'h00;//bit0:check 1588,bit1:check oam,active high
	//(2) private stream config
	bs_ad = 1024;/// the base address of the memory
	for(int i=0;i<16;i++)
	begin
		for(int j=0;j<8;j++)
		begin
			eth_private_cfg_vlan_word_mem[j] = {eth_cfg_mem[bs_ad+28+4*j],eth_cfg_mem[bs_ad+29+4*j],
										eth_cfg_mem[bs_ad+30+4*j],eth_cfg_mem[bs_ad+31+4*j] };
		end
		for(int j=0;j<512;j++)
		begin
			eth_private_cfg_sub_head_mem[j] = eth_cfg_mem[bs_ad+64+j] ;
		end
    	eth_private_cfg[i].port_num					=  eth_cfg_mem[bs_ad][5:4];
    	eth_private_cfg[i].set_err					=  eth_cfg_mem[bs_ad][3:0];
    	eth_private_cfg[i].pck_freq					= {eth_cfg_mem[bs_ad+1],eth_cfg_mem[bs_ad+2]};
    	eth_private_cfg[i].pload_set_type			= eth_cfg_mem[bs_ad+3];//4'b1100;//b3=1,fix_length (b2-b0:random,fix,increase)
    	eth_private_cfg[i].pload_set_length			= {eth_cfg_mem[bs_ad+4],eth_cfg_mem[bs_ad+5]};
    	eth_private_cfg[i].pload_set_fix_value		= eth_cfg_mem[bs_ad+6];
    	eth_private_cfg[i].pload_set_inc_value		= eth_cfg_mem[bs_ad+7];
    	eth_private_cfg[i].random_length_low		= {eth_cfg_mem[bs_ad+8],eth_cfg_mem[bs_ad+9]};
    	eth_private_cfg[i].random_length_high		= {eth_cfg_mem[bs_ad+10],eth_cfg_mem[bs_ad+11]};
    	eth_private_cfg[i].preamble_type			= eth_cfg_mem[bs_ad+12]	;
    	eth_private_cfg[i].sfd						= eth_cfg_mem[bs_ad+13]	;
    	eth_private_cfg[i].dmac						= {	eth_cfg_mem[bs_ad+14],eth_cfg_mem[bs_ad+15],	
														eth_cfg_mem[bs_ad+16],eth_cfg_mem[bs_ad+17],	
														eth_cfg_mem[bs_ad+18],eth_cfg_mem[bs_ad+19] }; 
    	eth_private_cfg[i].smac						= { eth_cfg_mem[bs_ad+20],eth_cfg_mem[bs_ad+21],
														eth_cfg_mem[bs_ad+22],eth_cfg_mem[bs_ad+23],
														eth_cfg_mem[bs_ad+24],eth_cfg_mem[bs_ad+25] };
    	eth_private_cfg[i].vlan_word_size			= {eth_cfg_mem[bs_ad+26],eth_cfg_mem[bs_ad+27]};
		eth_private_cfg[i].vlan_word_mem			= eth_private_cfg_vlan_word_mem;
    	eth_private_cfg[i].eth_type					= {eth_cfg_mem[bs_ad+60],eth_cfg_mem[bs_ad+61]};
    	eth_private_cfg[i].sub_head_size			= {eth_cfg_mem[bs_ad+62],eth_cfg_mem[bs_ad+63]};
    	eth_private_cfg[i].sub_head_mem				= eth_private_cfg_sub_head_mem; 
		bs_ad = bs_ad + 1024;
	end
	//(3) localbus config
	localbus_cfg[0].mem_path = "../../tb/utc/qst_vrd_uvm_vvd1602_ddr3_tc3_qclzw/config_data/SIM_FPGA_CFG_TOP/DUT_FPGA_CFG/FPGA.dat";
	localbus_cfg[0].oam_table_path = "../../tb/utc/qst_vrd_uvm_vvd1602_ddr3_tc3_qclzw/config_data/SIM_FPGA_CFG_TOP/DUT_FPGA_CFG/FPGA_OAM_TABLE.dat";
	localbus_cfg[0].vif_mode= 8'h0;//0:sub module,1:whole module,2:spi module  
	eth_public_cfg.oam_table_path = localbus_cfg[0].oam_table_path; 
	eth_public_cfg.localbus_mem_path= localbus_cfg[0].mem_path; 
	eth_public_cfg.port_mode=16'b10;//bit0:=1,oam tx,=0,oam rx;bit1:reserved for 1588
	eth_public_cfg.port_num=4'b0;//=4'b0,port0;4'd1,port1;4'd2,port2;4'd3,port3
	//通知env.i_agt.sqr,让其运行到main_phase时自动启动前面定义的eth_input_seq
    uvm_config_db#(uvm_object_wrapper)::set(this,"env_eth.input_agt.sqr.main_phase","default_sequence",eth_input_seq::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this,"env_localbus.input_agt.sqr.main_phase","default_sequence",localbus_input_seq::type_id::get());
	for(int i=0;i<16;i++)
	begin
		i_str = $psprintf("[%0d]",i);		
		uvm_config_db#(eth_private_config)::set(this,{"env_eth.input_agt.sqr"},{"eth_private_cfg",i_str},eth_private_cfg[i]);
		uvm_config_db#(eth_private_config)::set(this,{"env_eth.input_agt.drv"},{"eth_private_cfg",i_str},eth_private_cfg[i]);
		uvm_config_db#(eth_private_config)::set(this,{"env_eth.output_agt.mon"},{"eth_private_cfg",i_str},eth_private_cfg[i]);
		eth_private_cfg[i].print();
	end
	uvm_config_db#(eth_public_config)::set(this,{"env_eth.input_agt.sqr"},"eth_public_cfg",eth_public_cfg);
	uvm_config_db#(eth_public_config)::set(this,{"env_eth.input_agt.drv"},"eth_public_cfg",eth_public_cfg);
	uvm_config_db#(eth_public_config)::set(this,{"env_eth.output_agt.mon"},"eth_public_cfg",eth_public_cfg);
	uvm_config_db#(eth_public_config)::set(this,{"env_eth.my_eth_model"},"eth_public_cfg",eth_public_cfg);
	eth_public_cfg.print();
	for(int i=0;i<2;i++)
	begin
		i_str = $psprintf("[%0d]",i);		
		uvm_config_db#(localbus_config)::set(this,{"env_localbus.input_agt.sqr"},{"localbus_cfg",i_str},localbus_cfg[i]);
		uvm_config_db#(localbus_config)::set(this,{"env_localbus.input_agt.drv"},{"localbus_cfg",i_str},localbus_cfg[i]);
		//uvm_config_db#(localbus_config)::set(this,{"env_localbus.input_agt.drv"},{"localbus_cfg",i_str},localbus_cfg[i]);
	end
endfunction
