// `timescale 1ns / 100ps

`include "sva/sva_check_result.sv"

module tb_dut_top;

parameter ASIZE = 10				;
parameter DSIZE =  8				;

reg                 wrst    		;
reg                 wclk    		;
reg                 winc    		;
reg     [DSIZE-1:0] wdata   		;
wire				wfull  			; 
reg	                rrst    		;
reg	                rclk    		;
reg	                rinc    		;
wire   [DSIZE-1:0]  rdata   		;
wire                rempty  		;
wire   [DSIZE-1:0]  rdata_golden	;
wire                rempty_golden  	;

`include "wclk_and_wrst_tsk.svh"
`include "rclk_and_rrst_tsk.svh"

////////////////////////////////////////////////////////////////////////////////////////////////////
//		write_fifo_clear	
////////////////////////////////////////////////////////////////////////////////////////////////////
task write_fifo_clear;
begin
	wdata = 0;
	winc = 0;
end
endtask
////////////////////////////////////////////////////////////////////////////////////////////////////
//		read_fifo_clear	
////////////////////////////////////////////////////////////////////////////////////////////////////
task read_fifo_clear;
begin
	rinc = 0;
end
endtask
////////////////////////////////////////////////////////////////////////////////////////////////////
//		write_fifo
////////////////////////////////////////////////////////////////////////////////////////////////////
integer i;
task write_fifo;
input [31:0] length;
begin
	winc  = 1;
	for(i=0;i<length;i=i+1)begin
		wdata = i+1;
		repeat(1) @(posedge wclk);        
	end
	winc  = 0;
end
endtask
////////////////////////////////////////////////////////////////////////////////////////////////////
//		read_fifo	
////////////////////////////////////////////////////////////////////////////////////////////////////
integer j;
task read_fifo;
input [31:0] length;
begin
	rinc = 1;
	for(j=0;j<length;j=j+1)begin
		repeat(1) @(posedge rclk);        
	end
	rinc = 0;
end
endtask
////////////////////////////////////////////////////////////////////////////////////////////////////
//		dly_read_fifo	
////////////////////////////////////////////////////////////////////////////////////////////////////
task dly_read_fifo;
input [31:0] length;
begin
	repeat (10) @(posedge rclk);
	read_fifo(length);
end
endtask
////////////////////////////////////////////////////////////////////////////////////////////////////
//		instance real	
////////////////////////////////////////////////////////////////////////////////////////////////////
asyn_fifo #(ASIZE,DSIZE) u0_asyn_fifo(
	.I_wrst    (wrst     ),
	.I_wclk    (wclk     ),
	.I_winc    (winc     ),
	.I_wdata   (wdata    ),
	.O_wfull   (wfull    ),
	.I_rrst    (rrst     ),
	.I_rclk    (rclk     ),
	.I_rinc    (rinc     ),
	.O_rdata   (rdata    ),
	.O_rempty  (rempty   )  
);
////////////////////////////////////////////////////////////////////////////////////////////////////
//		instance golden 
////////////////////////////////////////////////////////////////////////////////////////////////////
beh_fifo #(ASIZE,DSIZE) u0_golden_asyn_fifo(
	.wrst    (wrst     		),
	.wclk    (wclk     		),
	.winc    (winc     		),
	.wdata   (wdata    		),
	.wfull   (wfull    		),
	.rrst    (rrst     		),
	.rclk    (rclk     		),
	.rinc    (rinc     		),
	.rdata   (rdata_golden  ),
	.rempty  (rempty_golden )  
);
////////////////////////////////////////////////////////////////////////////////////////////////////
//		process sva	
////////////////////////////////////////////////////////////////////////////////////////////////////
reg sva_clk = 0;
always #5 sva_clk=~sva_clk;

reg sva_sync = 0;
always @(posedge rclk)begin
	if(rinc) begin
		sva_sync <= 1'b1;
	end
end

reg sva_result_rdata= 1'b0;
always @(posedge rclk)begin
	if(sva_sync)begin
		sva_result_rdata <= (rdata == rdata_golden);
	end
	else begin
		sva_result_rdata <= 1'b0;
	end
end

// sva_check_result u0_sva_check_rdata (
//   .sva_clk 		    (sva_clk			    ),
// 	.sva_sync_state	(sva_sync			    ),
// 	.sva_chk_edge 	(rclk				      ),
// 	.sva_chk_result (sva_result_rdata	)
// );
// 
// reg sva_result_rempty = 1'b0;
// always @(posedge rclk)begin
// 	if(sva_sync)begin
// 		sva_result_rempty <= (rempty == rempty_golden);
// 	end
// 	else begin
// 		//sva_result_rempty <= 1'b0; 
// 		sva_result_rempty <= 1'b1; 
// 	end
// end
// 
// sva_check_result u0_sva_check_rempty (
// 	.sva_clk 		    (sva_clk			    ),
// 	.sva_sync_state	(sva_sync			    ),
// 	.sva_chk_edge 	(rclk				      ),
// 	.sva_chk_result (sva_result_rempty)
// );

////////////////////////////////////////////////////////////////////////////////////////////////////
//		main body	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
	write_fifo_clear;
	read_fifo_clear;
	fork
		wrst_tsk(30);
		rrst_tsk(20);
	join
	fork 
		write_fifo(30);
		dly_read_fifo(30);
	join
	fork 
		write_fifo(80);
		dly_read_fifo(81);
	join
	fork 
		write_fifo(90);
		dly_read_fifo(90);
	join

	#1000 $finish;
end
////////////////////////////////////////////////////////////////////////////////////////////////////
//		generate fsdb	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
   	//$helloworld;
  	$fsdbDumpvars("+fsdbfile+tb_dut_top.fsdb");
	  $fsdbDumpMDA(u0_asyn_fifo.mem,0,8);
   	$fsdbDumpSVA;
end

typedef bit[7:0]  BYTE;
typedef bit[15:0] WORD;
typedef int DWORD     ;
typedef int LONG      ;

`define BI_BITFIELDS 8'h03 

