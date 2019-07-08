`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/04 11:23:25
// Design Name: 
// Module Name: pooling_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pooling_tb;

reg [7:0] mem [0:500];
reg clk;
reg rst;
wire [7:0] Odata;
wire line_finish;

reg [7:0]  kernel_w;
reg [7:0]  stride;
reg [7:0]  wigth;

reg [7:0] Idata; 
reg [7:0] i,j,k , k1;
reg Ien;
reg flag;
reg [7:0] n;
wire data_valid;
wire finish;

integer out_1;

reg data_valid_reg;
reg[7:0] Odata_reg;

reg[7:0]  line_num;

reg file_closed_flag;


initial begin
  $readmemh("/home/cqiu/AIPrj/sim/sim_poolwz/tb/btc/qst_vrd_nuvm_vvd1602_nhls_tc1_poolwz/beforePoolConv1_2.dat",mem);//data.txt
  
      kernel_w=8'd4;
      stride =8'd3;
      wigth = 8'd30;
      clk=1'b0;
      rst=1'b0;
      i=8'd0; 
      j=8'd0;
      line_num <= 8'd0;
      n <= 8'd1;
      Ien<=1;
      flag <=0;
      k <=8'd0;
      k1 <= 8'd0;
      file_closed_flag <= 1'b0;
  #12  rst=1'b1;
  
end

always #5 clk =~clk;

always @(posedge clk)
begin
  if(rst)begin 

    data_valid_reg <= data_valid;
    Odata_reg <= Odata;

    if(i < wigth)  begin
        
        Idata[7:0] =mem[i+k]; 
        
        if(i == 4*j*stride  + 3 * stride + kernel_w-8'd1)
          begin
            j <= j+1; 
            i <= i-(kernel_w-stride) + 1;
          end         
        else i<=i+1;
     
    end
    
    else  begin
        
        if(!flag)begin 
             Ien<=0;         
           end
        else begin              
            i<=0;  
            k <= 1 + wigth *n;
            n <=n+1; 
            if(line_num >=  kernel_w - 8'd1) begin
               Ien<= 8'd1;
               line_num <= 8'd0;

                k1<= k1 + 8'd1;                 
               end 
            else  begin
                Ien <=1;
                line_num <= line_num + 8'd1;
               end
               
         end   
        j<=0;
      end 
      
    if(line_finish) begin
        flag <=1;
      end
    else flag <=0;
      
  end
  
  /*
     if(data_valid_reg && (k1 <= 8'd10) ) begin
         $fwrite(out_1,"%h  ",Odata_reg);   
      end
  */   
 
  
  
end



pooling  u0_pooling(
                .I_clk(clk),
                .I_rst_n(rst),
                .I_data(Idata),   
                .I_data_en(Ien),
                .I_kernel(kernel_w),
                .I_stride(stride),
                .I_line_wigth(wigth),
                .I_line_num(line_num),
                .O_data(Odata),
                .O_line_finish(line_finish),
                .O_finish(finish),
                .O_data_valid(data_valid)
                );


initial begin
	#30000 // 30 us
	$stop;
end

////////////////////////////////////////////////////////////////////////////////////////////////////
//		generate fsdb	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
   	$helloworld;
  	$fsdbDumpvars("+fsdbfile+tb_dut_top.fsdb");
   	$fsdbDumpSVA;
end



endmodule
