module dut_top(
	input 		I_rst		,
	input 		I_clk		,
	input		I_data_in	,	
	output 		O_data_out	
);

reg [2:0] S_data_in;

always @(posedge I_clk)begin
	S_data_in <= {S_data_in[0],I_data_in};
end

assign O_data_out = S_data_in[1];

endmodule

