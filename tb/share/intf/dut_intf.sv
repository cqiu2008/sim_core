`timescale 1ns/1ps
//`include "sva/sva_check_result.sv"
interface dut_intf(
input       I_10m_clk		,    
input       I_25m_clk		,
input       I_40m_clk		,    
input       I_50m_clk       ,   
input       I_66m_clk       ,   
input       I_312m5_clk     ,   
input       I_156m25_clk	,   
input       I_125m_clk		,   
input [15:0]sim_e1_clk		,	
input		I_cpu_clk		,
input       I_rst_n			
);

//////// logic design
//// localbus rx_data_mdio_valid ,using in the mdio bus,when the receive data is valid , active it
logic [3:0]		S_mdio_state	;	
//// sub module localbus
logic			S_sub_lb_clk	; 
logic			S_sub_cs_n		; 
logic			S_sub_rd_n		; 
logic			S_sub_wr_n		; 
logic [15:0]	S_sub_addr		; 
logic [15:0]	S_sub_din		; 
//// board level localbus		;
logic			S_brd_lae		;// idle state ready for write data 
logic			S_brd_cs_n		; 
logic			S_brd_rd_n		; 
logic			S_brd_wr_n		; 
logic [9:0]		S_brd_haddr		; 
logic [15:0]	S_brd_data		; 
logic 			S_brd_data_en	; 


//// rpea spi localbus,whole localbus 
logic 			S_arm_wr_en			;//// active low
logic 			S_arm_rd_en			;//// active low
logic 			S_arm_spi_cs		;//// active low
logic 			S_arm_spi_clk		;
logic 			S_arm_spi_sdi		;
logic 			S_arm_spi_sdo		;
//// traffic  
logic			S_eth_sync_state	;
logic			S_eth_chk_edge		;
logic			S_eth_chk_result	;
//// traffic 2g5 16bit 
logic [15:0]	S_egmii_txd			;
logic			S_egmii_txen		;
logic			S_egmii_txmod		;
logic [15:0]	S_egmii_rxd			;
logic			S_egmii_rxen		;
logic			S_egmii_rxmod		;
//// traffic 1g 8bit
logic [7:0]		S_gmii_txd			;
logic			S_gmii_txen			;
logic			S_gmii_txerr		;
logic [7:0]		S_gmii_rxd			;
logic			S_gmii_rxen			;
logic			S_gmii_rxerr		;
logic [3:0]		S_gmii_port_info	;
//// traffic 10g 32bit
logic [31:0]	S_xgmii_txd 		; 
logic [3:0]		S_xgmii_txc 		; 
logic 			S_xgmii_txcrc_err 	; 
logic [ 1:0]	S_xgmii_txport_num	;
logic [31:0]	S_xgmii_rxd 		; 
logic [3:0]		S_xgmii_rxc 		; 
logic 			S_xgmii_rxcrc_err	; 
logic [ 1:0]	S_xgmii_rxport_num	;
//// traffic 10g 64bit
logic [63:0] 	S_xgmii64b_txd		;
logic [ 7:0] 	S_xgmii64b_txc		;
logic [63:0] 	S_xgmii64b_rxd		;
logic [ 7:0] 	S_xgmii64b_rxc		;
bit				S_xgmii64b_rxclk	;

////

//// traffic E1 2.048M 
//bit	  [15:0]	sim_e1_clk			;	
bit	  [15:0]	sim_e1_bit			;	
bit	  [15:0]	dut_e1_clk			;	
bit   [15:0]	dut_e1_bit			;	
bit	  [15:0]	ref_e1_clk			;	
bit   [15:0]	ref_e1_bit			;	

bit	  [15:0]	e1_sync_state		;
bit	  [15:0]	e1_chk_edge			;
bit	  [15:0] 	e1_chk_result		;

///from model to DUT
//clocking clk_drv_e1 @(posedge sim_e1_clk);
//	output #1 sim_e1_bit;
//endclocking
//modport drv_e1(clocking clk_drv_e1);
//
//clocking clk_mon_e1 @(posedge sim_e1_clk);
//	input #1 sim_e1_bit;
//endclocking
//modport mon_e1(clocking clk_mon_e1);

//// oam Ctrl
logic [63:0]	S_sub_oam_system_timestamp;

//// 1G 1588 Ctrl
logic [63:0]	S_cf				;
logic [31:0]	S_reserved			;
logic [ 1:0]	S_valid_negedge 	;////when =10,means need to sample 

endinterface
