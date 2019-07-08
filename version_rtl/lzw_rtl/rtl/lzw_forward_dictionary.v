//----------------------------------------------------------------------------
//File Name    : lzw_forward_dictionary.v
//Author       : feng xiaoxiong
//----------------------------------------------------------------------------
//Module Hierarchy :
//xxx_inst |-lzw_forward_compress_inst |-lzw_forward_dictionary_inst
//----------------------------------------------------------------------------
//Release History :
//Version         Date           Author        Description
// 1.0          2018-12-24     feng xiaoxiong    1st draft
//----------------------------------------------------------------------------
//Main Function:
//a)dictionary restore;
//----------------------------------------------------------------------------
module  lzw_forward_dictionary  (

input              I_sys_clk                     , ///system clock,250m clock                 ///
input              I_sys_rst                     , ///system reset,sync with 250m             ///
//wr dictionary 
input       [ 9:0] I_wr_addr                     ,
input       [28:0] I_wr_data                     ,
input       [15:0] I_wr_en                       ,
//rd dictionary
input       [ 9:0] I_rd_addr                     ,
input       [13:0] I_prefix_code                 ,
output      [15:0] O_dictionary_valid            ,
output      [15:0] O_dictionary_match            ,
output      [13:0] O_dictionary_match_code       
);


reg         [15:0] S_conflict_flag               ;
reg         [28:0] S_doutb_2              [15:0] ;
wire        [28:0] S_doutb_1              [15:0] ;
wire        [28:0] S_rd_data              [15:0] ;           
wire        [15:0] S_dictionary_valid            ;
wire        [15:0] S_dictionary_match            ;
wire        [13:0] S_dictionary_match_code[15:0] ;


assign  O_dictionary_valid      = S_dictionary_valid ;
assign  O_dictionary_match      = S_dictionary_match ;
assign  O_dictionary_match_code = (((S_dictionary_match_code[0]  | S_dictionary_match_code[1]   )|
                                    (S_dictionary_match_code[2]  | S_dictionary_match_code[3]  ))|  
                                   ((S_dictionary_match_code[4]  | S_dictionary_match_code[5]   )|
                                    (S_dictionary_match_code[6]  | S_dictionary_match_code[7] )))|
                                  (((S_dictionary_match_code[8]  | S_dictionary_match_code[9]   )|
                                    (S_dictionary_match_code[10] | S_dictionary_match_code[11] ))|
                                   ((S_dictionary_match_code[12] | S_dictionary_match_code[13]  )|
                                    (S_dictionary_match_code[14] | S_dictionary_match_code[15] )));


///************************************************************************///
///                             small dictionary                           ///
///************************************************************************///

genvar i;
generate
for(i=0;i<16;i=i+1)
begin:small_dictionary

blk_mem_1024_29   blk_mem_1024_29_inst (
  .clka   (I_sys_clk   ),    // input wire clka
  .rsta   (I_sys_rst   ),    // input wire rsta
  .wea    (I_wr_en[i]  ),    // input wire [0 : 0] wea
  .addra  (I_wr_addr   ),    // input wire [9 : 0] addra
  .dina   (I_wr_data   ),    // input wire [28 : 0] dina
  .douta  (            ),    // output wire [28 : 0] douta
  .clkb   (I_sys_clk   ),    // input wire clkb
  .rstb   (I_sys_rst   ),    // input wire rstb
  .web    (1'b0        ),    // input wire [0 : 0] web
  .addrb  (I_rd_addr   ),    // input wire [9 : 0] addrb
  .dinb   (29'h0       ),    // input wire [28 : 0] dinb
  .doutb  (S_doutb_1[i])     // output wire [28 : 0] doutb
);


always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_conflict_flag[i] <= 1'b0;
    end
    else if(I_wr_en[i] && (I_wr_addr == I_rd_addr))
    begin
        S_conflict_flag[i] <= 1'b1;
    end
    else
    begin
        S_conflict_flag[i] <= 1'b0;
    end
end


always @(posedge I_sys_clk)
begin
    if(I_sys_rst)
    begin
        S_doutb_2[i] <= 29'h0;
    end
    else if(I_wr_en[i] && (I_wr_addr == I_rd_addr))
    begin
        S_doutb_2[i] <= I_wr_data;
    end
end
        
assign S_rd_data[i]               = S_conflict_flag[i] ? S_doutb_2[i] : S_doutb_1[i] ;
assign S_dictionary_valid[i]      = S_rd_data[i][28] ;
assign S_dictionary_match[i]      =(S_rd_data[i][28:14] == {1'b1,I_prefix_code})? 1'b1 : 1'b0 ; 
assign S_dictionary_match_code[i] =(S_rd_data[i][28:14] == {1'b1,I_prefix_code})? S_rd_data[i][13:0] : 14'h0 ;

end
endgenerate


endmodule
