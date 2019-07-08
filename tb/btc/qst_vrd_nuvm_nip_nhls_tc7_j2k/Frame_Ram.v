/////////////////////////////////////////////////////////////////
////                                                         ////
////             Design  : JPEG2000 DECODER                  ////
////             Author  : Chao Qiu                          ////
////             Email   : cqiu2008@hotmail.com              ////
////                       supermanqc@163.com                ////
////                                                         ////
/////////////////////////////////////////////////////////////////
////                                                         ////
////     Copyright (C) 2010,2011 Chao Qiu                    ////
////     This source file can not be used and distributed    ////
////     without permission.                                 ////
////                                                         ////
/////////////////////////////////////////////////////////////////
////                                                         ////
////                                                         ////
/////////////////////////////////////////////////////////////////
////                                                         ////
//// Change History : None                                   ////
////                                                         ////
/////////////////////////////////////////////////////////////////
////             File   :  Frame_Ram.v                       ////
////          Generate  :                                    ////
////       Description  :  Store the decompressed image data ////
////                in this Fram_Ram                         ////
////               Not synthesizable                         ////
/////////////////////////////////////////////////////////////////


`include  "Timescale.v"
`include  "J2K_Dec_Defines.v"

  module  Frame_Ram(
     Frame_Ram_rst_n,
     Frame_Ram_clk,
     Frame_Ram_cs,
     Frame_Ram_wr, // For Xilinx FPGA ML510
     Frame_Ram_addr,//J2K Decoder Top ::: output
     Frame_Ram_din, //J2K Decoder Top ::: input
     Frame_Ram_dout//J2K Decoder Top ::: output
     );
 
    input Frame_Ram_rst_n;
    input Frame_Ram_clk;
    input Frame_Ram_cs;
    input [`FA_RAM_WR-1:0]Frame_Ram_wr; // For Xilinx FPGA ML510
    input [`FA_RAM_AW-1:0]Frame_Ram_addr;//J2K Decoder Top ::: output
    output [`FA_RAM_DW-1:0]Frame_Ram_din; //J2K Decoder Top ::: input
    input [`FA_RAM_DW-1:0]Frame_Ram_dout;//J2K Decoder Top ::: output
    
    reg [`FA_RAM_DW-1:0]Frame_Ram_din; 

 
  endmodule