typedef struct packed {
	DWORD bfOffBits   ;//位图数据的起始位置，以相对于位图（11-14字节，低位在前）
	WORD  bfReserved2 ;//位图文件保留字，必须为0(9-10字节）
	WORD  bfReserved1 ;//位图文件保留字，必须为0(7-8字节）
	DWORD bfSize      ;//位图文件的大小，以字节为单位（3-6字节，低位在前）
	WORD  bfType      ;//位图文件的类型，在Windows中，此字段的值总为‘BM’(1-2字节）
	//文件头的偏移量表示，以字节为单位
} BitMapFileHeader  ;//BITMAPFILEHEADER;

typedef struct packed {
	DWORD biClrImportant  ;//位图显示过程中重要的颜色数（51-54字节）
	DWORD biClrUsed       ;//位图实际使用的颜色表中的颜色数（47-50字节）
	LONG  biYPelsPerMeter ;//位图垂直分辨率，像素数（43-46字节)
	LONG  biXPelsPerMeter ;//位图水平分辨率，像素数（39-42字节）
	DWORD biSizeImage     ;//位图的大小(其中包含了为了补齐行数是5的倍数而添加的空字节)，以字节为单位（35-38字节）
	DWORD biCompression   ;//位图压缩类型，必须是0（不压缩），（31-34字节）
	//1(BI_RLE8压缩类型）或2(BI_RLE4压缩类型）之一
	WORD  biBitCount      ;//每个像素所需的位数，必须是1（双色），（29-30字节）
	//4(16色），8(256色）16(高彩色)或24（真彩色）之一
	WORD  biPlanes        ;//目标设备的级别，必须为1(27-28字节）
	LONG  biHeight        ;//位图的高度，以像素为单位（23-26字节）
	LONG  biWidth         ;//位图的宽度，以像素为单位（19-22字节）
	DWORD biSize          ;//本结构所占用字节数（15-18字节）
} BitMapInfoHeader      ;//BITMAPINFOHEADER;
 
typedef struct packed {
	BYTE rgbReserved  ;//保留，必须为0
	BYTE rgbRed       ;//红色的亮度（值范围为0-255)
	BYTE rgbGreen     ;//绿色的亮度（值范围为0-255)
	BYTE rgbBlue      ;//蓝色的亮度（值范围为0-255)
} RgbQuad           ;//RGBQUAD;

