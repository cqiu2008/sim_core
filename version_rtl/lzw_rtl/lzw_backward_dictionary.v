//----------------------------------------------------------------------------
//File Name    : lzw_backward_dictionary.v
//Author       : feng xiaoxiong
//----------------------------------------------------------------------------
//Module Hierarchy :
//xxx_inst |-lzw_backward_decompress_inst |-lzw_backward_dictionary_inst
//----------------------------------------------------------------------------
//Release History :
//Version         Date           Author        Description
// 1.0          2018-1-2     feng xiaoxiong    1st draft
//----------------------------------------------------------------------------
//Main Function:
//a)rebulid backward dictionary;
//b)consult dictionary;
//----------------------------------------------------------------------------
module lzw_backward_dictionary(

input              I_sys_clk                     , ///system clock,250m clock                 ///
input              I_sys_rst                     , ///system reset,sync with 250m             ///
input              I_state_clr                   , ///clear state statistic                   ///
input       [22:0] I_dictionary_sync_data        , ///from tx dictionary                      ///
input       [13:0] I_dictionary_sync_addr        , ///from tx dictionary                      ///
input              I_dictionary_sync_wren        , ///from tx dictionary                      ///

input       [13:0] I_dictionary_addr             , ///dictionary consult addr                 ///
output      [22:0] O_dictionary_dout               ///dictionary consult dout                 ///

);

reg         [22:0] S_dictionary_sync_data        ;
reg         [13:0] S_dictionary_sync_addr        ;
reg                S_dictionary_sync_wren        ;

///************************************************************************///
///                      rebuild backward dictionary                       ///
///************************************************************************///

always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_dictionary_sync_data <= 23'h0;
        S_dictionary_sync_addr <= 14'h0;
        S_dictionary_sync_wren <=  1'b0;
    end
    else
    begin
        S_dictionary_sync_data <= I_dictionary_sync_data;
        S_dictionary_sync_addr <= I_dictionary_sync_addr;
        S_dictionary_sync_wren <= I_dictionary_sync_wren;
    end
end

blk_mem_16k_23  blk_mem_16k_23_inst (
  .clka  (I_sys_clk             ), // input wire clka
  .rsta  (I_sys_rst             ), // input wire rsta
  .wea   (S_dictionary_sync_wren), // input wire [0 : 0] wea
  .ena   (1'b1                  ), // input wire [0 : 0] ena
  .addra (S_dictionary_sync_addr), // input wire [13 : 0] addra
  .dina  (S_dictionary_sync_data), // input wire [22 : 0] dina
  .douta (                      ), // output wire [22 : 0] douta
  .clkb  (I_sys_clk             ), // input wire clkb
  .rstb  (I_sys_rst             ), // input wire rstb
  .web   (1'b0                  ), // input wire [0 : 0] web
  .enb   (1'b1                  ), // input wire [0 : 0] enb
  .addrb (I_dictionary_addr     ), // input wire [13 : 0] addrb
  .dinb  (23'h0                 ), // input wire [22 : 0] dinb
  .doutb (O_dictionary_dout     )  // output wire [22 : 0] doutb
);


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          ___     ___             ___     ___             ___     ___     ___   //
//S_dictionary_sync_data_en _______________|   |___|   |___________|   |___|   |___________|   |___|   |___|   |__//
//                                                                                                                //
//S_dictionary_sync_data[22:0]             | [a]b  | [b]a  |       | [ab]c | [c]b  |       | [ba]b |  [b]c | [c]c //
//   --bit[22]  :valid flag                                                                                       //
//   --bit[21:8]:matched prefix code                                                                              //
//   --bit[7:0] :current tx data                                                                                  //
//                                                                                                                //
//S_dictionary_sync_addr[13:0]             | 0x100 | 0x101 |       | 0x102 | 0X103 |       | 0x104 | 0x105 | 0x106// 
//   --bit[13:0]:dictionary code,0x100~                                                                           //  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


endmodule


