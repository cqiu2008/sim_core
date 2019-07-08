`include "share/intf/dut_intf.sv"
`include "share/clk_rst/clk_rst_source.sv"
`include "share/clk_rst/clk_gen_exp_cfg.sv"
`include "utb/package/eth_pkg.sv"
`include "utb/package/localbus_pkg.sv"
`include "sva/sva_check_result.sv"

module tb_dut_top;
import uvm_pkg::*;
import eth_pkg::*;
import localbus_pkg::*;
`include "utc/qst_vrd_uvm_vvd1602_ddr3_tc3_qclzw/qst_vrd_uvm_vvd1602_ddr3_tc3_qclzw.sv"
`include "utc/qst_vrd_uvm_vvd1602_ddr3_tc3_qclzw/intf/dut_top.sv"
wire		S_rst_n				;
wire		S_10m_clk			;
wire		S_25m_clk			;
wire		S_40m_clk			;
wire		S_33m_clk			;
wire		S_50m_clk			;
wire		S_66m_clk			;
wire		S_312m5_clk			;
wire		S_156m25_clk		;
wire		S_125m_clk			;
//==LocalBus
////====clock generator
clk_rst_source U0_clk_rst_source (
	.O_10m_clk		(S_10m_clk		),
	.O_25m_clk		(S_25m_clk		),
	.O_40m_clk		(S_40m_clk		),
	.O_33m_clk		(S_33m_clk		),
	.O_50m_clk		(S_50m_clk		),
	.O_66m_clk		(S_66m_clk		),
	.O_312m5_clk	(S_312m5_clk	),
	.O_156m25_clk	(S_156m25_clk	),
	.O_125m_clk		(S_125m_clk		),
	.O_rst_n		(S_rst_n		)	
 );
////====interface
dut_intf dut_if(
	.I_10m_clk		(S_10m_clk		),
	.I_25m_clk		(S_25m_clk		),
	.I_40m_clk		(S_40m_clk		),
	.I_50m_clk		(S_50m_clk		),
	.I_66m_clk		(S_66m_clk		),
	.I_312m5_clk	(S_312m5_clk	),
	.I_156m25_clk	(S_156m25_clk	),
	.I_125m_clk		(S_125m_clk		),
	.I_cpu_clk		(S_33m_clk		),
	.I_rst_n		(S_rst_n		)
);	
//====dut 
dut_top U0_dut_top (
	.I_rst_n			(S_rst_n			),
	.I_10m_clk			(S_10m_clk			),
	.I_25m_clk			(S_25m_clk			),
	.I_33m_clk			(S_33m_clk			),
	.I_40m_clk			(S_40m_clk			),
	.I_66m_clk			(S_66m_clk			),
	.I_312m5_clk		(S_312m5_clk		),
	.I_156m25_clk		(S_156m25_clk		),
	.I_125m_clk			(S_125m_clk			)
);
//==== eth check
sva_check_result U_sva_check_eth_result (
	.sva_clk 		(dut_if.I_312m5_clk			),
	.sva_sync_state	(dut_if.S_eth_sync_state	),
	.sva_chk_edge 	(dut_if.S_eth_chk_edge		),
	.sva_chk_result (dut_if.S_eth_chk_result	)
);
initial begin
   	$helloworld;
	begin
		wait(U0_dut_top.S_ddr_rdy); 
		$fsdbDumpvars("+fsdbfile+tb_dut_top.fsdb");
		/*
		$fsdbDumpMDA(U0_dut_top.U0_rcu_pla_top_32bit.U02_pla_backward_top_32bit.U02_pla_backward_parser_32bit.U0_pla_backward_id_calc.S_pla_slice_id,0,8);
		$fsdbDumpMDA(U0_dut_top.U0_rcu_pla_top_32bit.U02_pla_backward_top_32bit.U02_pla_backward_parser_32bit.U0_pla_backward_id_calc.S_pla_slice_id_temp,0,8);
		$fsdbDumpMDA(U0_dut_top.U0_rcu_pla_top_32bit.U02_pla_backward_top_32bit.U02_pla_backward_parser_32bit.U0_pla_backward_id_calc.S_pla_slice_id_max_temp1,0,4);
		$fsdbDumpMDA(U0_dut_top.U0_rcu_pla_top_32bit.U02_pla_backward_top_32bit.U02_pla_backward_parser_32bit.U0_pla_backward_id_calc.S_pla_slice_id_max_temp2,0,2);
		$fsdbDumpMDA(U0_dut_top.U0_rcu_pla_top_32bit.U02_pla_backward_top_32bit.U02_pla_backward_parser_32bit.U0_pla_backward_id_calc.S_pla_slice_id_min_temp1,0,4);
		$fsdbDumpMDA(U0_dut_top.U0_rcu_pla_top_32bit.U02_pla_backward_top_32bit.U02_pla_backward_parser_32bit.U0_pla_backward_id_calc.S_pla_slice_id_min_temp2,0,2);
		$fsdbDumpMDA(U0_dut_top.U0_rcu_pla_top_32bit.U02_pla_backward_top_32bit.U02_pla_backward_parser_32bit.U0_pla_backward_id_calc.S_pla_slice_id_bigger_temp1,0,4);
		$fsdbDumpMDA(U0_dut_top.U0_rcu_pla_top_32bit.U02_pla_backward_top_32bit.U02_pla_backward_parser_32bit.U0_pla_backward_id_calc.S_pla_slice_id_bigger_temp2,0,2);
		$fsdbDumpMDA(U0_dut_top.U0_rcu_pla_top_32bit.U02_pla_backward_top_32bit.U02_pla_backward_parser_32bit.U0_pla_backward_id_calc.S_pla_slice_id_smaller_temp1,0,4);
		$fsdbDumpMDA(U0_dut_top.U0_rcu_pla_top_32bit.U02_pla_backward_top_32bit.U02_pla_backward_parser_32bit.U0_pla_backward_id_calc.S_pla_slice_id_smaller_temp2,0,2);
		*/
		$fsdbDumpSVA;
	end
end

////====fsdb
initial begin
    //====config_db  set      my_if    driver  monitor
    //====Driver  monitor          DUT      
	//==== eth_env
	    uvm_config_db#(virtual dut_intf)::set(null,"uvm_test_top.env_eth.input_agt.drv","dut_intf",dut_if);
		uvm_config_db#(virtual dut_intf)::set(null,"uvm_test_top.env_eth.output_agt.mon","dut_intf",dut_if);
		uvm_config_db#(virtual dut_intf)::set(null,"uvm_test_top.env_eth.my_eth_scb","dut_intf",dut_if);
		uvm_config_db#(virtual dut_intf)::set(null,"uvm_test_top.env_eth.my_eth_model","dut_intf",dut_if);
	//==== utb body
    run_test();
end

endmodule


