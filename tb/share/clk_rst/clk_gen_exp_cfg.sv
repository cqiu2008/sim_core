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
//`include "sc_macro.v"///v.11/v,28ͷ�ļ�
//novas -21044:27
module clk_gen_exp_cfg(
//========================clk  rst  interface ===========================
  input                        I_sys_clk       , /// 125Mʱ��
  input                        I_rst           , /// ��λ�źţ�����Ч

  input						   I_rst_cfg       , ///
  input						   I_gen_stop	   , ///
  input     [31:0]			   I_sys_clk_freq  , ///
  input     [31:0]			   I_expect_clk	   , ///
  
//========================output=========================================
  output                       O_div_exp_clk      /// ���ز�����64K����ʱ��   
);
//====================wire signals===========================

//====================reg signals===========================
    //��ģ����ͨ��125M��ʱ�ӷ�Ƶ����64K��ʱ�ӣ�
    //125M/2.048M=15625/256.Ҳ����˵15625��125M��CLK�в���256��CLK���Ϳ��Բ���2.048M��ʱ���ˡ�
    //�����㷨��-��С����Ƶ��ԭ��
    //��15625��125M��CLK������ȡ��256��CLK,�Ϳ��Եõ�2.048M��ʱ��;125M/2.048M=15625/256;
	reg                 S_loc_2m048_clk ; ///
    reg     [15:0]      S_clk_count		; ///ʱ�Ӽ�����
    reg                 S_logic_2m048   ; ///ʱ�Ӵ���
    reg     [15:0]      S_numerator		; ///����
    reg     [15:0]      S_denuminator	; ///��ĸ


// 125 === I_numerator
// 2   === I_denuminator
///===========Parameter=================================
`ifdef FAST_SIMULATION ///��߲���Ƶ�ʣ��ӿ����
    parameter  C_NUMERATOR   =16'd15625; ///����
    parameter  C_DENUMINATOR =16'd2560  ; ///��ĸ,��10��
`else  ///��߲���Ƶ�ʣ��ӿ����
    parameter  C_NUMERATOR   =16'd15625; ///����
    parameter  C_DENUMINATOR =16'd512  ; ///��ĸ
`endif ///��߲���Ƶ�ʣ��ӿ����

    //��---���㷨��ʵ�֣�
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
	
    //����������
    always @(posedge I_sys_clk or posedge I_rst)
        if(I_rst)
              S_loc_2m048_clk <=  1'b1          ;
        else if(S_logic_2m048)
              S_loc_2m048_clk <= ~S_loc_2m048_clk ;
	    else 
			  S_loc_2m048_clk <= S_loc_2m048_clk  ;


endmodule

