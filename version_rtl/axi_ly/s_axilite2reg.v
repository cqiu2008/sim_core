`timescale 1ns / 1ps


module s_axilite2reg#(
parameter
    C_ADDR_WIDTH    = 32,
    C_DATA_WIDTH    = 32
)(
    input                                           I_aclk,
    input                                           I_arst,
    //axi
    output reg                                      O_lite_awready    = 0,
    input               [C_ADDR_WIDTH-1:0]          I_lite_awaddr,
    input                                           I_lite_awvalid,
    output reg                                      O_lite_wready     = 0,
    input               [C_DATA_WIDTH-1:0]          I_lite_wdata,
    input                                           I_lite_wvalid,
    input               [C_DATA_WIDTH/8-1:0]        I_lite_wstrb,
    input                                           I_lite_bready,
    output reg          [1:0]                       O_lite_bresp      = 0,//okay
    output reg                                      O_lite_bvalid     = 0,
    output reg                                      O_lite_arready    = 0,
    input               [C_ADDR_WIDTH-1:0]          I_lite_araddr,
    input                                           I_lite_arvalid,
    input                                           I_lite_rready,
    output reg          [C_DATA_WIDTH-1:0]          O_lite_rdata      = 0,
    output reg                                      O_lite_rvalid     = 0,
    output reg          [1:0]                       O_lite_rresp      = 0,
    //register
    output reg          [C_ADDR_WIDTH-1:0]          O_reg_addr   = 0,
    output reg          [C_DATA_WIDTH-1:0]          O_reg_data   = 0,
    input                                           I_ap_start_done,
    
    output reg                                      O_start,
    output reg          [31:0]                      O_ddr_rd_addr,
    output reg          [31:0]                      O_ddr_wr_addr,
    output reg          [31:0]                      O_in_data_bytes,
    output reg          [31:0]                      O_out_data_bytes,
    output              [31:0]                      O_ap_ctrl,
    input                                           I_ap_ready,
    input                                           I_ap_done
    );
    
    localparam  ADDR_AP_CTRL                = 32'ha000_0000;
    localparam  DDR_RD_BASE_ADDR            = 32'ha000_0010;
    localparam  DDR_WR_BASE_ADDR            = 32'ha000_0014;
    localparam  IN_DATA_BYTES               = 32'ha000_0018;
    localparam  OUT_DATA_BYTES              = 32'ha000_001c;
    
    reg    aw_en = 1'b1;
    reg    ap_idle = 1'b1;
    reg    [1:0] ap_start;
    wire   bv_en = O_lite_awready & I_lite_awvalid & ~O_lite_bvalid & O_lite_wready & I_lite_wvalid;
    wire   rd_en = O_lite_arready & I_lite_arvalid;
    wire   wr_en = O_lite_wready & I_lite_wvalid;
    wire   [31:0] ap_ctrl = {28'd0,I_ap_ready,ap_idle,I_ap_done,O_start};
    
    always@ (posedge I_aclk)
    begin
        ap_start[1] = ap_start[0];
        ap_start[0] = O_start;
    
        if (/*~ap_start[1] & ap_start[0]*/O_start)
            ap_idle <= 1'b0;
        else if (I_ap_done)
            ap_idle <= 1'b1;

    end
    
    always@ (posedge I_aclk)
    begin
        if (I_arst) begin
            O_lite_awready <= 1'b0;
            aw_en <= 1'b1;
        end
        else begin
            if (~O_lite_awready & I_lite_awvalid & I_lite_wvalid & aw_en) begin
                O_lite_awready <= 1'b1;
                aw_en <= 1'b0;
            end
            else if (I_lite_bready & O_lite_bvalid) begin
                O_lite_awready <= 1'b0;
                aw_en <= 1'b1;
            end
            else begin
                O_lite_awready <= 1'b0;
            end
        end
    end
    
    always@ (posedge I_aclk)
    begin
        if (~O_lite_awready & I_lite_awvalid & I_lite_wvalid & aw_en) 
            O_reg_addr <= I_lite_awaddr;
        else;
    end
    
    always@ (posedge I_aclk)
    begin
        if (I_arst)
            O_lite_wready <= 1'b0;
        else if (~O_lite_wready & I_lite_awvalid & I_lite_wvalid & aw_en)
            O_lite_wready <= 1'b1;
        else
            O_lite_wready <= 1'b0;
    end
    
    always@ (posedge I_aclk)
    begin
        if (I_arst)
            O_lite_bvalid <= 1'b0;
        else if (/*O_awready & I_awvalid & (~O_bvalid) & O_wready & I_wvalid*/bv_en & (~O_lite_bvalid))
            O_lite_bvalid <= 1'b1;
        else if (O_lite_bvalid & I_lite_bready)
            O_lite_bvalid <= 1'b0;
    end
    
    always@ (posedge I_aclk)
    begin
        if (I_arst)
            O_lite_arready <= 1'b0;
        else if (~O_lite_arready & I_lite_arvalid)
            O_lite_arready <= 1'b1;
        else 
            O_lite_arready <= 1'b0;
    end

    
    always@ (posedge I_aclk)
    begin
        O_reg_data <= I_lite_wdata;
    end
    
    
    always@ (posedge I_aclk)
    begin
        if (I_arst)
            O_lite_rvalid <= 1'b0;
        else 
        if (rd_en) 
            O_lite_rvalid <= 1'b1;
        else if (O_lite_rvalid & I_lite_rready)
            O_lite_rvalid <= 1'b0;
    
        if (rd_en) begin
           if (I_lite_araddr == ADDR_AP_CTRL)
               O_lite_rdata <= /*O_start*/ap_ctrl;
           else if (I_lite_araddr == DDR_RD_BASE_ADDR)
               O_lite_rdata <= O_ddr_rd_addr;
           else if (I_lite_araddr == DDR_WR_BASE_ADDR)
               O_lite_rdata <= O_ddr_wr_addr;
           else if (I_lite_araddr == IN_DATA_BYTES)
               O_lite_rdata <= O_in_data_bytes;
           else if (I_lite_araddr == OUT_DATA_BYTES)
               O_lite_rdata <= O_out_data_bytes;
        end
    end
    
    //move in part
    always@ (posedge I_aclk)
    begin
        if (I_arst)
            O_start <= 1'b0;
        else if (I_lite_awaddr == ADDR_AP_CTRL & wr_en)
            O_start <= I_lite_wdata[0];
        else if (I_ap_start_done)
            O_start <= 1'b0;
            
        if (I_lite_awaddr == DDR_RD_BASE_ADDR & wr_en)
            O_ddr_rd_addr <= I_lite_wdata;
            
        if (I_lite_awaddr == DDR_WR_BASE_ADDR & wr_en)
            O_ddr_wr_addr <= I_lite_wdata;
        
        if (I_lite_awaddr == IN_DATA_BYTES & wr_en)
            O_in_data_bytes <= I_lite_wdata;
            
        if (I_lite_awaddr == OUT_DATA_BYTES & wr_en)
            O_out_data_bytes <= I_lite_wdata;        
   end
    
endmodule
