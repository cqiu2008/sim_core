`timescale 1ns / 1ps

module test_func(
    input                  I_aclk,
    input                  I_arst,
    input                  I_start,
    //data in
    input    [127:0]       I_feature_in,
    input                  I_feature_dv,
    //data out
    output reg  [127:0]    O_feature_out,
    output reg             O_feature_dv
    );
    
    reg      [7:0]         S_wait_cnt;  
    reg                    S_wait_flag;
    
    always@ (posedge I_aclk)
    begin
//        if (I_start)
        begin
            O_feature_out <= ~I_feature_in;
            O_feature_dv <= I_feature_dv;
        end
    end
endmodule
