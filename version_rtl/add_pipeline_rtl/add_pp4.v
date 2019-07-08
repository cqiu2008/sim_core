module add_pp4(
	input 			I_rst		,
	input 			I_clk		,
	input  [63:0]	I_data_a	,
	input  [63:0]	I_data_b	,
	output [64:0]	O_data_sum	
);

parameter ADD_WIDTH = 5'd16;

wire [15:0] S_d0_a0	;
wire [15:0] S_d0_a1	;
wire [15:0] S_d0_a2	;
wire [15:0] S_d0_a3	;

assign S_d0_a0 = I_data_a[15: 0];
assign S_d0_a1 = I_data_a[31:16];
assign S_d0_a2 = I_data_a[47:32];
assign S_d0_a3 = I_data_a[63:48];

wire [15:0] S_d0_b0	;
wire [15:0] S_d0_b1	;
wire [15:0] S_d0_b2	;
wire [15:0] S_d0_b3	;

assign S_d0_b0 = I_data_b[15: 0];
assign S_d0_b1 = I_data_b[31:16];
assign S_d0_b2 = I_data_b[47:32];
assign S_d0_b3 = I_data_b[63:48];

////Stage 1
reg [16:0] S_d1_ab0	;
reg [16:0] S_d1_ab1	;
reg [15:0] S_d1_a2	;
reg [15:0] S_d1_b2	;
reg [15:0] S_d1_a3	;
reg [15:0] S_d1_b3	;
////Stage 2
reg [15:0] S_d2_ab0	;
reg [16:0] S_d2_ab1	;
reg [16:0] S_d2_ab2	;
reg [15:0] S_d2_a3	;
reg [15:0] S_d2_b3	;
////Stage 3 
reg [15:0] S_d3_ab0	;
reg [15:0] S_d3_ab1	;
reg [16:0] S_d3_ab2	;
reg [16:0] S_d3_ab3	;
////Stage 4
reg [15:0] S_d4_ab0	;
reg [15:0] S_d4_ab1	;
reg [15:0] S_d4_ab2	;
reg [16:0] S_d4_ab3	;

always @(posedge I_clk)begin
	////Stage 1
	S_d1_ab0 <= S_d0_a0 + S_d0_b0		;////S_d1_ab0[15:0] stable
	S_d1_ab1 <= S_d0_a1 + S_d0_b1  		;
	S_d1_a2  <= S_d0_a2;
	S_d1_b2  <= S_d0_b2;
	S_d1_a3  <= S_d0_a3;
	S_d1_b3  <= S_d0_b3;
	////Stage 2
	S_d2_ab0 <= S_d1_ab0[15:0]			;
	S_d2_ab1 <= S_d1_ab1 + S_d1_ab0[16]	;////S_d2_ab1[15:0] stable
	S_d2_ab2 <= S_d1_a2	 + S_d1_b2		;
	S_d2_a3	 <= S_d1_a3;
	S_d2_b3	 <= S_d1_b3;
	////Stage 3
	S_d3_ab0 <= S_d2_ab0				;
	S_d3_ab1 <= S_d2_ab1[15:0]			;
	S_d3_ab2 <= S_d2_ab2 + S_d2_ab1[16]	;////S_d3_ab2[15:0] stable
	S_d3_ab3 <= S_d2_a3 + S_d2_b3		;
	////Stage 4 
	S_d4_ab0 <= S_d3_ab0				;
	S_d4_ab1 <= S_d3_ab1				;
	S_d4_ab2 <= S_d3_ab2[15:0]			;
	S_d4_ab3 <= S_d3_ab3 + S_d3_ab2[16] ;////S_d4_ab3[16:0] stable
end

assign O_data_sum = {S_d4_ab3[16:0],S_d4_ab2[15:0],S_d4_ab1[15:0],S_d4_ab0[15:0]};

endmodule
