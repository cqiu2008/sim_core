`timescale 1ns/1ps
//`include "intf/nr8120_intf.sv"
module dut_top (
//====Golble Signal 
input		I_rst_n				,
//====CLOCK
input		I_10m_clk			,	
input		I_25m_clk			,	
input		I_33m_clk			,	
input		I_40m_clk			,	
input		I_66m_clk			,	
input		I_312m5_clk		    ,	
input		I_156m25_clk		,	
input		I_125m_clk			
);
/////////////////////////////////

wire [15:0] IO_cpu_data			;
wire		S_ddr_rdy			;
assign S_156m25_clk_n 	= ~ I_156m25_clk;
assign S_125m_clk_n 	= ~ I_125m_clk 	;
assign S_312m5_clk_n 	= ~ I_312m5_clk	;

//assign 	IO_cpu_data = dut_if.S_brd_data_en ? dut_if.S_brd_data:16'hz; 
assign dut_if.S_sub_lb_clk = I_312m5_clk ;

assign dut_if.S_xgmii_rxd = dut_if.S_xgmii_txd	; 
assign dut_if.S_xgmii_rxc = dut_if.S_xgmii_txc	; 
assign dut_if.S_xgmii_rxport_num = dut_if.S_xgmii_txport_num; 

endmodule