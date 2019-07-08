`timescale 1ns / 100ps

`include "sva/sva_check_result.sv"

module tb_dut_top;

parameter ASIZE = 10				;
parameter DSIZE =  8				;

reg                 wrst    		;
reg                 wclk    		;
reg                 winc    		;
reg     [DSIZE-1:0] wdata   		;
wire				wfull  			; 
reg	                rrst    		;
reg	                rclk    		;
reg	                rinc    		;
wire   [DSIZE-1:0]  rdata   		;
wire                rempty  		;
wire   [DSIZE-1:0]  rdata_golden	;
wire                rempty_golden  	;

`include "wclk_and_wrst_tsk.svh"
`include "rclk_and_rrst_tsk.svh"

////////////////////////////////////////////////////////////////////////////////////////////////////
//		write_fifo_clear	
////////////////////////////////////////////////////////////////////////////////////////////////////
task write_fifo_clear;
begin
	wdata = 0;
	winc = 0;
end
endtask
////////////////////////////////////////////////////////////////////////////////////////////////////
//		read_fifo_clear	
////////////////////////////////////////////////////////////////////////////////////////////////////
task read_fifo_clear;
begin
	rinc = 0;
end
endtask
////////////////////////////////////////////////////////////////////////////////////////////////////
//		write_fifo
////////////////////////////////////////////////////////////////////////////////////////////////////
task write_fifo;
input [31:0] length;
begin
	winc  = 1;
	for(int i=0;i<length;i++)begin
		wdata = i+1;
		repeat(1) @(posedge wclk);        
	end
	winc  = 0;
end
endtask
////////////////////////////////////////////////////////////////////////////////////////////////////
//		read_fifo	
////////////////////////////////////////////////////////////////////////////////////////////////////
task read_fifo;
input [31:0] length;
begin
	rinc = 1;
	for(int i=0;i<length;i++)begin
		repeat(1) @(posedge rclk);        
	end
	rinc = 0;
end
endtask
////////////////////////////////////////////////////////////////////////////////////////////////////
//		dly_read_fifo	
////////////////////////////////////////////////////////////////////////////////////////////////////
task dly_read_fifo;
input [31:0] length;
begin
	repeat (10) @(posedge rclk);
	read_fifo(length);
end
endtask
////////////////////////////////////////////////////////////////////////////////////////////////////
//		instance real	
////////////////////////////////////////////////////////////////////////////////////////////////////
asyn_fifo #(ASIZE,DSIZE) u0_asyn_fifo(
	.I_wrst    (wrst     ),
	.I_wclk    (wclk     ),
	.I_winc    (winc     ),
	.I_wdata   (wdata    ),
	.O_wfull   (wfull    ),
	.I_rrst    (rrst     ),
	.I_rclk    (rclk     ),
	.I_rinc    (rinc     ),
	.O_rdata   (rdata    ),
	.O_rempty  (rempty   )  
);
////////////////////////////////////////////////////////////////////////////////////////////////////
//		instance golden 
////////////////////////////////////////////////////////////////////////////////////////////////////
beh_fifo #(ASIZE,DSIZE) u0_golden_asyn_fifo(
	.wrst    (wrst     		),
	.wclk    (wclk     		),
	.winc    (winc     		),
	.wdata   (wdata    		),
	.wfull   (wfull    		),
	.rrst    (rrst     		),
	.rclk    (rclk     		),
	.rinc    (rinc     		),
	.rdata   (rdata_golden  ),
	.rempty  (rempty_golden )  
);
////////////////////////////////////////////////////////////////////////////////////////////////////
//		process sva	
////////////////////////////////////////////////////////////////////////////////////////////////////
reg sva_clk = 0;
always #5 sva_clk=~sva_clk;

reg sva_sync = 0;
always @(posedge rclk)begin
	if(rinc) begin
		sva_sync <= 1'b1;
	end
end

reg sva_result_rdata= 1'b0;
always @(posedge rclk)begin
	if(sva_sync)begin
		sva_result_rdata <= (rdata == rdata_golden);
	end
	else begin
		sva_result_rdata <= 1'b0;
	end
end

sva_check_result u0_sva_check_rdata (
	.sva_clk 		(sva_clk			),
	.sva_sync_state	(sva_sync			),
	.sva_chk_edge 	(rclk				),
	.sva_chk_result (sva_result_rdata	)
);

reg sva_result_rempty = 1'b0;
always @(posedge rclk)begin
	if(sva_sync)begin
		sva_result_rempty <= (rempty == rempty_golden);
	end
	else begin
		sva_result_rempty <= 1'b0; 
	end
end

sva_check_result u0_sva_check_rempty (
	.sva_clk 		(sva_clk			),
	.sva_sync_state	(sva_sync			),
	.sva_chk_edge 	(rclk				),
	.sva_chk_result (sva_result_rempty	)
);
////////////////////////////////////////////////////////////////////////////////////////////////////
//		main body	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
	write_fifo_clear;
	read_fifo_clear;
	fork
		wrst_tsk(30);
		rrst_tsk(20);
	join
	fork 
		write_fifo(30);
		dly_read_fifo(30);
	join

	#1000 $finish;
end
////////////////////////////////////////////////////////////////////////////////////////////////////
//		generate fsdb	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
   	$helloworld;
  	$fsdbDumpvars("+fsdbfile+tb_dut_top.fsdb");
	$fsdbDumpMDA(u0_asyn_fifo.mem,0,8);
   	$fsdbDumpSVA;
end

endmodule
