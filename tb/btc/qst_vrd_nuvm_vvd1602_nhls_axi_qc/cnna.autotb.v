// ==============================================================
// File generated on Mon Jul 08 12:23:32 CST 2019
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2018.3 (64-bit)
// SW Build 2405991 on Thu Dec  6 23:36:41 MST 2018
// IP Build 2404404 on Fri Dec  7 01:43:56 MST 2018
// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// ==============================================================
 `timescale 1ns/1ps


`define AUTOTB_DUT      cnna
`define AUTOTB_DUT_INST AESL_inst_cnna
`define AUTOTB_TOP      apatb_cnna_top
`define AUTOTB_LAT_RESULT_FILE "cnna.result.lat.rb"
`define AUTOTB_PER_RESULT_TRANS_FILE "cnna.performance.result.transaction.xml"
`define AUTOTB_TOP_INST AESL_inst_apatb_cnna_top
`define AUTOTB_MAX_ALLOW_LATENCY  15000000
`define AUTOTB_CLOCK_PERIOD_DIV2 5.00

`define AESL_DEPTH_FIN_DDR 1
`define AESL_DEPTH_fiddr_V 1
`define AESL_DEPTH_layer_iPara_batchSize 1
`define AESL_DEPTH_layer_iPara_width 1
`define AESL_DEPTH_layer_iPara_height 1
`define AESL_DEPTH_layer_iPara_ci_V 1
`define AESL_DEPTH_layer_iPara_ciAlign_V 1
`define AESL_DEPTH_layer_iPara_ciGroup_V 1
`define AESL_DEPTH_layer_iPara_memAddrImgIn_V 1
`define AUTOTB_TVIN_FIN_DDR  "../tv/cdatafile/c.cnna.autotvin_FIN_DDR.dat"
`define AUTOTB_TVIN_fiddr_V  "../tv/cdatafile/c.cnna.autotvin_fiddr_V.dat"
`define AUTOTB_TVIN_layer_iPara_memAddrImgIn_V  "../tv/cdatafile/c.cnna.autotvin_layer_iPara_memAddrImgIn_V.dat"
`define AUTOTB_TVIN_FIN_DDR_out_wrapc  "../tv/rtldatafile/rtl.cnna.autotvin_FIN_DDR.dat"
`define AUTOTB_TVIN_fiddr_V_out_wrapc  "../tv/rtldatafile/rtl.cnna.autotvin_fiddr_V.dat"
`define AUTOTB_TVIN_layer_iPara_memAddrImgIn_V_out_wrapc  "../tv/rtldatafile/rtl.cnna.autotvin_layer_iPara_memAddrImgIn_V.dat"
`define AUTOTB_TVOUT_FIN_DDR  "../tv/cdatafile/c.cnna.autotvout_FIN_DDR.dat"
`define AUTOTB_TVOUT_FIN_DDR_out_wrapc  "../tv/rtldatafile/rtl.cnna.autotvout_FIN_DDR.dat"
module `AUTOTB_TOP;

parameter AUTOTB_TRANSACTION_NUM = 1;
parameter PROGRESS_TIMEOUT = 10000000;
parameter LATENCY_ESTIMATION = 1587;
parameter LENGTH_FIN_DDR = 2080;
parameter LENGTH_fiddr_V = 1;
parameter LENGTH_layer_iPara_memAddrImgIn_V = 1;

task read_token;
    input integer fp;
    output reg [279 : 0] token;
    integer ret;
    begin
        token = "";
        ret = 0;
        ret = $fscanf(fp,"%s",token);
    end
endtask

reg AESL_clock;
reg rst;
reg start;
reg ce;
reg tb_continueTmp;
wire AESL_start;
wire AESL_reset;
wire AESL_ce;
wire AESL_ready;
wire AESL_idle;
wire AESL_continueTmp;
wire AESL_done;
reg AESL_done_delay = 0;
reg AESL_done_delay2 = 0;
reg AESL_ready_delay = 0;
wire ready;
wire ready_wire;
wire [6 : 0] axilite_AWADDR;
wire  axilite_AWVALID;
wire  axilite_AWREADY;
wire  axilite_WVALID;
wire  axilite_WREADY;
wire [31 : 0] axilite_WDATA;
wire [3 : 0] axilite_WSTRB;
wire [6 : 0] axilite_ARADDR;
wire  axilite_ARVALID;
wire  axilite_ARREADY;
wire  axilite_RVALID;
wire  axilite_RREADY;
wire [31 : 0] axilite_RDATA;
wire [1 : 0] axilite_RRESP;
wire  axilite_BVALID;
wire  axilite_BREADY;
wire [1 : 0] axilite_BRESP;
wire  axilite_INTERRUPT;
wire  FIN_DDR_AWVALID;
wire  FIN_DDR_AWREADY;
wire [31 : 0] FIN_DDR_AWADDR;
wire [0 : 0] FIN_DDR_AWID;
wire [7 : 0] FIN_DDR_AWLEN;
wire [2 : 0] FIN_DDR_AWSIZE;
wire [1 : 0] FIN_DDR_AWBURST;
wire [1 : 0] FIN_DDR_AWLOCK;
wire [3 : 0] FIN_DDR_AWCACHE;
wire [2 : 0] FIN_DDR_AWPROT;
wire [3 : 0] FIN_DDR_AWQOS;
wire [3 : 0] FIN_DDR_AWREGION;
wire [0 : 0] FIN_DDR_AWUSER;
wire  FIN_DDR_WVALID;
wire  FIN_DDR_WREADY;
wire [127 : 0] FIN_DDR_WDATA;
wire [15 : 0] FIN_DDR_WSTRB;
wire  FIN_DDR_WLAST;
wire [0 : 0] FIN_DDR_WID;
wire [0 : 0] FIN_DDR_WUSER;
wire  FIN_DDR_ARVALID;
wire  FIN_DDR_ARREADY;
wire [31 : 0] FIN_DDR_ARADDR;
wire [0 : 0] FIN_DDR_ARID;
wire [7 : 0] FIN_DDR_ARLEN;
wire [2 : 0] FIN_DDR_ARSIZE;
wire [1 : 0] FIN_DDR_ARBURST;
wire [1 : 0] FIN_DDR_ARLOCK;
wire [3 : 0] FIN_DDR_ARCACHE;
wire [2 : 0] FIN_DDR_ARPROT;
wire [3 : 0] FIN_DDR_ARQOS;
wire [3 : 0] FIN_DDR_ARREGION;
wire [0 : 0] FIN_DDR_ARUSER;
wire  FIN_DDR_RVALID;
wire  FIN_DDR_RREADY;
wire [127 : 0] FIN_DDR_RDATA;
wire  FIN_DDR_RLAST;
wire [0 : 0] FIN_DDR_RID;
wire [0 : 0] FIN_DDR_RUSER;
wire [1 : 0] FIN_DDR_RRESP;
wire  FIN_DDR_BVALID;
wire  FIN_DDR_BREADY;
wire [1 : 0] FIN_DDR_BRESP;
wire [0 : 0] FIN_DDR_BID;
wire [0 : 0] FIN_DDR_BUSER;
integer done_cnt = 0;
integer AESL_ready_cnt = 0;
integer ready_cnt = 0;
reg ready_initial;
reg ready_initial_n;
reg ready_last_n;
reg ready_delay_last_n;
reg done_delay_last_n;
reg interface_done = 0;
wire axilite_write_data_finish;
wire AESL_slave_start;
reg AESL_slave_start_lock = 0;
wire AESL_slave_write_start_in;
wire AESL_slave_write_start_finish;
reg AESL_slave_ready;
wire AESL_slave_output_done;
wire AESL_slave_done;
reg ready_rise = 0;
reg start_rise = 0;
reg slave_start_status = 0;
reg slave_done_status = 0;
reg ap_done_lock = 0;

wire ap_clk;
wire ap_rst_n;
wire ap_rst_n_n;

`AUTOTB_DUT `AUTOTB_DUT_INST(
    .s_axi_axilite_AWADDR(axilite_AWADDR),
    .s_axi_axilite_AWVALID(axilite_AWVALID),
    .s_axi_axilite_AWREADY(axilite_AWREADY),
    .s_axi_axilite_WVALID(axilite_WVALID),
    .s_axi_axilite_WREADY(axilite_WREADY),
    .s_axi_axilite_WDATA(axilite_WDATA),
    .s_axi_axilite_WSTRB(axilite_WSTRB),
    .s_axi_axilite_ARADDR(axilite_ARADDR),
    .s_axi_axilite_ARVALID(axilite_ARVALID),
    .s_axi_axilite_ARREADY(axilite_ARREADY),
    .s_axi_axilite_RVALID(axilite_RVALID),
    .s_axi_axilite_RREADY(axilite_RREADY),
    .s_axi_axilite_RDATA(axilite_RDATA),
    .s_axi_axilite_RRESP(axilite_RRESP),
    .s_axi_axilite_BVALID(axilite_BVALID),
    .s_axi_axilite_BREADY(axilite_BREADY),
    .s_axi_axilite_BRESP(axilite_BRESP),
    .interrupt(axilite_INTERRUPT),
    .ap_clk(ap_clk),
    .ap_rst_n(ap_rst_n),
    .m_axi_FIN_DDR_AWVALID(FIN_DDR_AWVALID),
    .m_axi_FIN_DDR_AWREADY(FIN_DDR_AWREADY),
    .m_axi_FIN_DDR_AWADDR(FIN_DDR_AWADDR),
    .m_axi_FIN_DDR_AWID(FIN_DDR_AWID),
    .m_axi_FIN_DDR_AWLEN(FIN_DDR_AWLEN),
    .m_axi_FIN_DDR_AWSIZE(FIN_DDR_AWSIZE),
    .m_axi_FIN_DDR_AWBURST(FIN_DDR_AWBURST),
    .m_axi_FIN_DDR_AWLOCK(FIN_DDR_AWLOCK),
    .m_axi_FIN_DDR_AWCACHE(FIN_DDR_AWCACHE),
    .m_axi_FIN_DDR_AWPROT(FIN_DDR_AWPROT),
    .m_axi_FIN_DDR_AWQOS(FIN_DDR_AWQOS),
    .m_axi_FIN_DDR_AWREGION(FIN_DDR_AWREGION),
    .m_axi_FIN_DDR_AWUSER(FIN_DDR_AWUSER),
    .m_axi_FIN_DDR_WVALID(FIN_DDR_WVALID),
    .m_axi_FIN_DDR_WREADY(FIN_DDR_WREADY),
    .m_axi_FIN_DDR_WDATA(FIN_DDR_WDATA),
    .m_axi_FIN_DDR_WSTRB(FIN_DDR_WSTRB),
    .m_axi_FIN_DDR_WLAST(FIN_DDR_WLAST),
    .m_axi_FIN_DDR_WID(FIN_DDR_WID),
    .m_axi_FIN_DDR_WUSER(FIN_DDR_WUSER),
    .m_axi_FIN_DDR_ARVALID(FIN_DDR_ARVALID),
    .m_axi_FIN_DDR_ARREADY(FIN_DDR_ARREADY),
    .m_axi_FIN_DDR_ARADDR(FIN_DDR_ARADDR),
    .m_axi_FIN_DDR_ARID(FIN_DDR_ARID),
    .m_axi_FIN_DDR_ARLEN(FIN_DDR_ARLEN),
    .m_axi_FIN_DDR_ARSIZE(FIN_DDR_ARSIZE),
    .m_axi_FIN_DDR_ARBURST(FIN_DDR_ARBURST),
    .m_axi_FIN_DDR_ARLOCK(FIN_DDR_ARLOCK),
    .m_axi_FIN_DDR_ARCACHE(FIN_DDR_ARCACHE),
    .m_axi_FIN_DDR_ARPROT(FIN_DDR_ARPROT),
    .m_axi_FIN_DDR_ARQOS(FIN_DDR_ARQOS),
    .m_axi_FIN_DDR_ARREGION(FIN_DDR_ARREGION),
    .m_axi_FIN_DDR_ARUSER(FIN_DDR_ARUSER),
    .m_axi_FIN_DDR_RVALID(FIN_DDR_RVALID),
    .m_axi_FIN_DDR_RREADY(FIN_DDR_RREADY),
    .m_axi_FIN_DDR_RDATA(FIN_DDR_RDATA),
    .m_axi_FIN_DDR_RLAST(FIN_DDR_RLAST),
    .m_axi_FIN_DDR_RID(FIN_DDR_RID),
    .m_axi_FIN_DDR_RUSER(FIN_DDR_RUSER),
    .m_axi_FIN_DDR_RRESP(FIN_DDR_RRESP),
    .m_axi_FIN_DDR_BVALID(FIN_DDR_BVALID),
    .m_axi_FIN_DDR_BREADY(FIN_DDR_BREADY),
    .m_axi_FIN_DDR_BRESP(FIN_DDR_BRESP),
    .m_axi_FIN_DDR_BID(FIN_DDR_BID),
    .m_axi_FIN_DDR_BUSER(FIN_DDR_BUSER));

// Assignment for control signal
assign ap_clk = AESL_clock;
assign ap_rst_n = AESL_reset;
assign ap_rst_n_n = ~AESL_reset;
assign AESL_reset = rst;
assign AESL_start = start;
assign AESL_ce = ce;
assign AESL_continueTmp = tb_continueTmp;
  assign AESL_slave_write_start_in = slave_start_status  & axilite_write_data_finish;
  assign AESL_slave_start = AESL_slave_write_start_finish;
  assign AESL_done = slave_done_status ;

always @(posedge AESL_clock)
begin
    if(AESL_reset === 0)
    begin
        slave_start_status <= 1;
    end
    else begin
        if (AESL_start == 1 ) begin
            start_rise = 1;
        end
        if (start_rise == 1 && AESL_done == 1 ) begin
            slave_start_status <= 1;
        end
        if (AESL_slave_write_start_in == 1 && AESL_done == 0) begin 
            slave_start_status <= 0;
            start_rise = 0;
        end
    end
end

always @(posedge AESL_clock)
begin
    if(AESL_reset === 0)
    begin
        AESL_slave_ready <= 0;
        ready_rise = 0;
    end
    else begin
        if (AESL_ready == 1 ) begin
            ready_rise = 1;
        end
        if (ready_rise == 1 && AESL_done_delay == 1 ) begin
            AESL_slave_ready <= 1;
        end
        if (AESL_slave_ready == 1) begin 
            AESL_slave_ready <= 0;
            ready_rise = 0;
        end
    end
end

always @ (posedge AESL_clock)
begin
    if (AESL_done == 1) begin
        slave_done_status <= 0;
    end
    else if (AESL_slave_output_done == 1 ) begin
        slave_done_status <= 1;
    end
end









wire    AESL_axi_master_FIN_DDR_ready;
wire    AESL_axi_master_FIN_DDR_done;
wire [32 - 1:0] fiddr_V;
AESL_axi_master_FIN_DDR AESL_AXI_MASTER_FIN_DDR(
    .clk   (AESL_clock),
    .reset (AESL_reset),
    .TRAN_FIN_DDR_AWVALID (FIN_DDR_AWVALID),
    .TRAN_FIN_DDR_AWREADY (FIN_DDR_AWREADY),
    .TRAN_FIN_DDR_AWADDR (FIN_DDR_AWADDR),
    .TRAN_FIN_DDR_AWID (FIN_DDR_AWID),
    .TRAN_FIN_DDR_AWLEN (FIN_DDR_AWLEN),
    .TRAN_FIN_DDR_AWSIZE (FIN_DDR_AWSIZE),
    .TRAN_FIN_DDR_AWBURST (FIN_DDR_AWBURST),
    .TRAN_FIN_DDR_AWLOCK (FIN_DDR_AWLOCK),
    .TRAN_FIN_DDR_AWCACHE (FIN_DDR_AWCACHE),
    .TRAN_FIN_DDR_AWPROT (FIN_DDR_AWPROT),
    .TRAN_FIN_DDR_AWQOS (FIN_DDR_AWQOS),
    .TRAN_FIN_DDR_AWREGION (FIN_DDR_AWREGION),
    .TRAN_FIN_DDR_AWUSER (FIN_DDR_AWUSER),
    .TRAN_FIN_DDR_WVALID (FIN_DDR_WVALID),
    .TRAN_FIN_DDR_WREADY (FIN_DDR_WREADY),
    .TRAN_FIN_DDR_WDATA (FIN_DDR_WDATA),
    .TRAN_FIN_DDR_WSTRB (FIN_DDR_WSTRB),
    .TRAN_FIN_DDR_WLAST (FIN_DDR_WLAST),
    .TRAN_FIN_DDR_WID (FIN_DDR_WID),
    .TRAN_FIN_DDR_WUSER (FIN_DDR_WUSER),
    .TRAN_FIN_DDR_ARVALID (FIN_DDR_ARVALID),
    .TRAN_FIN_DDR_ARREADY (FIN_DDR_ARREADY),
    .TRAN_FIN_DDR_ARADDR (FIN_DDR_ARADDR),
    .TRAN_FIN_DDR_ARID (FIN_DDR_ARID),
    .TRAN_FIN_DDR_ARLEN (FIN_DDR_ARLEN),
    .TRAN_FIN_DDR_ARSIZE (FIN_DDR_ARSIZE),
    .TRAN_FIN_DDR_ARBURST (FIN_DDR_ARBURST),
    .TRAN_FIN_DDR_ARLOCK (FIN_DDR_ARLOCK),
    .TRAN_FIN_DDR_ARCACHE (FIN_DDR_ARCACHE),
    .TRAN_FIN_DDR_ARPROT (FIN_DDR_ARPROT),
    .TRAN_FIN_DDR_ARQOS (FIN_DDR_ARQOS),
    .TRAN_FIN_DDR_ARREGION (FIN_DDR_ARREGION),
    .TRAN_FIN_DDR_ARUSER (FIN_DDR_ARUSER),
    .TRAN_FIN_DDR_RVALID (FIN_DDR_RVALID),
    .TRAN_FIN_DDR_RREADY (FIN_DDR_RREADY),
    .TRAN_FIN_DDR_RDATA (FIN_DDR_RDATA),
    .TRAN_FIN_DDR_RLAST (FIN_DDR_RLAST),
    .TRAN_FIN_DDR_RID (FIN_DDR_RID),
    .TRAN_FIN_DDR_RUSER (FIN_DDR_RUSER),
    .TRAN_FIN_DDR_RRESP (FIN_DDR_RRESP),
    .TRAN_FIN_DDR_BVALID (FIN_DDR_BVALID),
    .TRAN_FIN_DDR_BREADY (FIN_DDR_BREADY),
    .TRAN_FIN_DDR_BRESP (FIN_DDR_BRESP),
    .TRAN_FIN_DDR_BID (FIN_DDR_BID),
    .TRAN_FIN_DDR_BUSER (FIN_DDR_BUSER),
    .TRAN_FIN_DDR_fiddr_V (fiddr_V),
    .ready (AESL_axi_master_FIN_DDR_ready),
    .done  (AESL_axi_master_FIN_DDR_done)
);
assign    AESL_axi_master_FIN_DDR_ready    =   ready;
assign    AESL_axi_master_FIN_DDR_done    =   AESL_done_delay;

AESL_axi_slave_axilite AESL_AXI_SLAVE_axilite(
    .clk   (AESL_clock),
    .reset (AESL_reset),
    .TRAN_s_axi_axilite_AWADDR (axilite_AWADDR),
    .TRAN_s_axi_axilite_AWVALID (axilite_AWVALID),
    .TRAN_s_axi_axilite_AWREADY (axilite_AWREADY),
    .TRAN_s_axi_axilite_WVALID (axilite_WVALID),
    .TRAN_s_axi_axilite_WREADY (axilite_WREADY),
    .TRAN_s_axi_axilite_WDATA (axilite_WDATA),
    .TRAN_s_axi_axilite_WSTRB (axilite_WSTRB),
    .TRAN_s_axi_axilite_ARADDR (axilite_ARADDR),
    .TRAN_s_axi_axilite_ARVALID (axilite_ARVALID),
    .TRAN_s_axi_axilite_ARREADY (axilite_ARREADY),
    .TRAN_s_axi_axilite_RVALID (axilite_RVALID),
    .TRAN_s_axi_axilite_RREADY (axilite_RREADY),
    .TRAN_s_axi_axilite_RDATA (axilite_RDATA),
    .TRAN_s_axi_axilite_RRESP (axilite_RRESP),
    .TRAN_s_axi_axilite_BVALID (axilite_BVALID),
    .TRAN_s_axi_axilite_BREADY (axilite_BREADY),
    .TRAN_s_axi_axilite_BRESP (axilite_BRESP),
    .TRAN_axilite_interrupt (axilite_INTERRUPT),
    .TRAN_fiddr_V (fiddr_V),
    .TRAN_axilite_write_data_finish(axilite_write_data_finish),
    .TRAN_axilite_ready_out (AESL_ready),
    .TRAN_axilite_ready_in (AESL_slave_ready),
    .TRAN_axilite_done_out (AESL_slave_output_done),
    .TRAN_axilite_idle_out (AESL_idle),
    .TRAN_axilite_write_start_in     (AESL_slave_write_start_in),
    .TRAN_axilite_write_start_finish (AESL_slave_write_start_finish),
    .TRAN_axilite_transaction_done_in (AESL_done_delay),
    .TRAN_axilite_start_in  (AESL_slave_start)
);

initial begin : generate_AESL_ready_cnt_proc
    AESL_ready_cnt = 0;
    wait(AESL_reset === 1);
    while(AESL_ready_cnt != AUTOTB_TRANSACTION_NUM) begin
        while(AESL_ready !== 1) begin
            @(posedge AESL_clock);
            # 0.4;
        end
        @(negedge AESL_clock);
        AESL_ready_cnt = AESL_ready_cnt + 1;
        @(posedge AESL_clock);
        # 0.4;
    end
end

    event next_trigger_ready_cnt;
    
    initial begin : gen_ready_cnt
        ready_cnt = 0;
        wait (AESL_reset === 1);
        forever begin
            @ (posedge AESL_clock);
            if (ready == 1) begin
                if (ready_cnt < AUTOTB_TRANSACTION_NUM) begin
                    ready_cnt = ready_cnt + 1;
                end
            end
            -> next_trigger_ready_cnt;
        end
    end
    
    wire all_finish = (done_cnt == AUTOTB_TRANSACTION_NUM);
    
    // done_cnt
    always @ (posedge AESL_clock) begin
        if (~AESL_reset) begin
            done_cnt <= 0;
        end else begin
            if (AESL_done == 1) begin
                if (done_cnt < AUTOTB_TRANSACTION_NUM) begin
                    done_cnt <= done_cnt + 1;
                end
            end
        end
    end
    
    initial begin : finish_simulation
        wait (all_finish == 1);
        // last transaction is saved at negedge right after last done
        @ (posedge AESL_clock);
        @ (posedge AESL_clock);
        @ (posedge AESL_clock);
        @ (posedge AESL_clock);
        $stop;
    end
    
initial begin
    AESL_clock = 0;
    forever #`AUTOTB_CLOCK_PERIOD_DIV2 AESL_clock = ~AESL_clock;
