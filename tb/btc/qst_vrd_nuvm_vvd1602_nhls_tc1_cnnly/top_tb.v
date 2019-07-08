`timescale 1ns / 1ps
`include "/home/cqiu/AIPrj/sim/sim_cnnly/rtl/src/global_include.v"

module top_tb;

localparam  K = 9;
localparam  TOTAL_WEIGHT = ((~(|(`LAYER_CH_IN%16))) ? `LAYER_CH_IN : (((`LAYER_CH_IN+'d16)>>'d4)<<'d4))*`LAYER_CH_OUT*`LAYER_KX*`LAYER_KY;

reg                            I_clk               = 0;
reg   [`AXIWIDTH-1:0]          I_feature           = 0;
reg                            I_feature_dv        = 0;
reg   [`LITEWIDTH-1:0]         I_layer_num         = 0;
reg   [`LITEWIDTH-1:0]         I_feature_base_addr = 0;
reg   [`LITEWIDTH-1:0]         I_ci_num            = 0;
reg   [`LITEWIDTH-1:0]         I_co_num            = 0;
reg   [`LITEWIDTH-1:0]         I_kxk_num           = 0;
reg   [`LITEWIDTH-1:0]         I_ap_start          = 0;
reg   [`DWIDTH-1:0]            mem [TOTAL_WEIGHT+`LAYER_BIAS-1:0];
reg   [`AXIWIDTH-1:0]          I_weight            = 0;
reg                            I_weight_dv         = 0;
reg   [`DWIDTH-1:0]            fmem [`LAYER_KX*`LAYER_OWIDTH*(`AXIWIDTH/`DWIDTH)-1:0];//672lines*16points
wire  [24*`CH_OUT*`PIX-1:0]    O_result_0,O_result_1,O_macc_data;
reg   [24*`CH_OUT*`PIX-1:0]    result_array [1:0];
reg   [`KWIDTH-1:0]            I_ky                = 0;
wire                           S_dram_feature_rd_flag;

initial begin
I_clk = 0;
forever #5
I_clk = !I_clk;
end

initial begin
#50
@(posedge I_clk)//load layer0 weight
begin
I_layer_num         <= 0;
I_feature_base_addr <= 32'h1000_0000;
I_ci_num            <= 16;
I_co_num            <= 64;
I_kxk_num           <= 9;
end
@(posedge I_clk)
I_ap_start          <= 1;
#30
@(posedge I_clk)
I_ap_start          <= 0;

#6000
@(posedge I_clk)//load layer1 weight
begin
I_layer_num         <= 1;
I_feature_base_addr <= 32'h2000_0000;
I_ci_num            <= 16;
I_co_num            <= 64;
I_kxk_num           <= 9;
end
@(posedge I_clk)
I_ap_start          <= 1;
#30
@(posedge I_clk)
I_ap_start          <= 0;
end

initial begin
$readmemh("/home/cqiu/AIPrj/sim/sim_cnnly/tb/btc/qst_vrd_nuvm_vvd1602_nhls_tc1_cnnly/weight_layer0.txt",mem,0,TOTAL_WEIGHT+`LAYER_BIAS);
end

integer i;
initial begin
#200
for (i=0; i<`LAYER_WLOAD_LOOPS; i=i+1)//load layer0 weight
begin
@(posedge I_clk) begin
I_weight <= {mem[`LAYER_BIAS+15+i*`CH_IN],mem[`LAYER_BIAS+14+i*`CH_IN],mem[`LAYER_BIAS+13+i*`CH_IN],mem[`LAYER_BIAS+12+i*`CH_IN],
             mem[`LAYER_BIAS+11+i*`CH_IN],mem[`LAYER_BIAS+10+i*`CH_IN],mem[`LAYER_BIAS+9+i*`CH_IN],mem[`LAYER_BIAS+8+i*`CH_IN],
             mem[`LAYER_BIAS+7+i*`CH_IN],mem[`LAYER_BIAS+6+i*`CH_IN],mem[`LAYER_BIAS+5+i*`CH_IN],mem[`LAYER_BIAS+4+i*`CH_IN],
             mem[`LAYER_BIAS+3+i*`CH_IN],mem[`LAYER_BIAS+2+i*`CH_IN],mem[`LAYER_BIAS+1+i*`CH_IN],mem[`LAYER_BIAS+0+i*`CH_IN]};
I_weight_dv <= 1'b1;
end
end
@(posedge I_clk)
I_weight_dv <= 1'b0;

#1500
for (i=0; i<`LAYER_WLOAD_LOOPS; i=i+1)//load layer1 weight
begin
@(posedge I_clk) begin
I_weight <= {mem[`LAYER_BIAS+15+i*`CH_IN],mem[`LAYER_BIAS+14+i*`CH_IN],mem[`LAYER_BIAS+13+i*`CH_IN],mem[`LAYER_BIAS+12+i*`CH_IN],
             mem[`LAYER_BIAS+11+i*`CH_IN],mem[`LAYER_BIAS+10+i*`CH_IN],mem[`LAYER_BIAS+9+i*`CH_IN],mem[`LAYER_BIAS+8+i*`CH_IN],
             mem[`LAYER_BIAS+7+i*`CH_IN],mem[`LAYER_BIAS+6+i*`CH_IN],mem[`LAYER_BIAS+5+i*`CH_IN],mem[`LAYER_BIAS+4+i*`CH_IN],
             mem[`LAYER_BIAS+3+i*`CH_IN],mem[`LAYER_BIAS+2+i*`CH_IN],mem[`LAYER_BIAS+1+i*`CH_IN],mem[`LAYER_BIAS+0+i*`CH_IN]};
I_weight_dv <= 1'b1;
end
end
@(posedge I_clk)
I_weight_dv <= 1'b0;
end

reg    [127:0]    I_bias    =0;
reg               I_bias_dv =0;

integer bias;
initial begin
#200
for (bias=0; bias<4; bias=bias+1)
begin
@(posedge I_clk)begin
I_bias <= {mem[15+bias*`CH_IN],mem[14+bias*`CH_IN],mem[13+bias*`CH_IN],mem[12+bias*`CH_IN],
           mem[11+bias*`CH_IN],mem[10+bias*`CH_IN],mem[9+bias*`CH_IN],mem[8+bias*`CH_IN],
           mem[7+bias*`CH_IN],mem[6+bias*`CH_IN],mem[5+bias*`CH_IN],mem[4+bias*`CH_IN],
           mem[3+bias*`CH_IN],mem[2+bias*`CH_IN],mem[1+bias*`CH_IN],mem[0+bias*`CH_IN]};
I_bias_dv <= 1'b1;
end
end//for
@(posedge I_clk)
I_bias_dv <= 1'b0;
end

//---------------------------------------------

integer hand,p,hand_i;
integer data_i[10240-1:0];
initial begin
    hand = $fopen("/home/cqiu/AIPrj/sim/sim_cnnly/tb/btc/qst_vrd_nuvm_vvd1602_nhls_tc1_cnnly/catVgg16.i","r");
    for (p=0; p<10240; p=p+1)
    begin
        #1
        hand_i = $fscanf(hand,"%d",data_i[p]);
    end
end

reg [127:0]  feature_in = 0;
reg          feature_dv = 0;

integer floop;
initial begin
//#26625
#6300
for (floop=0; floop<224; floop=floop+1)
begin
@(posedge I_clk)
begin
    feature_in <= {{(13){8'd0}},data_i[floop*3+2][7:0],data_i[floop*3+1][7:0],data_i[floop*3+0][7:0]};
    feature_dv <= 1'b1;
end//clk
end//for
#1
@(posedge I_clk)
feature_dv <= 1'b0;

#5500
for (floop=224; floop<448; floop=floop+1)
begin
@(posedge I_clk)
begin
    feature_in <= {{(13){8'd0}},data_i[floop*3+2][7:0],data_i[floop*3+1][7:0],data_i[floop*3+0][7:0]};
    feature_dv <= 1'b1;
end//clk
end//for
#1
@(posedge I_clk)
feature_dv <= 1'b0;
end

//---------------------------------------------

integer k;
initial begin
$readmemh("/home/cqiu/AIPrj/sim/sim_cnnly/tb/btc/qst_vrd_nuvm_vvd1602_nhls_tc1_cnnly/sbufForLY190510Golden.txt",fmem,0,`LAYER_KX*`LAYER_OWIDTH*(`AXIWIDTH/`DWIDTH));
#6300
for (k=0; k<(`LAYER_KX*`LAYER_OWIDTH); k=k+1)
begin
@(posedge I_clk)
begin
I_feature <= {fmem[(`AXIWIDTH/`DWIDTH)*k+15],fmem[(`AXIWIDTH/`DWIDTH)*k+14],fmem[(`AXIWIDTH/`DWIDTH)*k+13],fmem[(`AXIWIDTH/`DWIDTH)*k+12],
              fmem[(`AXIWIDTH/`DWIDTH)*k+11],fmem[(`AXIWIDTH/`DWIDTH)*k+10],fmem[(`AXIWIDTH/`DWIDTH)*k+9],fmem[(`AXIWIDTH/`DWIDTH)*k+8],
              fmem[(`AXIWIDTH/`DWIDTH)*k+7],fmem[(`AXIWIDTH/`DWIDTH)*k+6],fmem[(`AXIWIDTH/`DWIDTH)*k+5],fmem[(`AXIWIDTH/`DWIDTH)*k+4],
              fmem[(`AXIWIDTH/`DWIDTH)*k+3],fmem[(`AXIWIDTH/`DWIDTH)*k+2],fmem[(`AXIWIDTH/`DWIDTH)*k+1],fmem[(`AXIWIDTH/`DWIDTH)*k+0]};
I_feature_dv <= 1'b1;
end//posedge
end//for
@(posedge I_clk)
I_feature_dv <= 1'b0;

//#4905
#4885
$readmemh("/home/cqiu/AIPrj/sim/sim_cnnly/tb/btc/qst_vrd_nuvm_vvd1602_nhls_tc1_cnnly/line1_k2_feature.txt",fmem,0,`LAYER_KX*`LAYER_OWIDTH*(`AXIWIDTH/`DWIDTH));
for (k=0; k<(`LAYER_KX*`LAYER_OWIDTH); k=k+1)
begin
@(posedge I_clk)
begin
I_feature <= {fmem[(`AXIWIDTH/`DWIDTH)*k+15],fmem[(`AXIWIDTH/`DWIDTH)*k+14],fmem[(`AXIWIDTH/`DWIDTH)*k+13],fmem[(`AXIWIDTH/`DWIDTH)*k+12],
              fmem[(`AXIWIDTH/`DWIDTH)*k+11],fmem[(`AXIWIDTH/`DWIDTH)*k+10],fmem[(`AXIWIDTH/`DWIDTH)*k+9],fmem[(`AXIWIDTH/`DWIDTH)*k+8],
              fmem[(`AXIWIDTH/`DWIDTH)*k+7],fmem[(`AXIWIDTH/`DWIDTH)*k+6],fmem[(`AXIWIDTH/`DWIDTH)*k+5],fmem[(`AXIWIDTH/`DWIDTH)*k+4],
              fmem[(`AXIWIDTH/`DWIDTH)*k+3],fmem[(`AXIWIDTH/`DWIDTH)*k+2],fmem[(`AXIWIDTH/`DWIDTH)*k+1],fmem[(`AXIWIDTH/`DWIDTH)*k+0]};
I_feature_dv <= 1'b1;
end//posedge
end//for
@(posedge I_clk)
I_feature_dv <= 1'b0;
end


reg     [8:0]     S_rd_depth    = -1;
reg               S_rd_en       = 0;
wire    [128*8-1:0] S_fout           ;
wire              S_fdv            ;
wire    [127:0]   O_cnv_data;
wire              O_cnv_dv;
wire    [31:0]    O_wr_DDRaddr;

initial begin
#30105
repeat(84)begin
    @(posedge I_clk)
    S_rd_depth <= S_rd_depth +1;
    S_rd_en <= 1'b1;
end//repeat
#1
@(posedge I_clk)
S_rd_en <= 1'b0;
end


top#(
    .AXIWIDTH        (128),
    .LITEWIDTH       (32),
    .CH_IN           (16),
    .DWIDTH          (8),
    .CH_OUT          (32),
    .PIX             (8),
    .ADD_WIDTH       (19),
    .LAYERWIDTH      (8),
    .KWIDTH          (4),
    .COWIDTH         (10),
    .DEPTHWIDTH      (9),
    .W_WIDTH         (10),
    .SWIDTH          (2),
    .PWIDTH          (2),
    .IEMEM_1ADOT     (16)
)top_inst(
    .I_clk           (I_clk),
    .I_rst           (I_rst),
    .I_feature       (feature_in),
    .I_feature_dv    (feature_dv),
    
    .I_layer_num     (I_layer_num),
    .I_feature_base_addr(I_feature_base_addr),
    .I_ci_num        (I_ci_num),
    .I_co_num        (I_co_num),
    .I_kx_num        (`LAYER_KX),
//    .I_ky_num        (`LAYER_KY),
    .I_iheight       (224),
    .I_iwidth        (224),
    .I_oheight       (224),
    .I_kernel_h      (3),
    .I_stride_h      (1),
    .I_pad_h         (1),
    .I_owidth_num    (`LAYER_OWIDTH),
    .I_ap_start      (I_ap_start),
    .I_weight        (I_weight),
    .I_weight_dv     (I_weight_dv),
    .I_bias          (I_bias),
    .I_bias_dv       (I_bias_dv),
//    .I_ky            (I_ky),
    .O_result_0      (O_result_0),
    .O_result_1      (O_result_1),
    .O_data_dv       (),
    .O_macc_data     (O_macc_data),
    .O_dram_feature_rd_flag (S_dram_feature_rd_flag),
    .O_cnv_data      (O_cnv_data),
    .O_cnv_dv        (O_cnv_dv),
    .O_wr_DDRaddr    (O_wr_DDRaddr)
    );
    
    reg [127:0]   S_obuf [1023:0];
    initial begin
    #17755
    repeat (910)
    begin
    @(posedge I_clk)
    begin
        if (O_cnv_dv)
            S_obuf[O_wr_DDRaddr-32'h20000000] <= O_cnv_data;
    end
    end
    end
    
    reg [31:0]    test_wr_out_addr;
    reg [127:0]   test_data_out;
    integer fp_test_wr;
    
    initial begin
    #26895
    test_wr_out_addr=0;
    test_data_out=0;
    @(posedge I_clk)
    repeat(896)begin
    @(posedge I_clk)
    begin
        test_data_out <= S_obuf[test_wr_out_addr];
        test_wr_out_addr <= test_wr_out_addr + 1;
    end
    end
    end
    
    initial begin
    fp_test_wr = $fopen("final_dataOut.txt","w");
    #26910
    repeat(896) begin

    @(posedge I_clk)
    begin
    $fwrite(fp_test_wr,"%8d%8d%8d%8d%8d%8d%8d%8d%8d%8d%8d%8d%8d%8d%8d%8d\n",
             $signed(test_data_out[8*0+:8]),$signed(test_data_out[8*1+:8]),
             $signed(test_data_out[8*2+:8]),$signed(test_data_out[8*3+:8]),
             $signed(test_data_out[8*4+:8]),$signed(test_data_out[8*5+:8]),
             $signed(test_data_out[8*6+:8]),$signed(test_data_out[8*7+:8]),
             $signed(test_data_out[8*8+:8]),$signed(test_data_out[8*9+:8]),
             $signed(test_data_out[8*10+:8]),$signed(test_data_out[8*11+:8]),
             $signed(test_data_out[8*12+:8]),$signed(test_data_out[8*13+:8]),
             $signed(test_data_out[8*14+:8]),$signed(test_data_out[8*15+:8]));
    end
    end//repeat
    end
    
    
    
    
    
    
    
    
    
    
    
    
    

reg  [6143:0]  S_result0_d1=0;
reg  [6143:0]  S_result0_d2=0;
reg  [6143:0]  S_result0_d3=0;
initial begin
forever begin
    @(posedge I_clk) begin
        S_result0_d1 <= O_result_0;
        S_result0_d2 <= S_result0_d1;
        S_result0_d3 <= S_result0_d2;
    end
end
end


integer fp_w;
integer cog,wog;
initial begin
fp_w = $fopen("dataOut.txt","w");
cog=0;
wog=0;
//#10010//k345
#17750//k678
repeat(`LAYER_OWIDTH/`PIX) begin

@(posedge I_clk) begin

$display("wog =%d, pix = 0",wog);
$display("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
         $signed(O_result_0[24*0+:24]),$signed(O_result_0[24*1+:24]),
         $signed(O_result_0[24*2+:24]),$signed(O_result_0[24*3+:24]),
         $signed(O_result_0[24*4+:24]),$signed(O_result_0[24*5+:24]),
         $signed(O_result_0[24*6+:24]),$signed(O_result_0[24*7+:24]),
         $signed(O_result_0[24*8+:24]),$signed(O_result_0[24*9+:24]),
         $signed(O_result_0[24*10+:24]),$signed(O_result_0[24*11+:24]),
         $signed(O_result_0[24*12+:24]),$signed(O_result_0[24*13+:24]),
         $signed(O_result_0[24*14+:24]),$signed(O_result_0[24*15+:24]),
         $signed(O_result_0[24*16+:24]),$signed(O_result_0[24*17+:24]),
         $signed(O_result_0[24*18+:24]),$signed(O_result_0[24*19+:24]),
         $signed(O_result_0[24*20+:24]),$signed(O_result_0[24*21+:24]),
         $signed(O_result_0[24*22+:24]),$signed(O_result_0[24*23+:24]),
         $signed(O_result_0[24*24+:24]),$signed(O_result_0[24*25+:24]),
         $signed(O_result_0[24*26+:24]),$signed(O_result_0[24*27+:24]),
         $signed(O_result_0[24*28+:24]),$signed(O_result_0[24*29+:24]),
         $signed(O_result_0[24*30+:24]),$signed(O_result_0[24*31+:24]));
         
$fwrite(fp_w,"%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d",
         $signed(S_result0_d1[24*0+:24]),$signed(S_result0_d1[24*1+:24]),
         $signed(S_result0_d1[24*2+:24]),$signed(S_result0_d1[24*3+:24]),
         $signed(S_result0_d1[24*4+:24]),$signed(S_result0_d1[24*5+:24]),
         $signed(S_result0_d1[24*6+:24]),$signed(S_result0_d1[24*7+:24]),
         $signed(S_result0_d1[24*8+:24]),$signed(S_result0_d1[24*9+:24]),
         $signed(S_result0_d1[24*10+:24]),$signed(S_result0_d1[24*11+:24]),
         $signed(S_result0_d1[24*12+:24]),$signed(S_result0_d1[24*13+:24]),
         $signed(S_result0_d1[24*14+:24]),$signed(S_result0_d1[24*15+:24]),
         $signed(S_result0_d1[24*16+:24]),$signed(S_result0_d1[24*17+:24]),
         $signed(S_result0_d1[24*18+:24]),$signed(S_result0_d1[24*19+:24]),
         $signed(S_result0_d1[24*20+:24]),$signed(S_result0_d1[24*21+:24]),
         $signed(S_result0_d1[24*22+:24]),$signed(S_result0_d1[24*23+:24]),
         $signed(S_result0_d1[24*24+:24]),$signed(S_result0_d1[24*25+:24]),
         $signed(S_result0_d1[24*26+:24]),$signed(S_result0_d1[24*27+:24]),
         $signed(S_result0_d1[24*28+:24]),$signed(S_result0_d1[24*29+:24]),
         $signed(S_result0_d1[24*30+:24]),$signed(S_result0_d1[24*31+:24]));
                  
$display("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
         $signed(O_result_1[24*0+:24]),$signed(O_result_1[24*1+:24]),
         $signed(O_result_1[24*2+:24]),$signed(O_result_1[24*3+:24]),
         $signed(O_result_1[24*4+:24]),$signed(O_result_1[24*5+:24]),
         $signed(O_result_1[24*6+:24]),$signed(O_result_1[24*7+:24]),
         $signed(O_result_1[24*8+:24]),$signed(O_result_1[24*9+:24]),
         $signed(O_result_1[24*10+:24]),$signed(O_result_1[24*11+:24]),
         $signed(O_result_1[24*12+:24]),$signed(O_result_1[24*13+:24]),
         $signed(O_result_1[24*14+:24]),$signed(O_result_1[24*15+:24]),
         $signed(O_result_1[24*16+:24]),$signed(O_result_1[24*17+:24]),
         $signed(O_result_1[24*18+:24]),$signed(O_result_1[24*19+:24]),
         $signed(O_result_1[24*20+:24]),$signed(O_result_1[24*21+:24]),
         $signed(O_result_1[24*22+:24]),$signed(O_result_1[24*23+:24]),
         $signed(O_result_1[24*24+:24]),$signed(O_result_1[24*25+:24]),
         $signed(O_result_1[24*26+:24]),$signed(O_result_1[24*27+:24]),
         $signed(O_result_1[24*28+:24]),$signed(O_result_1[24*29+:24]),
         $signed(O_result_1[24*30+:24]),$signed(O_result_1[24*31+:24]));
 
$fwrite(fp_w,"%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d\n",
         $signed(O_result_1[24*0+:24]),$signed(O_result_1[24*1+:24]),
         $signed(O_result_1[24*2+:24]),$signed(O_result_1[24*3+:24]),
         $signed(O_result_1[24*4+:24]),$signed(O_result_1[24*5+:24]),
         $signed(O_result_1[24*6+:24]),$signed(O_result_1[24*7+:24]),
         $signed(O_result_1[24*8+:24]),$signed(O_result_1[24*9+:24]),
         $signed(O_result_1[24*10+:24]),$signed(O_result_1[24*11+:24]),
         $signed(O_result_1[24*12+:24]),$signed(O_result_1[24*13+:24]),
         $signed(O_result_1[24*14+:24]),$signed(O_result_1[24*15+:24]),
         $signed(O_result_1[24*16+:24]),$signed(O_result_1[24*17+:24]),
         $signed(O_result_1[24*18+:24]),$signed(O_result_1[24*19+:24]),
         $signed(O_result_1[24*20+:24]),$signed(O_result_1[24*21+:24]),
         $signed(O_result_1[24*22+:24]),$signed(O_result_1[24*23+:24]),
         $signed(O_result_1[24*24+:24]),$signed(O_result_1[24*25+:24]),
         $signed(O_result_1[24*26+:24]),$signed(O_result_1[24*27+:24]),
         $signed(O_result_1[24*28+:24]),$signed(O_result_1[24*29+:24]),
         $signed(O_result_1[24*30+:24]),$signed(O_result_1[24*31+:24]));	

	
$display("wog =%d, pix = 1",wog);
$display("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
         $signed(O_result_0[24*32+:24]),$signed(O_result_0[24*33+:24]),
         $signed(O_result_0[24*34+:24]),$signed(O_result_0[24*35+:24]),
         $signed(O_result_0[24*36+:24]),$signed(O_result_0[24*37+:24]),
         $signed(O_result_0[24*38+:24]),$signed(O_result_0[24*39+:24]),
         $signed(O_result_0[24*40+:24]),$signed(O_result_0[24*41+:24]),
         $signed(O_result_0[24*42+:24]),$signed(O_result_0[24*43+:24]),
         $signed(O_result_0[24*44+:24]),$signed(O_result_0[24*45+:24]),
         $signed(O_result_0[24*46+:24]),$signed(O_result_0[24*47+:24]),
         $signed(O_result_0[24*48+:24]),$signed(O_result_0[24*49+:24]),
         $signed(O_result_0[24*50+:24]),$signed(O_result_0[24*51+:24]),
         $signed(O_result_0[24*52+:24]),$signed(O_result_0[24*53+:24]),
         $signed(O_result_0[24*54+:24]),$signed(O_result_0[24*55+:24]),
         $signed(O_result_0[24*56+:24]),$signed(O_result_0[24*57+:24]),
         $signed(O_result_0[24*58+:24]),$signed(O_result_0[24*59+:24]),
         $signed(O_result_0[24*60+:24]),$signed(O_result_0[24*61+:24]),
         $signed(O_result_0[24*62+:24]),$signed(O_result_0[24*63+:24]));
                
$fwrite(fp_w,"%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d",
         $signed(S_result0_d1[24*32+:24]),$signed(S_result0_d1[24*33+:24]),
         $signed(S_result0_d1[24*34+:24]),$signed(S_result0_d1[24*35+:24]),
         $signed(S_result0_d1[24*36+:24]),$signed(S_result0_d1[24*37+:24]),
         $signed(S_result0_d1[24*38+:24]),$signed(S_result0_d1[24*39+:24]),
         $signed(S_result0_d1[24*40+:24]),$signed(S_result0_d1[24*41+:24]),
         $signed(S_result0_d1[24*42+:24]),$signed(S_result0_d1[24*43+:24]),
         $signed(S_result0_d1[24*44+:24]),$signed(S_result0_d1[24*45+:24]),
         $signed(S_result0_d1[24*46+:24]),$signed(S_result0_d1[24*47+:24]),
         $signed(S_result0_d1[24*48+:24]),$signed(S_result0_d1[24*49+:24]),
         $signed(S_result0_d1[24*50+:24]),$signed(S_result0_d1[24*51+:24]),
         $signed(S_result0_d1[24*52+:24]),$signed(S_result0_d1[24*53+:24]),
         $signed(S_result0_d1[24*54+:24]),$signed(S_result0_d1[24*55+:24]),
         $signed(S_result0_d1[24*56+:24]),$signed(S_result0_d1[24*57+:24]),
         $signed(S_result0_d1[24*58+:24]),$signed(S_result0_d1[24*59+:24]),
         $signed(S_result0_d1[24*60+:24]),$signed(S_result0_d1[24*61+:24]),
         $signed(S_result0_d1[24*62+:24]),$signed(S_result0_d1[24*63+:24]));
                                   
	
$display("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
         $signed(O_result_1[24*32+:24]),$signed(O_result_1[24*33+:24]),
         $signed(O_result_1[24*34+:24]),$signed(O_result_1[24*35+:24]),
         $signed(O_result_1[24*36+:24]),$signed(O_result_1[24*37+:24]),
         $signed(O_result_1[24*38+:24]),$signed(O_result_1[24*39+:24]),
         $signed(O_result_1[24*40+:24]),$signed(O_result_1[24*41+:24]),
         $signed(O_result_1[24*42+:24]),$signed(O_result_1[24*43+:24]),
         $signed(O_result_1[24*44+:24]),$signed(O_result_1[24*45+:24]),
         $signed(O_result_1[24*46+:24]),$signed(O_result_1[24*47+:24]),
         $signed(O_result_1[24*48+:24]),$signed(O_result_1[24*49+:24]),
         $signed(O_result_1[24*50+:24]),$signed(O_result_1[24*51+:24]),
         $signed(O_result_1[24*52+:24]),$signed(O_result_1[24*53+:24]),
         $signed(O_result_1[24*54+:24]),$signed(O_result_1[24*55+:24]),
         $signed(O_result_1[24*56+:24]),$signed(O_result_1[24*57+:24]),
         $signed(O_result_1[24*58+:24]),$signed(O_result_1[24*59+:24]),
         $signed(O_result_1[24*60+:24]),$signed(O_result_1[24*61+:24]),
         $signed(O_result_1[24*62+:24]),$signed(O_result_1[24*63+:24]));            

$fwrite(fp_w,"%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d\n",
         $signed(O_result_1[24*32+:24]),$signed(O_result_1[24*33+:24]),
         $signed(O_result_1[24*34+:24]),$signed(O_result_1[24*35+:24]),
         $signed(O_result_1[24*36+:24]),$signed(O_result_1[24*37+:24]),
         $signed(O_result_1[24*38+:24]),$signed(O_result_1[24*39+:24]),
         $signed(O_result_1[24*40+:24]),$signed(O_result_1[24*41+:24]),
         $signed(O_result_1[24*42+:24]),$signed(O_result_1[24*43+:24]),
         $signed(O_result_1[24*44+:24]),$signed(O_result_1[24*45+:24]),
         $signed(O_result_1[24*46+:24]),$signed(O_result_1[24*47+:24]),
         $signed(O_result_1[24*48+:24]),$signed(O_result_1[24*49+:24]),
         $signed(O_result_1[24*50+:24]),$signed(O_result_1[24*51+:24]),
         $signed(O_result_1[24*52+:24]),$signed(O_result_1[24*53+:24]),
         $signed(O_result_1[24*54+:24]),$signed(O_result_1[24*55+:24]),
         $signed(O_result_1[24*56+:24]),$signed(O_result_1[24*57+:24]),
         $signed(O_result_1[24*58+:24]),$signed(O_result_1[24*59+:24]),
         $signed(O_result_1[24*60+:24]),$signed(O_result_1[24*61+:24]),
         $signed(O_result_1[24*62+:24]),$signed(O_result_1[24*63+:24]));
	
	
$display("wog =%d, pix = 2",wog);
$display("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
         $signed(O_result_0[24*64+:24]),$signed(O_result_0[24*65+:24]),
         $signed(O_result_0[24*66+:24]),$signed(O_result_0[24*67+:24]),
         $signed(O_result_0[24*68+:24]),$signed(O_result_0[24*69+:24]),
         $signed(O_result_0[24*70+:24]),$signed(O_result_0[24*71+:24]),
         $signed(O_result_0[24*72+:24]),$signed(O_result_0[24*73+:24]),
         $signed(O_result_0[24*74+:24]),$signed(O_result_0[24*75+:24]),
         $signed(O_result_0[24*76+:24]),$signed(O_result_0[24*77+:24]),
         $signed(O_result_0[24*78+:24]),$signed(O_result_0[24*79+:24]),
         $signed(O_result_0[24*80+:24]),$signed(O_result_0[24*81+:24]),
         $signed(O_result_0[24*82+:24]),$signed(O_result_0[24*83+:24]),
         $signed(O_result_0[24*84+:24]),$signed(O_result_0[24*85+:24]),
         $signed(O_result_0[24*86+:24]),$signed(O_result_0[24*87+:24]),
         $signed(O_result_0[24*88+:24]),$signed(O_result_0[24*89+:24]),
         $signed(O_result_0[24*90+:24]),$signed(O_result_0[24*91+:24]),
         $signed(O_result_0[24*92+:24]),$signed(O_result_0[24*93+:24]),
         $signed(O_result_0[24*94+:24]),$signed(O_result_0[24*95+:24]));

$fwrite(fp_w,"%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d",
         $signed(S_result0_d1[24*64+:24]),$signed(S_result0_d1[24*65+:24]),
         $signed(S_result0_d1[24*66+:24]),$signed(S_result0_d1[24*67+:24]),
         $signed(S_result0_d1[24*68+:24]),$signed(S_result0_d1[24*69+:24]),
         $signed(S_result0_d1[24*70+:24]),$signed(S_result0_d1[24*71+:24]),
         $signed(S_result0_d1[24*72+:24]),$signed(S_result0_d1[24*73+:24]),
         $signed(S_result0_d1[24*74+:24]),$signed(S_result0_d1[24*75+:24]),
         $signed(S_result0_d1[24*76+:24]),$signed(S_result0_d1[24*77+:24]),
         $signed(S_result0_d1[24*78+:24]),$signed(S_result0_d1[24*79+:24]),
         $signed(S_result0_d1[24*80+:24]),$signed(S_result0_d1[24*81+:24]),
         $signed(S_result0_d1[24*82+:24]),$signed(S_result0_d1[24*83+:24]),
         $signed(S_result0_d1[24*84+:24]),$signed(S_result0_d1[24*85+:24]),
         $signed(S_result0_d1[24*86+:24]),$signed(S_result0_d1[24*87+:24]),
         $signed(S_result0_d1[24*88+:24]),$signed(S_result0_d1[24*89+:24]),
         $signed(S_result0_d1[24*90+:24]),$signed(S_result0_d1[24*91+:24]),
         $signed(S_result0_d1[24*92+:24]),$signed(S_result0_d1[24*93+:24]),
         $signed(S_result0_d1[24*94+:24]),$signed(S_result0_d1[24*95+:24]));
	
	
	
	$display("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
         $signed(O_result_1[24*64+:24]),$signed(O_result_1[24*65+:24]),
         $signed(O_result_1[24*66+:24]),$signed(O_result_1[24*67+:24]),
         $signed(O_result_1[24*68+:24]),$signed(O_result_1[24*69+:24]),
         $signed(O_result_1[24*70+:24]),$signed(O_result_1[24*71+:24]),
         $signed(O_result_1[24*72+:24]),$signed(O_result_1[24*73+:24]),
         $signed(O_result_1[24*74+:24]),$signed(O_result_1[24*75+:24]),
         $signed(O_result_1[24*76+:24]),$signed(O_result_1[24*77+:24]),
         $signed(O_result_1[24*78+:24]),$signed(O_result_1[24*79+:24]),
         $signed(O_result_1[24*80+:24]),$signed(O_result_1[24*81+:24]),
         $signed(O_result_1[24*82+:24]),$signed(O_result_1[24*83+:24]),
         $signed(O_result_1[24*84+:24]),$signed(O_result_1[24*85+:24]),
         $signed(O_result_1[24*86+:24]),$signed(O_result_1[24*87+:24]),
         $signed(O_result_1[24*88+:24]),$signed(O_result_1[24*89+:24]),
         $signed(O_result_1[24*90+:24]),$signed(O_result_1[24*91+:24]),
         $signed(O_result_1[24*92+:24]),$signed(O_result_1[24*93+:24]),
         $signed(O_result_1[24*94+:24]),$signed(O_result_1[24*95+:24]));
         
$fwrite(fp_w,"%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d\n",
         $signed(O_result_1[24*64+:24]),$signed(O_result_1[24*65+:24]),
         $signed(O_result_1[24*66+:24]),$signed(O_result_1[24*67+:24]),
         $signed(O_result_1[24*68+:24]),$signed(O_result_1[24*69+:24]),
         $signed(O_result_1[24*70+:24]),$signed(O_result_1[24*71+:24]),
         $signed(O_result_1[24*72+:24]),$signed(O_result_1[24*73+:24]),
         $signed(O_result_1[24*74+:24]),$signed(O_result_1[24*75+:24]),
         $signed(O_result_1[24*76+:24]),$signed(O_result_1[24*77+:24]),
         $signed(O_result_1[24*78+:24]),$signed(O_result_1[24*79+:24]),
         $signed(O_result_1[24*80+:24]),$signed(O_result_1[24*81+:24]),
         $signed(O_result_1[24*82+:24]),$signed(O_result_1[24*83+:24]),
         $signed(O_result_1[24*84+:24]),$signed(O_result_1[24*85+:24]),
         $signed(O_result_1[24*86+:24]),$signed(O_result_1[24*87+:24]),
         $signed(O_result_1[24*88+:24]),$signed(O_result_1[24*89+:24]),
         $signed(O_result_1[24*90+:24]),$signed(O_result_1[24*91+:24]),
         $signed(O_result_1[24*92+:24]),$signed(O_result_1[24*93+:24]),
         $signed(O_result_1[24*94+:24]),$signed(O_result_1[24*95+:24]));
	
	
$display("wog =%d, pix = 3",wog);
$display("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
         $signed(O_result_0[24*96+:24]),$signed(O_result_0[24*97+:24]),
         $signed(O_result_0[24*98+:24]),$signed(O_result_0[24*99+:24]),
         $signed(O_result_0[24*100+:24]),$signed(O_result_0[24*101+:24]),
         $signed(O_result_0[24*102+:24]),$signed(O_result_0[24*103+:24]),
         $signed(O_result_0[24*104+:24]),$signed(O_result_0[24*105+:24]),
         $signed(O_result_0[24*106+:24]),$signed(O_result_0[24*107+:24]),
         $signed(O_result_0[24*108+:24]),$signed(O_result_0[24*109+:24]),
         $signed(O_result_0[24*110+:24]),$signed(O_result_0[24*111+:24]),
         $signed(O_result_0[24*112+:24]),$signed(O_result_0[24*113+:24]),
         $signed(O_result_0[24*114+:24]),$signed(O_result_0[24*115+:24]),
         $signed(O_result_0[24*116+:24]),$signed(O_result_0[24*117+:24]),
         $signed(O_result_0[24*118+:24]),$signed(O_result_0[24*119+:24]),
         $signed(O_result_0[24*120+:24]),$signed(O_result_0[24*121+:24]),
         $signed(O_result_0[24*122+:24]),$signed(O_result_0[24*123+:24]),
         $signed(O_result_0[24*124+:24]),$signed(O_result_0[24*125+:24]),
         $signed(O_result_0[24*126+:24]),$signed(O_result_0[24*127+:24]));         

$fwrite(fp_w,"%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d",
         $signed(S_result0_d1[24*96+:24]),$signed(S_result0_d1[24*97+:24]),
         $signed(S_result0_d1[24*98+:24]),$signed(S_result0_d1[24*99+:24]),
         $signed(S_result0_d1[24*100+:24]),$signed(S_result0_d1[24*101+:24]),
         $signed(S_result0_d1[24*102+:24]),$signed(S_result0_d1[24*103+:24]),
         $signed(S_result0_d1[24*104+:24]),$signed(S_result0_d1[24*105+:24]),
         $signed(S_result0_d1[24*106+:24]),$signed(S_result0_d1[24*107+:24]),
         $signed(S_result0_d1[24*108+:24]),$signed(S_result0_d1[24*109+:24]),
         $signed(S_result0_d1[24*110+:24]),$signed(S_result0_d1[24*111+:24]),
         $signed(S_result0_d1[24*112+:24]),$signed(S_result0_d1[24*113+:24]),
         $signed(S_result0_d1[24*114+:24]),$signed(S_result0_d1[24*115+:24]),
         $signed(S_result0_d1[24*116+:24]),$signed(S_result0_d1[24*117+:24]),
         $signed(S_result0_d1[24*118+:24]),$signed(S_result0_d1[24*119+:24]),
         $signed(S_result0_d1[24*120+:24]),$signed(S_result0_d1[24*121+:24]),
         $signed(S_result0_d1[24*122+:24]),$signed(S_result0_d1[24*123+:24]),
         $signed(S_result0_d1[24*124+:24]),$signed(S_result0_d1[24*125+:24]),
         $signed(S_result0_d1[24*126+:24]),$signed(S_result0_d1[24*127+:24])); 

	
	$display("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
         $signed(O_result_1[24*96+:24]),$signed(O_result_1[24*97+:24]),
         $signed(O_result_1[24*98+:24]),$signed(O_result_1[24*99+:24]),
         $signed(O_result_1[24*100+:24]),$signed(O_result_1[24*101+:24]),
         $signed(O_result_1[24*102+:24]),$signed(O_result_1[24*103+:24]),
         $signed(O_result_1[24*104+:24]),$signed(O_result_1[24*105+:24]),
         $signed(O_result_1[24*106+:24]),$signed(O_result_1[24*107+:24]),
         $signed(O_result_1[24*108+:24]),$signed(O_result_1[24*109+:24]),
         $signed(O_result_1[24*110+:24]),$signed(O_result_1[24*111+:24]),
         $signed(O_result_1[24*112+:24]),$signed(O_result_1[24*113+:24]),
         $signed(O_result_1[24*114+:24]),$signed(O_result_1[24*115+:24]),
         $signed(O_result_1[24*116+:24]),$signed(O_result_1[24*117+:24]),
         $signed(O_result_1[24*118+:24]),$signed(O_result_1[24*119+:24]),
         $signed(O_result_1[24*120+:24]),$signed(O_result_1[24*121+:24]),
         $signed(O_result_1[24*122+:24]),$signed(O_result_1[24*123+:24]),
         $signed(O_result_1[24*124+:24]),$signed(O_result_1[24*125+:24]),
         $signed(O_result_1[24*126+:24]),$signed(O_result_1[24*127+:24]));  

$fwrite(fp_w,"%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d\n",
         $signed(O_result_1[24*96+:24]),$signed(O_result_1[24*97+:24]),
         $signed(O_result_1[24*98+:24]),$signed(O_result_1[24*99+:24]),
         $signed(O_result_1[24*100+:24]),$signed(O_result_1[24*101+:24]),
         $signed(O_result_1[24*102+:24]),$signed(O_result_1[24*103+:24]),
         $signed(O_result_1[24*104+:24]),$signed(O_result_1[24*105+:24]),
         $signed(O_result_1[24*106+:24]),$signed(O_result_1[24*107+:24]),
         $signed(O_result_1[24*108+:24]),$signed(O_result_1[24*109+:24]),
         $signed(O_result_1[24*110+:24]),$signed(O_result_1[24*111+:24]),
         $signed(O_result_1[24*112+:24]),$signed(O_result_1[24*113+:24]),
         $signed(O_result_1[24*114+:24]),$signed(O_result_1[24*115+:24]),
         $signed(O_result_1[24*116+:24]),$signed(O_result_1[24*117+:24]),
         $signed(O_result_1[24*118+:24]),$signed(O_result_1[24*119+:24]),
         $signed(O_result_1[24*120+:24]),$signed(O_result_1[24*121+:24]),
         $signed(O_result_1[24*122+:24]),$signed(O_result_1[24*123+:24]),
         $signed(O_result_1[24*124+:24]),$signed(O_result_1[24*125+:24]),
         $signed(O_result_1[24*126+:24]),$signed(O_result_1[24*127+:24]));  
	
	
$display("wog =%d, pix = 4",wog);
$display("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
         $signed(O_result_0[24*128+:24]),$signed(O_result_0[24*129+:24]),
         $signed(O_result_0[24*130+:24]),$signed(O_result_0[24*131+:24]),
         $signed(O_result_0[24*132+:24]),$signed(O_result_0[24*133+:24]),
         $signed(O_result_0[24*134+:24]),$signed(O_result_0[24*135+:24]),
         $signed(O_result_0[24*136+:24]),$signed(O_result_0[24*137+:24]),
         $signed(O_result_0[24*138+:24]),$signed(O_result_0[24*139+:24]),
         $signed(O_result_0[24*140+:24]),$signed(O_result_0[24*141+:24]),
         $signed(O_result_0[24*142+:24]),$signed(O_result_0[24*143+:24]),
         $signed(O_result_0[24*144+:24]),$signed(O_result_0[24*145+:24]),
         $signed(O_result_0[24*146+:24]),$signed(O_result_0[24*147+:24]),
         $signed(O_result_0[24*148+:24]),$signed(O_result_0[24*149+:24]),
         $signed(O_result_0[24*150+:24]),$signed(O_result_0[24*151+:24]),
         $signed(O_result_0[24*152+:24]),$signed(O_result_0[24*153+:24]),
         $signed(O_result_0[24*154+:24]),$signed(O_result_0[24*155+:24]),
         $signed(O_result_0[24*156+:24]),$signed(O_result_0[24*157+:24]),
         $signed(O_result_0[24*158+:24]),$signed(O_result_0[24*159+:24]));

$fwrite(fp_w,"%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d",
         $signed(S_result0_d1[24*128+:24]),$signed(S_result0_d1[24*129+:24]),
         $signed(S_result0_d1[24*130+:24]),$signed(S_result0_d1[24*131+:24]),
         $signed(S_result0_d1[24*132+:24]),$signed(S_result0_d1[24*133+:24]),
         $signed(S_result0_d1[24*134+:24]),$signed(S_result0_d1[24*135+:24]),
         $signed(S_result0_d1[24*136+:24]),$signed(S_result0_d1[24*137+:24]),
         $signed(S_result0_d1[24*138+:24]),$signed(S_result0_d1[24*139+:24]),
         $signed(S_result0_d1[24*140+:24]),$signed(S_result0_d1[24*141+:24]),
         $signed(S_result0_d1[24*142+:24]),$signed(S_result0_d1[24*143+:24]),
         $signed(S_result0_d1[24*144+:24]),$signed(S_result0_d1[24*145+:24]),
         $signed(S_result0_d1[24*146+:24]),$signed(S_result0_d1[24*147+:24]),
         $signed(S_result0_d1[24*148+:24]),$signed(S_result0_d1[24*149+:24]),
         $signed(S_result0_d1[24*150+:24]),$signed(S_result0_d1[24*151+:24]),
         $signed(S_result0_d1[24*152+:24]),$signed(S_result0_d1[24*153+:24]),
         $signed(S_result0_d1[24*154+:24]),$signed(S_result0_d1[24*155+:24]),
         $signed(S_result0_d1[24*156+:24]),$signed(S_result0_d1[24*157+:24]),
         $signed(S_result0_d1[24*158+:24]),$signed(S_result0_d1[24*159+:24]));


	
	
$display("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
         $signed(O_result_1[24*128+:24]),$signed(O_result_1[24*129+:24]),
         $signed(O_result_1[24*130+:24]),$signed(O_result_1[24*131+:24]),
         $signed(O_result_1[24*132+:24]),$signed(O_result_1[24*133+:24]),
         $signed(O_result_1[24*134+:24]),$signed(O_result_1[24*135+:24]),
         $signed(O_result_1[24*136+:24]),$signed(O_result_1[24*137+:24]),
         $signed(O_result_1[24*138+:24]),$signed(O_result_1[24*139+:24]),
         $signed(O_result_1[24*140+:24]),$signed(O_result_1[24*141+:24]),
         $signed(O_result_1[24*142+:24]),$signed(O_result_1[24*143+:24]),
         $signed(O_result_1[24*144+:24]),$signed(O_result_1[24*145+:24]),
         $signed(O_result_1[24*146+:24]),$signed(O_result_1[24*147+:24]),
         $signed(O_result_1[24*148+:24]),$signed(O_result_1[24*149+:24]),
         $signed(O_result_1[24*150+:24]),$signed(O_result_1[24*151+:24]),
         $signed(O_result_1[24*152+:24]),$signed(O_result_1[24*153+:24]),
         $signed(O_result_1[24*154+:24]),$signed(O_result_1[24*155+:24]),
         $signed(O_result_1[24*156+:24]),$signed(O_result_1[24*157+:24]),
         $signed(O_result_1[24*158+:24]),$signed(O_result_1[24*159+:24]));

$fwrite(fp_w,"%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d\n",
         $signed(O_result_1[24*128+:24]),$signed(O_result_1[24*129+:24]),
         $signed(O_result_1[24*130+:24]),$signed(O_result_1[24*131+:24]),
         $signed(O_result_1[24*132+:24]),$signed(O_result_1[24*133+:24]),
         $signed(O_result_1[24*134+:24]),$signed(O_result_1[24*135+:24]),
         $signed(O_result_1[24*136+:24]),$signed(O_result_1[24*137+:24]),
         $signed(O_result_1[24*138+:24]),$signed(O_result_1[24*139+:24]),
         $signed(O_result_1[24*140+:24]),$signed(O_result_1[24*141+:24]),
         $signed(O_result_1[24*142+:24]),$signed(O_result_1[24*143+:24]),
         $signed(O_result_1[24*144+:24]),$signed(O_result_1[24*145+:24]),
         $signed(O_result_1[24*146+:24]),$signed(O_result_1[24*147+:24]),
         $signed(O_result_1[24*148+:24]),$signed(O_result_1[24*149+:24]),
         $signed(O_result_1[24*150+:24]),$signed(O_result_1[24*151+:24]),
         $signed(O_result_1[24*152+:24]),$signed(O_result_1[24*153+:24]),
         $signed(O_result_1[24*154+:24]),$signed(O_result_1[24*155+:24]),
         $signed(O_result_1[24*156+:24]),$signed(O_result_1[24*157+:24]),
         $signed(O_result_1[24*158+:24]),$signed(O_result_1[24*159+:24]));

	
	
$display("wog =%d, pix = 5",wog);
$display("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
         $signed(O_result_0[24*160+:24]),$signed(O_result_0[24*161+:24]),
         $signed(O_result_0[24*162+:24]),$signed(O_result_0[24*163+:24]),
         $signed(O_result_0[24*164+:24]),$signed(O_result_0[24*165+:24]),
         $signed(O_result_0[24*166+:24]),$signed(O_result_0[24*167+:24]),
         $signed(O_result_0[24*168+:24]),$signed(O_result_0[24*169+:24]),
         $signed(O_result_0[24*170+:24]),$signed(O_result_0[24*171+:24]),
         $signed(O_result_0[24*172+:24]),$signed(O_result_0[24*173+:24]),
         $signed(O_result_0[24*174+:24]),$signed(O_result_0[24*175+:24]),
         $signed(O_result_0[24*176+:24]),$signed(O_result_0[24*177+:24]),
         $signed(O_result_0[24*178+:24]),$signed(O_result_0[24*179+:24]),
         $signed(O_result_0[24*180+:24]),$signed(O_result_0[24*181+:24]),
         $signed(O_result_0[24*182+:24]),$signed(O_result_0[24*183+:24]),
         $signed(O_result_0[24*184+:24]),$signed(O_result_0[24*185+:24]),
         $signed(O_result_0[24*186+:24]),$signed(O_result_0[24*187+:24]),
         $signed(O_result_0[24*188+:24]),$signed(O_result_0[24*189+:24]),
         $signed(O_result_0[24*190+:24]),$signed(O_result_0[24*191+:24]));

$fwrite(fp_w,"%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d",
         $signed(S_result0_d1[24*160+:24]),$signed(S_result0_d1[24*161+:24]),
         $signed(S_result0_d1[24*162+:24]),$signed(S_result0_d1[24*163+:24]),
         $signed(S_result0_d1[24*164+:24]),$signed(S_result0_d1[24*165+:24]),
         $signed(S_result0_d1[24*166+:24]),$signed(S_result0_d1[24*167+:24]),
         $signed(S_result0_d1[24*168+:24]),$signed(S_result0_d1[24*169+:24]),
         $signed(S_result0_d1[24*170+:24]),$signed(S_result0_d1[24*171+:24]),
         $signed(S_result0_d1[24*172+:24]),$signed(S_result0_d1[24*173+:24]),
         $signed(S_result0_d1[24*174+:24]),$signed(S_result0_d1[24*175+:24]),
         $signed(S_result0_d1[24*176+:24]),$signed(S_result0_d1[24*177+:24]),
         $signed(S_result0_d1[24*178+:24]),$signed(S_result0_d1[24*179+:24]),
         $signed(S_result0_d1[24*180+:24]),$signed(S_result0_d1[24*181+:24]),
         $signed(S_result0_d1[24*182+:24]),$signed(S_result0_d1[24*183+:24]),
         $signed(S_result0_d1[24*184+:24]),$signed(S_result0_d1[24*185+:24]),
         $signed(S_result0_d1[24*186+:24]),$signed(S_result0_d1[24*187+:24]),
         $signed(S_result0_d1[24*188+:24]),$signed(S_result0_d1[24*189+:24]),
         $signed(S_result0_d1[24*190+:24]),$signed(S_result0_d1[24*191+:24]));

	
$display("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
         $signed(O_result_1[24*160+:24]),$signed(O_result_1[24*161+:24]),
         $signed(O_result_1[24*162+:24]),$signed(O_result_1[24*163+:24]),
         $signed(O_result_1[24*164+:24]),$signed(O_result_1[24*165+:24]),
         $signed(O_result_1[24*166+:24]),$signed(O_result_1[24*167+:24]),
         $signed(O_result_1[24*168+:24]),$signed(O_result_1[24*169+:24]),
         $signed(O_result_1[24*170+:24]),$signed(O_result_1[24*171+:24]),
         $signed(O_result_1[24*172+:24]),$signed(O_result_1[24*173+:24]),
         $signed(O_result_1[24*174+:24]),$signed(O_result_1[24*175+:24]),
         $signed(O_result_1[24*176+:24]),$signed(O_result_1[24*177+:24]),
         $signed(O_result_1[24*178+:24]),$signed(O_result_1[24*179+:24]),
         $signed(O_result_1[24*180+:24]),$signed(O_result_1[24*181+:24]),
         $signed(O_result_1[24*182+:24]),$signed(O_result_1[24*183+:24]),
         $signed(O_result_1[24*184+:24]),$signed(O_result_1[24*185+:24]),
         $signed(O_result_1[24*186+:24]),$signed(O_result_1[24*187+:24]),
         $signed(O_result_1[24*188+:24]),$signed(O_result_1[24*189+:24]),
         $signed(O_result_1[24*190+:24]),$signed(O_result_1[24*191+:24]));

$fwrite(fp_w,"%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d\n",
         $signed(O_result_1[24*160+:24]),$signed(O_result_1[24*161+:24]),
         $signed(O_result_1[24*162+:24]),$signed(O_result_1[24*163+:24]),
         $signed(O_result_1[24*164+:24]),$signed(O_result_1[24*165+:24]),
         $signed(O_result_1[24*166+:24]),$signed(O_result_1[24*167+:24]),
         $signed(O_result_1[24*168+:24]),$signed(O_result_1[24*169+:24]),
         $signed(O_result_1[24*170+:24]),$signed(O_result_1[24*171+:24]),
         $signed(O_result_1[24*172+:24]),$signed(O_result_1[24*173+:24]),
         $signed(O_result_1[24*174+:24]),$signed(O_result_1[24*175+:24]),
         $signed(O_result_1[24*176+:24]),$signed(O_result_1[24*177+:24]),
         $signed(O_result_1[24*178+:24]),$signed(O_result_1[24*179+:24]),
         $signed(O_result_1[24*180+:24]),$signed(O_result_1[24*181+:24]),
         $signed(O_result_1[24*182+:24]),$signed(O_result_1[24*183+:24]),
         $signed(O_result_1[24*184+:24]),$signed(O_result_1[24*185+:24]),
         $signed(O_result_1[24*186+:24]),$signed(O_result_1[24*187+:24]),
         $signed(O_result_1[24*188+:24]),$signed(O_result_1[24*189+:24]),
         $signed(O_result_1[24*190+:24]),$signed(O_result_1[24*191+:24]));

	
$display("wog =%d, pix = 6",wog);
$display("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
         $signed(O_result_0[24*192+:24]),$signed(O_result_0[24*193+:24]),
         $signed(O_result_0[24*194+:24]),$signed(O_result_0[24*195+:24]),
         $signed(O_result_0[24*196+:24]),$signed(O_result_0[24*197+:24]),
         $signed(O_result_0[24*198+:24]),$signed(O_result_0[24*199+:24]),
         $signed(O_result_0[24*200+:24]),$signed(O_result_0[24*201+:24]),
         $signed(O_result_0[24*202+:24]),$signed(O_result_0[24*203+:24]),
         $signed(O_result_0[24*204+:24]),$signed(O_result_0[24*205+:24]),
         $signed(O_result_0[24*206+:24]),$signed(O_result_0[24*207+:24]),
         $signed(O_result_0[24*208+:24]),$signed(O_result_0[24*209+:24]),
         $signed(O_result_0[24*210+:24]),$signed(O_result_0[24*211+:24]),
         $signed(O_result_0[24*212+:24]),$signed(O_result_0[24*213+:24]),
         $signed(O_result_0[24*214+:24]),$signed(O_result_0[24*215+:24]),
         $signed(O_result_0[24*216+:24]),$signed(O_result_0[24*217+:24]),
         $signed(O_result_0[24*218+:24]),$signed(O_result_0[24*219+:24]),
         $signed(O_result_0[24*220+:24]),$signed(O_result_0[24*221+:24]),
         $signed(O_result_0[24*222+:24]),$signed(O_result_0[24*223+:24]));

$fwrite(fp_w,"%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d",
         $signed(S_result0_d1[24*192+:24]),$signed(S_result0_d1[24*193+:24]),
         $signed(S_result0_d1[24*194+:24]),$signed(S_result0_d1[24*195+:24]),
         $signed(S_result0_d1[24*196+:24]),$signed(S_result0_d1[24*197+:24]),
         $signed(S_result0_d1[24*198+:24]),$signed(S_result0_d1[24*199+:24]),
         $signed(S_result0_d1[24*200+:24]),$signed(S_result0_d1[24*201+:24]),
         $signed(S_result0_d1[24*202+:24]),$signed(S_result0_d1[24*203+:24]),
         $signed(S_result0_d1[24*204+:24]),$signed(S_result0_d1[24*205+:24]),
         $signed(S_result0_d1[24*206+:24]),$signed(S_result0_d1[24*207+:24]),
         $signed(S_result0_d1[24*208+:24]),$signed(S_result0_d1[24*209+:24]),
         $signed(S_result0_d1[24*210+:24]),$signed(S_result0_d1[24*211+:24]),
         $signed(S_result0_d1[24*212+:24]),$signed(S_result0_d1[24*213+:24]),
         $signed(S_result0_d1[24*214+:24]),$signed(S_result0_d1[24*215+:24]),
         $signed(S_result0_d1[24*216+:24]),$signed(S_result0_d1[24*217+:24]),
         $signed(S_result0_d1[24*218+:24]),$signed(S_result0_d1[24*219+:24]),
         $signed(S_result0_d1[24*220+:24]),$signed(S_result0_d1[24*221+:24]),
         $signed(S_result0_d1[24*222+:24]),$signed(S_result0_d1[24*223+:24]));

	
	
$display("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
         $signed(O_result_1[24*192+:24]),$signed(O_result_1[24*193+:24]),
         $signed(O_result_1[24*194+:24]),$signed(O_result_1[24*195+:24]),
         $signed(O_result_1[24*196+:24]),$signed(O_result_1[24*197+:24]),
         $signed(O_result_1[24*198+:24]),$signed(O_result_1[24*199+:24]),
         $signed(O_result_1[24*200+:24]),$signed(O_result_1[24*201+:24]),
         $signed(O_result_1[24*202+:24]),$signed(O_result_1[24*203+:24]),
         $signed(O_result_1[24*204+:24]),$signed(O_result_1[24*205+:24]),
         $signed(O_result_1[24*206+:24]),$signed(O_result_1[24*207+:24]),
         $signed(O_result_1[24*208+:24]),$signed(O_result_1[24*209+:24]),
         $signed(O_result_1[24*210+:24]),$signed(O_result_1[24*211+:24]),
         $signed(O_result_1[24*212+:24]),$signed(O_result_1[24*213+:24]),
         $signed(O_result_1[24*214+:24]),$signed(O_result_1[24*215+:24]),
         $signed(O_result_1[24*216+:24]),$signed(O_result_1[24*217+:24]),
         $signed(O_result_1[24*218+:24]),$signed(O_result_1[24*219+:24]),
         $signed(O_result_1[24*220+:24]),$signed(O_result_1[24*221+:24]),
         $signed(O_result_1[24*222+:24]),$signed(O_result_1[24*223+:24]));

$fwrite(fp_w,"%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d\n",
         $signed(O_result_1[24*192+:24]),$signed(O_result_1[24*193+:24]),
         $signed(O_result_1[24*194+:24]),$signed(O_result_1[24*195+:24]),
         $signed(O_result_1[24*196+:24]),$signed(O_result_1[24*197+:24]),
         $signed(O_result_1[24*198+:24]),$signed(O_result_1[24*199+:24]),
         $signed(O_result_1[24*200+:24]),$signed(O_result_1[24*201+:24]),
         $signed(O_result_1[24*202+:24]),$signed(O_result_1[24*203+:24]),
         $signed(O_result_1[24*204+:24]),$signed(O_result_1[24*205+:24]),
         $signed(O_result_1[24*206+:24]),$signed(O_result_1[24*207+:24]),
         $signed(O_result_1[24*208+:24]),$signed(O_result_1[24*209+:24]),
         $signed(O_result_1[24*210+:24]),$signed(O_result_1[24*211+:24]),
         $signed(O_result_1[24*212+:24]),$signed(O_result_1[24*213+:24]),
         $signed(O_result_1[24*214+:24]),$signed(O_result_1[24*215+:24]),
         $signed(O_result_1[24*216+:24]),$signed(O_result_1[24*217+:24]),
         $signed(O_result_1[24*218+:24]),$signed(O_result_1[24*219+:24]),
         $signed(O_result_1[24*220+:24]),$signed(O_result_1[24*221+:24]),
         $signed(O_result_1[24*222+:24]),$signed(O_result_1[24*223+:24]));


	
$display("wog =%d, pix = 7",wog);
$display("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
         $signed(O_result_0[24*224+:24]),$signed(O_result_0[24*225+:24]),
         $signed(O_result_0[24*226+:24]),$signed(O_result_0[24*227+:24]),
         $signed(O_result_0[24*228+:24]),$signed(O_result_0[24*229+:24]),
         $signed(O_result_0[24*230+:24]),$signed(O_result_0[24*231+:24]),
         $signed(O_result_0[24*232+:24]),$signed(O_result_0[24*233+:24]),
         $signed(O_result_0[24*234+:24]),$signed(O_result_0[24*235+:24]),
         $signed(O_result_0[24*236+:24]),$signed(O_result_0[24*237+:24]),
         $signed(O_result_0[24*238+:24]),$signed(O_result_0[24*239+:24]),
         $signed(O_result_0[24*240+:24]),$signed(O_result_0[24*241+:24]),
         $signed(O_result_0[24*242+:24]),$signed(O_result_0[24*243+:24]),
         $signed(O_result_0[24*244+:24]),$signed(O_result_0[24*245+:24]),
         $signed(O_result_0[24*246+:24]),$signed(O_result_0[24*247+:24]),
         $signed(O_result_0[24*248+:24]),$signed(O_result_0[24*249+:24]),
         $signed(O_result_0[24*250+:24]),$signed(O_result_0[24*251+:24]),
         $signed(O_result_0[24*252+:24]),$signed(O_result_0[24*253+:24]),
         $signed(O_result_0[24*254+:24]),$signed(O_result_0[24*255+:24]));
         
$fwrite(fp_w,"%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d",
         $signed(S_result0_d1[24*224+:24]),$signed(S_result0_d1[24*225+:24]),
         $signed(S_result0_d1[24*226+:24]),$signed(S_result0_d1[24*227+:24]),
         $signed(S_result0_d1[24*228+:24]),$signed(S_result0_d1[24*229+:24]),
         $signed(S_result0_d1[24*230+:24]),$signed(S_result0_d1[24*231+:24]),
         $signed(S_result0_d1[24*232+:24]),$signed(S_result0_d1[24*233+:24]),
         $signed(S_result0_d1[24*234+:24]),$signed(S_result0_d1[24*235+:24]),
         $signed(S_result0_d1[24*236+:24]),$signed(S_result0_d1[24*237+:24]),
         $signed(S_result0_d1[24*238+:24]),$signed(S_result0_d1[24*239+:24]),
         $signed(S_result0_d1[24*240+:24]),$signed(S_result0_d1[24*241+:24]),
         $signed(S_result0_d1[24*242+:24]),$signed(S_result0_d1[24*243+:24]),
         $signed(S_result0_d1[24*244+:24]),$signed(S_result0_d1[24*245+:24]),
         $signed(S_result0_d1[24*246+:24]),$signed(S_result0_d1[24*247+:24]),
         $signed(S_result0_d1[24*248+:24]),$signed(S_result0_d1[24*249+:24]),
         $signed(S_result0_d1[24*250+:24]),$signed(S_result0_d1[24*251+:24]),
         $signed(S_result0_d1[24*252+:24]),$signed(S_result0_d1[24*253+:24]),
         $signed(S_result0_d1[24*254+:24]),$signed(S_result0_d1[24*255+:24]));

	
$display("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
         $signed(O_result_1[24*224+:24]),$signed(O_result_1[24*225+:24]),
         $signed(O_result_1[24*226+:24]),$signed(O_result_1[24*227+:24]),
         $signed(O_result_1[24*228+:24]),$signed(O_result_1[24*229+:24]),
         $signed(O_result_1[24*230+:24]),$signed(O_result_1[24*231+:24]),
         $signed(O_result_1[24*232+:24]),$signed(O_result_1[24*233+:24]),
         $signed(O_result_1[24*234+:24]),$signed(O_result_1[24*235+:24]),
         $signed(O_result_1[24*236+:24]),$signed(O_result_1[24*237+:24]),
         $signed(O_result_1[24*238+:24]),$signed(O_result_1[24*239+:24]),
         $signed(O_result_1[24*240+:24]),$signed(O_result_1[24*241+:24]),
         $signed(O_result_1[24*242+:24]),$signed(O_result_1[24*243+:24]),
         $signed(O_result_1[24*244+:24]),$signed(O_result_1[24*245+:24]),
         $signed(O_result_1[24*246+:24]),$signed(O_result_1[24*247+:24]),
         $signed(O_result_1[24*248+:24]),$signed(O_result_1[24*249+:24]),
         $signed(O_result_1[24*250+:24]),$signed(O_result_1[24*251+:24]),
         $signed(O_result_1[24*252+:24]),$signed(O_result_1[24*253+:24]),
         $signed(O_result_1[24*254+:24]),$signed(O_result_1[24*255+:24]));

$fwrite(fp_w,"%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d\n",
         $signed(O_result_1[24*224+:24]),$signed(O_result_1[24*225+:24]),
         $signed(O_result_1[24*226+:24]),$signed(O_result_1[24*227+:24]),
         $signed(O_result_1[24*228+:24]),$signed(O_result_1[24*229+:24]),
         $signed(O_result_1[24*230+:24]),$signed(O_result_1[24*231+:24]),
         $signed(O_result_1[24*232+:24]),$signed(O_result_1[24*233+:24]),
         $signed(O_result_1[24*234+:24]),$signed(O_result_1[24*235+:24]),
         $signed(O_result_1[24*236+:24]),$signed(O_result_1[24*237+:24]),
         $signed(O_result_1[24*238+:24]),$signed(O_result_1[24*239+:24]),
         $signed(O_result_1[24*240+:24]),$signed(O_result_1[24*241+:24]),
         $signed(O_result_1[24*242+:24]),$signed(O_result_1[24*243+:24]),
         $signed(O_result_1[24*244+:24]),$signed(O_result_1[24*245+:24]),
         $signed(O_result_1[24*246+:24]),$signed(O_result_1[24*247+:24]),
         $signed(O_result_1[24*248+:24]),$signed(O_result_1[24*249+:24]),
         $signed(O_result_1[24*250+:24]),$signed(O_result_1[24*251+:24]),
         $signed(O_result_1[24*252+:24]),$signed(O_result_1[24*253+:24]),
         $signed(O_result_1[24*254+:24]),$signed(O_result_1[24*255+:24]));
	
	
#60         
$display("~~~~~~~~~          ~~~~~~~~~          ~~~~~~~~~");         

if (cog==1)
    cog <= 'd0;
else 
    cog <= 'd1;
    
if (cog==1)
    wog <= wog+'d1;
         
end//clk
end//repeat
end

initial begin
	#30000 // 30 us
	@(posedge I_clk)//load layer0 weight
	$stop;
end

endmodule
