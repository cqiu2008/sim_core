//FILE_HEADER-------------------------------------------------------
//ZTE Copyright(C)
// ZTE Company Confidential
//------------------------------------------------------------------
// Project Name : NR8120 xxxx
// FILE NAME    : sw_tx_mux.v
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
//novas -22105:900
///`timescale 1ns/100ps
//`include "sc_macro.v" ///头文件
module sw_tx_mux
(
//========================clk  rst  interface ===========================================
    input                        I_125m_clk         ,/// 125M时钟
    input                        I_rst              ,/// 复位信号，高有效
//=========================gmii tx  interface ===========================================
    input                        I_tx_gmii_dv_p0    ,/// 
    input                        I_tx_gmii_err_p0   ,/// 
    input      [7:0]             I_tx_gmii_d_p0     ,/// 
    input                        I_tx_gmii_dv_p1   ,/// 
    input                        I_tx_gmii_err_p1  ,/// 
    input      [7:0]             I_tx_gmii_d_p1    ,/// 
    input                        I_tx_gmii_dv_p2   ,/// 
    input                        I_tx_gmii_err_p2  ,/// 
    input      [7:0]             I_tx_gmii_d_p2    ,/// 
    input                        I_tx_gmii_dv_p3   ,/// 
    input                        I_tx_gmii_err_p3  ,/// 
    input      [7:0]             I_tx_gmii_d_p3    ,/// 
//=========================outputs===================================
    output reg [3:0]             O_tx_port_info		,///
    output reg                   O_tx_gmii_dv       ,///
    output reg [7:0]             O_tx_gmii_d        ,///
    output                       O_tx_gmii_err       ///
);

//========reg signals
//====TX_MUX
reg  [2:0]     S_tx_gmii_dv_p0_buf       ;///
reg  [2:0]     S_tx_gmii_dv_p1_buf       ;///
reg  [2:0]     S_tx_gmii_dv_p2_buf       ;///
reg  [2:0]     S_tx_gmii_dv_p3_buf       ;///

reg            S_tx_gmii_dv_p0           ;/// 
reg            S_tx_gmii_dv_p1           ;/// 
reg            S_tx_gmii_dv_p2           ;/// 
reg            S_tx_gmii_dv_p3           ;/// 

reg  [8:0]     S_tx_send_state           ;///
reg  [8:0]     S_tx_send_state_next      ;///
reg            S_tx_send_already         ;///

reg            S_tx_fifo_rd_en_p0        ;///
reg            S_tx_fifo_rd_en_p1        ;///
reg            S_tx_fifo_rd_en_p2        ;///
reg            S_tx_fifo_rd_en_p3        ;///

reg            S_tx_fifo_rd_en_p0_buf1   ;///
reg            S_tx_fifo_rd_en_p1_buf1   ;///
reg            S_tx_fifo_rd_en_p2_buf1   ;///
reg            S_tx_fifo_rd_en_p3_buf1   ;///

reg  [7:0]     S_tx_ifg_cnt				 ;///MAC包间隔计数器
reg            S_tx_gmii_dv_buf1	     ;/// 


//========wire signals 
//====TX_MUX
wire           S_fifo_p0_empty           ;///
wire           S_fifo_p1_empty           ;///
wire           S_fifo_p2_empty           ;///
wire           S_fifo_p3_empty           ;///
wire           S_fifo_p0_full            ;///
wire           S_fifo_p1_full            ;///
wire           S_fifo_p2_full            ;///
wire           S_fifo_p3_full            ;///
wire           S_tx_fifo_wr_en_p0        ;///
wire           S_tx_fifo_wr_en_p1        ;///
wire           S_tx_fifo_wr_en_p2        ;///
wire           S_tx_fifo_wr_en_p3        ;///

wire [8:0]     S_tx_fifo_rdata_p0        ;///
wire [8:0]     S_tx_fifo_rdata_p1        ;///
wire [8:0]     S_tx_fifo_rdata_p2        ;///
wire [8:0]     S_tx_fifo_rdata_p3        ;///


wire [12:0]    S_tx_fifo_usedw_p0        ;///
wire [12:0]    S_tx_fifo_usedw_p1        ;///
wire [12:0]    S_tx_fifo_usedw_p2        ;///
wire [12:0]    S_tx_fifo_usedw_p3        ;///