end


reg end_FIN_DDR;
reg [31:0] size_FIN_DDR;
reg [31:0] size_FIN_DDR_backup;
reg end_fiddr_V;
reg [31:0] size_fiddr_V;
reg [31:0] size_fiddr_V_backup;
reg end_layer_iPara_memAddrImgIn_V;
reg [31:0] size_layer_iPara_memAddrImgIn_V;
reg [31:0] size_layer_iPara_memAddrImgIn_V_backup;

initial begin : initial_process
    integer proc_randTmp;
    rst = 0;
    # 100;
    repeat(3) @ (posedge AESL_clock);
    rst = 1;
end
initial begin : start_process
    integer proc_randTmp;
    reg [31:0] start_cnt;
    ce = 1;
    start = 0;
    start_cnt = 0;
    wait (AESL_reset === 1);
    @ (posedge AESL_clock);
    #0 start = 1;
    start_cnt = start_cnt + 1;
    forever begin
        @ (posedge AESL_clock);
        if (start_cnt >= AUTOTB_TRANSACTION_NUM) begin
            // keep pushing garbage in
            #0 start = 1;
        end
        if (AESL_ready) begin
            start_cnt = start_cnt + 1;
        end
    end
end

always @(AESL_done)
begin
    tb_continueTmp = AESL_done;
