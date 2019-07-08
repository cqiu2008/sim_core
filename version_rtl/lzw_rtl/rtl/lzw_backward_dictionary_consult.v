//----------------------------------------------------------------------------
//File Name    : lzw_backward_consult.v
//Author       : feng xiaoxiong
//----------------------------------------------------------------------------
//Module Hierarchy :
//xxx_inst |-lzw_backward_decompress_inst |-lzw_backward_consult_inst
//----------------------------------------------------------------------------
//Release History :
//Version         Date           Author        Description
// 1.0          2018-1-4     feng xiaoxiong    1st draft
//----------------------------------------------------------------------------
//Main Function:
//a)receive compress data and consult dictionary;
//c)recover payload data;
//----------------------------------------------------------------------------
module lzw_backward_dictionary_consult(

input              I_sys_clk                     , ///system clock,250m clock                 ///
input              I_sys_rst                     , ///system reset,sync with 250m             ///
input              I_state_clr                   , ///clear state statistic                   ///
input       [13:0] I_compress_data               , ///compressed data                         ///
input              I_compress_data_en            , ///compressed data en                      ///
input       [22:0] I_dictionary_dout             , ///dictionary consult dout                 ///
output      [13:0] O_dictionary_addr             , ///dictionary consult addr                 ///
output      [ 7:0] O_dictionary_recv_data        , ///dictionary recv data                    ///  
output             O_dictionary_recv_data_en     , ///dictionary recv data_en                 ///
output             O_reverse_byte_flag           , ///reverse byte flag                       ///
output      [ 4:0] O_reverse_byte_num            , ///reverse byte num                        ///
output             O_reverse_byte_num_wren         ///reverse byte num wren                   ///
);

reg         [13:0] S_compress_data               ;
reg                S_compress_data_en            ;

reg                S_fifo_rden                   ;
wire        [13:0] S_fifo_dout                   ;
wire               S_fifo_full                   ;
wire               S_fifo_empty                  ;
wire        [12:0] S_fifo_data_count             ;

wire        [13:0] S_dictionary_addr             ;
wire               S_dictionary_recv_valid       ;
wire        [13:0] S_dictionary_recv_code        ;
wire        [ 7:0] S_dictionary_recv_data        ;
reg         [13:0] S_dictionary_recv_code_buf    ;
reg                S_bottom_flag                 ;
reg                S_bottom_flag_d1              ;
reg                S_clk_div2                    ;
reg                S_dictionary_recv_data_en     ;
reg                S_reverse_byte_flag           ;
reg         [ 4:0] S_reverse_byte_num            ;
reg                S_reverse_byte_num_wren       ;
reg                S_fifo_rden_d1                ;
reg                S_fifo_rden_d2                ;

assign  O_dictionary_addr         =  S_dictionary_addr         ;
assign  S_dictionary_recv_valid   =  I_dictionary_dout[22]     ;
assign  S_dictionary_recv_code    =  I_dictionary_dout[21:8]   ;
assign  S_dictionary_recv_data    =  I_dictionary_dout[ 7:0]   ;

assign  O_dictionary_recv_data    =  S_dictionary_recv_data    ;
assign  O_dictionary_recv_data_en =  S_dictionary_recv_data_en ;
assign  O_reverse_byte_flag       =  S_reverse_byte_flag       ;
assign  O_reverse_byte_num        =  S_reverse_byte_num        ;
assign  O_reverse_byte_num_wren   =  S_reverse_byte_num_wren   ;

///************************************************************************///
///                          consult dictionary                            ///
///************************************************************************///

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_compress_data    <= 14'h0;
        S_compress_data_en <= 1'b0 ;
    end
    else
    begin
        S_compress_data    <= I_compress_data   ;
        S_compress_data_en <= I_compress_data_en;
    end
end

fifo_8k_14bit   fifo_8k_14bit_inst (
  .clk       (I_sys_clk         ), // input wire clk
  .srst      (I_sys_rst         ), // input wire srst
  .din       (S_compress_data   ), // input wire [13 : 0] din
  .wr_en     (S_compress_data_en), // input wire wr_en
  .rd_en     (S_fifo_rden       ), // input wire rd_en
  .dout      (S_fifo_dout       ), // output wire [13 : 0] dout
  .full      (S_fifo_full       ), // output wire full
  .empty     (S_fifo_empty      ), // output wire empty
  .data_count(S_fifo_data_count )  // output wire [12 : 0] data_count
);

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_clk_div2 <= 1'b1;
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
        S_fifo_rden <= 1'b0;
    end
    else if(S_clk_div2 && ~S_fifo_empty && (S_dictionary_addr[13:8] == 6'h0))
    begin
        S_fifo_rden <= 1'b1;
    end
    else
    begin
        S_fifo_rden <= 1'b0;
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_bottom_flag <= 1'b1;
    end
    else if(~S_clk_div2)
    begin
        if(S_dictionary_recv_valid && (S_dictionary_recv_code[13:0] == 14'h0))
        begin
            S_bottom_flag <= 1'b1;
        end
        else
        begin
            S_bottom_flag <= 1'b0;
        end
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_dictionary_recv_code_buf <= 14'h0;
    end
    else 
    begin
        S_dictionary_recv_code_buf <= S_dictionary_recv_code;
    end
end

assign S_dictionary_addr = (S_fifo_empty || S_bottom_flag) ? S_fifo_dout : S_dictionary_recv_code_buf; 

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_fifo_rden_d1 <= 1'b0;
        S_fifo_rden_d2 <= 1'b0;
    end
    else
    begin
        S_fifo_rden_d1 <= S_fifo_rden   ;
        S_fifo_rden_d2 <= S_fifo_rden_d1;
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_dictionary_recv_data_en <= 1'b0;
    end
    else if((~S_clk_div2) && (S_fifo_rden_d2 || (~S_bottom_flag)))
    begin
        S_dictionary_recv_data_en <= 1'b1;
    end
    else
    begin
        S_dictionary_recv_data_en <= 1'b0;
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_reverse_byte_flag <= 1'b0;
    end
    else if(~S_clk_div2 && ((~S_bottom_flag) || (S_dictionary_addr[13:8] != 6'h0)))
    begin
        S_reverse_byte_flag <= 1'b1;
    end
    else
    begin
        S_reverse_byte_flag <= 1'b0;
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_reverse_byte_num <= 5'h0;
    end
    else if(S_reverse_byte_num_wren)
    begin
        S_reverse_byte_num <= 5'h0;
    end
    else if(S_dictionary_recv_data_en)
    begin
        if(S_reverse_byte_flag)
        begin
            S_reverse_byte_num <= S_reverse_byte_num + 5'h1;
        end
        else
        begin
            S_reverse_byte_num <= 5'h0;
        end
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_bottom_flag_d1 <= 1'b1;
    end
    else
    begin
        S_bottom_flag_d1 <= S_bottom_flag;
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_reverse_byte_num_wren <= 1'b0;
    end
    else if(S_bottom_flag && (~S_bottom_flag_d1))
    begin
        S_reverse_byte_num_wren <= 1'b1;
    end
    else
    begin
        S_reverse_byte_num_wren <= 1'b0;
    end
end

endmodule


