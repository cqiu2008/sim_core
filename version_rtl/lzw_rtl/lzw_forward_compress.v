//----------------------------------------------------------------------------
//File Name    : lzw_forward_compress.v
//Author       : feng xiaoxiong
//----------------------------------------------------------------------------
//Module Hierarchy :
//xxx_inst |-lzw_forward_compress_inst
//----------------------------------------------------------------------------
//Release History :
//Version         Date           Author        Description
// 1.0          2018-12-24     feng xiaoxiong    1st draft
//----------------------------------------------------------------------------
//Main Function:
//a)initial dictionary;
//b)look up dictionary,match or not;
//c)update prefix code;
//c)mismatch->write dictionary;
//e)mismatch->output current prefix code to compressed data ram;
//f)dictionary synchronization message to dictionary framer
//----------------------------------------------------------------------------
module  lzw_forward_compress  (

input              I_sys_clk                , ///system clock,250m clock                         ///
input              I_sys_rst                , ///system reset,sync with 250m                     ///
input       [ 7:0] I_tx_data                , ///payload data                                    ///
input              I_tx_data_en             , ///payload data enable                             ///
input              I_dictionary_lock        , ///lock means don't update dictionary              ///
input              I_state_clr              , ///clear state statistic                           ///
              
output      [13:0] O_compress_data          , ///compressed dictionary code                      ///
output             O_compress_data_en       , ///compressed dictionary code en                   ///
output      [22:0] O_rx_dictionary_data     , ///dictionary sync message to dictionary framer    ///
output      [13:0] O_rx_dictionary_addr     , ///dictionary sync message to dictionary framer    ///
output             O_rx_dictionary_data_en  , ///dictionary sync message to dictionary framer    ///
output reg  [31:0] O_uncompress_data_cnt    , ///uncompress byte cnt                             ///                     
output reg  [31:0] O_compress_data_cnt      , ///compress byte cnt                               ///
output reg  [15:0] O_tx_package_cnt           ///tx package cnt                                  ///
);

reg                S_clk_div2               ;
reg         [ 7:0] S_tx_data                ;
reg                S_tx_data_en             ;
reg                S_compare_cycle          ;
reg                S_update_cycle           ;
reg         [13:0] S_prefix_code            ;
reg         [13:0] S_prefix_code_d1         ;
reg         [13:0] S_dictionary_code        ;
reg         [14:0] S_dictionary_sn          ;
reg         [ 9:0] S_wr_addr                ;
reg         [15:0] S_wr_en                  ;
reg         [13:0] S_compress_data          ;
reg                S_compress_data_en       ;
reg         [22:0] S_rx_dictionary_data     ;   
reg                S_rx_dictionary_data_en  ;
reg                S_state_clr              ;

wire        [28:0] S_wr_data                ;
wire        [ 9:0] S_rd_addr                ;
wire        [15:0] S_dictionary_match       ;
wire        [15:0] S_dictionary_valid       ;
wire        [13:0] S_dictionary_match_code  ;

//lzw compress algorithm example,dictionary initial a(1) b(2) c(3)
//========================================================================================================
//             |    Clock Cycle                
//--------------------------------------------------------------------------------------------------------
//  variables  |    1         2        3        4        5        6        7        8        9       10    
//--------------------------------------------------------------------------------------------------------
//      x      |    a         b        a        b        c        b        a        b        c        c
//      I      |    0         a        b        a        ab       c        b        ba       b        c 
//     Ix      |    a         ab       ba       ab      abc       cb       ba      bab       bc      cc
//    Match    |    Y         N        N        Y        N        N        Y        N        N        N  
//     Mem     |             ab(4)    ba(5)             abc(6)   cb(7)            bab(8)    bc(9)   cc(10)
// output code |              a(1)     b(2)              ab(4)    c(3)             ba(5)     b(2)    c(3)    
//--------------------------------------------------------------------------------------------------------