end

initial begin : ready_initial_process
    ready_initial = 0;
    wait (AESL_start === 1);
    ready_initial = 1;
    @(posedge AESL_clock);
    ready_initial = 0;
end

always @(posedge AESL_clock)
begin
    if(AESL_reset === 0)
      AESL_ready_delay = 0;
  else
      AESL_ready_delay = AESL_ready;
end
initial begin : ready_last_n_process
  ready_last_n = 1;
  wait(ready_cnt == AUTOTB_TRANSACTION_NUM)
  @(posedge AESL_clock);
  ready_last_n <= 0;
end

always @(posedge AESL_clock)
begin
    if(AESL_reset === 0)
      ready_delay_last_n = 0;
  else
      ready_delay_last_n <= ready_last_n;
end
assign ready = (ready_initial | AESL_ready_delay);
assign ready_wire = ready_initial | AESL_ready_delay;
initial begin : done_delay_last_n_process
  done_delay_last_n = 1;
  while(done_cnt < AUTOTB_TRANSACTION_NUM)
      @(posedge AESL_clock);
  # 0.1;
  done_delay_last_n = 0;
end

always @(posedge AESL_clock)
begin
    if(AESL_reset === 0)
  begin
      AESL_done_delay <= 0;
      AESL_done_delay2 <= 0;
  end
  else begin
      AESL_done_delay <= AESL_done & done_delay_last_n;
      AESL_done_delay2 <= AESL_done_delay;
  end
