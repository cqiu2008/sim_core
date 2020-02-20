//`timescale 1ns/100ps

//`include "sva/sva_check_result.sv"

module tb_dut_top;
  reg                           pclk                    ;
  reg                           presetn                 ;
  reg                           psel                    ;// i          APB Peripheral Select Signal
  reg                           penable                 ;// i          Strobe Signal
  reg                           pwrite                  ;// i          Write Signal
  reg  [28:0]                   paddr                   ;// i[28:0]    Address bus
  reg  [31:0]                   pwdata                  ;// i[31:0]    Write data Bus
  wire [31:0]                   prdata                  ;// o[31:0]    Read Data Bus
  wire                          pready                  ;// new o      For APB4.0 bus APB IF ready signal
  wire                          pslverr                 ;// new o      For APB4.0 bus APB Slave error signal
  reg   [3:0]                   pstrb                   ;// new i[3:0] For APB4.0 bus
//DMA I/O
  wire                          dma_tx_single           ;// o          DMA TRansmit FIFO Single Signal
  wire                          dma_tx_req              ;// o          Transmit FIFO DMA Request
  reg                           dma_tx_ack              ;// i          DMA Tx burst end
  wire                          dma_rx_single           ;// o          DMA Receive FIFO Single Signal
  wire                          dma_rx_req              ;// o          Receive FIFO DMA request
  reg                           dma_rx_ack              ;// i          DMA Rx burst end
// delay line cfg
  reg                           cfg_rw_init_state       ;// new i      soft initial the state .
  reg  [1:0]                    cfg_rw_drv_degree       ;// new i      driver clock phase . 0 : 0  ,  1: 90  , 2 ; 180 ,  3 : 270
  reg  [7:0]                    cfg_rw_drv_delaynum     ;// new i      delay element number for cclk_in_drv
  reg                           cfg_rw_drv_sel          ;// new i      0-phase shift; 1-phase shift + delay line
  reg  [1:0]                    cfg_rw_sample_degree    ;// new i      sample clock phase . 0 : 0  ,  1: 90  , 2 ; 180 ,  3 : 270
  reg  [7:0]                    cfg_rw_sample_delaynum  ;// new i      delay element number for cclk_in_sample
  reg                           cfg_rw_sample_sel       ;// new i      0-phase shift; 1-phase shift + delay line
// soc cfg
  reg                           soc_test_mode           ;// new i
  reg                           scan_clk_func           ;// new i
//qspi bus
  reg                           ssi_clk                 ;// i          Peripheral Serial Clock Signal,should be 200M attention
  reg                           ssi_rst_n               ;// i          Preipheral async Reset Signal
//qspi_io
  wire                          io_clk_out              ;// o          Peripheral Serial Clock Signal
  wire                          io_clk_out_oen          ;// o          Peripheral Serial Clock Signal
  wire                          io_csn0_out             ;// o          CHIP SELECT
  wire                          io_csn0_out_oen         ;// o          CHIP SELECT
  wire                          io_csn1_out             ;// o          CHIP SELECT
  wire                          io_csn1_out_oen         ;// o          CHIP SELECT
  reg  [3:0]                    io_data_masked_pin      ;// i          Receive Data Signal
  wire [3:0]                    io_data                 ;// o          Transmit Data Signal
  wire [3:0]                    io_data_oe_n            ;// o          Output enable Signal
  wire                          ssi_intr                ;// o          combined interrupt wire


//`include "pclk_and_presetn_tsk.svh" begin
////////////////////////////////////////////////////////////////////////////////////////////////////
//		pclk generator
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
	pclk = 0;
end
always #5 pclk =~pclk;

////////////////////////////////////////////////////////////////////////////////////////////////////
//		presetn task
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
	presetn = 1; 
end

task presetn_tsk;
input [31:0]rst_num;
begin
	presetn = 1'b1;
	repeat (1) @(posedge pclk);
	#1
	presetn = 1'b0;
	repeat (rst_num) @(posedge pclk);
	#1
	presetn = 1'b1;
	repeat (1) @(posedge pclk);
	#1;
end
endtask

//`include "rclk_and_rrst_tsk.svh" begin

