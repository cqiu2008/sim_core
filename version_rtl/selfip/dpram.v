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
module dpram #(
parameter 	
	MEM_STYLE  = "block",
	DSIZE = 32		,
	ASIZE = 10		
)(
input								I_rst			,	
input								I_clk0			,
input		[ASIZE-1		 	 :0]I_addr0			,
input		[DSIZE-1		 	 :0]I_wdata0		,
input								I_ce0			,
input								I_wr0			,
output reg	[DSIZE-1		     :0]O_rdata0		,
input								I_clk1			,
input		[ASIZE-1		 	 :0]I_addr1			,
input		[DSIZE-1		 	 :0]I_wdata1		,
input								I_ce1			,
input								I_wr1			,
output reg	[DSIZE-1		     :0]O_rdata1		 
);

initial begin
#0	O_rdata0 < = {DSIZE{1'b0}};
#0	O_rdata1 < = {DSIZE{1'b0}};
end

localparam DEPTH = 1 << ASIZE;
(* ram_style=MEM_STYLE *)reg [DSIZE-1:0] mem [0:DEPTH-1];

always @(posedge I_clk0)begin
	if(I_wr0 && I_ce0)begin
		mem[I_waddr0] <= I_wdata0;
	end
end

always @(posedge I_clk0)begin
	if(I_rst)begin
		O_rdata0 <= {DSIZE{1'b0}}	; 
	end
	else begin 
		O_rdata0 <= mem[I_addr0]	;
	end
end

always @(posedge I_clk1)begin
	if(I_wr1 && I_ce1)begin
		mem[I_waddr1] <= I_wdata1;
	end
end

always @(posedge I_clk1)begin
	if(I_rst)begin
		O_rdata1 <= {DSIZE{1'b0}}	; 
	end
	else begin 
		O_rdata1 <= mem[I_addr1]	;
	end
end

endmodule