end
always @(posedge AESL_clock)
begin
    if(AESL_reset === 0)
      interface_done = 0;
  else begin
      # 0.01;
      if(ready === 1 && ready_cnt > 0 && ready_cnt < AUTOTB_TRANSACTION_NUM)
          interface_done = 1;
      else if(AESL_done_delay === 1 && done_cnt == AUTOTB_TRANSACTION_NUM)
          interface_done = 1;
      else
          interface_done = 0;
  end
end

reg dump_tvout_finish_FIN_DDR;

initial begin : dump_tvout_runtime_sign_FIN_DDR
    integer fp;
    dump_tvout_finish_FIN_DDR = 0;
    fp = $fopen(`AUTOTB_TVOUT_FIN_DDR_out_wrapc, "w");
    if (fp == 0) begin
        $display("Failed to open file \"%s\"!", `AUTOTB_TVOUT_FIN_DDR_out_wrapc);
        $display("ERROR: Simulation using HLS TB failed.");
        $stop;
    end
    $fdisplay(fp,"[[[runtime]]]");
    $fclose(fp);
    wait (done_cnt == AUTOTB_TRANSACTION_NUM);
    // last transaction is saved at negedge right after last done
    @ (posedge AESL_clock);
    @ (posedge AESL_clock);
    @ (posedge AESL_clock);
    fp = $fopen(`AUTOTB_TVOUT_FIN_DDR_out_wrapc, "a");
    if (fp == 0) begin
        $display("Failed to open file \"%s\"!", `AUTOTB_TVOUT_FIN_DDR_out_wrapc);
        $display("ERROR: Simulation using HLS TB failed.");
        $stop;
    end
    $fdisplay(fp,"[[[/runtime]]]");
    $fclose(fp);
    dump_tvout_finish_FIN_DDR = 1;
