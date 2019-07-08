//FILE_HEADER--------------------------------------------------------------
//Copyright:ZTE
//Company Confidential:ZTE
//------------------------------------------------------------------------
//FILE NAME:      v11_loc_64k_gen.v
//DEPARTMENT:     ZTE-GU
//AUTHOR:         Qiu Chao 
//AUTHOR'S EMAIL: Qiu.Chao@zte.com.cn
//------------------------------------------------------------------------
//RELEASE HISTORY
//VERSION     DATE      AUTHOR           DESCRIPTION
// 1.0      2012-07-08  Qiu Chao         Original version.
//------------------------------------------------------------------------
//KEYWORDS:v11_loc_64k_gen
//------------------------------------------------------------------------
//PURPOSE: v11_loc_64k_gen            
//------------------------------------------------------------------------
//PARAMETERS:v11_loc_64k_gen
//novas -35001:100
//PARAM NAME:RANG:DESCRIPTION:DEFAULT:UNITS:
//-------------------------------------------------------------------------
//END_HEADER-------------------------------------------------------------- 
///`timescale 1ns/1ns
//novas -16057:36
//`include "sc_macro.v"///v.11/v,28头文件
//novas -21044:27
module clk_gen_exp_cfg(
//========================clk  rst  interface ===========================
  input                        I_sys_clk       , /// 125M时钟
  input                        I_rst           , /// 复位信号，高有效

  input						   I_rst_cfg       , ///
  input						   I_gen_stop	   , ///
  input     [31:0]			   I_sys_clk_freq  , ///
  input     [31:0]			   I_expect_clk	   , ///
  
//========================output=========================================
  output                       O_div_exp_clk      /// 本地产生的64K工作时钟   
);
//====================wire signals===========================

//====================reg signals===========================
    //本模块是通过125M的时钟分频产生64K的时钟；
    //125M/2.048M=15625/256.也就是说15625个125M的CLK中产生256个CLK，就可以产生2.048M的时钟了。
    //采用算法∑-△小数分频的原理
    //从15625个125M的CLK当中提取出256个CLK,就可以得到2.048M的时钟;125M/2.048M=15625/256;
	reg                 S_loc_2m048_clk ; ///
    reg     [15:0]      S_clk_count		; ///时钟计数器
    reg                 S_logic_2m048   ; ///时钟打拍
    reg     [15:0]      S_numerator		; ///分子
    reg     [15:0]      S_denuminator	; ///分母


// 125 === I_numerator
// 2   === I_denuminator
///===========Parameter=================================
`ifdef FAST_SIMULATION ///提高采样频率，加快仿真
    parameter  C_NUMERATOR   =16'd15625; ///分子
    parameter  C_DENUMINATOR =16'd2560  ; ///分母,快10倍
`else  ///提高采样频率，加快仿真
    parameter  C_NUMERATOR   =16'd15625; ///分子
    parameter  C_DENUMINATOR =16'd512  ; ///分母
`endif ///提高采样频率，加快仿真

    //∑---△算法的实现；
    always@(posedge I_sys_clk or posedge I_rst)
    if(I_rst)
	   begin
            S_clk_count <=  16'd0;
            S_logic_2m048  <=  1'b0;
       end
    else if(S_clk_count < C_DENUMINATOR)
	    begin
            S_clk_count <= S_clk_count - C_DENUMINATOR + C_NUMERATOR;//17
            S_logic_2m048<=1'b1;
        end
    else begin
            S_clk_count <= S_clk_count - C_DENUMINATOR;
            S_logic_2m048<=1'b0;
          end
		  
	assign O_div_exp_clk = S_loc_2m048_clk;
	
    //叠加起来；
    always @(posedge I_sys_clk or posedge I_rst)
        if(I_rst)
              S_loc_2m048_clk <=  1'b1          ;
        else if(S_logic_2m048)
              S_loc_2m048_clk <= ~S_loc_2m048_clk ;
	    else 
			  S_loc_2m048_clk <= S_loc_2m048_clk  ;


endmodule

