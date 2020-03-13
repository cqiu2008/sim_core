/***********************************************************************************
** DISCLAIMER                                                                     **
**                                                                                **
**   SMIC hereby provides the quality information to you but makes no claims,     **
** promises or guarantees about the accuracy, completeness, or adequacy of the    **
** information herein. The information contained herein is provided on an "AS IS" **
** basis without any warranty, and SMIC assumes no obligation to provide support  **
** of any kind or otherwise maintain the information.                             **
**   SMIC disclaims any representation that the information does not infringe any **
** intellectual property rights or proprietary rights of any third parties.SMIC   **
** makes no other warranty, whether express, implied or statutory as to any       **
** matter whatsoever,including but not limited to the accuracy or sufficiency of  **
** any information or the merchantability and fitness for a particular purpose.   **
** Neither SMIC nor any of its representatives shall be liable for any cause of   **
** action incurred to connect to this service.                                    **
**                                                                                **
** STATEMENT OF USE AND CONFIDENTIALITY                                           **
**                                                                                **
**   The following/attached material contains confidential and proprietary        **
** information of SMIC. This material is based upon information which SMIC        **
** considers reliable, but SMIC neither represents nor warrants that such         **
** information is accurate or complete, and it must not be relied upon as such.   **
** This information was prepared for informational purposes and is for the use    **
** by SMIC's customer only. SMIC reserves the right to make changes in the        **
** information at any time without notice.                                        **
**   No part of this information may be reproduced, transmitted, transcribed,     **
** stored in a retrieval system, or translated into any human or computer         **
** language, in any form or by any means, electronic, mechanical, magnetic,       **
** optical, chemical, manual, or otherwise, without the prior written consent of  **
** SMIC. Any unauthorized use or disclosure of this material is strictly          **
** prohibited and may be unlawful. By accepting this material, the receiving      **
** party shall be deemed to have acknowledged, accepted, and agreed to be bound   **
** by the foregoing limitations and restrictions. Thank you.                      **
************************************************************************************
**  Check tool version:
**  VCS       :  vcs_2011.12-SP1
**  NC-Verilog:  INCISIV10.20.035
**  ModelSim  :  ams_2012.1_1 
** 
************************************************************************************
**  Project : S40NLLPLLGS_ZP1500 (IP DesignKit)                                                               
**                                                                                 
************************************************************************************
**  History:                                                                      
**  Version   Date         Author       Description                               
************************************************************************************
** V1.1.1    2010/08/02	  Baoli        Initial Version.
** V1.6.3    2013/12/15   Kessy        Improve the verilog behavior for XIN change case and CLK_OUT out of range case
** V1.6.5    2016/03/09   Kessy        Improve unknow (line 251) and LT(line 334,335) definition
***********************************************************************************/


`celldefine
`timescale 1ns/1ps
        
  //`define LT_in		     500000                       
  `define LT_in		     50000                       
  `define M_width	     8
  `define N_width	     4
  `define OD_width	     2 
  `define BP_delay	     2  
  `define M_min 	     2  
  `define N_min 	     1 
  `define CLK_OUT_min	     500  
  `define CLK_OUT_max	     1500
  `define XIN_N_min	     1 
  `define XIN_N_max	     50
  `define LKDT_in_SLEEP12    1'b0   
  `define CLK_OUT_in_SLEEP12 1'b0 
  `define unknown_value      1'bx
  `define CLK_OUT_in_lock    1'bx
      
module S40NLLPLLGS_ZP1500 ( 
   AVDD, 
   AVSS, 
   DVDD, 
   DVSS, 
   XIN, 
   CLK_OUT, 
   LKDT, 
   N, 
   M, 
   PDRST, 
   OD, 
   BP 
   );
   
   parameter LT=`LT_in;

   inout   AVDD;
   inout   AVSS;
   inout   DVDD;
   inout   DVSS;
   input   XIN; 	// input	
   output  CLK_OUT;	// PLL, clock out
   output  LKDT;	// PLL, lock out 
   input   [3:0]   N;	// Input 4-bit divider control pins.
   input   [7:0]   M;	// Feed Back 8-bit divider control pins.
   input   PDRST   ;	// PDRST =0 should be used in normal PLL operation.
   input   [1:0]   OD;  // Output divider control pin
   input   BP;  	// PLL bypass mode selection

