//----------------------------------------------------------------------------
//File Name    : lzw_backward_byte_reverse.v
//Author       : feng xiaoxiong
//----------------------------------------------------------------------------
//Module Hierarchy :
//xxx_inst |-lzw_backward_decompress_inst |-lzw_backward_byte_reverse_inst
//----------------------------------------------------------------------------
//Release History :
//Version         Date           Author        Description
// 1.0          2018-1-7     feng xiaoxiong    1st draft
//----------------------------------------------------------------------------
//Main Function:
//a)reverse payload data;
//----------------------------------------------------------------------------
module lzw_backward_byte_reverse(

input              I_sys_clk                     , ///system clock,250m clock                 ///
input              I_sys_rst                     , ///system reset,sync with 250m             ///
input              I_state_clr                   , ///clear state statistic                   ///
input       [ 7:0] I_dictionary_recv_data        , ///dictionary recv data                    ///  
input              I_dictionary_recv_data_en     , ///dictionary recv data_en                 ///
input              I_reverse_byte_flag           , ///reverse byte flag                       ///
input       [ 4:0] I_reverse_byte_num            , ///reverse byte num                        ///
input              I_reverse_byte_num_wren       , ///reverse byte num wren                   ///

output reg  [ 7:0] O_payload_data    =8'b0       , ///recovered payload data                  ///
output reg         O_payload_data_en =1'b0         ///recovered payload data en               ///
);

reg         [ 7:0] S_dictionary_recv_data        ;   
reg                S_dictionary_recv_data_en     ; 
reg                S_reverse_byte_flag           ; 
reg         [ 4:0] S_reverse_byte_num            ; 
reg                S_reverse_byte_num_wren       ; 
reg                S_clk_div2                    ;

reg         [ 4:0] S_para_fifo_wdata             ;
reg                S_para_fifo_wren              ;
reg                S_para_fifo_rden              ;
wire        [ 4:0] S_para_fifo_dout              ;
wire               S_para_fifo_full              ;
wire               S_para_fifo_empty             ;
wire        [ 9:0] S_para_fifo_data_count        ;
reg         [ 8:0] S_data_fifo_wdata             ;
reg                S_data_fifo_wren              ;
reg                S_data_fifo_rden              ;
wire        [ 8:0] S_data_fifo_dout              ;
wire               S_data_fifo_full              ;
wire               S_data_fifo_empty             ;
wire        [ 9:0] S_data_fifo_data_count        ;

wire        [4:0]  S_rd_rev_num                  ;
wire               S_rd_rev_flg                  ;
wire        [7:0]  S_rd_rev_data                 ;
reg         [4:0]  S_rd_rev_cnt                  ;
reg                S_data_fifo_rden_d1           ;
reg                S_data_fifo_rden_d2           ;
reg                S_data_fifo_rden_d3           ;
reg         [9:0]  S_ram_wr_addr                 ;
reg                S_ram_wr_en                   ;
reg         [7:0]  S_ram_wr_data                 ;

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_dictionary_recv_data    <= 8'h0;
        S_dictionary_recv_data_en <= 1'b0;
    end
    else 
    begin
        S_dictionary_recv_data    <= I_dictionary_recv_data   ;
        S_dictionary_recv_data_en <= I_dictionary_recv_data_en;
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_reverse_byte_flag       <= 1'b0;
        S_reverse_byte_num        <= 5'h0;
        S_reverse_byte_num_wren   <= 1'b0;
    end
    else 
    begin
        S_reverse_byte_flag       <= I_reverse_byte_flag      ;
        S_reverse_byte_num        <= I_reverse_byte_num       ;
        S_reverse_byte_num_wren   <= I_reverse_byte_num_wren  ;
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_para_fifo_wdata <= 5'h0;
        S_para_fifo_wren  <= 1'b0;
    end
    else
    begin
        S_para_fifo_wdata <= S_reverse_byte_num     ;
        S_para_fifo_wren  <= S_reverse_byte_num_wren;
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_data_fifo_wdata <= 9'h0;
        S_data_fifo_wren  <= 1'b0;
    end
    else
    begin
        S_data_fifo_wdata <= {S_reverse_byte_flag,S_dictionary_recv_data};
        S_data_fifo_wren  <= S_dictionary_recv_data_en;
    end
end