//====TX_MUX
parameter      C_TX_IDLE		= 9'b000000001; ///
parameter      C_TX_P0_PRE      = 9'b000000010; /// 
parameter      C_TX_P0_SEND     = 9'b000000100; /// 
parameter      C_TX_P1_PRE      = 9'b000001000; /// 
parameter      C_TX_P1_SEND     = 9'b000010000; ///
parameter      C_TX_P2_PRE      = 9'b000100000; ///
parameter      C_TX_P2_SEND     = 9'b001000000; ///
parameter      C_TX_P3_PRE      = 9'b010000000; ///
parameter      C_TX_P3_SEND		= 9'b100000000; ///
parameter      C_PKT_GAP_MIN	= 8'd8        ; ///
///MAC包间隔最小值 FIFO中缓存MAC包数据间已增加了3个clk的间隔，所以这里设为9  9+3=12


//================================================================TX_MUX Buffer delay=========================
//==== the case oam return packets from the RX port come to here latter than the TX port
//==== RX port means P1 port ,TX port means P0 port,
//==== so we delay the TX port packets in order to let the RX port come earlyer
logic [8:0] S_tx_gmii_mem_p0[0:255];
wire [8:0]S_tx_gmii_mem_out;
always @(posedge I_125m_clk)
begin
	S_tx_gmii_mem_p0[0] <= {I_tx_gmii_dv_p0 ,I_tx_gmii_d_p0};//      S_tx_gmii_dv_p01,S_tx_gmii_d_p01}; 
	for(int i=0;i<255;i++)
	begin
		S_tx_gmii_mem_p0[i+1] <=  S_tx_gmii_mem_p0[i];
	end
end
assign S_tx_gmii_mem_out=S_tx_gmii_mem_p0[31];





//================================================================TX_MUX===================================
//====assign
assign O_tx_gmii_err  = 1'b0; 

//=================================================================TX_MUX==================================
//assign         S_tx_fifo_wr_en_p0 = (|S_tx_gmii_dv_p0_buf)|I_tx_gmii_dv_p0; 
assign         S_tx_fifo_wr_en_p0 = (|S_tx_gmii_dv_p0_buf)|S_tx_gmii_mem_out[8]; 
assign         S_tx_fifo_wr_en_p1 = (|S_tx_gmii_dv_p1_buf)|I_tx_gmii_dv_p1; 
assign         S_tx_fifo_wr_en_p2 = (|S_tx_gmii_dv_p2_buf)|I_tx_gmii_dv_p2; 
assign         S_tx_fifo_wr_en_p3 = (|S_tx_gmii_dv_p3_buf)|I_tx_gmii_dv_p3; 

assign S_tx_fifo_usedw_p0[12] = S_fifo_p0_full; 
assign S_tx_fifo_usedw_p1[12] = S_fifo_p1_full; 
assign S_tx_fifo_usedw_p2[12] = S_fifo_p2_full; 
assign S_tx_fifo_usedw_p3[12] = S_fifo_p3_full; 

fifo4096x9_sw_mux U0_p0_fifo4096x9(
   .clock (I_125m_clk                       ),
   //.data  ({I_tx_gmii_dv_p0,I_tx_gmii_d_p0} ),
   .data  (S_tx_gmii_mem_out ),
   .rdreq (S_tx_fifo_rd_en_p0               ),
   .wrreq (S_tx_fifo_wr_en_p0               ),
   .empty (S_fifo_p0_empty                  ),
   .full  (S_fifo_p0_full                   ),
   .q     (S_tx_fifo_rdata_p0               ),
   .usedw (S_tx_fifo_usedw_p0[11:0]         )
);