//////buffer////////
   wire CLK_OUTi, XINi, PDRSTi, BPi, CLK_OUT, LKDT, LKDTi;
   wire [3:0] Ni;
   wire [1:0] ODi;
   wire [7:0] Mi;
   
   buf(LKDT,LKDTi);   
   buf(XINi,XIN);
   buf(PDRSTi,PDRST);
   buf(BPi,BP);
   buf(CLK_OUT,CLK_OUTi);
   buf(Ni[0],N[0]);
   buf(Ni[1],N[1]);
   buf(Ni[2],N[2]);
   buf(Ni[3],N[3]);
   buf(Mi[0],M[0]);
   buf(Mi[1],M[1]);
   buf(Mi[2],M[2]);
   buf(Mi[3],M[3]);
   buf(Mi[4],M[4]);
   buf(Mi[5],M[5]);
   buf(Mi[6],M[6]);
   buf(Mi[7],M[7]);
   buf(ODi[0],OD[0]);
   buf(ODi[1],OD[1]);

//////internal signal///////
   real XIN_period, XIN_period_p, pre_r_time, XIN_frq_divN, clk_frq_xNO, XIN_period_max; 
   real clk_out_delay, dvd, Mi_real, Ni_real; 
   reg [2:0] cond;
   wire clk_valid, lkdt_en, xin_bypass; 
   reg st_r, clk_out, XIN_change, unknow_XIN, sample_XIN0, sample_XIN1; 
   reg unknow_N, unknow_M, unknow_BP, unknow_OD, unknow_RESET, unknow_PDRST;
   wire unknow;
   reg XIN_change_pre, XIN_change_post;   
   
