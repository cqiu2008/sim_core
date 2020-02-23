/*******************************************************************************
*
* Confidential:  This file and all files delivered herewith are Micron Confidential Information.
*
*    File Name:  nand_die_model.V
*        Model:  BUS Functional
*    Simulator:  ModelSim
* Dependencies:  nand_parameters.vh
*
*        Email:  modelsupport@micron.com
*      Company:  Micron Technology, Inc.
*  Part Number:  MT29F
*
*  Description:  Micron NAND Verilog Model
*
*   Limitation:
*
*         Note:  This model does not model bit errors on read or write.
                 This model is a superset of all supported Micron NAND devices.
                 The model is configured for a particular device's parameters 
                 and features by the required include file, nand_parameters.vh.
*
*   Disclaimer:  THESE DESIGNS ARE PROVIDED "AS IS" WITH NO WARRANTY
*                WHATSOEVER AND MICRON SPECIFICALLY DISCLAIMS ANY
*                IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR
*                A PARTICULAR PURPOSE, OR AGAINST INFRINGEMENT.
*
*                Copyright © 2012 Micron Semiconductor Products, Inc.
*                All rights reserved
*
*   1.00 yhliu  6/2/15:Initial version.

*                        
*******************************************************************************/

`timescale 1ns/1ps

module nand_spi_chip_wrapper(
	inout SI,
	input SCK,
	input CS_N,
	inout HOLD_N,
	inout WP_N,
	inout SO
	);

`ifdef D_4Gb
	nand_spi_chip #(.mds(2'b10)) uut_0  (.SI(SI), .SCK(SCK), .CS_N(CS_N), .HOLD_N(HOLD_N), .WP_N(WP_N), .SO(SO));
	nand_spi_chip #(.mds(2'b11)) uut_1  (.SI(SI), .SCK(SCK), .CS_N(CS_N), .HOLD_N(HOLD_N), .WP_N(WP_N), .SO(SO));
`else
	nand_spi_chip #(.mds(2'b00)) uut_0  (.SI(SI), .SCK(SCK), .CS_N(CS_N), .HOLD_N(HOLD_N), .WP_N(WP_N), .SO(SO));
`endif 

endmodule
