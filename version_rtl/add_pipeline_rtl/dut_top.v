module dut_top(
	input 			I_rst		,
	input 			I_clk		,
	input  [63:0]	I_data_a	,
	input  [63:0]	I_data_b	,
	output [64:0]	O_data_sum	
);

add_pp4 U0_add_pp4(
	.I_rst		(I_rst		),
	.I_clk		(I_clk		),
	.I_data_a	(I_data_a	),
	.I_data_b	(I_data_b	),
	.O_data_sum	(O_data_sum	)
);

endmodule

