module mux2to1_structure(
input  		I_in1,
input   	I_in2,
input   	I_sel,
output  	O_out
);

//assign O_out =  I_sel ? I_in1 : I_in2; //// behavior desciption
////behaviro description
//assign O_out = (I_sel & I_in1 ) | ((!I_sel) & I_in2);
////structure description
wire S_sel_n;
wire S_in1_out;
wire S_in2_out;
not u1(S_sel_n,I_sel);
and u2(S_in1_out,I_sel,I_in1);
and u3(S_in2_out,S_sel_n,I_in2);
or u4(O_out,S_in1_out,S_in2_out);

endmodule