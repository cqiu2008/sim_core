////////////////////////////////////////////////
// [Confidential]
// This file and all files delivered herewith are Micron Confidential Information.
//
//[Disclaimer]    
//This software code and all associated documentation, comments
//or other information (collectively "Software") is provided 
//"AS IS" without warranty of any kind. MICRON TECHNOLOGY, INC. 
//("MTI") EXPRESSLY DISCLAIMS ALL WARRANTIES EXPRESS OR IMPLIED,
//INCLUDING BUT NOT LIMITED TO, NONINFRINGEMENT OF THIRD PARTY
//RIGHTS, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS
//FOR ANY PARTICULAR PURPOSE. MTI DOES NOT WARRANT THAT THE
//SOFTWARE WILL MEET YOUR REQUIREMENTS, OR THAT THE OPERATION OF
//THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE. FURTHERMORE,
//MTI DOES NOT MAKE ANY REPRESENTATIONS REGARDING THE USE OR THE
//RESULTS OF THE USE OF THE SOFTWARE IN TERMS OF ITS CORRECTNESS,
//ACCURACY, RELIABILITY, OR OTHERWISE. THE ENTIRE RISK ARISING OUT
//OF USE OR PERFORMANCE OF THE SOFTWARE REMAINS WITH YOU. IN NO
//EVENT SHALL MTI, ITS AFFILIATED COMPANIES OR THEIR SUPPLIERS BE
//LIABLE FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, INCIDENTAL, OR
//SPECIAL DAMAGES (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS
//OF PROFITS, BUSINESS INTERRUPTION, OR LOSS OF INFORMATION)
//ARISING OUT OF YOUR USE OF OR INABILITY TO USE THE SOFTWARE,
//EVEN IF MTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
//Because some jurisdictions prohibit the exclusion or limitation
//of liability for consequential or incidental damages, the above
//limitation may not apply to you.
//
//Copyright 2012 Micron Technology, Inc. All rights reserved.
////////////////////////////////////////////////
`timescale 1ns / 1ps

module tb_dut_top;

`include "nand_spi_chip_parameters.vh"

`ifdef SHM_DUMP
  initial begin
    $shm_open("shm.db");
    $shm_probe(tb_dut_top,"AS");	 
  end
`endif

// Ports Declaration
reg           SI                                              ;
reg           SCK = 0                                         ;
reg           CS_N                                            ;
reg           HOLD_N                                          ;
reg           WP_N                                            ;
reg				    SO                                              ;
reg [7:0]			rd_dq                                           ;
reg [7:0]			rd_data                                         ;
wire          si_so0 = SI                                     ;
wire          so_so1 = SO                                     ;
wire          wpn_so2 = WP_N                                  ;
wire          hold_so3 = HOLD_N                               ;
reg           address_in = 0                                  ;
reg           data_in = 0                                     ;
reg           test_done = 0                                   ;
// some testbench signals here
reg           rd_verify                                       ;
reg           device                                          ;
reg [7:0]     lastCmd                                         ;
reg           x2_output_mode                                  ;
reg           x4_output_mode                                  ;
realtime      tm_sck_pos = 0                                  ;
realtime      tm_sck_neg = 0                                  ;
real          tCK_sync                                        ;
reg           alt_powerup = 0                                 ;
wire          power_complete                                  ; 
assign power_complete = tb_dut_top.uut.uut_0.reset_completed_once ;
////////////////////////////////////////////////////////////////////////////////////////////////////
//  Initial some signals	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
  //initialize some regs that will be used
  rd_verify = 0                                               ;
  device = 0                                                  ;
  lastCmd = 8'h00                                             ;
  x2_output_mode = 0                                          ;
  x4_output_mode = 0                                          ;
  SI = 0                                                      ;
  SCK <= #tWL_min 1                                           ; //get the clock toggling
  CS_N = 1                                                    ;
  HOLD_N = 1                                                  ;
  WP_N = 1                                                    ;
  SO = 1'bz                                                   ;
  setup_params_array                                          ;
end

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Model Instance (Simulate extern chips) 
////////////////////////////////////////////////////////////////////////////////////////////////////
nand_spi_chip_wrapper uut  (
  .SI     (si_so0     ), 
  .SCK    (SCK        ), 
  .CS_N   (CS_N       ), 
  .HOLD_N (hold_so3   ), 
  .WP_N   (wpn_so2    ), 
  .SO     (so_so1     )
);

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Generate the SCK 
////////////////////////////////////////////////////////////////////////////////////////////////////
always @(SCK or alt_powerup or power_complete)begin
  if (!(alt_powerup && ~power_complete)) begin
    SCK <= #(tCK_min/2) ~SCK;
  end
end
    
always @(SCK) begin
  if (SCK)begin
    tm_sck_pos = $realtime;
  end
  else begin
    tm_sck_neg = $realtime;
  end
end

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Statistic the uut.SCK counter
////////////////////////////////////////////////////////////////////////////////////////////////////

reg ssi_clk ;
initial begin
  ssi_clk = 1'b0;
end
always #(tCK_min/10) ssi_clk <= ~ssi_clk;

reg             uut_sck1d               ;
reg     [15: 0] uut_sckcnt              ;

always @(posedge ssi_clk)begin
  uut_sck1d  <= uut.SCK     ;
end

always @(posedge ssi_clk)begin
  if(!uut.CS_N)begin
    if( (~uut_sck1d) && uut.SCK )begin
      uut_sckcnt <= uut_sckcnt + 16'h1;
    end
  end
  else begin
    uut_sckcnt <= 16'h0;
  end
end

////////////////////////////////////////////////////////////////////////////////////////////////////
//  TASKS 
////////////////////////////////////////////////////////////////////////////////////////////////////
`include "nand_spi_tasks.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////
//  add sub testcase  
////////////////////////////////////////////////////////////////////////////////////////////////////
`include "subtestcase.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////
//  generate fsdb	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
  $fsdbDumpvars("+fsdbfile+tb_dut_top.fsdb");
	$fsdbDumpMDA;
  $fsdbDumpSVA;
end

endmodule

