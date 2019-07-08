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
////             File   :  TB_J2K_Decoder_Top.v              ////
////          Generate  :                                    ////
////       Description  :  TestBench for J2K_Decoder         ////
////                                                         ////
/////////////////////////////////////////////////////////////////

//??include??????????ModelSim????????????//
//?XXX.mpf?????????????????????????//

 `include   "Timescale.v"
 `include   "J2K_Dec_Defines.v"

// `define FSDB 
`define RGB_SET // High 1 active
 /// if RGB_SET has not defined , so the TB is single image(huidu tu xiang) 
//`define BMP_GRAY_SET
`define BMP_COLOR_SET
 /// bmp图像，从下到上，从左到右顺序排放
 /// if BMP_GRAY_SET has not defined , so the TB is PNM format image 
////`define VCS_FSDB

module  TB_J2K_Decoder_Top;
//// J2K global signals 
    reg J2K_rst_n;
    reg J2K_clk;
    reg J2K_en;
    reg [7:0]mem_dat;


	string data_path = "../../tb/btc/qst_vrd_nuvm_nip_nhls_tc7_j2k/";
    
    `ifdef RGB_SET 
//// Bit Stream ram signals 
    wire BitStream_Ram_rst_n_R;
    wire BitStream_Ram_rst_n_G;
    wire BitStream_Ram_rst_n_B;
   
    wire BitStream_Ram_clk_R;
    wire BitStream_Ram_clk_G;
    wire BitStream_Ram_clk_B;
   
    wire BitStream_Ram_cs_R;
    wire BitStream_Ram_cs_G;
    wire BitStream_Ram_cs_B;
   
    wire [`BS_RAM_RD-1:0]BitStream_Ram_rd_R;
    wire [`BS_RAM_RD-1:0]BitStream_Ram_rd_G;
    wire [`BS_RAM_RD-1:0]BitStream_Ram_rd_B;
    
    wire [`BS_RAM_AW-1:0]BitStream_Ram_addr_R;
    wire [`BS_RAM_AW-1:0]BitStream_Ram_addr_G;
    wire [`BS_RAM_AW-1:0]BitStream_Ram_addr_B;

    wire [`BS_RAM_DW-1:0]BitStream_Ram_din_R;
    wire [`BS_RAM_DW-1:0]BitStream_Ram_din_G;
    wire [`BS_RAM_DW-1:0]BitStream_Ram_din_B;
   
    wire [`BS_RAM_DW-1:0]BitStream_Ram_dout_R;
    wire [`BS_RAM_DW-1:0]BitStream_Ram_dout_G;
    wire [`BS_RAM_DW-1:0]BitStream_Ram_dout_B;

//// Frame Ram signals
    wire Frame_Ram_rst_n_R;
    wire Frame_Ram_rst_n_G;
    wire Frame_Ram_rst_n_B;
    wire Frame_Ram_clk_R;
    wire Frame_Ram_clk_G;
    wire Frame_Ram_clk_B;
    wire Frame_Ram_cs_R;
    wire Frame_Ram_cs_G;
    wire Frame_Ram_cs_B;
    wire [`FA_RAM_WR-1:0]Frame_Ram_wr_R;
    wire [`FA_RAM_WR-1:0]Frame_Ram_wr_G;
    wire [`FA_RAM_WR-1:0]Frame_Ram_wr_B;  // For xilinx FPGA ML510
    wire [`FA_RAM_AW-1:0]Frame_Ram_addr_R;
    wire [`FA_RAM_AW-1:0]Frame_Ram_addr_G;
    wire [`FA_RAM_AW-1:0]Frame_Ram_addr_B; // J2K_Decoder To ::: output
    wire [`FA_RAM_DW-1:0]Frame_Ram_din_R;
    wire [`FA_RAM_DW-1:0]Frame_Ram_din_G;
    wire [`FA_RAM_DW-1:0]Frame_Ram_din_B; // J2K_Decoder Top ::: input
    wire [`FA_RAM_DW-1:0]Frame_Ram_dout_R;
    wire [`FA_RAM_DW-1:0]Frame_Ram_dout_G;
    wire [`FA_RAM_DW-1:0]Frame_Ram_dout_B; // J2K_Decoder Top ::: outpu
    wire [3:0]T1_Dec_State_R;
    wire [3:0]T1_Dec_State_G;
    wire [3:0]T1_Dec_State_B;
    wire IDWT_done_R;
    wire IDWT_done_G;
    wire IDWT_done_B;
    
 `else 
   
    wire BitStream_Ram_rst_n;
    wire BitStream_Ram_clk;
    wire BitStream_Ram_cs;
    wire [`BS_RAM_RD-1:0]BitStream_Ram_rd;
    wire [`BS_RAM_AW-1:0]BitStream_Ram_addr;
    wire [`BS_RAM_DW-1:0]BitStream_Ram_din;
    wire [`BS_RAM_DW-1:0]BitStream_Ram_dout;
//// Frame Ram signals
    wire Frame_Ram_rst_n;
    wire Frame_Ram_clk;
    wire Frame_Ram_cs;
    wire [`FA_RAM_WR-1:0]Frame_Ram_wr; // For Xilinx FPGA ML510
    wire [`FA_RAM_AW-1:0]Frame_Ram_addr;//J2K Decoder Top ::: output
    wire [`FA_RAM_DW-1:0]Frame_Ram_din; //J2K Decoder Top ::: input
    wire [`FA_RAM_DW-1:0]Frame_Ram_dout;//J2K Decoder Top ::: output
    wire [3:0]T1_Dec_State;
    wire IDWT_done;
    
`endif
    
  //parameter for T1_Dec_State
    parameter IDLE_STATE = 4'd0;
    parameter PACKET_HEADER_LL_STATE  = 4'd1;
    parameter PACKET_DATA_LL_STATE    = 4'd2;
    parameter PACKET_HEADER_HL_LH_HH_STATE  = 4'd3;
    parameter PACKET_HEADER_LH_STATE  = 4'd4;
    parameter PACKET_HEADER_HH_STATE  = 4'd5;
    parameter PACKET_DATA_HL_STATE    = 4'd6;
    parameter PACKET_DATA_LH_STATE    = 4'd7;
    parameter PACKET_DATA_HH_STATE    = 4'd8;
    parameter END_STATE = 4'd9;
  
`ifdef VCS_FSDB
	`ifdef RGB_SET
 	//// FSDB Generation
 	always @(T1_Dec_State_R)begin
 	//if( T1_Dec_State >= PACKET_HEADER_HL_LH_HH_STATE)begin 
 	  if( T1_Dec_State_R >= PACKET_DATA_LH_STATE )begin 
 	       $dumpfile("J2K_Dec_RGB.fsdb");
 	       $dumpvars;
 	  end
 	end
 	`else
 	always @(T1_Dec_State)begin
 	     //if( T1_Dec_State >= PACKET_HEADER_HL_LH_HH_STATE)begin 
 	  if( T1_Dec_State >= PACKET_DATA_HH_STATE )begin 
 	       $dumpfile("J2K_Dec.fsdb");
 	       $dumpvars;
 	  end
 	end
 	`endif
`else
 	////====fsdb
	initial begin
   		$helloworld;
  		$fsdbDumpvars("+fsdbfile+tb_dut_top.fsdb");
   		$fsdbDumpSVA;
	end
`endif

`ifdef BMP_GRAY_SET
reg [7:0]bmp_gray_head_ram[0:1080];
initial begin
  $readmemh("dat_bmp_512_512_head/bmp_gray_512_512_head.dat",bmp_gray_head_ram);
end
 
integer outbmp_data;
initial begin
  //outbmp_data = $fopen($psprintf("%s%s",data_path,"result_jp2/outbmp_msim.txt"));
  outbmp_data = $fopen("outbmp_msim.txt");
end
`endif

`ifdef BMP_COLOR_SET
reg [7:0]bmp_color_head_ram[0:63];
initial begin
  //$readmemh("dat_bmp_512_512_head/bmp_color_512_512_head.dat",bmp_color_head_ram);
  $readmemh($psprintf("%s%s",data_path,"dat_bmp_512_512_head/bmp_color_512_512_head.dat"),bmp_color_head_ram);
end
`endif



//******* Clock generation *****************//
   initial begin
	   J2K_clk = 1'b0;
   end
   always #13 J2K_clk = ~J2K_clk;
//******* Clock generation *****************//

  /***** task number of delay clocks ******/
   task num_del_clk;
      input [31:0]num;
     begin
       repeat (num) @(posedge J2K_clk); 
       #3;
     end
   endtask
/***** task number of delay clocks ******/

/***** task  reset module *******/
  task rst_task;
     begin
     J2K_rst_n = 1'b1;

     num_del_clk(12);

     J2K_rst_n = 1'b0;

     num_del_clk(24);

     J2K_rst_n = 1'b1;
     end
  endtask
/***** task  reset module *******/


/***** task number of delay clocks ******/
   task NUM_BS_READ;
      input [31:0]num;
     begin
	     repeat (num) begin
		     #3 @(posedge J2K_clk);
		      // J2K_addr = J2K_addr+1;
	       end
                     
     end
   endtask
/***** task number of delay clocks ******/


//For .pnm
integer 		 handle;
integer                       i;
integer                       j;
integer                   index;

///////////////// INSTANCE RGB //////////////////
`ifdef RGB_SET
//R instance
//// instance J2K_Decoder_Top Design Top
J2K_Decoder_Top J2K_Decoder_R(
   .dis_ctr(1'b1),
   .dis_idwt(1'b1),
    //// J2K global signals
   .J2K_rst_n(J2K_rst_n),
   .J2K_clk(J2K_clk),
   .J2K_en(J2K_en),
   //// Just for test
   .T1_Dec_State(T1_Dec_State_R), 
   //// Bit Stream ram signals
   .BitStream_Ram_rst_n(BitStream_Ram_rst_n_R),
   .BitStream_Ram_clk(BitStream_Ram_clk_R),
   .BitStream_Ram_cs(BitStream_Ram_cs_R),
   .BitStream_Ram_rd(BitStream_Ram_rd_R),
   .BitStream_Ram_addr(BitStream_Ram_addr_R),
   .BitStream_Ram_din(BitStream_Ram_din_R),
   .BitStream_Ram_dout(BitStream_Ram_dout_R),
   // Frame Ram signals
   .Frame_Ram_rst_n(Frame_Ram_rst_n_R),
   .Frame_Ram_clk(Frame_Ram_clk_R),
   .Frame_Ram_cs(Frame_Ram_cs_R),
   .Frame_Ram_wr(Frame_Ram_wr_R),
   .Frame_Ram_addr(Frame_Ram_addr_R),
   .Frame_Ram_din(Frame_Ram_din_R),
   .Frame_Ram_dout(Frame_Ram_dout_R)
);
//// instance 2
J2K_BitStream_Ram J2K_BS_RAM_R(
   .BitStream_Ram_rst_n(BitStream_Ram_rst_n_R),
   .BitStream_Ram_clk(BitStream_Ram_clk_R),
   .BitStream_Ram_cs(BitStream_Ram_cs_R),
   .BitStream_Ram_rd(BitStream_Ram_rd_R),
   .BitStream_Ram_addr(BitStream_Ram_addr_R),
   .BitStream_Ram_din(BitStream_Ram_din_R),
   .BitStream_Ram_dout(BitStream_Ram_dout_R)
);
//// instance 3
Frame_Ram FRAME_RAM_R(
   .Frame_Ram_rst_n(Frame_Ram_rst_n_R),
   .Frame_Ram_clk(Frame_Ram_clk_R),
   .Frame_Ram_cs(Frame_Ram_cs_R),
   .Frame_Ram_wr(Frame_Ram_wr_R),
   .Frame_Ram_addr(Frame_Ram_addr_R),
   .Frame_Ram_din(Frame_Ram_din_R),
   .Frame_Ram_dout(Frame_Ram_dout_R)
);
    
///G instance
//// instance J2K_Decoder_Top Design Top
J2K_Decoder_Top J2K_Decoder_G(
   .dis_ctr(1'b0),
   .dis_idwt(1'b0),
   //// J2K global signals
   .J2K_rst_n(J2K_rst_n),
   .J2K_clk(J2K_clk),
   .J2K_en(J2K_en),
   //// Just for test
   .T1_Dec_State(T1_Dec_State_G), 
   //// Bit Stream ram signals
   .BitStream_Ram_rst_n(BitStream_Ram_rst_n_G),
   .BitStream_Ram_clk(BitStream_Ram_clk_G),
   .BitStream_Ram_cs(BitStream_Ram_cs_G),
   .BitStream_Ram_rd(BitStream_Ram_rd_G),
   .BitStream_Ram_addr(BitStream_Ram_addr_G),
   .BitStream_Ram_din(BitStream_Ram_din_G),
   .BitStream_Ram_dout(BitStream_Ram_dout_G),
   // Frame Ram signals
   .Frame_Ram_rst_n(Frame_Ram_rst_n_G),
   .Frame_Ram_clk(Frame_Ram_clk_G),
   .Frame_Ram_cs(Frame_Ram_cs_G),
   .Frame_Ram_wr(Frame_Ram_wr_G),
   .Frame_Ram_addr(Frame_Ram_addr_G),
   .Frame_Ram_din(Frame_Ram_din_G),
   .Frame_Ram_dout(Frame_Ram_dout_G)
);
//// instance 2
J2K_BitStream_Ram J2K_BS_RAM_G(
   .BitStream_Ram_rst_n(BitStream_Ram_rst_n_G),
   .BitStream_Ram_clk(BitStream_Ram_clk_G),
   .BitStream_Ram_cs(BitStream_Ram_cs_G),
   .BitStream_Ram_rd(BitStream_Ram_rd_G),
   .BitStream_Ram_addr(BitStream_Ram_addr_G),
   .BitStream_Ram_din(BitStream_Ram_din_G),
   .BitStream_Ram_dout(BitStream_Ram_dout_G)
);
//// instance 3
Frame_Ram FRAME_RAM_G(
   .Frame_Ram_rst_n(Frame_Ram_rst_n_G),
   .Frame_Ram_clk(Frame_Ram_clk_G),
   .Frame_Ram_cs(Frame_Ram_cs_G),
   .Frame_Ram_wr(Frame_Ram_wr_G),
   .Frame_Ram_addr(Frame_Ram_addr_G),
   .Frame_Ram_din(Frame_Ram_din_G),
   .Frame_Ram_dout(Frame_Ram_dout_G)
);
   
//B instance
//// instance J2K_Decoder_Top Design Top
J2K_Decoder_Top J2K_Decoder_B(
   .dis_ctr(1'b0),
   .dis_idwt(1'b0),
   //// J2K global signals
   .J2K_rst_n(J2K_rst_n),
   .J2K_clk(J2K_clk),
   .J2K_en(J2K_en),
   //// Just for test
   .T1_Dec_State(T1_Dec_State_B), 
   //// Bit Stream ram signals
   .BitStream_Ram_rst_n(BitStream_Ram_rst_n_B),
   .BitStream_Ram_clk(BitStream_Ram_clk_B),
   .BitStream_Ram_cs(BitStream_Ram_cs_B),
   .BitStream_Ram_rd(BitStream_Ram_rd_B),
   .BitStream_Ram_addr(BitStream_Ram_addr_B),
   .BitStream_Ram_din(BitStream_Ram_din_B),
   .BitStream_Ram_dout(BitStream_Ram_dout_B),
   // Frame Ram signals
   .Frame_Ram_rst_n(Frame_Ram_rst_n_B),
   .Frame_Ram_clk(Frame_Ram_clk_B),
   .Frame_Ram_cs(Frame_Ram_cs_B),
   .Frame_Ram_wr(Frame_Ram_wr_B),
   .Frame_Ram_addr(Frame_Ram_addr_B),
   .Frame_Ram_din(Frame_Ram_din_B),
   .Frame_Ram_dout(Frame_Ram_dout_B)
);
//// instance 2
J2K_BitStream_Ram J2K_BS_RAM_B(
   .BitStream_Ram_rst_n(BitStream_Ram_rst_n_B),
   .BitStream_Ram_clk(BitStream_Ram_clk_B),
   .BitStream_Ram_cs(BitStream_Ram_cs_B),
   .BitStream_Ram_rd(BitStream_Ram_rd_B),
   .BitStream_Ram_addr(BitStream_Ram_addr_B),
   .BitStream_Ram_din(BitStream_Ram_din_B),
   .BitStream_Ram_dout(BitStream_Ram_dout_B)
);
//// instance 3
Frame_Ram FRAME_RAM_B(
   .Frame_Ram_rst_n(Frame_Ram_rst_n_B),
   .Frame_Ram_clk(Frame_Ram_clk_B),
   .Frame_Ram_cs(Frame_Ram_cs_B),
   .Frame_Ram_wr(Frame_Ram_wr_B),
   .Frame_Ram_addr(Frame_Ram_addr_B),
   .Frame_Ram_din(Frame_Ram_din_B),
   .Frame_Ram_dout(Frame_Ram_dout_B)
);

initial begin
   $readmemh($psprintf("%s%s",data_path,"data_jp2/JP2_DAT32_R.dat"),J2K_BS_RAM_R.BitStream_Ram);
   $readmemh($psprintf("%s%s",data_path,"data_jp2/JP2_DAT32_G.dat"),J2K_BS_RAM_G.BitStream_Ram);
   $readmemh($psprintf("%s%s",data_path,"data_jp2/JP2_DAT32_B.dat"),J2K_BS_RAM_B.BitStream_Ram);
end



assign IDWT_done_R = J2K_Decoder_R.J2K_T1_DECODER_U1.T1_BIT_PLANE_DECODER.IDWT_TOP_U1.IDWT_done;
assign IDWT_done_G = J2K_Decoder_G.J2K_T1_DECODER_U1.T1_BIT_PLANE_DECODER.IDWT_TOP_U1.IDWT_done;
assign IDWT_done_B = J2K_Decoder_B.J2K_T1_DECODER_U1.T1_BIT_PLANE_DECODER.IDWT_TOP_U1.IDWT_done;
always @(IDWT_done_R or IDWT_done_G or IDWT_done_B) begin
   if( IDWT_done_R && IDWT_done_G && IDWT_done_B ) begin
     `ifdef BMP_COLOR_SET
         for(j=0;j<512;j=j+1)
	 for(i=0;i<512;i=i+1)
	 begin
	 index = ((511-j)<<9)+i;
$fwrite(handle,"%c",J2K_Decoder_B.J2K_T1_DECODER_U1.T1_BIT_PLANE_DECODER.IDWT_TOP_U1.Mem.memblk[index]);
$fwrite(handle,"%c",J2K_Decoder_G.J2K_T1_DECODER_U1.T1_BIT_PLANE_DECODER.IDWT_TOP_U1.Mem.memblk[index]);
$fwrite(handle,"%c",J2K_Decoder_R.J2K_T1_DECODER_U1.T1_BIT_PLANE_DECODER.IDWT_TOP_U1.Mem.memblk[index]);
        end // end for
     `else  
        #2 for(i=0;i<262144;i=i+1)
	begin
          $fwrite(handle,"%c",J2K_Decoder_R.J2K_T1_DECODER_U1.T1_BIT_PLANE_DECODER.IDWT_TOP_U1.Mem.memblk[i]);
          $fwrite(handle,"%c",J2K_Decoder_G.J2K_T1_DECODER_U1.T1_BIT_PLANE_DECODER.IDWT_TOP_U1.Mem.memblk[i]);
          $fwrite(handle,"%c",J2K_Decoder_B.J2K_T1_DECODER_U1.T1_BIT_PLANE_DECODER.IDWT_TOP_U1.Mem.memblk[i]);
        end // end for
     `endif 
     
     $fclose(handle);
     $display("\n\n");
     $display("****************************************************");
     $display("**JPEG2000 Decoder Simulation Finished ... ... ...**");
     $display("****************************************************");
     $display("\n");
     #2 $finish;
   end // end if
end // end always 


//////////////////////////////////////////////////////////////////
//
//
//Simulation Initialization 
//
initial 
  begin
  $display("\n\n");
  $display("****************************************************");
  $display("**JPEG2000 Decoder Simulation Started ... ... ... **");
  $display("****************************************************");
  $display("\n");
  J2K_en = 1'b1;
  rst_task;
  `ifdef BMP_COLOR_SET
    handle = $fopen("TestImg.bmp","wb+");
   // m_pfData = fopen(m_strFileName, "w+");
   // 将 "w+“改成为"wb+"就OK了！
   // 原来调用fwrite函数时，如果碰到换行符（0x0A），
   // 编译器会自动转换为回车换行符（0x0D 0x0A），
   // 然后写入文件。
   // 这样写入文件的数据就会与原始数据有差异。
    for(i=0;i<54;i=i+1)begin
      $fwrite(handle,"%c",bmp_color_head_ram[i]);
   end
  `else
    handle = $fopen("TestImg.pnm","wb+");
   // m_pfData = fopen(m_strFileName, "w+");
   // 将 "w+“改成为"wb+"就OK了！
   // 原来调用fwrite函数时，如果碰到换行符（0x0A），
   // 编译器会自动转换为回车换行符（0x0D 0x0A），
   // 然后写入文件。
   // 这样写入文件的数据就会与原始数据有差异。
    $fwrite(handle,"P6\n512 512\n255\n"); //彩色的
  `endif
end



`else
 //// instance J2K_Decoder_Top Design Top
    //
    J2K_Decoder_Top J2K_Decoder(
    //// J2K global signals
      .dis_ctr(1'b1),
      .dis_idwt(1'b1),
      .J2K_rst_n(J2K_rst_n),
      .J2K_clk(J2K_clk),
      .J2K_en(J2K_en),
   //// Just for test
      .T1_Dec_State(T1_Dec_State), 
   //// Bit Stream ram signals
      .BitStream_Ram_rst_n(BitStream_Ram_rst_n),
      .BitStream_Ram_clk(BitStream_Ram_clk),
      .BitStream_Ram_cs(BitStream_Ram_cs),
      .BitStream_Ram_rd(BitStream_Ram_rd),
      .BitStream_Ram_addr(BitStream_Ram_addr),
      .BitStream_Ram_din(BitStream_Ram_din),
      .BitStream_Ram_dout(BitStream_Ram_dout),
   // Frame Ram signals
      .Frame_Ram_rst_n(Frame_Ram_rst_n),
      .Frame_Ram_clk(Frame_Ram_clk),
      .Frame_Ram_cs(Frame_Ram_cs),
      .Frame_Ram_wr(Frame_Ram_wr),
      .Frame_Ram_addr(Frame_Ram_addr),
      .Frame_Ram_din(Frame_Ram_din),
      .Frame_Ram_dout(Frame_Ram_dout)
      );

//// instance 2
//
  J2K_BitStream_Ram J2K_BS_RAM(
      .BitStream_Ram_rst_n(BitStream_Ram_rst_n),
      .BitStream_Ram_clk(BitStream_Ram_clk),
      .BitStream_Ram_cs(BitStream_Ram_cs),
      .BitStream_Ram_rd(BitStream_Ram_rd),
      .BitStream_Ram_addr(BitStream_Ram_addr),
      .BitStream_Ram_din(BitStream_Ram_din),
      .BitStream_Ram_dout(BitStream_Ram_dout)
   );

//// instance 3
//
  Frame_Ram FRAME_RAM(
    .Frame_Ram_rst_n(Frame_Ram_rst_n),
    .Frame_Ram_clk(Frame_Ram_clk),
    .Frame_Ram_cs(Frame_Ram_cs),
    .Frame_Ram_wr(Frame_Ram_wr),
    .Frame_Ram_addr(Frame_Ram_addr),
    .Frame_Ram_din(Frame_Ram_din),
    .Frame_Ram_dout(Frame_Ram_dout)
   );

initial begin
  $readmemh($psprintf("%s%s",data_path,"data_jp2/JP2_DAT32.dat"),J2K_BS_RAM.BitStream_Ram);
end

assign IDWT_done = J2K_Decoder.J2K_T1_DECODER_U1.T1_BIT_PLANE_DECODER.IDWT_TOP_U1.IDWT_done;

//always @(IDWT_done or J2K_Decoder.J2K_T1_DECODER_U1.T1_BIT_PLANE_DECODER.IDWT_TOP_U1.Mem.memblk[index] ) begin
//   if(IDWT_done) begin
//      mem_dat = J2K_Decoder.J2K_T1_DECODER_U1.T1_BIT_PLANE_DECODER.IDWT_TOP_U1.Mem.memblk[index] ;
//   end
//end// end always 


always @(IDWT_done) begin
   if(IDWT_done) begin
     `ifdef BMP_GRAY_SET
        //#2 for(i=262143;i>=0;i=i-1)
        for(j=0;j<512;j=j+1) // bmp图像，从下到上，从左到右顺序排放
	   for(i=0;i<512;i=i+1)
	 begin
             index = ((511-j)<<9)+i;
             $fwrite(handle,"%c",J2K_Decoder.J2K_T1_DECODER_U1.T1_BIT_PLANE_DECODER.IDWT_TOP_U1.Mem.memblk[index]);
    
    $fdisplay(outbmp_data,"%0x",J2K_Decoder.J2K_T1_DECODER_U1.T1_BIT_PLANE_DECODER.IDWT_TOP_U1.Mem.memblk[index]); 
       end // end for

     `else  
        #2 for(i=0;i<262144;i=i+1)
	 begin
       $fwrite(handle,"%c",J2K_Decoder.J2K_T1_DECODER_U1.T1_BIT_PLANE_DECODER.IDWT_TOP_U1.Mem.memblk[i]);
     end // end for
     `endif 
    
     $fclose("outbmp_data"); 
     $fclose(handle);
     $display("\n\n");
     $display("****************************************************");
     $display("**JPEG2000 Decoder Simulation Finished ... ... ...**");
     $display("****************************************************");
     $display("\n");
     #123456
     #2 $finish;
   end // end if
end // end always 

initial 
  begin
  $display("\n\n");
  $display("****************************************************");
  $display("**JPEG2000 Decoder Simulation Started ... ... ... **");
  $display("****************************************************");
  $display("\n");
  J2K_en = 1'b1;
  rst_task;

  `ifdef BMP_GRAY_SET
    handle = $fopen("TestImg.bmp","wb+");
  
  // 当初调色版上有一组数据：ff 0a 0a 0a 这组数据被修改成了 ff xx xx xx
  // 不这么做会有问题  
  // 开始 输出512*512*8位灰度图像的各种头信息
  // (以下是解决方案) 
  // m_pfData = fopen(m_strFileName, "w+");
  // 将 "w+“改成为"wb+"就OK了！
  // 原来调用fwrite函数时，如果碰到换行符（0x0A），
  // 编译器会自动转换为回车换行符（0x0D 0x0A），
  // 然后写入文件。
  // 这样写入文件的数据就会与原始数据有差异。
  
  for(i=0;i<1078;i=i+1)begin
      $fwrite(handle,"%c",bmp_gray_head_ram[i]);
   end
  // 完毕 输出512*512*8位灰度图像的各种头信息
 `else 
     handle = $fopen("TestImg.pnm","wb+");
     $fwrite(handle,"P5\n512 512\n255\n"); //单色的
 `endif

end

`endif
///////////////// INSTANCE RGB //////////////////




   
 
endmodule
