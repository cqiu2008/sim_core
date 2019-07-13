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
module spram #(
parameter 	
	MEM_STYLE  = "block",//"distributed"
	ASIZE = 10			,	
	DSIZE = 32				
)(
// clk
input								I_rst			,	
input								I_clk			,
input		[ASIZE-1		 	 :0]I_addr			,
input		[DSIZE-1		 	 :0]I_data			,
input								I_ce			,
input								I_wr			,
output reg	[DSIZE-1		     :0]O_data			
);

initial begin
#0 O_data = {DSIZE{1'b0}};
end

localparam DEPTH = 1 << ASIZE;
(* ram_style=MEM_STYLE *)reg [DSIZE-1:0] mem [0:DEPTH-1];

always @(posedge I_clk)begin
	if(I_wr && I_ce)begin
		mem[I_addr] <= I_data;
	end
end

always @(posedge I_clk)begin
	if(I_rst)begin
		O_data <= {DSIZE{1'b0}}	; 
	end
	else begin
		O_data <= mem[I_addr]	;
	end
	else begin
		O_data <= O_data		; 
	end
end

endmodule