end


////////////////////////////////////////////
// progress and performance
////////////////////////////////////////////

task wait_start();
    while (~AESL_start) begin
        @ (posedge AESL_clock);
    end
endtask

reg [31:0] clk_cnt = 0;
reg AESL_ready_p1;
reg AESL_start_p1;

always @ (posedge AESL_clock) begin
    clk_cnt <= clk_cnt + 1;
    AESL_ready_p1 <= AESL_ready;
    AESL_start_p1 <= AESL_start;
end

reg [31:0] start_timestamp [0:AUTOTB_TRANSACTION_NUM - 1];
reg [31:0] start_cnt;
reg [31:0] ready_timestamp [0:AUTOTB_TRANSACTION_NUM - 1];
reg [31:0] ap_ready_cnt;
reg [31:0] finish_timestamp [0:AUTOTB_TRANSACTION_NUM - 1];
reg [31:0] finish_cnt;
event report_progress;

initial begin
    start_cnt = 0;
    finish_cnt = 0;
    ap_ready_cnt = 0;
    wait (AESL_reset == 1);
    wait_start();
    start_timestamp[start_cnt] = clk_cnt;
    start_cnt = start_cnt + 1;
    if (AESL_done) begin
        finish_timestamp[finish_cnt] = clk_cnt;
        finish_cnt = finish_cnt + 1;
    end
    -> report_progress;
    forever begin
        @ (posedge AESL_clock);
        if (start_cnt < AUTOTB_TRANSACTION_NUM) begin
            if ((AESL_start && AESL_ready_p1)||(AESL_start && ~AESL_start_p1)) begin
                start_timestamp[start_cnt] = clk_cnt;
                start_cnt = start_cnt + 1;
            end
        end
        if (ap_ready_cnt < AUTOTB_TRANSACTION_NUM) begin
            if (AESL_start_p1 && AESL_ready_p1) begin
                ready_timestamp[ap_ready_cnt] = clk_cnt;
                ap_ready_cnt = ap_ready_cnt + 1;
            end
        end
        if (finish_cnt < AUTOTB_TRANSACTION_NUM) begin
            if (AESL_done) begin
                finish_timestamp[finish_cnt] = clk_cnt;
                finish_cnt = finish_cnt + 1;
            end
        end
        -> report_progress;
    end
