module tb_dut_top;

//==Golble Rst
reg			S_rst				;
//==Clock
reg			S_100m_clk			;
reg			S_data_in			;
wire		S_data_out			;	
//====dut 
dut_top U1_test(
	.I_rst		(S_rst			),
	.I_clk		(S_100m_clk		),
	.I_data_in	(S_data_in		),
	.O_data_out (S_data_out		)
);

always #10 S_100m_clk = ~S_100m_clk;

task tsk_dly_clks;
	input	[ 15:0]	I_dly_num	;	
	begin
		repeat(I_dly_num)
		begin
			@(posedge S_100m_clk) ;
			#1	;
		end
	end
endtask

initial begin 
	S_100m_clk = 1'b1;
	S_rst =1'b0;
	S_data_in =  1'b1;
	tsk_dly_clks(20);
	S_rst =1'b1;
	S_data_in =  1'b0;
	tsk_dly_clks(200);
	S_rst =1'b0;
	S_data_in =  1'b1;
	tsk_dly_clks(20000);
	$finish;
end

////====fsdb
//initial begin
//   	$helloworld;
//  	$fsdbDumpvars("+fsdbfile+tb_dut_top.fsdb");
//   	$fsdbDumpSVA;
//end



endmodule
