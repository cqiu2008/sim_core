`include "share/intf/dut_intf.sv"
`include "share/clk_rst/clk_rst_source.sv"
`include "share/clk_rst/clk_gen_exp_cfg.sv"

module tb_dut_top;
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
initial begin
   	$helloworld;
	begin
		////wait(U0_dut_top.S_ddr_rdy); 
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

//assign dut_if.S_sub_lb_clk = S_312m5_clk	;	




//====tsk localbus
//====WriteFpgaReg
task WriteFpgaReg;
	input [15:0]I_localbus_addr;
	input [15:0]I_localbus_data;
begin
	//(1) initial signal
	dut_if.S_sub_cs_n	<= 1'b1		;
	dut_if.S_sub_rd_n	<= 1'b1		;
	dut_if.S_sub_wr_n	<= 1'b1		;
	dut_if.S_sub_addr	<= 16'h0	;
	dut_if.S_sub_din	<= 16'h0	;
	//(2) active low the S_arm_wr_en  
	////(1)first step load the cpu address and cpu input data
	repeat(1) @(posedge dut_if.S_sub_lb_clk);        
	dut_if.S_sub_addr	<= I_localbus_addr	;
	dut_if.S_sub_din	<= I_localbus_data	;
	dut_if.S_sub_cs_n	<= 1'b1		;
	dut_if.S_sub_rd_n	<= 1'b1		;
	dut_if.S_sub_wr_n	<= 1'b1		;
	////(2)second step active the cs_n
	repeat(2) @(posedge dut_if.S_sub_lb_clk);        
	dut_if.S_sub_cs_n	<= 1'b0;
	////(3)third step active the wr_n
	repeat(2) @(posedge dut_if.S_sub_lb_clk);        
	dut_if.S_sub_wr_n	<= 1'b0;
	repeat(2) @(posedge dut_if.S_sub_lb_clk);        
	////(4)four step set ctrl signal default value 
	dut_if.S_sub_cs_n	<= 1'b1		;
	dut_if.S_sub_rd_n	<= 1'b1		;
	dut_if.S_sub_wr_n	<= 1'b1		;
	////(5)five step set the default value
	repeat(2) @(posedge dut_if.S_sub_lb_clk);        
	dut_if.S_sub_addr	<= 16'h0	;
	dut_if.S_sub_din	<= 16'h0	;
end
endtask


task sendPkgClear;
begin
	dut_if.S_xgmii_txd			= 32'h07070707; 
	dut_if.S_xgmii_txc			= 4'hf ; 
	dut_if.S_xgmii_txport_num	= 2'h0 ;
end
endtask

var bit[31:0]arrayXgmiiTxd1[0:28]={
	32'hfb55_5555,32'h5555_55d5,32'h0000_0100,32'h0001_0010,32'h9400_0002,32'h8100_0064,
	32'hfe02_0001,32'h0070_0403,32'h0201_1211,32'h4847_4645,32'h4443_4241,32'h4039_3837,
	32'h3635_3433,32'h3231_3029,32'h2827_2625,32'h2423_2221,32'h2019_1817,32'h1615_1413,
	32'h1211_1009,32'h0807_0605,32'h0403_0201,32'h0403_0201,32'h1413_1211,32'h2423_2221,
	32'h3433_3231,32'h0095_0bf2,32'hf5e6_83e2,32'hda9f_1667,32'h086e_4bfd
	};
var bit[31:0]arrayXgmiiTxc1[0:28]={
	4'h8,4'h0,4'h0,4'h0,4'h0,4'h0,
	4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,
	4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,
	4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,
	4'h0,4'h0,4'h0,4'h0,4'h1
};

task sendPkgRun;
begin
	sendPkgClear;
	repeat(1) @(negedge S_312m5_clk);        
	for(int i=0;i<29;i++)begin
		dut_if.S_xgmii_txd	= arrayXgmiiTxd1[i];
		dut_if.S_xgmii_txc	= arrayXgmiiTxc1[i];
		repeat(1) @(negedge S_312m5_clk);        
	end
	sendPkgClear;
	repeat(1000) @(negedge S_312m5_clk);        
	sendPkgClear;

end
endtask

//====Initial body
initial begin
	sendPkgClear;
	WriteFpgaReg(16'h0,16'h0);
	#10000;
	WriteFpgaReg(16'h0310,16'h0002);
	WriteFpgaReg(16'h0313,16'h0f0f);
	WriteFpgaReg(16'h0314,16'h000f);
	WriteFpgaReg(16'h031e,16'h0007);
	for(int i=0;i<99999;i++)begin
		sendPkgRun;
	end
end


endmodule


