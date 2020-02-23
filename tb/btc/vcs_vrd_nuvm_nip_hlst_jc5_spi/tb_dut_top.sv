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
`define IPEN  1

module tb_dut_top;

`include "nand_spi_chip_parameters.vh"
`include "ssi_ip_parameters.vh"

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
wire          si_so0                                          ; 
wire          so_so1                                          ; 
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
assign power_complete = uut.uut_0.reset_completed_once        ;

reg             pclk                                          ; // APB Clock Signal
reg             presetn                                       ; // APB async Reset Signal
reg             psel                                          ; // APB Peripheral Select Signal
reg             penable                                       ; // Strobe Signal
reg             pwrite                                        ; // Write Signal
reg  [9:0]      paddr                                         ; // Address bus
reg  [31:0]     pwdata                                        ; // Write data Bus
wire [31:0]     prdata                                        ; // Read Data Bus
reg             ssi_clk                                       ; // Peripheral Serial Clock Signal
reg             ssi_rst_n                                     ; // Preipheral async Reset Signal
reg             soc_test_mode                                 ; // Scan Test reg signal
reg             dma_tx_ack                                    ; // DMA Tx burst end
reg             dma_rx_ack                                    ; // DMA Rx burst end
wire            dma_tx_req                                    ; // Transmit FIFO DMA Request
wire            dma_rx_req                                    ; // Receive FIFO DMA request
wire            dma_tx_single                                 ; // DMA TRansmit FIFO Single Signal
wire            dma_rx_single                                 ; // DMA Receive FIFO Single Signal
reg             io_clk_in                                     ; // Peripheral Serial Clock Signal
wire            io_clk_out                                    ; // Peripheral Serial Clock Signal
wire            io_clk_out_oen                                ; // Peripheral Serial Clock Signal
reg             io_csn0_in                                    ; // CHIP SELECT
wire            io_csn0_out                                   ; // CHIP SELECT
wire            io_csn1_out                                   ; // CHIP SELECT
wire            io_csn0_out_oen                               ; // CHIP SELECT
wire            io_csn1_out_oen                               ; // CHIP SELECT
reg  [3:0]      io_data_masked_pin                            ; // Receive Data Signal
wire [3:0]      io_data                                       ; // Transmit Data Signal
wire [3:0]      io_data_oe_n                                  ; // Output enable Signal
wire [3:0]      inout_data                                    ; // inout type io_data   
wire            ssi_intr                                      ; // combined interrupt 
reg  [31:0]     oprdata                                       ; // Get Read Data bus
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
spi_wrapper U_spi_wrapper(
.pclk               (pclk               ),// APB Clock Signal
.presetn            (presetn            ),// APB async Reset Signal
.psel               (psel               ),// APB Peripheral Select Signal
.penable            (penable            ),// Strobe Signal
.pwrite             (pwrite             ),// Write Signal
.paddr              (paddr              ),// Address bus
.pwdata             (pwdata             ),// Write data Bus
.prdata             (prdata             ),// Read Data Bus
.ssi_clk            (ssi_clk            ),// Peripheral Serial Clock Signal
.ssi_rst_n          (ssi_rst_n          ),// Preipheral async Reset Signal
.soc_test_mode      (soc_test_mode      ),// Scan Test reg signal
.dma_tx_ack         (dma_tx_ack         ),// DMA Tx burst end
.dma_rx_ack         (dma_rx_ack         ),// DMA Rx burst end
.dma_tx_req         (dma_tx_req         ),// Transmit FIFO DMA Request
.dma_rx_req         (dma_rx_req         ),// Receive FIFO DMA request
.dma_tx_single      (dma_tx_single      ),// DMA TRansmit FIFO Single Signal
.dma_rx_single      (dma_rx_single      ),// DMA Receive FIFO Single Signal
.io_clk_in          (io_clk_in          ),// Peripheral Serial Clock Signal
.io_clk_out         (io_clk_out         ),// Peripheral Serial Clock Signal
.io_clk_out_oen     (io_clk_out_oen     ),// Peripheral Serial Clock Signal
.io_csn0_in         (io_csn0_in         ),// CHIP SELECT
.io_csn0_out        (io_csn0_out        ),// CHIP SELECT
.io_csn1_out        (io_csn1_out        ),// CHIP SELECT
.io_csn0_out_oen    (io_csn0_out_oen    ),// CHIP SELECT
.io_csn1_out_oen    (io_csn1_out_oen    ),// CHIP SELECT
.io_data_masked_pin (io_data_masked_pin ),// Receive Data Signal
.io_data            (io_data            ),// Transmit Data Signal
.io_data_oe_n       (io_data_oe_n       ),// Output enable Signal
.ssi_intr           (ssi_intr           ) // combined interrupt 
);

assign inout_data[3]      = io_data_oe_n[3] ? 1'bz : io_data[3] ;
assign inout_data[2]      = io_data_oe_n[2] ? 1'bz : io_data[2] ;
assign inout_data[1]      = io_data_oe_n[1] ? 1'bz : io_data[1] ;
assign inout_data[0]      = io_data_oe_n[0] ? 1'bz : io_data[0] ;
assign io_data_masked_pin = inout_data                          ;

pullup (inout_data[3]);
pullup (inout_data[2]);
//pullup (inout_data[1]);
//pullup (inout_data[0]);

`ifdef IPEN 
  assign si_so0 = inout_data[0]   ;
  assign so_so1 = inout_data[1]   ;
  nand_spi_chip_wrapper uut  (
    .SI               (inout_data[0]      ), 
    .SCK              (io_clk_out         ), 
    .CS_N             (io_csn0_out        ), 
    .HOLD_N           (inout_data[3]      ), 
    .WP_N             (inout_data[2]      ),
    .SO               (inout_data[1]      )
  );
`else
  nand_spi_chip_wrapper uut  (
    .SI               (si_so0             ), 
    .SCK              (SCK                ), 
    .CS_N             (CS_N               ), 
    .HOLD_N           (hold_so3           ), 
    .WP_N             (wpn_so2            ), 
    .SO               (so_so1             )
  );
`endif

////////////////////////////////////////////////////////////////////////////////////////////////////
//		clk generator
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
	pclk = 0;
end
always #10 pclk =~pclk;

initial begin
	ssi_clk = 0;
end
always #7.2 ssi_clk =~ssi_clk;

////////////////////////////////////////////////////////////////////////////////////////////////////
//	simulation body	
////////////////////////////////////////////////////////////////////////////////////////////////////
// initial begin
//   rst_init;
// #300000
//   $finish;
// end

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
//`include "nand_spi_tasks.vh"
`include "apb_regssi_tasks.vh"
`include "apb_spi_tasks.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////
//  add sub testcase  
////////////////////////////////////////////////////////////////////////////////////////////////////
//`include "subtestcase.vh"
//`include "mstspi_testcase.vh"
`include "mstspi_tc_single_rd_wr.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////
//  generate fsdb	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
  $fsdbDumpvars("+fsdbfile+tb_dut_top.fsdb");
	$fsdbDumpMDA;
  $fsdbDumpSVA;
end

endmodule