end

reg [31:0] progress_timeout;

initial begin : simulation_progress
    real intra_progress;
    wait (AESL_reset == 1);
    progress_timeout = PROGRESS_TIMEOUT;
    $display("////////////////////////////////////////////////////////////////////////////////////");
    $display("// Inter-Transaction Progress: Completed Transaction / Total Transaction");
    $display("// Intra-Transaction Progress: Measured Latency / Latency Estimation * 100%%");
    $display("//");
    $display("// RTL Simulation : \"Inter-Transaction Progress\" [\"Intra-Transaction Progress\"] @ \"Simulation Time\"");
    $display("////////////////////////////////////////////////////////////////////////////////////");
    print_progress();
    while (finish_cnt < AUTOTB_TRANSACTION_NUM) begin
        @ (report_progress);
        if (finish_cnt < AUTOTB_TRANSACTION_NUM) begin
            if (AESL_done) begin
                print_progress();
                progress_timeout = PROGRESS_TIMEOUT;
            end else begin
                if (progress_timeout == 0) begin
                    print_progress();
                    progress_timeout = PROGRESS_TIMEOUT;
                end else begin
                    progress_timeout = progress_timeout - 1;
                end
            end
        end
    end
    print_progress();
    $display("////////////////////////////////////////////////////////////////////////////////////");
    calculate_performance();
