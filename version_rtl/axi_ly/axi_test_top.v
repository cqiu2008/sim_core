`timescale 1ns / 1ps


module axi_test_top#(
parameter
    C_DATA_WIDTH  = 128,
    C_ADDR_WIDTH  = 32,
    C_LITE_DWIDTH = 32
)(
    input                                    I_aclk,
    input                                    I_arst,
    //axi_mem
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
    output             [C_ADDR_WIDTH-1:0]    O_awaddr,
    output             [7:0]                 O_awlen,
    output                                   O_awvalid,
    output             [C_DATA_WIDTH-1:0]    O_wdata,
    output                                   O_wlast,
    output                                   O_wvalid,
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
    output             [C_ADDR_WIDTH-1:0]    O_araddr,
    output             [7:0]                 O_arlen,
    output                                   O_arvalid,
    output                                   O_rready,
    //axi lite
    output                                   O_lite_awready,
    input              [C_ADDR_WIDTH-1:0]    I_lite_awaddr,
    input                                    I_lite_awvalid,
    output                                   O_lite_wready,
    input              [C_LITE_DWIDTH-1:0]   I_lite_wdata,
    input                                    I_lite_wvalid,
    input              [C_LITE_DWIDTH/8-1:0] I_lite_wstrb,
    input                                    I_lite_bready,
    output             [1:0]                 O_lite_bresp,//okay
    output                                   O_lite_bvalid,
    output                                   O_lite_arready,
    input              [C_ADDR_WIDTH-1:0]    I_lite_araddr,
    input                                    I_lite_arvalid,
    input                                    I_lite_rready,
    output             [C_LITE_DWIDTH-1:0]   O_lite_rdata,
    output                                   O_lite_rvalid,
    output             [1:0]                 O_lite_rresp
 );
 
 
 localparam  ADDR_AP_CTRL                = 6'h00;
 localparam  DDR_RD_BASE_ADDR            = 6'h10;
 localparam  DDR_WR_BASE_ADDR            = 6'h14;
 localparam  IN_DATA_BYTES               = 6'h18;
 localparam  OUT_DATA_BYTES              = 6'h1c;
 localparam  AXILITE_READ_BACK           = 6'h20;
 
 wire             S_start;
 wire  [31:0]     S_ddr_rd_addr;
 wire  [31:0]     S_ddr_wr_addr;
 wire  [31:0]     S_in_data_bytes;
 wire  [31:0]     S_out_data_bytes;
 
 wire  [127:0]    S_mem_din;
 wire             S_mem_din_valid;
 wire  [127:0]    S_w_din;
 wire             S_w_din_valid;
 wire  [127:0]    S_feature_out;
 wire             S_feature_dv;
 
 wire             S_ap_ready;
 wire             S_ap_done;

 
     m_axi_mem#(
         .C_DATA_WIDTH      (128),
         .C_ADDR_WIDTH      (32)
     )m_axi_mem_rd_feature(
         .I_clk             (I_aclk),
         .I_rst             (~I_arst),
         .I_ap_start        (S_start),
         .I_ddr_rd_addr     (S_ddr_rd_addr),
         .I_ddr_wr_addr     (S_ddr_wr_addr),
         .I_in_data_bytes   (S_in_data_bytes),
         .I_out_data_bytes  (S_out_data_bytes),
         //axi write
         .I_awready         (I_awready),
         .I_bresp           (I_bresp),
         .I_bvalid          (I_bvalid),
         .I_wready          (I_wready),
         .I_bid             (I_bid),
         .O_awlock          (O_awlock),
         .O_awid            (O_awid),
         .O_awburst         (O_awburst),
         .O_awcache         (O_awcache),
         .O_awprot          (O_awprot),
         .O_awsize          (O_awsize),
         .O_bready          (O_bready),
         .O_wstrb           (O_wstrb),
         .O_awaddr          (O_awaddr),
         .O_awlen           (O_awlen),
         .O_awvalid         (O_awvalid),
         .O_wdata           (O_wdata),
         .O_wlast           (O_wlast),
         .O_wvalid          (O_wvalid),
         //axi read
         .I_arready         (I_arready),
         .I_rdata           (I_rdata),
         .I_rvalid          (I_rvalid),
         .I_rlast           (I_rlast),
         .I_rresp           (I_rresp),
         .I_rid             (I_rid),
         .O_arburst         (O_arburst),
         .O_arcache         (O_arcache),
         .O_arprot          (O_arprot),
         .O_arsize          (O_arsize),
         .O_arid            (O_arid),
         .O_arlock          (O_arlock),
         .O_araddr          (O_araddr),
         .O_arlen           (O_arlen),
         .O_arvalid         (O_arvalid),
         .O_rready          (O_rready),
         //memory
         .O_mem_din         (S_mem_din),//feature in,transport to next module
         .O_mem_din_valid   (S_mem_din_valid),
         .I_mem_dout        (S_feature_out),//feature out,transport to ddr
         .I_mem_dout_valid  (S_feature_dv),
         .O_ap_ready        (S_ap_ready),
         .O_ap_done         (S_ap_done)
         );
         
     m_axi_mem#(
         .C_DATA_WIDTH      (128),
         .C_ADDR_WIDTH      (32)
     )m_axi_mem_rd_weight(
         .I_clk             (I_aclk),
         .I_rst             (~I_arst),
         .I_ap_start        (S_start),
         .I_ddr_rd_addr     (S_ddr_rd_addr),
         .I_ddr_wr_addr     (S_ddr_wr_addr),
         .I_in_data_bytes   (S_in_data_bytes),
         .I_out_data_bytes  (S_out_data_bytes),
         //axi write
         .I_awready         (),
         .I_bresp           (),
         .I_bvalid          (),
         .I_wready          (),
         .I_bid             (),
         .O_awlock          (),
         .O_awid            (),
         .O_awburst         (),
         .O_awcache         (),
         .O_awprot          (),
         .O_awsize          (),
         .O_bready          (),
         .O_wstrb           (),
         .O_awaddr          (),
         .O_awlen           (),
         .O_awvalid         (),
         .O_wdata           (),
         .O_wlast           (),
         .O_wvalid          (),
         //axi read
         .I_arready         (I_arready),
         .I_rdata           (I_rdata),
         .I_rvalid          (I_rvalid),
         .I_rlast           (I_rlast),
         .I_rresp           (I_rresp),
         .I_rid             (I_rid),
         .O_arburst         (),
         .O_arcache         (),
         .O_arprot          (),
         .O_arsize          (),
         .O_arid            (),
         .O_arlock          (),
         .O_araddr          (),
         .O_arlen           (),
         .O_arvalid         (),
         .O_rready          (),
         //memory
         .O_mem_din         (S_w_din),
         .O_mem_din_valid   (S_w_din_valid),
         .I_mem_dout        (),
         .I_mem_dout_valid  (),
         .O_ap_ready        (),
         .O_ap_done         ()
         );
         
        s_axilite2reg#(
         .C_ADDR_WIDTH      (32),
         .C_DATA_WIDTH      (32)
         )s_axilite2reg(
         .I_aclk(I_aclk),
         .I_arst(~I_arst),
         //axi
         .O_lite_awready    (O_lite_awready),
         .I_lite_awaddr     (I_lite_awaddr),
         .I_lite_awvalid    (I_lite_awvalid),
         .O_lite_wready     (O_lite_wready),
         .I_lite_wdata      (I_lite_wdata),
         .I_lite_wvalid     (I_lite_wvalid),
         .I_lite_wstrb      (I_lite_wstrb),
         .I_lite_bready     (1'b1),
         .O_lite_bresp      (O_lite_bresp),
         .O_lite_bvalid     (O_lite_bvalid),
         .O_lite_arready    (O_lite_arready),
         .I_lite_araddr     (I_lite_araddr),
         .I_lite_arvalid    (I_lite_arvalid),
         .I_lite_rready     (I_lite_rready),
         .O_lite_rdata      (O_lite_rdata),
         .O_lite_rvalid     (O_lite_rvalid),
         .O_lite_rresp      (O_lite_rresp),
         //register
         .O_reg_addr        (S_reg_addr),
         .O_reg_data        (S_reg_data),
         .I_ap_start_done   (I_rlast),
         .O_start           (S_start),
         .O_ddr_rd_addr     (S_ddr_rd_addr),
         .O_ddr_wr_addr     (S_ddr_wr_addr),
         .O_in_data_bytes   (S_in_data_bytes),
         .O_out_data_bytes  (S_out_data_bytes),
         .I_ap_ready        (S_ap_ready),
         .I_ap_done         (S_ap_done)
         );
         
        test_func test_func(
         .I_aclk            (I_aclk),
         .I_arst            (~I_arst),
         .I_start           (S_start),
         //data in
         .I_feature_in      (S_mem_din),
         .I_feature_dv      (S_mem_din_valid),
         //data out
         .O_feature_out     (S_feature_out),
         .O_feature_dv      (S_feature_dv)
         );
         
endmodule
