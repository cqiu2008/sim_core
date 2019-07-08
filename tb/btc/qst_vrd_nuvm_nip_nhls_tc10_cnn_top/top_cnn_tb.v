`timescale 1ns / 1ps
module top_cnn_tb;

parameter KERNEL_SIZE = 3;
parameter LEARNING_RATE = 16'd15552; // 0.95 using WL = 16 and FL = 14
parameter WL = 16;
parameter FL = 14;

parameter FF_MODE = 0, FB_MODE = 1, GR_MODE = 2;

integer i;

reg CLK, RESET, Start;
reg signed [(WL - 1):0] in1, in2, in3, in4, in5, in6, in7, in8, in9;
reg signed [(WL - 1):0] label1, label2, label3, label4, label5, label6, label7, label8, label9, label10;
wire signed [(WL - 1):0] out1, out2, out3, out4, out5, out6, out7, out8, out9, out10;
wire Done;

top_cnn #(.KERNEL_SIZE(KERNEL_SIZE), .LEARNING_RATE(LEARNING_RATE), .WL(WL), .FL(FL)) dut(
    CLK, RESET, Start, Done, 
    in1, in2, in3, in4, in5, in6, in7, in8, in9, 
    label1, label2, label3, label4, label5, label6, label7, label8, label9, label10,
    out1, out2, out3, out4, out5, out6, out7, out8, out9, out10
);

always #5 CLK = ~CLK;

initial begin
    RESET = 0;
    CLK = 0;
    in1 = (1 << (FL - 2));
    in2 = (1 << (FL - 2));
    in3 = (1 << (FL - 2));
    in4 = (1 << (FL - 2));
    in5 = (1 << (FL - 2));
    in6 = (1 << (FL - 2));
    in7 = (1 << (FL - 2));
    in8 = (1 << (FL - 2));
    in9 = (1 << (FL - 2));
    label1 = (1 << (FL - 2));
    label2 = (1 << (FL - 2));
    label3 = (1 << (FL - 2));
    label4 = (1 << (FL - 2));
    label5 = (1 << (FL - 2));
    label6 = (1 << (FL - 2));
    label7 = (1 << (FL - 2));
    label8 = (1 << (FL - 2));
    label9 = (1 << (FL - 2));
    label10 = (1 << (FL - 2));
    
    #15
    
    RESET = 1;
    
    #10
    
    Start = 1;
    
    #((2*3 + 1 + 1)*32*32 * 10 + 20)

    #(2*16*16*10 + 10)
    
    #(3*16*4*10 + 10)
        
    #20
    
    #(3*16*4*10*10 + 10)
    
    #(2*16*4*10 + 20)
    
    #(2*3*16*16*10 + 16*10)
    
    #(3*32*32*3*10 + 10)
        
    #10
    
    $stop;
end

////====fsdb
initial begin
	$helloworld;
	$fsdbDumpvars("+fsdbfile+tb_dut_top.fsdb");
	$fsdbDumpSVA;
end

endmodule