/////RESET must be low//////
   always @(Ni or Mi)
   begin
      if(PDRSTi==1'b0)
      begin
	  $display("%m ****************************************************");
	  $display("%m Warning at %fns : M & N must change within PDRST=1",$realtime); 
      end   
   end      


/////initial 
   initial 
   begin
     XIN_period_max = 1000/(`XIN_N_min*`N_min);
     pre_r_time = $realtime;
     clk_out = 1'b0;
     clk_out_delay = 5;
     st_r = 1'b0;
     unknow_XIN = 1'b0;
     unknow_PDRST = 1'b0;
     unknow_N = 1'b0;
     unknow_M = 1'b0;
     unknow_BP = 1'b0; 
     unknow_OD = 1'b0; 
     unknow_RESET = 1'b0;  
     dvd =1;
     XIN_period = 1; 
     XIN_change = 0;
     cond = 3'b111;
     sample_XIN0 = 0;
     sample_XIN1 = 1;
     XIN_change_pre = 0; 
     XIN_change_post = 0;    
   end  
   
   always @(Mi)
      Mi_real=Mi;
      
   always @(Ni)
      Ni_real=Ni;
                
///////output divider//////
   always @(ODi)
   begin
      case(ODi)
      2'b00:  dvd=1;
      2'b01:  dvd=2;
      2'b10:  dvd=4;
      2'b11:  dvd=8;
      endcase
   end     
   
//////XINi period///////////
   always @(posedge XINi)
   begin
      XIN_period_p <= XIN_period;
      XIN_period <= $realtime -pre_r_time;
      pre_r_time <=$realtime;
   end 
   
//////XINi period change///////////
   always @(posedge XINi or posedge PDRSTi)
   begin
      if(PDRSTi==1'b1)
          sample_XIN0 = 1'b0;
      else
      begin
      #0.001;
      if(((XIN_period-XIN_period_p)<=0.001)&&((XIN_period_p-XIN_period)<=0.001))
      begin
          #(XIN_period-0.002) sample_XIN0 = XINi;
      end
      end
   end
   
   always @(negedge XINi or posedge PDRSTi)
   begin
      if(PDRSTi==1'b1)
          sample_XIN1 = 1'b1;
      else
      begin
      if(((XIN_period-XIN_period_p)<=0.001)&&((XIN_period_p-XIN_period)<=0.001))
      begin
          #(XIN_period-0.001) sample_XIN1 = XINi;
      end
      end
   end   
   
   always @(posedge XINi)
   begin
      if(PDRSTi==1'b0)
      begin
      #0.001;
      if(((XIN_period-XIN_period_p)>0.001)||((XIN_period_p-XIN_period)>0.001))
          XIN_change_pre = ~XIN_change_pre;
      end
   end   
   
   always @(sample_XIN0 or sample_XIN1)
   begin
      if((sample_XIN0!==1'b0)||(sample_XIN1!=1'b1))
      begin
           XIN_change_post = ~XIN_change_post; 
      end
   end 
   
   always @(XIN_change_pre or XIN_change_post)
   begin
      XIN_change = ~XIN_change; 
   end  
      
//////////input unknow///////////////     
   assign unknow = (^Ni===1'bx) | (^Mi===1'bx) | (BPi===1'bx) | (PDRSTi===1'bx)
                  | (^ODi===1'bx) | (XINi===1'bx);
      
   always @(posedge lkdt_en)
   begin
      if((unknow==1'b1)&&($realtime>0)) 
      begin          
	  $display("%m ****************************************************");
	  $display("%m Error at %fns : One or more of the inputs unknown.",$realtime);
      end   
   end		  
         	              
////////////usage condition////////////////
   always @ (Mi or Ni or XIN_period or Mi_real or Ni_real)
   begin 
      if((Mi>=`M_min)&&(Ni>=`N_min))
      begin
          XIN_frq_divN = 1000 / (Ni_real * XIN_period);
          clk_frq_xNO =  Mi_real * 1000 / (Ni_real * XIN_period);                          
          cond[0] = (!((`XIN_N_min-XIN_frq_divN)>=0.001)) & (!((XIN_frq_divN-`XIN_N_max)>=0.001));
          cond[1] = (!((`CLK_OUT_min-clk_frq_xNO)>=0.001)) & (!((clk_frq_xNO-`CLK_OUT_max)>=0.001));
      end
      cond[2] = ((Mi >=`M_min) && (Ni >=`N_min));
   end 
   
   assign  clk_valid = (& cond);
   
   always @ (cond or BPi or lkdt_en) 
   begin 
    #1;
    if ((cond[2]==1'b0) && (BPi==1'b0) && (lkdt_en==1'b1)&&(unknow==1'b0))
    begin
	$display("%m ****************************************************");
   	$display("%m Error at %f ns:  Violate rule (3) -   M >= 2; N >= 1 ; M =%5d  N =%5d",$realtime, M, N);  
    end      
    else begin
        if ((cond[0]==1'b0) && (BPi==1'b0) && (lkdt_en==1'b1)&&(unknow==1'b0))
    	begin
	    $display("%m ****************************************************");
   	    $display("%m Error at %f ns: Violate rule (1) -   1MHz <= XIN/N <= 50MHz; XIN/N =%10fMHz ", $realtime, XIN_frq_divN); 
    	end
    	if ((cond[1]==1'b0) && (BPi==1'b0) && (lkdt_en==1'b1)&&(unknow==1'b0))
    	begin
	    $display("%m ****************************************************");
   	    $display("%m Error at %f ns: Violate rule (2) -   500MHz <= CLK_OUTxNO <= 1500MHz; CLK_OUTxNO =%10fMHz ", $realtime, clk_frq_xNO ); 
    	end
    end
   end   

/////////////output period/////////////////    
   always @(Mi or Ni or ODi or XIN_period or dvd or Ni_real or Mi_real)
   begin
      if((Mi>=`M_min)&&(Ni>=`N_min)&&(|ODi!==1'bx)&&(XIN_period<=XIN_period_max))
          clk_out_delay = ((Ni_real*XIN_period*dvd)/(Mi_real))/2;  
      else
          clk_out_delay = 5;   
   end
   
/////////////re-lock /////////////////
   always @(Ni or Mi or PDRSTi or XIN_change or unknow or BPi)
   begin
          st_r=1'b0;
	  #1 st_r=1'b1;	  	  
   end
   
/////////////output clk /////////////////
   always @(posedge lkdt_en) 
   begin: syn_clk_out
      fork 
          begin
	      while(1) 
	         #(clk_out_delay) clk_out=~clk_out;
	  end
	  begin
	      @(Ni or Mi or PDRSTi or XIN_change or unknow or BPi)
	      begin
	         clk_out = 0;
		 disable syn_clk_out;     
	      end
	  end    
      join
   end     
   
   assign #(LT-1.001,0) lkdt_en = st_r;   
   wire #(LT-1,0) lkdt_en2 = st_r;  
   assign #`BP_delay xin_bypass = XINi;
   
   assign CLK_OUTi = PDRSTi ? `CLK_OUT_in_SLEEP12 : 
		     BPi ? xin_bypass : 
		     unknow ? `unknown_value :
		     !lkdt_en ? `CLK_OUT_in_lock : 
		     clk_valid ? clk_out : 1'b0;
   
   assign LKDTi =  PDRSTi ? `LKDT_in_SLEEP12 : 
		  unknow ? `unknown_value : 
		  clk_valid ? lkdt_en2 : 1'b0;
              
endmodule
`endcelldefine  