fifo4096x9_sw_mux U1_p1_fifo4096x9(
  .clock  (I_125m_clk                       ),
  .data   ({I_tx_gmii_dv_p1,I_tx_gmii_d_p1} ),
  .rdreq  (S_tx_fifo_rd_en_p1               ),
  .wrreq  (S_tx_fifo_wr_en_p1               ),
  .empty  (S_fifo_p1_empty                  ),
  .full   (S_fifo_p1_full                   ),
  .q      (S_tx_fifo_rdata_p1               ),
  .usedw  (S_tx_fifo_usedw_p1[11:0]         )
 );

 fifo4096x9_sw_mux U1_p2_fifo4096x9(
  .clock  (I_125m_clk                       ),
  .data   ({I_tx_gmii_dv_p2,I_tx_gmii_d_p2} ),
  .rdreq  (S_tx_fifo_rd_en_p2               ),
  .wrreq  (S_tx_fifo_wr_en_p2               ),
  .empty  (S_fifo_p2_empty                  ),
  .full   (S_fifo_p2_full                   ),
  .q      (S_tx_fifo_rdata_p2               ),
  .usedw  (S_tx_fifo_usedw_p2[11:0]         )
 );

 fifo4096x9_sw_mux U1_p3_fifo4096x9(
  .clock  (I_125m_clk                        ),
  .data   ({I_tx_gmii_dv_p3,I_tx_gmii_d_p3}),
  .rdreq  (S_tx_fifo_rd_en_p3               ),
  .wrreq  (S_tx_fifo_wr_en_p3               ),
  .empty  (S_fifo_p3_empty                  ),
  .full   (S_fifo_p3_full                   ),
  .q      (S_tx_fifo_rdata_p3               ),
  .usedw  (S_tx_fifo_usedw_p3[11:0]         )
 );

always @ (posedge I_125m_clk or posedge I_rst)
begin
	if(I_rst)
	begin
		S_tx_gmii_dv_buf1 <= 1'b0;
	end
	else
	begin
		S_tx_gmii_dv_buf1 <= O_tx_gmii_dv; 
	end
end

//assign O_tx_port_info={S_tx_send_state[8],S_tx_send_state[6],S_tx_send_state[4],S_tx_send_state[2]};	
always @ (posedge I_125m_clk or posedge I_rst)
begin
	if(I_rst)
	begin
		O_tx_port_info <= 4'b0000;
	end
	else if(O_tx_gmii_dv && (!S_tx_gmii_dv_buf1)) 
	begin
		case({S_tx_send_state[8],S_tx_send_state[6],S_tx_send_state[4],S_tx_send_state[2]})
		4'b0001:
		begin
			O_tx_port_info <= 4'b0000;
		end
		4'b0010:
		begin
			O_tx_port_info <= 4'b0001;
		end
		4'b0100:
		begin
			O_tx_port_info <= 4'b0010;
		end
		4'b1000:
		begin
			O_tx_port_info <= 4'b0011;
		end
		default:
		begin
			O_tx_port_info <= 4'b0000;
		end
		endcase
	end
	else
	begin
		O_tx_port_info <= O_tx_port_info; 
	end
end