end

task get_intra_progress(output real intra_progress);
    begin
        if (start_cnt > finish_cnt) begin
            intra_progress = clk_cnt - start_timestamp[finish_cnt];
        end else if(finish_cnt > 0) begin
            intra_progress = LATENCY_ESTIMATION;
        end else begin
            intra_progress = 0;
        end
        intra_progress = intra_progress / LATENCY_ESTIMATION;
    end
endtask

task print_progress();
    real intra_progress;
    begin
        if (LATENCY_ESTIMATION > 0) begin
            get_intra_progress(intra_progress);
            $display("// RTL Simulation : %0d / %0d [%2.2f%%] @ \"%0t\"", finish_cnt, AUTOTB_TRANSACTION_NUM, intra_progress * 100, $time);
        end else begin
            $display("// RTL Simulation : %0d / %0d [n/a] @ \"%0t\"", finish_cnt, AUTOTB_TRANSACTION_NUM, $time);
        end
    end
endtask

task calculate_performance();
    integer i;
    integer fp;
    reg [31:0] latency [0:AUTOTB_TRANSACTION_NUM - 1];
    reg [31:0] latency_min;
    reg [31:0] latency_max;
    reg [31:0] latency_total;
    reg [31:0] latency_average;
    reg [31:0] interval [0:AUTOTB_TRANSACTION_NUM - 2];
    reg [31:0] interval_min;
    reg [31:0] interval_max;
    reg [31:0] interval_total;
    reg [31:0] interval_average;
    begin
        latency_min = -1;
        latency_max = 0;
        latency_total = 0;
        interval_min = -1;
        interval_max = 0;
        interval_total = 0;

        for (i = 0; i < AUTOTB_TRANSACTION_NUM; i = i + 1) begin
            // calculate latency
            latency[i] = finish_timestamp[i] - start_timestamp[i];
            if (latency[i] > latency_max) latency_max = latency[i];
            if (latency[i] < latency_min) latency_min = latency[i];
            latency_total = latency_total + latency[i];
            // calculate interval
            if (AUTOTB_TRANSACTION_NUM == 1) begin
                interval[i] = 0;
                interval_max = 0;
                interval_min = 0;
                interval_total = 0;
            end else if (i < AUTOTB_TRANSACTION_NUM - 1) begin
                interval[i] = finish_timestamp[i] - start_timestamp[i]+1;
                if (interval[i] > interval_max) interval_max = interval[i];
                if (interval[i] < interval_min) interval_min = interval[i];
                interval_total = interval_total + interval[i];
            end
        end

        latency_average = latency_total / AUTOTB_TRANSACTION_NUM;
        if (AUTOTB_TRANSACTION_NUM == 1) begin
            interval_average = 0;
        end else begin
            interval_average = interval_total / (AUTOTB_TRANSACTION_NUM - 1);
        end

        fp = $fopen(`AUTOTB_LAT_RESULT_FILE, "w");

        $fdisplay(fp, "$MAX_LATENCY = \"%0d\"", latency_max);
        $fdisplay(fp, "$MIN_LATENCY = \"%0d\"", latency_min);
        $fdisplay(fp, "$AVER_LATENCY = \"%0d\"", latency_average);
        $fdisplay(fp, "$MAX_THROUGHPUT = \"%0d\"", interval_max);
        $fdisplay(fp, "$MIN_THROUGHPUT = \"%0d\"", interval_min);
        $fdisplay(fp, "$AVER_THROUGHPUT = \"%0d\"", interval_average);

        $fclose(fp);

        fp = $fopen(`AUTOTB_PER_RESULT_TRANS_FILE, "w");

        $fdisplay(fp, "%20s%16s%16s", "", "latency", "interval");
        if (AUTOTB_TRANSACTION_NUM == 1) begin
            i = 0;
            $fdisplay(fp, "transaction%8d:%16d%16d", i, latency[i], interval[i]);
        end else begin
            for (i = 0; i < AUTOTB_TRANSACTION_NUM; i = i + 1) begin
                if (i < AUTOTB_TRANSACTION_NUM - 1) begin
                    $fdisplay(fp, "transaction%8d:%16d%16d", i, latency[i], interval[i]);
                end else begin
                    $fdisplay(fp, "transaction%8d:%16d               x", i, latency[i]);
                end
            end
        end

        $fclose(fp);
    end
