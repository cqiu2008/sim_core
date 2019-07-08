module tb_dut_top;

//==Clock
reg			S_100m_clk			;
reg			S_in1				;
reg			S_in2				;
reg			S_sel				;
wire		S_out				;
//====dut 
mux2to1_structure U1_test(
	.I_in1		(S_in1		),
	.I_in2		(S_in2		),
	.I_sel		(S_sel		),
	.O_out		(S_out		)
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

wire O_expect_out;
assign O_expect_out = S_sel ? S_in1:S_in2;

task tsk_mux2to1;
	input [15:0]I_dly_num	;
	input 		I_in1		;
	input 		I_in2		;
	input 		I_sel		;
	begin
		S_in1	= I_in1	;
		S_in2	= I_in2	;
		S_sel	= I_sel	;
		tsk_dly_clks(I_dly_num);
		//assert (O_expect_out == S_out);
	end
endtask

initial begin 
	S_100m_clk = 1'b1;
	S_in1 = 1'b0;
	S_in2 = 1'b0;
	tsk_dly_clks(20);
	tsk_mux2to1(16'd10,1'b0,1'b0,1'b0);
	tsk_mux2to1(16'd10,1'b0,1'b0,1'b1);
	tsk_mux2to1(16'd10,1'b0,1'b1,1'b1);
	tsk_mux2to1(16'd10,1'b0,1'b1,1'b0);
	tsk_mux2to1(16'd10,1'b1,1'b1,1'b0);
	tsk_mux2to1(16'd10,1'b1,1'b1,1'b1);
	$finish;
end

var bit[31:0]arrayXgmiiTxd1[0:28]={
	32'hfb55_5555,32'h5555_55d5,32'h0000_0100,32'h0001_0010,32'h9400_0002,32'h8100_0064,
	32'hfe02_0001,32'h0070_0403,32'h0201_1211,32'h4847_4645,32'h4443_4241,32'h4039_3837,
	32'h3635_3433,32'h3231_3029,32'h2827_2625,32'h2423_2221,32'h2019_1817,32'h1615_1413,
	32'h1211_1009,32'h0807_0605,32'h0403_0201,32'h0403_0201,32'h1413_1211,32'h2423_2221,
	32'h3433_3231,32'h0095_0bf2,32'hf5e6_83e2,32'hda9f_1667,32'h086e_4bfd
	};
var bit[31:0]arrayXgmiiTxc1[0:28]={
	4'h8,4'h0,4'h0,4'h0,4'h0,4'h0,
	4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,
	4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,
	4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,
	4'h0,4'h0,4'h0,4'h0,4'h1
};
////====fsdb
//initial begin
//   	$helloworld;
//  	$fsdbDumpvars("+fsdbfile+tb_dut_top.fsdb");
//   	$fsdbDumpSVA;
//end



endmodule