typedef struct packed {
  RgbQuad [2:0]     bmiClr         ;//RGBQUAD;
  BitMapInfoHeader  bmiHdr         ;//BITMAPINFOHEADER;
  BitMapFileHeader  bmfHdr         ;//BITMAPFILEHEADER;
} sRgb565Header;

function initRgb565(
  input [31:0] width          ,//位图的宽度，以像素为单位（19-22字节）
  input [31:0] height         ,//位图的高度，以像素为单位（23-26字节） 
  ref sRgb565Header sh          
);
  begin
  	sh.bmiHdr.biSize = $bits(BitMapInfoHeader)/8;
  	sh.bmiHdr.biWidth = width;//指定图像的宽度，单位是像素
  	sh.bmiHdr.biHeight = height;//指定图像的高度，单位是像素
  	sh.bmiHdr.biPlanes = 1;//目标设备的级别，必须是1
  	sh.bmiHdr.biBitCount = 16;//表示用到颜色时用到的位数 16位表示高彩色图
  	sh.bmiHdr.biCompression = `BI_BITFIELDS;//BI_RGB仅有RGB555格式
  	sh.bmiHdr.biSizeImage = (width * height * 2);//指定实际位图所占字节数
  	sh.bmiHdr.biXPelsPerMeter = 0;//水平分辨率，单位长度内的像素数
  	sh.bmiHdr.biYPelsPerMeter = 0;//垂直分辨率，单位长度内的像素数
  	sh.bmiHdr.biClrUsed = 0;//位图实际使用的彩色表中的颜色索引数（设为0的话，则说明使用所有调色板项）
  	sh.bmiHdr.biClrImportant = 0;//说明对图象显示有重要影响的颜色索引的数目，0表示所有颜色都重要
  	//RGB565格式掩码
  	sh.bmiClr[0].rgbBlue = 0;
  	sh.bmiClr[0].rgbGreen = 8'hF8;
  	sh.bmiClr[0].rgbRed = 0;
  	sh.bmiClr[0].rgbReserved = 0;
  	sh.bmiClr[1].rgbBlue = 8'hE0;
  	sh.bmiClr[1].rgbGreen = 8'h07;
  	sh.bmiClr[1].rgbRed = 0;
  	sh.bmiClr[1].rgbReserved = 0;
  	sh.bmiClr[2].rgbBlue = 8'h1F;
  	sh.bmiClr[2].rgbGreen = 0;
  	sh.bmiClr[2].rgbRed = 0;
  	sh.bmiClr[2].rgbReserved = 0;
  	sh.bmfHdr.bfType = 16'h4D42;//文件类型，0x4D42也就是字符'BM'
  	sh.bmfHdr.bfOffBits = ($bits(BitMapFileHeader) + 
                           $bits(BitMapInfoHeader) + 
                           $bits(RgbQuad) * 3)/8;//实际图像数据偏移量
  	sh.bmfHdr.bfSize = (sh.bmfHdr.bfOffBits + sh.bmiHdr.biSizeImage);//文件大小
  	sh.bmfHdr.bfReserved1 = 0;//保留，必须为0
  	sh.bmfHdr.bfReserved2 = 0;//保留，必须为0
  end
endfunction

integer k;
bit[15:0] endNum;
bit[$bits(sRgb565Header)/8-1:0][7:0]shape1;
bit[7:0]tmpShape[];

initial begin

  sRgb565Header sh;
  initRgb565(16,16,sh);
  shape1 = {>>BYTE{sh}};
  endNum=$bits(sRgb565Header)/8;
  tmpShape = new[endNum];
  for(k=0;k<$bits(sRgb565Header)/8;k=k+1)begin
    tmpShape[endNum-k-1] = shape1[k];
    $write("%2h ::%2h---",shape1[k],tmpShape[endNum-k-1]);
    if((k+1)%16 == 0)begin
      $write("\n");
    end
  end
  $display("bmiHdr.biSize   =%4d",sh.bmiHdr.biSize);
  $display("bmfHdr.bfSize   =%4d",sh.bmfHdr.bfSize);
  $display("bmfHdr.bfOffBits=%4d",sh.bmfHdr.bfOffBits);
end

endmodule
