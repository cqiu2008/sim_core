module mux3to1_structure(
input  		I_in1,
input   	I_in2,
input   	I_in3,
input  [1:0]I_sel,
output  	O_out
);

////structure description
wire S_in1_in2_out;
mux2to1_structure u1(I_in1,I_in2,I_sel[0],S_in1_in2_out);
mux2to1_structure u1(I_in3,S_in1_in2_out,I_sel[1],O_out);

endmodule
