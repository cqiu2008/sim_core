module tb_dut_top;

reg			S_rst				;
reg			S_100m_clk			;
reg	[63:0]	S_data_a			;
reg	[63:0]	S_data_b			;
wire [64:0]	S_data_sum			;

//====dut 
dut_top U1_test(
	.I_rst		(S_rst		),
	.I_clk		(S_100m_clk	),
	.I_data_a	(S_data_a	),
	.I_data_b	(S_data_b	),
	.O_data_sum	(S_data_sum	)
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

task tsk_send_data;
	input  [63:0] I_data_a	;
	input  [63:0] I_data_b	;
	input  [15:0] I_dly_num	;
	S_data_a = I_data_a;
	S_data_b = I_data_b;
	tsk_dly_clks(I_dly_num);
endtask

initial begin
	S_data_a = 64'd0; 
	S_data_b = 64'd0; 
end

initial begin 
	S_rst =1'b0;
	S_100m_clk = 1'b1;
	tsk_dly_clks(100);
	S_rst =1'b1;
	tsk_send_data(	64'h0123_4567_89ab_cdef,
					64'h0555_6666_7777_8888,
					4'd10);
	tsk_dly_clks(100);
	tsk_send_data(	64'h1123_4567_89ab_cdef,
					64'h1555_6666_7777_8888,
					4'd10);
	tsk_dly_clks(100);
	tsk_send_data(	64'h2123_4567_89ab_cdef,
					64'h2555_6666_7777_8888,
					4'd10);
	tsk_send_data(	64'h3123_4567_89ab_cdef,
					64'h3555_6666_7777_8888,
					4'd10);
	tsk_send_data(	64'h1111_2222_3333_4444,
					64'h9999_0000_aaaa_bbbb,
					4'd10);
	tsk_send_data(	64'h5123_4567_89ab_cdef,
					64'h5555_6666_7777_8888,
					4'd10);
	tsk_send_data(	64'h6123_4567_89ab_cdef,
					64'h6555_6666_7777_8888,
					4'd10);
	tsk_dly_clks(100);

	$finish;
end

////====fsdb
initial begin
   	$helloworld;
  	$fsdbDumpvars("+fsdbfile+tb_dut_top.fsdb");
   	$fsdbDumpSVA;
end



endmodule