// task dly_tst;
// input [31:0] length;
// begin
// 	repeat (10) @(posedge rclk);
// end
// endtask
////////////////////////////////////////////////////////////////////////////////////////////////////
//		instance 
////////////////////////////////////////////////////////////////////////////////////////////////////
qspi_mst_DW_apb_ssi_top U_qspi_mst_DW_apb_ssi_top(
  .pclk                    (pclk                    ),// i          APB Clock Signal
  .presetn                 (presetn                 ),// i          APB async Reset Signal
  .psel                    (psel                    ),// i          APB Peripheral Select Signal
  .penable                 (penable                 ),// i          Strobe Signal
  .pwrite                  (pwrite                  ),// i          Write Signal
  .paddr                   (paddr                   ),// i[28:0]    Address bus
  .pwdata                  (pwdata                  ),// i[31:0]    Write data Bus
  .prdata                  (prdata                  ),// o[31:0]    Read Data Bus
  .pready                  (pready                  ),// new o      For APB4.0 bus APB IF ready signal
  .pslverr                 (pslverr                 ),// new o      For APB4.0 bus APB Slave error signal
  .pstrb                   (pstrb                   ),// new i[3:0] For APB4.0 bus
  .dma_tx_single           (dma_tx_single           ),// o          DMA TRansmit FIFO Single Signal
  .dma_tx_req              (dma_tx_req              ),// o          Transmit FIFO DMA Request
  .dma_tx_ack              (dma_tx_ack              ),// i          DMA Tx burst end
  .dma_rx_single           (dma_rx_single           ),// o          DMA Receive FIFO Single Signal
  .dma_rx_req              (dma_rx_req              ),// o          Receive FIFO DMA request
  .dma_rx_ack              (dma_rx_ack              ),// i          DMA Rx burst end
  .cfg_rw_init_state       (cfg_rw_init_state       ),// new i      soft initial the state .
  .cfg_rw_drv_degree       (cfg_rw_drv_degree       ),// new i      driver clock phase . 0 : 0  ,  1: 90  , 2 ; 180 ,  3 : 270
  .cfg_rw_drv_delaynum     (cfg_rw_drv_delaynum     ),// new i      delay element number for cclk_in_drv
  .cfg_rw_drv_sel          (cfg_rw_drv_sel          ),// new i      0-phase shift; 1-phase shift + delay line
  .cfg_rw_sample_degree    (cfg_rw_sample_degree    ),// new i      sample clock phase . 0 : 0  ,  1: 90  , 2 ; 180 ,  3 : 270
  .cfg_rw_sample_delaynum  (cfg_rw_sample_delaynum  ),// new i      delay element number for cclk_in_sample
  .cfg_rw_sample_sel       (cfg_rw_sample_sel       ),// new i      0-phase shift; 1-phase shift + delay line
  .soc_test_mode           (soc_test_mode           ),// new i
  .scan_clk_func           (scan_clk_func           ),// new i
  .ssi_clk                 (ssi_clk                 ),// i          Peripheral Serial Clock Signal,should be 200M attention
  .ssi_rst_n               (ssi_rst_n               ),// i          Preipheral async Reset Signal
  .io_clk_out              (io_clk_out              ),// o          Peripheral Serial Clock Signal
  .io_clk_out_oen          (io_clk_out_oen          ),// o          Peripheral Serial Clock Signal
  .io_csn0_out             (io_csn0_out             ),// o          CHIP SELECT
  .io_csn0_out_oen         (io_csn0_out_oen         ),// o          CHIP SELECT
  .io_csn1_out             (io_csn1_out             ),// o          CHIP SELECT
  .io_csn1_out_oen         (io_csn1_out_oen         ),// o          CHIP SELECT
  .io_data_masked_pin      (io_data_masked_pin      ),// i          Receive Data Signal
  .io_data                 (io_data                 ),// o          Transmit Data Signal
  .io_data_oe_n            (io_data_oe_n            ),// o          Output enable Signal
  .ssi_intr                (ssi_intr                ) // o          combined interrupt output
);


////////////////////////////////////////////////////////////////////////////////////////////////////
//		main body	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
	fork
		presetn_tsk(30);
	join

	#1000 $finish;
end
////////////////////////////////////////////////////////////////////////////////////////////////////
//		generate fsdb	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
  $fsdbDumpvars("+fsdbfile+tb_dut_top.fsdb");
	$fsdbDumpMDA;
  $fsdbDumpSVA;
end

endmodule