endtask


////////////////////////////////////////////
// Dependence Check
////////////////////////////////////////////

`ifndef POST_SYN

`endif

/*
initial begin
    //__CNNFILE__
    integer fp;
    fp = $fopen("cnna.log", "w");
    while(1)begin
        @(negedge AESL_clock);
        #1ns;
        if(FOUT_DDR_WREADY && FOUT_DDR_WVALID)begin
            $fdisplay(fp, "%4d %4d %4d %4d %4d %4d %4d %4d %4d %4d %4d %4d %4d %4d %4d %4d"
            ,FOUT_DDR_WDATA[  7:  0]
            ,FOUT_DDR_WDATA[ 15:  8]
            ,FOUT_DDR_WDATA[ 23: 16]
            ,FOUT_DDR_WDATA[ 31: 24]
            ,FOUT_DDR_WDATA[ 39: 32]
            ,FOUT_DDR_WDATA[ 47: 40]
            ,FOUT_DDR_WDATA[ 55: 48]
            ,FOUT_DDR_WDATA[ 63: 56]
            ,FOUT_DDR_WDATA[ 71: 64]
            ,FOUT_DDR_WDATA[ 79: 72]
            ,FOUT_DDR_WDATA[ 87: 80]
            ,FOUT_DDR_WDATA[ 95: 88]
            ,FOUT_DDR_WDATA[103: 96]
            ,FOUT_DDR_WDATA[111:104]
            ,FOUT_DDR_WDATA[119:112]
            ,FOUT_DDR_WDATA[127:120]);
        end
    end
    $fclose(fp);
end
*/

initial begin
	$helloword;
	$fsdbDumpvars("+fsdbfile+tb_dut_top.fsdb");
	$fsdbDumpSVA;
end
endmodule