//====S_tx_fifo_rd_en_p1
//====S_tx_fifo_rd_en_p2
//====S_tx_fifo_rd_en_p0
//====S_tx_fifo_rd_en_p3
//====S_tx_ifg_cnt
always @ (posedge I_125m_clk or posedge I_rst)
begin
	if(I_rst)
	begin
		S_tx_fifo_rd_en_p0   <= 1'b0;
		S_tx_fifo_rd_en_p1   <= 1'b0;
		S_tx_fifo_rd_en_p2   <= 1'b0;
		S_tx_fifo_rd_en_p3   <= 1'b0;
		S_tx_ifg_cnt         <= 8'd0;
	end
    else
    begin
	case(S_tx_send_state)
	C_TX_IDLE :
    begin
		S_tx_fifo_rd_en_p0   <= 1'b0;
		S_tx_fifo_rd_en_p1   <= 1'b0;
		S_tx_fifo_rd_en_p2   <= 1'b0;
		S_tx_fifo_rd_en_p3   <= 1'b0;
		S_tx_ifg_cnt         <= 8'd0;
    end
	C_TX_P0_PRE :
    begin
		S_tx_fifo_rd_en_p0   <= 1'b0;
		S_tx_fifo_rd_en_p1   <= 1'b0;
		S_tx_fifo_rd_en_p2   <= 1'b0;
		S_tx_fifo_rd_en_p3   <= 1'b0;
		S_tx_ifg_cnt         <= S_tx_ifg_cnt+8'd1;
    end
    C_TX_P0_SEND :
    begin
		S_tx_fifo_rd_en_p0   <= 1'b1;
		S_tx_fifo_rd_en_p1   <= 1'b0;
		S_tx_fifo_rd_en_p2   <= 1'b0;
		S_tx_fifo_rd_en_p3   <= 1'b0;
		S_tx_ifg_cnt         <= 8'd0; 
    end
    C_TX_P1_PRE :
    begin
		S_tx_fifo_rd_en_p0   <= 1'b0;
		S_tx_fifo_rd_en_p1   <= 1'b0;
		S_tx_fifo_rd_en_p2   <= 1'b0;
		S_tx_fifo_rd_en_p3   <= 1'b0;
		S_tx_ifg_cnt         <= S_tx_ifg_cnt+8'd1;
    end
    C_TX_P1_SEND :
    begin
		S_tx_fifo_rd_en_p0   <= 1'b0;
		S_tx_fifo_rd_en_p1   <= 1'b1;
		S_tx_fifo_rd_en_p2   <= 1'b0;
		S_tx_fifo_rd_en_p3   <= 1'b0;
		S_tx_ifg_cnt         <= 8'd0; 
    end
    C_TX_P2_PRE :
    begin
		S_tx_fifo_rd_en_p0   <= 1'b0;
		S_tx_fifo_rd_en_p1   <= 1'b0;
		S_tx_fifo_rd_en_p2   <= 1'b0;
		S_tx_fifo_rd_en_p3   <= 1'b0;
		S_tx_ifg_cnt         <= S_tx_ifg_cnt+8'd1;
    end
    C_TX_P2_SEND :
    begin
		S_tx_fifo_rd_en_p0   <= 1'b0;
		S_tx_fifo_rd_en_p1   <= 1'b0;
		S_tx_fifo_rd_en_p2   <= 1'b1;
		S_tx_fifo_rd_en_p3   <= 1'b0;
		S_tx_ifg_cnt         <= 8'd0; 
    end
    C_TX_P3_PRE :
    begin
		S_tx_fifo_rd_en_p1   <= 1'b0;
		S_tx_fifo_rd_en_p2   <= 1'b0;
		S_tx_fifo_rd_en_p0   <= 1'b0;
		S_tx_fifo_rd_en_p3   <= 1'b0;
		S_tx_ifg_cnt         <= S_tx_ifg_cnt+8'd1;
    end
    C_TX_P3_SEND :
    begin
		S_tx_fifo_rd_en_p0   <= 1'b0;
		S_tx_fifo_rd_en_p1   <= 1'b0;
		S_tx_fifo_rd_en_p2   <= 1'b0;
		S_tx_fifo_rd_en_p3   <= 1'b1;
		S_tx_ifg_cnt         <= 8'd0; 
    end
    default      :
    begin
		S_tx_fifo_rd_en_p0   <= 1'b0;
		S_tx_fifo_rd_en_p1   <= 1'b0;
		S_tx_fifo_rd_en_p2   <= 1'b0;
		S_tx_ifg_cnt         <= 8'd0; 
    end
    endcase
    end
end

//====S_tx_fifo_rd_en_p0_buf1
//====S_tx_fifo_rd_en_p1_buf1
//====S_tx_fifo_rd_en_p2_buf1
//====S_tx_fifo_rd_en_p3_buf1
always @ (posedge I_125m_clk or posedge I_rst)
begin
	if(I_rst)
    begin
		S_tx_fifo_rd_en_p0_buf1  <= 1'b0;
		S_tx_fifo_rd_en_p1_buf1  <= 1'b0;
		S_tx_fifo_rd_en_p2_buf1  <= 1'b0;
		S_tx_fifo_rd_en_p3_buf1  <= 1'b0;
    end
    else
    begin
		S_tx_fifo_rd_en_p0_buf1  <= S_tx_fifo_rd_en_p0;
		S_tx_fifo_rd_en_p1_buf1  <= S_tx_fifo_rd_en_p1;
		S_tx_fifo_rd_en_p2_buf1  <= S_tx_fifo_rd_en_p2;
		S_tx_fifo_rd_en_p3_buf1  <= S_tx_fifo_rd_en_p3;
    end
end


