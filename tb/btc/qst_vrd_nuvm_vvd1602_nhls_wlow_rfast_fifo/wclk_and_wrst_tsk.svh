//--------------------------------------------------------------------------------------------------
//File Name    : wclk_and_wrst_tsk 
//Author       : qiu.chao 
//--------------------------------------------------------------------------------------------------
//Module Hierarchy :
//wclk_and_wrst_tsk_inst |-wclk_and_wrst_tsk
//--------------------------------------------------------------------------------------------------
//Release History :
//Version         Date           Author        Description
// 1.0          2019-01-01       qiu.chao       1st draft
//--------------------------------------------------------------------------------------------------
//Main Function Tree:
//a)wclk_and_wrst_tsk: 
//Description Function:
//wclk_and_wrst_tsk
//--------------------------------------------------------------------------------------------------

////////////////////////////////////////////////////////////////////////////////////////////////////
// Naming specification																			  // 
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
//		wclk generator
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
	wclk = 0;
end
always #13 wclk =~wclk;

////////////////////////////////////////////////////////////////////////////////////////////////////
//		wrst task
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
	wrst = 0; 
end

task wrst_tsk;
input [31:0]rst_num;
begin
	wrst = 1'b0;
	repeat (1) @(posedge wclk);
	#1
	wrst = 1'b1;
	repeat (rst_num) @(posedge wclk);
	#1
	wrst = 1'b0;
	repeat (1) @(posedge wclk);
	#1;
end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                //
//    __    __    __    __    __    __    __    __    __    __    __    __    __    __    __    __//
// __|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |/
//                                                                                                //
//                                                                                                //
////////////////////////////////////////////////////////////////////////////////////////////////////