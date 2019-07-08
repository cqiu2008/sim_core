`timescale 1ns/1ps 
module clk_rst_source ( 
output	reg  O_10m_clk		,
output  reg  O_25m_clk		,
output  reg  O_40m_clk		,
output  reg  O_50m_clk		,
output  reg  O_33m_clk		,
output  reg  O_66m_clk		,
output  reg  O_312m5_clk	,
output  reg  O_156m25_clk	,
output  reg  O_125m_clk		,
output  reg  O_2m048_clk	,
output  reg  O_rst_n
);

parameter   C_10M_CLK_PERIOD 	= 50	;
parameter   C_25M_CLK_PERIOD 	= 20	;
parameter   C_40M_CLK_PERIOD 	= 12.5	;
parameter   C_50M_CLK_PERIOD 	= 10	;
parameter   C_66M_CLK_PERIOD 	= 7.576	;
parameter   C_33M_CLK_PERIOD 	= 15.152; 
parameter   C_312M5_CLK_PERIOD 	= 1.6	;
parameter   C_156M25_CLK_PERIOD = 3.2	;
parameter   C_125M_CLK_PERIOD 	= 4  	;
parameter   C_RESET_PERIOD 		= 200	;


always #C_10M_CLK_PERIOD  	O_10m_clk 	= ~O_10m_clk	;
always #C_25M_CLK_PERIOD  	O_25m_clk 	= ~O_25m_clk	;
always #C_40M_CLK_PERIOD  	O_40m_clk 	= ~O_40m_clk	;
always #C_50M_CLK_PERIOD  	O_50m_clk 	= ~O_50m_clk	;
always #C_66M_CLK_PERIOD  	O_66m_clk 	= ~O_66m_clk	;
always #C_33M_CLK_PERIOD  	O_33m_clk 	= ~O_33m_clk	;
always #C_312M5_CLK_PERIOD  O_312m5_clk = ~O_312m5_clk	;
always #C_156M25_CLK_PERIOD O_156m25_clk= ~O_156m25_clk	;
always #C_125M_CLK_PERIOD   O_125m_clk	= ~O_125m_clk	;


//==== E1 clock
logic [31:0]  S_sys_clk_freq	;
logic [31:0]  S_expect_clk		;

initial
begin
	S_sys_clk_freq = 32'd125000 ;///15625
    S_expect_clk   = 32'd2048   ;///256
end


initial
begin
	O_40m_clk  	<= 1;
    O_50m_clk  	<= 1;
    O_10m_clk  	<= 1;
    O_33m_clk  	<= 1;
    O_66m_clk  	<= 1;
    O_25m_clk  	<= 1;
    O_312m5_clk	<= 1;
    O_156m25_clk<= 1;
    O_125m_clk	<= 1;
    O_rst_n  	<= 0;
    #C_RESET_PERIOD
    O_rst_n  	<= 1;
end

////生成2.048M时钟
clk_gen_exp_cfg U_clk_gen_exp_cfg(
    .I_rst             (!O_rst_n		), 
    .I_sys_clk         (O_125m_clk		), 
    .I_rst_cfg         (1'b0			),   /// 复位信号,高有效,频率变化时要复位
    .I_gen_stop        (1'b0			),   
    .I_sys_clk_freq    (S_sys_clk_freq	),   /// 分子
    .I_expect_clk      (S_expect_clk	),   /// 分母
    .O_div_exp_clk     (O_2m048_clk		)
);


endmodule
