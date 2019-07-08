//FILE_HEADER-------------------------------------------------------
//ZTE Copyright(C)
// ZTE Company Confidential
//------------------------------------------------------------------
// Project Name : NR8120 xxxx
// FILE NAME    : sw_mux.v
// AUTHOR       : qiu,chao
// Department   : MicroWave Department
// Email        : qiu.chao@zte.com.cn
//------------------------------------------------------------------
// Module Hiberarchy:
//x                 |----tx_cpri_timing
//x                 |----tx_cpri_iq_map   
//x tx_cpri_top-----|----tx_cpri_spec_cw   
//x                 |----tx_cpri_vendor_cw
//x                 |----tx_cpri_framing 
//-----------------------------------------------------------------
// Release History:
//-----------------------------------------------------------------
// Version      Date      Author        Description
// 1.0        2-23-2013   qiuchao       initial version
// 1.1        mm-dd-yyyy   Author       �޸ġ���������Ҫ��������
//-----------------------------------------------------------------
//Main Function:
// a) Insert basic spec ctrl words,mac or hdlc data and iq data into cpri frame.
//-----------------------------------------------------------------
//REUSE ISSUES: xxxxxxxx          
//Reset Strategy: asynchronous reset
//Clock Strategy: xxxxxxxx
//Critical Timing: xxxxxxxx
//Asynchronous Interface: xxxxxxxx
//END_HEADER--------------------------------------------------------
//novas -16057:10
///`timescale 1ns/100ps
module sw_mux
(
//========================clk  rst  interface ===========================================
    input                        I_125m_clk        ,/// 125Mʱ��
    input                        I_rst             ,/// ��λ�źţ�����Ч
//=========================gmii tx  interface ===========================================
    input                        I_tx_gmii_dv_p0   ,/// 
    input                        I_tx_gmii_err_p0  ,/// 
    input      [7:0]             I_tx_gmii_d_p0    ,/// 
    input                        I_tx_gmii_dv_p1   ,/// 
    input                        I_tx_gmii_err_p1  ,/// 
    input      [7:0]             I_tx_gmii_d_p1    ,/// 
    input                        I_tx_gmii_dv_p2   ,/// 
    input                        I_tx_gmii_err_p2  ,/// 
    input      [7:0]             I_tx_gmii_d_p2    ,/// 
    input                        I_tx_gmii_dv_p3   ,/// 
    input                        I_tx_gmii_err_p3  ,/// 
    input      [7:0]             I_tx_gmii_d_p3    ,/// 
//=========================gmii rx  interface ===========================================
    input                        I_rx_gmii_dv      ,/// 
    input                        I_rx_gmii_err     ,/// 
    input      [7:0]             I_rx_gmii_d       ,/// 
//=========================outputs===================================
    output                       O_tx_gmii_dv      ,/// 
    output     [7:0]             O_tx_gmii_d       ,/// 
    output                       O_tx_gmii_err     ,/// 
    output                       O_rx_gmii_dv_p0   ,/// 
    output     [7:0]             O_rx_gmii_d_p0    ,/// 
    output                       O_rx_gmii_err_p0  ,/// 
    output                       O_rx_gmii_dv_p1   ,/// 
    output     [7:0]             O_rx_gmii_d_p1    ,/// 
    output                       O_rx_gmii_err_p1  ,/// 
    output                       O_rx_gmii_dv_p2   ,/// 
    output     [7:0]             O_rx_gmii_d_p2    ,/// 
    output                       O_rx_gmii_err_p2  ,/// 
    output                       O_rx_gmii_dv_p3   ,/// 
    output     [7:0]             O_rx_gmii_d_p3    ,/// 
    output                       O_rx_gmii_err_p3  
);
//========wire signals 
//================================================================Instance===========================================
sw_tx_mux U0_sw_tx_mux(
  .I_125m_clk        (I_125m_clk               ),/// 125Mʱ��
  .I_rst             (I_rst                    ),/// ��λ�źţ�����Ч
  .I_tx_gmii_dv_p0   (I_tx_gmii_dv_p0          ),/// 
  .I_tx_gmii_err_p0  (I_tx_gmii_err_p0         ),/// 
  .I_tx_gmii_d_p0    (I_tx_gmii_d_p0           ),/// 
  .I_tx_gmii_dv_p1	 (I_tx_gmii_dv_p1          ),/// 
  .I_tx_gmii_err_p1  (I_tx_gmii_err_p1         ),/// 
  .I_tx_gmii_d_p1    (I_tx_gmii_d_p1           ),/// 
  .I_tx_gmii_dv_p2   (I_tx_gmii_dv_p2          ),/// 
  .I_tx_gmii_err_p2  (I_tx_gmii_err_p2         ),/// 
  .I_tx_gmii_d_p2    (I_tx_gmii_d_p2           ),/// 
  .I_tx_gmii_dv_p3   (I_tx_gmii_dv_p3          ),///
  .I_tx_gmii_d_p3    (I_tx_gmii_d_p3           ),/// 
  .O_tx_gmii_dv      (O_tx_gmii_dv             ),///
  .O_tx_gmii_d       (O_tx_gmii_d              ),///
  .O_tx_gmii_err     (O_tx_gmii_err            ) ///
);
sw_rx_mux U0_sw_rx_mux(
  .I_125m_clk        (I_125m_clk               ),/// 125Mʱ��
  .I_rst             (I_rst                    ),/// ��λ�źţ�����Ч
  .I_rx_gmii_dv      (I_rx_gmii_dv			   ),/// gmii ����������Ч
  .I_rx_gmii_err     (I_rx_gmii_err			   ),/// gmii �������ݴ���ָʾ
  .I_rx_gmii_d       (I_rx_gmii_d			   ),/// gmii ��������
  .O_rx_gmii_dv_p0   (O_rx_gmii_dv_p0          ),/// 
  .O_rx_gmii_d_p0    (O_rx_gmii_d_p0           ),/// 
  .O_rx_gmii_err_p0  (O_rx_gmii_err_p0         ),/// 
  .O_rx_gmii_dv_p1	 (O_rx_gmii_dv_p1          ),/// 
  .O_rx_gmii_d_p1    (O_rx_gmii_d_p1           ),/// 
  .O_rx_gmii_err_p1  (O_rx_gmii_err_p1         ),/// 
  .O_rx_gmii_dv_p2   (O_rx_gmii_dv_p2          ),/// 
  .O_rx_gmii_d_p2    (O_rx_gmii_d_p2           ),/// 
  .O_rx_gmii_err_p2  (O_rx_gmii_err_p2         ),/// 
  .O_rx_gmii_dv_p3   (O_rx_gmii_dv_p3          ),/// 
  .O_rx_gmii_d_p3    (O_rx_gmii_d_p3           ),/// 
  .O_rx_gmii_err_p3  (O_rx_gmii_err_p3         ) /// 
);

//====S_rx_gmii_err_dv_din
endmodule