//====S_tx_gmii_dv_p0_buf
always @ (posedge I_125m_clk or posedge I_rst)
begin
	if(I_rst)
	begin
		S_tx_gmii_dv_p0_buf  <= 3'd0;
		S_tx_gmii_dv_p1_buf  <= 3'd0;
		S_tx_gmii_dv_p2_buf  <= 3'd0;
		S_tx_gmii_dv_p3_buf  <= 3'd0;
    end
    else
    begin
		//S_tx_gmii_dv_p0_buf  <= {S_tx_gmii_dv_p0_buf[1:0],I_tx_gmii_dv_p0};
		S_tx_gmii_dv_p0_buf  <= {S_tx_gmii_dv_p0_buf[1:0],S_tx_gmii_mem_out[8]};
		S_tx_gmii_dv_p1_buf  <= {S_tx_gmii_dv_p1_buf[1:0],I_tx_gmii_dv_p1}; 
		S_tx_gmii_dv_p2_buf  <= {S_tx_gmii_dv_p2_buf[1:0],I_tx_gmii_dv_p2}; 
		S_tx_gmii_dv_p3_buf  <= {S_tx_gmii_dv_p3_buf[1:0],I_tx_gmii_dv_p3}; 
    end    
end

//====S_tx_send_state
always @ (posedge I_125m_clk or posedge I_rst)
begin
	if(I_rst)
    begin
		S_tx_send_state    <= 9'b0					;
    end
    else
    begin
		S_tx_send_state    <= S_tx_send_state_next	;
    end
end

