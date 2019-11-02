//----------------------------------------------------------------------------
//File Name    : beh_fifo 
//Author       : qiu.chao 
//----------------------------------------------------------------------------
//Module Hierarchy :
//beh_fifo_inst |-beh_fifo
//----------------------------------------------------------------------------
//Release History :
//Version         Date           Author        Description
// 1.0          2019-01-01       beh_fifo			1st draft
//----------------------------------------------------------------------------
//Main Function Tree:
//a)beh_fifo : 
//Description Function:
//The behavioral model that I sometimes use for testing a FIFO desing is a FIFO 
//model that is simple to code.
//THIS FIFO MODEL IS NOT SAFE FOR SYNTHESIS
//----------------------------------------------------------------------------
//`timescale 1ns/100ps
module beh_fifo #(
parameter
	DSIZE = 8,
	ASIZE = 1024 
)(
input					wclk	, 
input					wrst	,
input				 	winc	,
input		[DSIZE-1:0]	wdata	,
input					rclk	,
input					rrst	,
input					rinc	,
output reg [DSIZE-1:0]	rdata	,	
output 					rempty	,
output					wfull	
);

parameter MEMDEPTH = 1<<ASIZE;

reg	[ASIZE:0] wptr	;
reg	[ASIZE:0] wrptr1;
reg	[ASIZE:0] wrptr2;
reg	[ASIZE:0] wrptr3;
reg	[ASIZE:0] rptr	;
reg	[ASIZE:0] rwptr1;
reg	[ASIZE:0] rwptr2;
reg	[ASIZE:0] rwptr3;
reg	[DSIZE-1:0] ex_mem[0:MEMDEPTH-1];

////////////////////////////////////////////////////////////////////////////////////////////////////
//		beh_fifo	  																			  //
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
//    __    __    __    __    __    __    __    __    __    __    __    __    __    __    __    __//
// __|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |/
//                                                                                                //
////////////////////////////////////////////////////////////////////////////////////////////////////

always @(posedge wclk)begin
	if(wrst)begin
		wptr <= 0;
	end
	else if(winc && !wfull)begin
		ex_mem[wptr[ASIZE-1:0]] <= wdata	;
		wptr					<= wptr + 1	;
	end
end

always @(posedge wclk)begin
	if(wrst)begin
		{wrptr3,wrptr2,wrptr1} <= 0;
	end
	else begin
		{wrptr3,wrptr2,wrptr1} <= {wrptr2,wrptr1,rptr}; 
	end
end

always @(posedge rclk )begin
	if(rrst)begin
		rptr 	<= 1'b0;
	end
	else if(rinc && !rempty)begin
		rptr 	<= rptr + 1'b1;
	end
end

always @(posedge rclk )begin
	if(rrst)begin
		{rwptr3,rwptr2,rwptr1}	<= 0;
	end
	else begin
		{rwptr3,rwptr2,rwptr1}	<= {rwptr2,rwptr1,wptr}; 
	end
end

always @(posedge rclk )begin
	rdata <= ex_mem[rptr[ASIZE-1:0]];
end

assign rempty = (rptr == rwptr3);

assign wfull  = ((wptr[ASIZE-1:0] ==  wrptr3[ASIZE-1:0]) && 
				 (wptr[ASIZE] != wrptr3[ASIZE]));

endmodule

