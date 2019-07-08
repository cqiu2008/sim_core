`timescale 1ns/100ps
module m_axi_mem#(
parameter
    C_DATA_WIDTH       = 128,
    C_ADDR_WIDTH       = 32
)(
    input                                    I_clk,
    input                                    I_rst,
    input                                    I_ap_start,
    input              [31:0]                I_ddr_rd_addr,
    input              [31:0]                I_ddr_wr_addr,
    input              [31:0]                I_in_data_bytes,
    input              [31:0]                I_out_data_bytes,
    //axi write
    input                                    I_awready,
    input              [1:0]                 I_bresp,
    input                                    I_bvalid,
    input                                    I_wready,
    input              [3:0]                 I_bid,
    output                                   O_awlock,
    output             [3:0]                 O_awid,
    output             [1:0]                 O_awburst,
    output             [3:0]                 O_awcache,
    output             [2:0]                 O_awprot,
    output             [2:0]                 O_awsize,
    output                                   O_bready,
    output             [C_DATA_WIDTH/8-1:0]  O_wstrb,
    output reg         [C_ADDR_WIDTH-1:0]    O_awaddr = 0,
    output reg         [7:0]                 O_awlen = 0,
    output reg                               O_awvalid = 0,
    output reg         [C_DATA_WIDTH-1:0]    O_wdata = 0,
    output reg                               O_wlast = 0,
    output reg                               O_wvalid = 0,
    //axi read
    input                                    I_arready,
    input              [C_DATA_WIDTH-1:0]    I_rdata,
    input                                    I_rvalid,
    input                                    I_rlast,
    input              [1:0]                 I_rresp,
    input              [3:0]                 I_rid,
    output             [1:0]                 O_arburst,
    output             [3:0]                 O_arcache,
    output             [2:0]                 O_arprot,
    output             [2:0]                 O_arsize,
    output             [3:0]                 O_arid,
    output                                   O_arlock,
    output reg         [C_ADDR_WIDTH-1:0]    O_araddr = 0,
    output reg         [7:0]                 O_arlen = 0,
    output reg                               O_arvalid = 0,
    output reg                               O_rready = 0,
    //memory
    output reg         [C_DATA_WIDTH-1:0]    O_mem_din = 0,
    output reg                               O_mem_din_valid = 0,
    input              [C_DATA_WIDTH-1:0]    I_mem_dout,
    input                                    I_mem_dout_valid,
    output reg                               O_ap_ready = 0,
    output reg                               O_ap_done
    );

localparam C_AXI_BURST = 16;
localparam C_DATA_RATIO = GETASIZE(C_DATA_WIDTH*C_AXI_BURST/8);//8
localparam C_DATA_RATIO2 = GETASIZE(C_DATA_WIDTH/8);
localparam C_ADDR_OFFSET = C_AXI_BURST*C_DATA_WIDTH/8;	
localparam C_AXI_BURST_SIZE = GETASIZE(C_AXI_BURST);
localparam C_RD_WL_LIMIT = 16;
localparam C_RD_WL_THRE = 200;
localparam C_WR_WL_THRE = 200;
reg S_ap_start = 0;
reg S_ap_start_pos = 0;
reg S_ap_start_pos_d = 0;
reg [3:0] S_rd_last_len = 0;
reg [31:0] S_rd_num = 0;
reg [15:0] S_rd_wl = 0;
reg S_rd_wl_av = 0;
reg S_rd_wl_av_d = 0;
reg S_rd_single_id = 0;
reg S_rd_last_id = 0;
reg S_rd_v = 0;
reg S_rd_v_d = 0;
reg S_ramr_we = 0;
reg [127:0] S_ramr_wdata = 0;
reg [7:0] S_ramr_waddr = 0;
reg [7:0] S_ramr_raddr = 0;
reg       S_ramr_rd = 0;
reg [127:0] S_ramr_rdata = 0;
reg       S_ramr_rd_d = 0;
reg       S_ramr_rd_2d = 0;
reg [7:0] S_ar_num = 0;
reg [7:0] S_ar_diff = 0;
reg       S_rd_flag = 0;
reg [7:0] S_ramr_d_left = 0;
(* ram_style="block" *)reg [C_DATA_WIDTH-1:0] S_ramr [C_RD_WL_LIMIT*C_AXI_BURST-1:0];
reg [3:0] S_wr_last_len = 0;
reg [31:0] S_wr_num = 0;
reg S_wr_single_id = 0;
reg S_wr_last_id = 0;
reg S_wr_v = 0;
(* ram_style="block" *)reg [C_DATA_WIDTH-1:0] S_ramw [C_RD_WL_LIMIT*C_AXI_BURST-1:0];
reg [7:0] S_ramw_waddr = 0;
reg [7:0] S_ramw_raddr = 0;
reg [7:0] S_ramw_addr_diff = 0;
reg [31:0] S_axiw_time = 0;
reg [31:0] S_axiw_num = 0;
reg S_first_w_id = 0;
reg S_first_w_id_d = 0;
reg S_con_w_id = 0;
reg S_con_w_id_d = 0;
reg [7:0] S_ramw_num_prep = 0;
reg [7:0] S_ramw_num_prep_s1 = 0;
reg [7:0] S_ramw_num_prep_s2 = 0;
reg [7:0] S_ramw_num_prep_latch = 0;
reg [7:0] S_ramw_num_prep_latch_s1 = 0;
reg [7:0] S_axiw_clk_cnt = 0;
reg S_ramw_of_id = 0;
reg [8:0] S_ramr_data_num = 0;
reg [31:0] S_rd_num_left = 0;
//reg [2:0] S_ramr_rd_wait_cnt = 0;
//reg S_ramr_rd_wait = 0;
//reg [7:0] S_ramr_waddr_s1 = 0;
//reg [7:0] S_ramr_rcnt = 0;
//reg S_ramr_rd_v = 0;

assign O_awcache = 4'b0010; 
assign O_arcache = 4'b0010; 
assign O_awburst = 2'b01;   //INCR
assign O_arburst = 2'b01;   //INCR
assign O_awprot  = 3'b010;
assign O_arprot  = 3'b010;
assign O_awsize  = 3'b100;  //2^4=16bytes(128-bit)
assign O_arsize  = 3'b100;  //2^4=16bytes(128-bit)
assign O_awlock  = 1'b0;
assign O_arlock  = 1'b0;
assign O_awid    = 4'd0;
assign O_arid    = 4'd0;
assign O_wstrb   = 16'hffff;
assign O_bready  = 1'b1;

always@ (posedge I_clk)
begin
    if (O_wlast && ~(|S_axiw_time))
    begin
        O_ap_ready <= 1'b1;
        O_ap_done <= 1'b1;
    end
    else if (I_ap_start)
    begin
        O_ap_ready <= 1'b0;
        O_ap_done <= 1'b0;
    end
end

always @(posedge I_clk)	
begin
    S_ap_start <= I_ap_start;
	S_ap_start_pos <= I_ap_start && !S_ap_start;
	S_ap_start_pos_d <= S_ap_start_pos;
	
	if(I_ap_start && !S_ap_start)
	    S_rd_last_len <= (|I_in_data_bytes[C_DATA_RATIO2+:C_AXI_BURST_SIZE]) ? (I_in_data_bytes[C_DATA_RATIO2+:C_AXI_BURST_SIZE] - 'd1) : (C_AXI_BURST-1);
	
	if(I_ap_start && !S_ap_start)
	    S_rd_num <= (I_in_data_bytes>>C_DATA_RATIO) + (|I_in_data_bytes[C_DATA_RATIO2+:C_AXI_BURST_SIZE]);
	else if(I_arready && O_arvalid)
	    S_rd_num <= S_rd_num - 'd1;
	
    if(I_ap_start && !S_ap_start)    
	    O_araddr <= I_ddr_rd_addr;
	else if(I_arready && O_arvalid)
	    O_araddr <= O_araddr + C_ADDR_OFFSET;
	    
	S_rd_wl_av <= S_ar_diff < C_RD_WL_THRE;

    if((S_ap_start_pos || S_rd_v) && S_rd_wl_av && !O_arvalid)
        O_arvalid <= 1'b1;
    else if(O_arvalid && I_arready)		
	    O_arvalid <= 1'b0;
	
	if(I_ap_start && !S_ap_start)
	    S_rd_single_id <= I_in_data_bytes<=C_AXI_BURST*C_DATA_WIDTH/8;
	
	if(S_ap_start_pos || (O_arvalid && I_arready))
	    O_arlen <= (S_rd_single_id || S_rd_last_id) ? S_rd_last_len : C_AXI_BURST-1;
    
	if(I_ap_start && !S_ap_start)
	    S_rd_last_id <= 1'b0;
	else if(S_ap_start_pos)
	    S_rd_last_id <= S_rd_num=='d2;
	else if(S_rd_num=='d3 && I_arready && O_arvalid)
	    S_rd_last_id <= 1'b1;
	    
	if(S_ap_start_pos)
	    S_rd_v <= 1'b1;
	else if((S_rd_num=='d1) && O_arvalid && I_arready)
	    S_rd_v <= 1'b0;	
	
end

always @(posedge I_clk)
begin
    if(S_ap_start_pos)
	    O_rready <= 1'b1;
	    
	if (O_rready && I_rvalid && !S_ramr_rd)
	    S_ramr_data_num <= S_ramr_data_num + 1;
	else if (!(O_rready && I_rvalid) && S_ramr_rd)
	    S_ramr_data_num <= S_ramr_data_num - 1;
	
	S_ramr_we <= O_rready && I_rvalid;
	S_ramr_wdata <= I_rdata;
	
	if(I_rst)
	    S_ramr_waddr <= 'd0;
	else if (I_ap_start && !S_ap_start)
	    S_ramr_waddr <= 'd0;
	else if(S_ramr_we)
	    S_ramr_waddr <= S_ramr_waddr + 'd1;
	
	if(S_ramr_we)
	    S_ramr[S_ramr_waddr] <= S_ramr_wdata;
	    
    if(I_ap_start && !S_ap_start)
        S_rd_num_left <= I_in_data_bytes;	
    else if(S_ramr_rd)
        S_rd_num_left <= S_rd_num_left - 'd16;
    
	if (S_ramr_data_num[8])
	    S_ramr_rd <= 1'b0;
	else if (S_ramr_data_num=='d1 && !S_ramr_we)
        S_ramr_rd <= 1'b0;
	else if (S_ramr_data_num > 0)
	    S_ramr_rd <= 1'b1;

	
	if(I_rst)
        S_ramr_raddr <= 'd0;
    else if (I_ap_start && !S_ap_start)
        S_ramr_raddr <= 'd0;
    else if(S_ramr_rd)
        S_ramr_raddr <= S_ramr_raddr + 'd1;
		

	
//	S_ramr_waddr_s1 <= S_ramr_waddr - 'd1;
//	if(S_ramr_waddr != S_ramr_raddr && S_ramr_rd_v && !S_ramw_of_id)
//	    S_ramr_rd <= 1'b1;
//	else if((S_ramr_waddr_s1 == S_ramr_raddr && !S_ramr_we) || S_ramw_of_id)
//	    S_ramr_rd <= 1'b0;
	
//	if(S_ap_start_pos)
//	    S_ramr_rd_wait <= 1'b0;
//	else if((S_ramr_waddr_s1 == S_ramr_raddr && !S_ramr_we && S_ramr_rd) || S_ramw_of_id)
//	    S_ramr_rd_wait <= 1'b1;
//	else if(S_ramr_rd_wait_cnt[2])
//	    S_ramr_rd_wait <= 1'b0;
		
//	if(S_ramr_rd_wait)	
//	    S_ramr_rd_wait_cnt <= S_ramr_rd_wait_cnt + 'd1;
//	else
//	    S_ramr_rd_wait_cnt <= 'd0;
	
//	if(S_ap_start_pos)
//	    S_ramr_rd_v <= 1'b1;
//	else if(S_ramr_waddr != S_ramr_raddr && S_ramr_rd_v && !S_ramw_of_id)
//	    S_ramr_rd_v <= 1'b0;
//	else if(S_ramr_rd_wait_cnt[2] && S_ramr_rd_wait)
//	    S_ramr_rd_v <= 1'b1;
	
	S_ramr_rdata <= S_ramr[S_ramr_raddr];
	O_mem_din <= S_ramr_rdata;
	S_ramr_rd_d <= S_ramr_rd;
//	S_ramr_rd_2d <= S_ramr_rd_d;
	O_mem_din_valid <= S_ramr_rd_d;
	
//	if(S_ap_start_pos)
//	    S_ramr_rcnt <= 'd0;
//	else if(S_ramr_rd)
//	    S_ramr_rcnt <= S_ramr_rcnt + 'd1;
	
//    if(S_ap_start_pos)
//	    S_ar_num <= 'd0;
//	else if(O_arvalid && I_arready)
//	    S_ar_num <= S_ar_num + O_arlen + 'd1;
//    S_ar_diff <= S_ar_num - S_ramr_rcnt;
	
end

function integer GETASIZE;
input integer a;
integer i;
begin
    for(i=1;(2**i)<a;i=i+1)
      begin
      end
    GETASIZE = i;
end
endfunction
//================================================
always @(posedge I_clk)
begin
    if(I_ap_start && !S_ap_start)    
	    O_awaddr <= I_ddr_wr_addr;
	else if(I_awready && O_awvalid)
	    O_awaddr <= O_awaddr + C_ADDR_OFFSET;
		
	if(I_ap_start && !S_ap_start)
	    S_wr_last_len <= (|I_out_data_bytes[C_DATA_RATIO2+:C_AXI_BURST_SIZE]) ? (I_out_data_bytes[C_DATA_RATIO2+:C_AXI_BURST_SIZE] - 'd1) : (C_AXI_BURST-1);
	
	if(I_ap_start && !S_ap_start)
	    S_wr_num <= (I_out_data_bytes>>C_DATA_RATIO) + (|I_out_data_bytes[C_DATA_RATIO2+:C_AXI_BURST_SIZE]);
	else if(I_awready && O_awvalid)
	    S_wr_num <= S_wr_num - 'd1;

    if((S_ap_start_pos || S_wr_v) && !O_awvalid)
        O_awvalid <= 1'b1;
    else if(O_awvalid && I_awready)		
	    O_awvalid <= 1'b0;
	
	if(I_ap_start && !S_ap_start)
	    S_wr_single_id <= I_out_data_bytes<=C_AXI_BURST*C_DATA_WIDTH/8;
	
	if(S_ap_start_pos || (O_awvalid && I_awready))
	    O_awlen <= (S_wr_single_id || S_wr_last_id) ? S_wr_last_len : C_AXI_BURST-1;
    
	if(I_ap_start && !S_ap_start)
	    S_wr_last_id <= 1'b0;
	else if(S_ap_start_pos)
	    S_wr_last_id <= S_wr_num=='d2;
	else if(S_wr_num=='d3 && I_awready && O_awvalid)
	    S_wr_last_id <= 1'b1;
	    
	if(S_ap_start_pos)
	    S_wr_v <= 1'b1;
	else if((S_wr_num=='d1) && O_awvalid && I_awready)
	    S_wr_v <= 1'b0;		
end

always @(posedge I_clk)
begin
    if(I_mem_dout_valid)
	    S_ramw[S_ramw_waddr] <= I_mem_dout;
	    
	if(I_ap_start && !S_ap_start)
	    S_ramw_waddr <= 'd0;
	else if(I_mem_dout_valid)
	    S_ramw_waddr <= S_ramw_waddr + 'd1;
	    
	if(I_ap_start && !S_ap_start)
	    S_axiw_time <= (I_out_data_bytes>>C_DATA_RATIO) + (|I_out_data_bytes[C_DATA_RATIO2+:C_AXI_BURST_SIZE]);
	else if((!S_first_w_id && S_first_w_id_d) || (!S_con_w_id && S_con_w_id_d))
	    S_axiw_time <= S_axiw_time - 'd1;
	    
	if(I_ap_start && !S_ap_start)	
	    S_axiw_num <= I_out_data_bytes>>C_DATA_RATIO2;
	else if((!S_first_w_id && S_first_w_id_d) || (!S_con_w_id && S_con_w_id_d))
	    S_axiw_num <= S_axiw_num - C_AXI_BURST;
	
	if(I_ap_start && !S_ap_start)
	    S_ramw_raddr <= 'd0;
	else if((!S_first_w_id && S_first_w_id_d) || (!S_con_w_id && S_con_w_id_d) || (O_wvalid && I_wready && !O_wlast))
	    S_ramw_raddr <= S_ramw_raddr + 'd1;
	
	if((!S_first_w_id && S_first_w_id_d) || (!S_con_w_id && S_con_w_id_d) || (O_wvalid && I_wready))
	    O_wdata <= S_ramw[S_ramw_raddr];
	
    S_ramw_addr_diff <= S_ramw_waddr - S_ramw_raddr;
	S_ramw_of_id <= S_ramw_addr_diff > C_WR_WL_THRE;
	S_ramw_num_prep <= S_axiw_time>1 ? C_AXI_BURST : S_axiw_num;
	if(S_ap_start_pos)
	    S_first_w_id <= 1'b1;
	else if(S_ramw_addr_diff >= S_ramw_num_prep)
	    S_first_w_id <= 1'b0;
	S_first_w_id_d <= S_first_w_id;
	
	if(O_wvalid && I_wready && O_wlast && (S_axiw_time>'d0))
	    S_con_w_id <= 1'b1;
	else if(S_ramw_addr_diff >= S_ramw_num_prep)
	    S_con_w_id <= 1'b0;
	S_con_w_id_d <= S_con_w_id;
	

	if(S_ramw_addr_diff >= S_ramw_num_prep && (S_con_w_id || S_first_w_id))
	begin    
		S_ramw_num_prep_latch <= S_ramw_num_prep_s1;
	    S_ramw_num_prep_latch_s1 <= S_ramw_num_prep_s2;
	end
	S_ramw_num_prep_s1 <= S_ramw_num_prep - 'd1;
	S_ramw_num_prep_s2 <= S_ramw_num_prep - 'd2;
	if((!S_first_w_id && S_first_w_id_d) || (!S_con_w_id && S_con_w_id_d))	
	    S_axiw_clk_cnt <= 'd0;
	else if(O_wvalid && I_wready)
	    S_axiw_clk_cnt <= S_axiw_clk_cnt + 'd1;
	    
	if((!S_first_w_id && S_first_w_id_d) || (!S_con_w_id && S_con_w_id_d))
	    O_wvalid <= 1'b1;
	else if(S_axiw_clk_cnt == S_ramw_num_prep_latch && I_wready)
	    O_wvalid <= 1'b0;
	
	if((((!S_first_w_id && S_first_w_id_d) || (!S_con_w_id && S_con_w_id_d)) && (S_ramw_num_prep_latch=='d0)) || ((S_axiw_clk_cnt == S_ramw_num_prep_latch_s1) && I_wready && O_wvalid))
	    O_wlast <= 1'b1;
	else if(I_wready)
	    O_wlast <= 1'b0;
end

endmodule
