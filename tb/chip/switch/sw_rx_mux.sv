//FILE_HEADER-------------------------------------------------------
//ZTE Copyright(C)
// ZTE Company Confidential
//------------------------------------------------------------------
// Project Name : NR8120 xxxx
// FILE NAME    : sw_rx_mux.v
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
// 1.1        mm-dd-yyyy   Author       修改、增减的主要内容描述
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
//novas -22057:500
///`timescale 1ns/100ps
module sw_rx_mux
(
//========================clk  rst  interface ===========================================
    input                        I_125m_clk         ,/// 125M时钟
    input                        I_rst              ,/// 复位信号，高有效
//=========================gmii rx  interface ===========================================
    input                        I_rx_gmii_dv       ,/// gmii 接收数据有效
    input                        I_rx_gmii_err      ,/// gmii 接收数据错误指示
    input      [7:0]             I_rx_gmii_d        ,/// gmii 接收数据
//=========================outputs===================================
    output reg                   O_rx_gmii_dv_p0    ,/// 
    output reg [7:0]             O_rx_gmii_d_p0     ,/// 
    output reg                   O_rx_gmii_err_p0	,/// 
    output reg                   O_rx_gmii_dv_p1	,/// 
    output reg [7:0]             O_rx_gmii_d_p1		,/// 
    output reg                   O_rx_gmii_err_p1	,/// 
    output reg                   O_rx_gmii_dv_p2	,/// 
    output reg [7:0]             O_rx_gmii_d_p2		,/// 
    output reg                   O_rx_gmii_err_p2	,/// 
    output reg                   O_rx_gmii_dv_p3	,/// 
    output reg [7:0]             O_rx_gmii_d_p3		,/// 
    output reg                   O_rx_gmii_err_p3	 /// 
);
//===RX_MUX
//==== p0
always @(posedge I_125m_clk or posedge I_rst)
begin
	if(I_rst)
	begin
		O_rx_gmii_dv_p0   <= 1'b0			;
		O_rx_gmii_err_p0  <= 1'b0			;
		O_rx_gmii_d_p0    <= 8'b0			;
	end
	else
	begin
		O_rx_gmii_err_p0  <= I_rx_gmii_err	; 
		O_rx_gmii_dv_p0   <= I_rx_gmii_dv	; 
		O_rx_gmii_d_p0    <= I_rx_gmii_d	; 
	end
end
//==== p1
always @(posedge I_125m_clk or posedge I_rst)
begin
	if(I_rst)
	begin
		O_rx_gmii_dv_p1   <= 1'b0			;
		O_rx_gmii_err_p1  <= 1'b0			;
		O_rx_gmii_d_p1    <= 8'b0			;
	end
	else
	begin
		O_rx_gmii_err_p1  <= I_rx_gmii_err	; 
		O_rx_gmii_dv_p1   <= I_rx_gmii_dv	; 
		O_rx_gmii_d_p1    <= I_rx_gmii_d	; 
	end
end
//==== p2
always @(posedge I_125m_clk or posedge I_rst)
begin
	if(I_rst)
	begin
		O_rx_gmii_dv_p2   <= 1'b0			;
		O_rx_gmii_err_p2  <= 1'b0			;
		O_rx_gmii_d_p2    <= 8'b0			;
	end
	else
	begin
		O_rx_gmii_err_p2  <= I_rx_gmii_err	; 
		O_rx_gmii_dv_p2   <= I_rx_gmii_dv	; 
		O_rx_gmii_d_p2    <= I_rx_gmii_d	; 
	end
end
//==== p3
always @(posedge I_125m_clk or posedge I_rst)
begin
	if(I_rst)
	begin
		O_rx_gmii_dv_p3   <= 1'b0			;
		O_rx_gmii_err_p3  <= 1'b0			;
		O_rx_gmii_d_p3    <= 8'b0			;
	end
	else
	begin
		O_rx_gmii_err_p3  <= I_rx_gmii_err	; 
		O_rx_gmii_dv_p3   <= I_rx_gmii_dv	; 
		O_rx_gmii_d_p3    <= I_rx_gmii_d	; 
	end
end

endmodule