fifo_1k_5bit para_fifo (
  .clk        (I_sys_clk             ), // input wire clk
  .srst       (I_sys_rst             ), // input wire srst
  .din        (S_para_fifo_wdata     ), // input wire [4 : 0] din
  .wr_en      (S_para_fifo_wren      ), // input wire wr_en
  .rd_en      (S_para_fifo_rden      ), // input wire rd_en
  .dout       (S_para_fifo_dout      ), // output wire [4 : 0] dout
  .full       (S_para_fifo_full      ), // output wire full
  .empty      (S_para_fifo_empty     ), // output wire empty
  .data_count (S_para_fifo_data_count)  // output wire [9 : 0] data_count
);

fifo_1k_9bit data_fifo (
  .clk        (I_sys_clk             ), // input wire clk
  .srst       (I_sys_rst             ), // input wire srst
  .din        (S_data_fifo_wdata     ), // input wire [8 : 0] din
  .wr_en      (S_data_fifo_wren      ), // input wire wr_en
  .rd_en      (S_data_fifo_rden      ), // input wire rd_en
  .dout       (S_data_fifo_dout      ), // output wire [8 : 0] dout
  .full       (S_data_fifo_full      ), // output wire full
  .empty      (S_data_fifo_empty     ), // output wire empty
  .data_count (S_data_fifo_data_count)  // output wire [9 : 0] data_count
);

assign  S_rd_rev_num   = S_para_fifo_dout[4:0];
assign  S_rd_rev_flg   = S_data_fifo_dout[8]  ;
assign  S_rd_rev_data  = S_data_fifo_dout[7:0];

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_clk_div2 <= 1'b0;
    end
    else
    begin
        S_clk_div2 <= ~S_clk_div2;
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_data_fifo_rden <= 1'b0;
    end
    else if(S_clk_div2 && (S_data_fifo_data_count > 10'hff))
    begin
        S_data_fifo_rden <= 1'b1;
    end
    else
    begin
        S_data_fifo_rden <= 1'b0;
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_rd_rev_cnt <= 5'h0;
    end
    else if(S_clk_div2)
    begin
        if(S_rd_rev_flg && (S_rd_rev_cnt < S_rd_rev_num))
        begin
            S_rd_rev_cnt <= S_rd_rev_cnt + 5'h1;
        end
        else if(S_rd_rev_flg && (S_rd_rev_cnt == S_rd_rev_num) && (S_rd_rev_cnt !=5'h0))
        begin
            S_rd_rev_cnt <= 5'h1;
        end
        else
        begin
            S_rd_rev_cnt <= 5'h0;
        end
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_para_fifo_rden <= 1'b0;
    end
    else if(~S_clk_div2 && S_rd_rev_flg && (S_rd_rev_cnt == S_rd_rev_num))
    begin
        S_para_fifo_rden <= 1'b1;
    end
    else
    begin
        S_para_fifo_rden <= 1'b0;
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_data_fifo_rden_d1 <= 1'b0;
        S_data_fifo_rden_d2 <= 1'b0;
        S_data_fifo_rden_d3 <= 1'b0;
    end
    else
    begin
        S_data_fifo_rden_d1 <= S_data_fifo_rden   ;
        S_data_fifo_rden_d2 <= S_data_fifo_rden_d1;
        S_data_fifo_rden_d3 <= S_data_fifo_rden_d2;
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_ram_wr_en   <=  1'b0;
        S_ram_wr_data <=  8'h0;
    end
    else 
    begin
        S_ram_wr_en   <= S_data_fifo_rden_d3; 
        S_ram_wr_data <= S_rd_rev_data      ;
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_ram_wr_addr <= 10'h0;
    end
    else if(S_ram_wr_en)
    begin
        if((S_rd_rev_cnt == 5'h0) && (S_rd_rev_cnt < S_rd_rev_num))
        begin
            S_ram_wr_addr <= S_ram_wr_addr + S_rd_rev_num - S_rd_rev_cnt;
        end
        else if((S_rd_rev_cnt != 5'h0) && (S_rd_rev_cnt < S_rd_rev_num))
        begin
            S_ram_wr_addr <= S_ram_wr_addr - S_rd_rev_cnt;
        end
        else
        begin
            S_ram_wr_addr <= S_ram_wr_addr + 10'h1;
        end
    end
end



endmodule


