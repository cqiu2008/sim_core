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
////             File   :  J2K_BitStream_Ram.v               ////
////          Generate  :                                    ////
////       Description  :                                    ////
////                     Behavior RAM for encoded bitstream  ////
////       storing, Not synthesizable                        ////
/////////////////////////////////////////////////////////////////

//??include??????????ModelSim????????????//
//?XXX.mpf?????????????????????????//

`include    "Timescale.v"
`include    "J2K_Dec_Defines.v"


module J2K_BitStream_Ram(
    BitStream_Ram_rst_n,
    BitStream_Ram_clk,
    BitStream_Ram_cs,
    BitStream_Ram_rd,
    BitStream_Ram_addr,
    BitStream_Ram_din,
    BitStream_Ram_dout
   );
 
//// inputs 
  input BitStream_Ram_rst_n; // low active 
  input BitStream_Ram_clk;
  input BitStream_Ram_cs; // high active 
  input [`BS_RAM_RD-1:0]BitStream_Ram_rd;
  input [`BS_RAM_AW-1:0]BitStream_Ram_addr;

  input [`BS_RAM_DW-1:0]BitStream_Ram_dout;
//// outputs 
  output [`BS_RAM_DW-1:0]BitStream_Ram_din;

  
//// variable declarations
   reg [`BS_RAM_DW-1:0]BitStream_Ram_din;
  //reg [`BS_RAM_DW-1:0]BitStream_Ram_dout;
  
  wire [`BS_RAM_DW-1:0]BS_temp;
   assign BS_temp = BitStream_Ram_dout;

  reg [`BS_RAM_DW-1:0]BitStream_Ram[0:`BS_RAM_SIZE-1];

  //path   D: / xxx/xxx/xxx/xx.dat
  //
  //在ModelSim仿真环境下，该目录以工程名XXX.mpf文件所在的目录为当前目录
  /*initial begin
             //$readmemh("../src/JP2_DATA/JP2_DAT32.dat",BitStream_Ram);
               $readmemh("data_jp2/JP2_DAT32.dat",BitStream_Ram);
             //$readmemh("data_jp2/JP2_DAT32_BeiChuanR.dat",BitStream_Ram);
             //$readmemh("data_jp2/JP2_DAT32_BeiChuanG.dat",BitStream_Ram);
             //$readmemh("data_jp2/JP2_DAT32_BeiChuanB.dat",BitStream_Ram);
          end*/
	
/////////////////////////////////
//
// module body 
//

always @(posedge BitStream_Ram_clk)begin
	if(!BitStream_Ram_rst_n)
          BitStream_Ram_din <= #2 0;
        else 
	 if(BitStream_Ram_rd[0] && BitStream_Ram_cs)
	   BitStream_Ram_din <= #2 BitStream_Ram[BitStream_Ram_addr];
       end


 endmodule