//====S_tx_send_already
always @ (posedge I_125m_clk or posedge I_rst)
begin
	if(I_rst)
    begin
		S_tx_send_already  <= 1'b0 ;
    end
    else
    begin
		S_tx_send_already  <=	(S_tx_fifo_usedw_p0>=13'd8)|
								(S_tx_fifo_usedw_p1>=13'd8)|
								(S_tx_fifo_usedw_p2>=13'd8)|
								(S_tx_fifo_usedw_p3>=13'd8);
    end
end
///=== 1 2 3 4 
///====
always @ (*) 
begin                
	case(S_tx_send_state)
    C_TX_IDLE:
    begin
		if(S_tx_send_already)
               S_tx_send_state_next = C_TX_P0_PRE;
        else
               S_tx_send_state_next = C_TX_IDLE  ;
    end
    C_TX_P0_PRE: 
    begin
        if(S_tx_ifg_cnt < C_PKT_GAP_MIN)  
               S_tx_send_state_next = C_TX_P0_PRE ;
        else if (S_tx_fifo_usedw_p0 >= 13'd8)
               S_tx_send_state_next = C_TX_P0_SEND;
        else if (S_tx_fifo_usedw_p1 >= 13'd8)
               S_tx_send_state_next = C_TX_P1_SEND;
        else if (S_tx_fifo_usedw_p2 >= 13'd8)
               S_tx_send_state_next = C_TX_P2_SEND ;
        else if (S_tx_fifo_usedw_p3 >= 13'd8)
               S_tx_send_state_next = C_TX_P3_SEND;
        else
               S_tx_send_state_next = C_TX_P1_PRE ;
    end
    C_TX_P0_SEND: 
    begin
        if((!S_tx_fifo_rdata_p0[8]) && S_tx_fifo_rd_en_p0_buf1)
               S_tx_send_state_next = C_TX_P1_PRE;
        else 
               S_tx_send_state_next = C_TX_P0_SEND;
    end
    C_TX_P1_PRE: 
    begin
         if(S_tx_ifg_cnt < C_PKT_GAP_MIN)
               S_tx_send_state_next = C_TX_P1_PRE ;
         else if (S_tx_fifo_usedw_p1 >= 13'd8) 
               S_tx_send_state_next = C_TX_P1_SEND;
         else if (S_tx_fifo_usedw_p2 >= 13'd8)
               S_tx_send_state_next = C_TX_P2_SEND;
         else if (S_tx_fifo_usedw_p3 >= 13'd8)
               S_tx_send_state_next = C_TX_P3_SEND;
         else if (S_tx_fifo_usedw_p0 >= 13'd8)
               S_tx_send_state_next = C_TX_P0_SEND;
         else
               S_tx_send_state_next = C_TX_P2_PRE ;
    end
    C_TX_P1_SEND: 
    begin
        if((!S_tx_fifo_rdata_p1[8]) && S_tx_fifo_rd_en_p1_buf1)
               S_tx_send_state_next = C_TX_P2_PRE ;
        else 
               S_tx_send_state_next = C_TX_P1_SEND;
    end
    C_TX_P2_PRE  : 
    begin
         if(S_tx_ifg_cnt < C_PKT_GAP_MIN)
               S_tx_send_state_next = C_TX_P2_PRE ;
         else if(S_tx_fifo_usedw_p2 >= 13'd8) 
               S_tx_send_state_next = C_TX_P2_SEND;
         else if(S_tx_fifo_usedw_p3 >= 13'd8)
               S_tx_send_state_next = C_TX_P3_SEND;
         else if(S_tx_fifo_usedw_p0 >= 13'd8)
               S_tx_send_state_next = C_TX_P0_SEND;
         else if(S_tx_fifo_usedw_p1 >= 13'd8)
               S_tx_send_state_next = C_TX_P1_SEND;
         else
               S_tx_send_state_next = C_TX_P3_PRE ;
    end
    C_TX_P2_SEND: 
    begin
        if((!S_tx_fifo_rdata_p2[8]) && S_tx_fifo_rd_en_p2_buf1)
               S_tx_send_state_next = C_TX_P3_PRE ;
        else 
               S_tx_send_state_next = C_TX_P2_SEND;
    end
    C_TX_P3_PRE:
    begin
         if(S_tx_ifg_cnt < C_PKT_GAP_MIN)
               S_tx_send_state_next = C_TX_P3_PRE ;
         else if(S_tx_fifo_usedw_p3 >= 13'd8)
               S_tx_send_state_next = C_TX_P3_SEND;
         else if(S_tx_fifo_usedw_p0 >= 13'd8)
               S_tx_send_state_next = C_TX_P0_SEND;
         else if(S_tx_fifo_usedw_p1 >= 13'd8)
               S_tx_send_state_next = C_TX_P1_SEND;
         else if(S_tx_fifo_usedw_p2 >= 11'd8) 
               S_tx_send_state_next = C_TX_P2_SEND;
         else
               S_tx_send_state_next = C_TX_P0_PRE ;
    end
    C_TX_P3_SEND:
    begin
        if((!S_tx_fifo_rdata_p3[8]) && S_tx_fifo_rd_en_p3_buf1)
               S_tx_send_state_next = C_TX_P0_PRE ;
        else 
               S_tx_send_state_next = C_TX_P3_SEND;
    end

    default     :
               S_tx_send_state_next = C_TX_IDLE    ;
    endcase
end
//====O_tx_gmii_dv
//====O_tx_gmii_d
always @ (posedge I_125m_clk or posedge I_rst)
begin
	if(I_rst)
    begin
		O_tx_gmii_dv         <= 1'd0;
		O_tx_gmii_d          <= 8'd0;
    end
    else
    begin
    case(S_tx_send_state)
    C_TX_IDLE :
    begin
		O_tx_gmii_dv         <= 1'd0;
		O_tx_gmii_d          <= 8'd0;
    end
	C_TX_P0_PRE :
    begin
        O_tx_gmii_dv         <= 1'd0;
        O_tx_gmii_d          <= 8'd0;
    end
    C_TX_P0_SEND:
    begin
		O_tx_gmii_dv         <= S_tx_fifo_rdata_p0[8]  ;
		O_tx_gmii_d          <= S_tx_fifo_rdata_p0[7:0];
    end
    C_TX_P1_PRE :
    begin
		O_tx_gmii_dv         <= 1'd0;
		O_tx_gmii_d          <= 8'd0;
    end
    C_TX_P1_SEND:
    begin
		O_tx_gmii_dv         <= S_tx_fifo_rdata_p1[8]  ;
		O_tx_gmii_d          <= S_tx_fifo_rdata_p1[7:0];
    end
    C_TX_P2_PRE :
    begin
		O_tx_gmii_dv         <= 1'd0;
		O_tx_gmii_d          <= 8'd0;
    end
    C_TX_P2_SEND:
    begin
		O_tx_gmii_dv         <= S_tx_fifo_rdata_p2[8]  ;
		O_tx_gmii_d          <= S_tx_fifo_rdata_p2[7:0];
    end
    C_TX_P3_PRE :
    begin
		O_tx_gmii_dv         <= 1'd0;
		O_tx_gmii_d          <= 8'd0;
    end
    C_TX_P3_SEND:
    begin
		O_tx_gmii_dv         <= S_tx_fifo_rdata_p3[8]  ;
		O_tx_gmii_d          <= S_tx_fifo_rdata_p3[7:0];
    end
    default:
    begin
        O_tx_gmii_dv         <= O_tx_gmii_dv;
        O_tx_gmii_d          <= O_tx_gmii_d;
    end
    endcase
    end
end

endmodule
