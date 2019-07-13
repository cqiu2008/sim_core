//FILE_HEADER-----------------------------------------------------------------
//ZTE  Copyright (C)
//ZTE Company Confidential
//----------------------------------------------------------------------------
//Project Name : cnna
//FILE NAME    : dpram.v
//AUTHOR       : qiu.chao 
//Department   : Technical Planning Department/System Products/ZTE
//Email        : qiu.chao@zte.com.cn
//----------------------------------------------------------------------------
//Module Hiberarchy :
//        |--U01_dpram
//        |--U02_axim_wddr
// cnna --|--U03_axis_reg
//        |--U04_main_process
//----------------------------------------------------------------------------
//Relaese History :
//----------------------------------------------------------------------------
//Version         Date           Author        Description
// 1.1           july-30-2019                    
//----------------------------------------------------------------------------
//Main Function:
//a)Get the data from ddr chip using axi master bus
//b)Write it to the ibuf ram
//----------------------------------------------------------------------------
//REUSE ISSUES: none
//Reset Strategy: synchronization 
//Clock Strategy: one common clock 
//Critical Timing: none 
//Asynchronous Interface: none 
//END_HEADER------------------------------------------------------------------
`timescale 1 ns / 100 ps
module sdpram #(
parameter 	
	MEM_STYLE  = "block",
	DSIZE = 32		,
	ASIZE = 10		
)(
input								I_rst			,	
input								I_wclk			,
input		[ASIZE-1		 	 :0]I_waddr			,
input		[DSIZE-1		 	 :0]I_wdata			,
input								I_ce			,
input								I_wr			,
input								I_rclk			,
input		[ASIZE-1		     :0]I_raddr			,
input								I_rd			,
output reg	[DSIZE-1		     :0]O_rdata
);

initial begin
#0	O_rdata < = {DSIZE{1'b0}};
end

localparam DEPTH = 1 << ASIZE;
(* ram_style=MEM_STYLE *)reg [DSIZE-1:0] mem [0:DEPTH-1];

always @(posedge I_wclk)begin
	if(I_wr && I_ce)begin
		mem[I_waddr] <= I_wdata;
	end
end

always @(posedge I_rclk)begin
	if(I_rst)begin
		O_rdata <= {DSIZE{1'b0}}; 
	end
	else if(I_rd && I_ce)begin
		O_rdata <= mem[I_raddr]	;
	end
	else begin
		O_rdata <= O_rdata		;
	end
end

endmodule
