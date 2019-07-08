//----------------------------------------------------------------------------
//File Name    : lzw_backward_decompress.v
//Author       : feng xiaoxiong
//----------------------------------------------------------------------------
//Module Hierarchy :
//xxx_inst |-lzw_backward_decompress_inst
//----------------------------------------------------------------------------
//Release History :
//Version         Date           Author        Description
// 1.0          2018-12-26     feng xiaoxiong    1st draft
//----------------------------------------------------------------------------
//Main Function:
//a)rebulid backward dictionary;
//b)receive compress data and consult dictionary;
//c)recover payload data;
//----------------------------------------------------------------------------
module lzw_backward_decompress(

input              I_sys_clk                     , ///system clock,250m clock                 ///
input              I_sys_rst                     , ///system reset,sync with 250m             ///
input              I_state_clr                   , ///clear state statistic                   ///
input       [22:0] I_dictionary_sync_data        , ///from tx dictionary                      ///
input       [13:0] I_dictionary_sync_addr        , ///from tx dictionary                      ///
input              I_dictionary_sync_wren        , ///from tx dictionary                      ///
input       [13:0] I_compress_data               , ///compressed data                         ///
input              I_compress_data_en            , ///compressed data en                      ///

output      [ 7:0] O_payload_data                , ///recovered payload data                  ///
output             O_payload_data_en               ///recovered payload data en               ///
);

wire        [13:0] S_dictionary_addr             ;
wire        [22:0] S_dictionary_dout             ;

wire        [ 7:0] S_dictionary_recv_data        ;
wire               S_dictionary_recv_data_en     ;
wire               S_reverse_byte_flag           ;
wire        [ 4:0] S_reverse_byte_num            ;
wire               S_reverse_byte_num_wren       ;

//lzw decompress algorithm example,dictionary initial a(1) b(2) c(3)
//========================================================================================================
//             |    Clock Cycle                
//--------------------------------------------------------------------------------------------------------
//  variables  |    1         2        3        4        5        6        7        8        9       10    
//--------------------------------------------------------------------------------------------------------
// input code  |    1         2             4            3             5            2        3       10 
//      I      |    a         b             ab           c             ba           b        c           cc 
//      x      |    a         b        a        b        c        b        a        b        c        c 
//     Ix      |    ax        bx           abx           cx            bax          bx       cx      ccx
// Write Mem   |             ab(4)         ba(5)        abc(6)         cb(7)        bab(8)   bc(9)   cc(10)
//--------------------------------------------------------------------------------------------------------

lzw_backward_dictionary lzw_backward_dictionary_inst
(
.I_sys_clk                (I_sys_clk                 ),
.I_sys_rst                (I_sys_rst                 ),
.I_state_clr              (I_state_clr               ),
.I_dictionary_sync_data   (I_dictionary_sync_data    ),
.I_dictionary_sync_addr   (I_dictionary_sync_addr    ),
.I_dictionary_sync_wren   (I_dictionary_sync_wren    ),
.I_dictionary_addr        (S_dictionary_addr         ),
.O_dictionary_dout        (S_dictionary_dout         )
);


lzw_backward_data_recover lzw_backward_data_recover_inst
(
.I_sys_clk                (I_sys_clk                 ),
.I_sys_rst                (I_sys_rst                 ),   
.I_state_clr              (I_state_clr               ),
.I_compress_data          (I_compress_data           ),
.I_compress_data_en       (I_compress_data_en        ),
.I_dictionary_dout        (S_dictionary_dout         ),
.O_dictionary_addr        (S_dictionary_addr         ),
.O_dictionary_recv_data   (S_dictionary_recv_data    ),
.O_dictionary_recv_data_en(S_dictionary_recv_data_en ),
.O_reverse_byte_flag      (S_reverse_byte_flag       ),
.O_reverse_byte_num       (S_reverse_byte_num        ),
.O_reverse_byte_num_wren  (S_reverse_byte_num_wren   )
);

lzw_backward_byte_reverse lzw_backward_byte_reverse_inst
(
.I_sys_clk                (I_sys_clk                 ),    
.I_sys_rst                (I_sys_rst                 ),
.I_state_clr              (I_state_clr               ),
.I_dictionary_recv_data   (S_dictionary_recv_data    ),
.I_dictionary_recv_data_en(S_dictionary_recv_data_en ),
.I_reverse_byte_flag      (S_reverse_byte_flag       ),
.I_reverse_byte_num       (S_reverse_byte_num        ),
.I_reverse_byte_num_wren  (S_reverse_byte_num_wren   ),
.O_payload_data           (O_payload_data            ), 
.O_payload_data_en        (O_payload_data_en         )   

);



endmodule