assign S_wr_data               = {1'b1,S_prefix_code_d1[13:0],S_dictionary_code[13:0]};
assign S_rd_addr               = {S_prefix_code[1:0],S_tx_data[7:0]}                  ;
assign O_compress_data         = S_compress_data                                      ;
assign O_compress_data_en      = S_compress_data_en                                   ;
assign O_rx_dictionary_addr    = S_dictionary_code                                    ;
assign O_rx_dictionary_data    = S_rx_dictionary_data                                 ;
assign O_rx_dictionary_data_en = S_rx_dictionary_data_en                              ;


always@(posedge I_sys_clk)
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
        S_tx_data    <= 8'h0;
        S_tx_data_en <= 1'h0;
    end
    else if(S_clk_div2)
    begin
        S_tx_data    <= I_tx_data   ;
        S_tx_data_en <= I_tx_data_en;
    end
end


always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_compare_cycle <= 1'b0;
        S_update_cycle  <= 1'b0;
    end
    else 
    begin
        S_compare_cycle <= S_tx_data_en &&(~S_clk_div2);
        S_update_cycle  <= S_tx_data_en &&  S_clk_div2 ;
    end
end

///************************************************************************///
/// mismatch dictionary: prefix code I <= current input data x             ///
///    match dictionary: prefix code I <= dictionary match code(current Ix)///
///************************************************************************///
always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_prefix_code <= 14'h0;
    end
    else if(S_compare_cycle)
    begin
        if(S_dictionary_match == 16'h0)
        begin
            S_prefix_code <= {6'h0,S_tx_data};
        end
        else
        begin
            S_prefix_code <= S_dictionary_match_code;
        end
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_prefix_code_d1 <= 14'h0;
    end
    else
    begin
        S_prefix_code_d1 <= S_prefix_code;
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_dictionary_code <= 14'hff;
    end
    else if(S_compare_cycle && (S_dictionary_match == 16'h0) && (~I_dictionary_lock))
    begin
        S_dictionary_code <= S_dictionary_code + 14'h1;
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_dictionary_sn <= 15'h1;
    end
    else if(S_compare_cycle && (S_dictionary_match == 16'h0) && (~I_dictionary_lock))
    begin
        S_dictionary_sn <= {S_dictionary_sn[13:0],S_dictionary_sn[14]};
    end
end


always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_wr_en <= 16'h0;
    end
    else if(S_compare_cycle && (S_dictionary_match == 16'h0) && (~I_dictionary_lock))
    begin
        if(S_dictionary_valid !== 16'hffff)
        begin
            S_wr_en <= S_dictionary_valid + 16'h1;
        end
        else
        begin
            S_wr_en <= {S_dictionary_sn,1'b0};
        end
    end
    else 
    begin
        S_wr_en <= 16'h0;
    end
end


always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_wr_addr <= 10'h0;
    end
    else if(S_update_cycle)
    begin
        S_wr_addr <= {S_prefix_code[1:0],S_tx_data[7:0]};
    end
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                       //
//S_tx_data          |   a  |   b   |   a   |   b   |   c   |   b   |   a   |   b   |   c   |   c   |    //
//                       ___     ___     ___     ___     ___     ___     ___     ___     ___     ___     //
//S_compare_cycle    ___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___ //
//                           ___     ___     ___     ___     ___     ___     ___     ___     ___     ___ //
//S_update_cycle     _______|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|    //
//                                                                                                       //
//S_prefix_code      |   0  |   a   |   b   |   a   | 0x100 |   c   |   b   | 0x101 |   b   |   c   |    //
//                                                                                                       //
//S_dictionary_code  | 0xff |  0xff | 0x100 | 0x101 | 0x101 | 0x102 | 0x103 | 0x103 | 0x104 | 0x105 |    //
//                       ___                     ___                     ___                             //
//S_dictionary_match ___|   |___________________|   |___________________|   |____________________________//
//                                   ___     ___             ___     ___             ___     ___     ___ //
//S_wr_en            _______________|   |___|   |___________|   |___|   |___________|   |___|   |___|   |//
//                                                                                                       //
//S_wr_addr                     | ADDR  | ADDR  |       | ADDR  | ADDR  |       | ADDR  | ADDR  | ADDR  |//
//                                                                                                       //                                                 
//S_wr_data                         | D |   | D |           | D |   | D |           | D |   | D |   | D |//
//                                   ___     ___             ___     ___             ___     ___     ___ //
//S_compress_data_en _______________|   |___|   |___________|   |___|   |___________|   |___|   |___|   |//
//                                                                                                       //
//S_compress_data                   |   a   |   b   |       | 0x100 |   c   |       | 0x101 |   b   |   c//
//                                   ___     ___             ___     ___             ___     ___     ___ //
//dictionary_data_en _______________|   |___|   |___________|   |___|   |___________|   |___|   |___|   |//
//                                                                                                       //
//dictionary_data                   | [a]b  | [b]a  |       | [ab]c | [c]b  |       | [ba]b |  [b]c |[c]c//
//                                                                                                       //
//dictionary_addr                   | 0x100 | 0x101 |       | 0x102 | 0X103 |       | 0x104 | 0x105 |    // 
///////////////////////////////////////////////////////////////////////////////////////////////////////////

lzw_forward_dictionary   lzw_forward_dictionary_inst(
.I_sys_clk                 (I_sys_clk               ),
.I_sys_rst                 (I_sys_rst               ),
.I_wr_addr                 (S_wr_addr               ),
.I_wr_data                 (S_wr_data               ),
.I_wr_en                   (S_wr_en                 ),
.I_rd_addr                 (S_rd_addr               ),
.I_prefix_code             (S_prefix_code           ),
.O_dictionary_valid        (S_dictionary_valid      ),
.O_dictionary_match        (S_dictionary_match      ),
.O_dictionary_match_code   (S_dictionary_match_code )
);


///************************************************************************///
///     mismatch dictionary->output current prefix code I                  ///
///************************************************************************///

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_compress_data    <= 14'h0;
        S_compress_data_en <=  1'b0;
    end
    else if(S_compare_cycle && (S_dictionary_match == 16'h0))
    begin
        S_compress_data    <= S_prefix_code;
        S_compress_data_en <=  1'b1;
    end
    else
    begin
        S_compress_data    <= S_compress_data;
        S_compress_data_en <= 1'b0;
    end
end

///************************************************************************///
///     mismatch dictionary->output dictionary synchronization message     ///
///************************************************************************///

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_rx_dictionary_data_en <= 1'b0;
    end
    else if(S_compare_cycle && (S_dictionary_match == 16'h0) && (~I_dictionary_lock))
    begin
        S_rx_dictionary_data_en <= 1'b1;
    end
    else
    begin
        S_rx_dictionary_data_en <= 1'b0;
    end
end


always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_rx_dictionary_data <= 23'h0;
    end
    else if(S_compare_cycle)
    begin
        S_rx_dictionary_data <= {1'b1,S_prefix_code,S_tx_data};
    end
end


///************************************************************************///
///                              state statistics                          ///
///************************************************************************///

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_state_clr <= 1'b0;
    end
    else
    begin
        S_state_clr <= I_state_clr;
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        O_uncompress_data_cnt <= 32'h0;
    end
    else if(S_state_clr)
    begin
        O_uncompress_data_cnt <= 32'h0;
    end
    else if(S_tx_data_en)
    begin
        O_uncompress_data_cnt <= O_uncompress_data_cnt + 32'h1;
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        O_compress_data_cnt <= 32'h0;
    end
    else if(S_state_clr)
    begin
        O_compress_data_cnt <= 32'h0;
    end
    else if(S_compress_data_en)
    begin
        O_compress_data_cnt <= O_compress_data_cnt + 32'h1;
    end
end

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        O_tx_package_cnt <= 32'h0;
    end
    else if(S_state_clr)
    begin
        O_tx_package_cnt <= 16'h0;
    end
    else if(I_tx_data_en && (~S_tx_data_en) && S_clk_div2)
    begin
        O_tx_package_cnt <= O_tx_package_cnt + 16'h1;
    end
end

    

endmodule
