`timescale 1ns / 1ps
//`define SEQUENCE

module tb_dut_top;

reg          I_aclk;
reg          I_arst;
reg          I_awready=1;
reg          I_arready=1;
reg   [31:0] I_lite_awaddr;
reg          I_lite_awvalid;
wire         S_lite_awready;
wire         S_lite_wready;
reg   [31:0] I_wdata;
reg          I_wvalid;
reg  [127:0] I_rdata = 128'h0;
reg          I_rvalid;
reg          I_rlast;
wire         O_arvalid;
reg  [31:0]  I_lite_araddr;
reg          I_lite_arvalid;
wire         S_lite_arready;
wire [31:0]  S_lite_rdata;
wire         O_rready;


initial begin
   I_aclk = 0;
   forever #5 I_aclk = ~I_aclk;
end
    
initial begin
   I_arst = 1;
   #1000
   I_arst = 0;
end


initial begin
addr_config;
//#5000
//addr_config;
//#5100
//addr_config;
//#5000
//addr_config;
//#6000
//addr_config;
//#12000
//addr_config;
//#18000
//addr_config;
//#18000
//addr_config;
end

initial begin
data_config_1;
//#5000
//data_config_2;
//#4900
//data_config_3;
//#5000
//data_config_4;
//#6000
//data_config_5;
//#12000
//data_config_6;
//#18000
//data_config_7;
//#18000
//data_config_8;
end


initial begin
I_lite_arvalid = 0;
forever
#800
@(posedge I_aclk)
begin
I_lite_araddr = 'ha000_0000;
I_lite_arvalid = 1'b1;
end
wait (S_lite_arready)
@(posedge I_aclk)
I_lite_arvalid = 1'b0;
end


initial begin
#2550
byte48x48;
//gen_rfifo_data_288_sequence;
//#6000
//gen_rfifo_data_1024_sequence;
//#5200
//gen_rfifo_data_288_unsequence;
//#5100
//gen_rfifo_data_256_unsequence;
//#8500
//gen_rfifo_data_128x129_sequence;
//#15000
//gen_rfifo_data_272_sequence;
//#15000
//gen_rfifo_data_272_unsequence;
//#15000
//gen_rfifo_data_32x34_unsequence;
end



task addr_config;
begin
#1200
   @(posedge I_aclk)
   begin
   I_lite_awaddr = 32'ha000_0010;
   I_lite_awvalid = 1'b1;
   end
   #1
   wait(S_lite_awready)
   @(posedge I_aclk)
   begin
   I_lite_awvalid = 1'b0;
   end
   
   #300
   @(posedge I_aclk)
   begin
   I_lite_awaddr = 32'ha000_0014;
   I_lite_awvalid = 1'b1;
   end
   #1
   wait(S_lite_awready)
   @(posedge I_aclk)
   begin
   I_lite_awvalid = 1'b0;
   end

   #300
   @(posedge I_aclk)
   begin
   I_lite_awaddr = 32'ha000_0018;
   I_lite_awvalid = 1'b1;
   end
   #1
   wait(S_lite_awready)
   @(posedge I_aclk)
   begin
   I_lite_awvalid = 1'b0;
   end
   
   #300
   @(posedge I_aclk)
   begin
   I_lite_awaddr = 32'ha000_001c;
   I_lite_awvalid = 1'b1;
   end
   #1
   wait(S_lite_awready)
   @(posedge I_aclk)
   begin
   I_lite_awvalid = 1'b0;
   end
   
   #300
   @(posedge I_aclk)
   begin
   I_lite_awaddr = 32'ha000_0000;
   I_lite_awvalid = 1'b1;
   end
   #1
   wait(S_lite_awready)
   @(posedge I_aclk)
   begin
   I_lite_awvalid = 1'b0;
   end
end
endtask

task data_config_1;
begin
#1300
@(posedge I_aclk)
begin
I_wdata = 32'h8000_0000;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'h8c00_0000;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd2304;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd2304;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd1;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end
end
endtask

task data_config_2;
begin
#1300
@(posedge I_aclk)
begin
I_wdata = 32'h8000_0000;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'h8c00_0000;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd1024;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd1024;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd1;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end
end
endtask

task data_config_3;
begin
#1300
@(posedge I_aclk)
begin
I_wdata = 32'h8000_0000;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'h8c00_0000;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd288;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd288;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd1;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end
end
endtask

task data_config_4;
begin
#1300
@(posedge I_aclk)
begin
I_wdata = 32'h8000_0000;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'h8c00_0000;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd256;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd256;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd1;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end
end
endtask

task data_config_5;
begin
#1300
@(posedge I_aclk)
begin
I_wdata = 32'h8000_0000;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'h8c00_0000;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd640;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd640;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd1;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end
end
endtask

task data_config_6;
begin
#1300
@(posedge I_aclk)
begin
I_wdata = 32'h8000_0000;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'h8c00_0000;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd272;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd272;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd1;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end
end
endtask

task data_config_7;
begin
#300
@(posedge I_aclk)
begin
I_wdata = 32'h8000_0000;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'h8c00_0000;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd272;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd272;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd1;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end
end
endtask

task data_config_8;
begin
#300
@(posedge I_aclk)
begin
I_wdata = 32'h8000_0000;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'h8c00_0000;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd1088;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd1088;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end

#300
@(posedge I_aclk)
begin
I_wdata = 32'd1;
I_wvalid = 1'b1;
end
#1
wait(S_lite_wready)
@(posedge I_aclk)
begin
I_wvalid = 1'b0;
end
end
endtask

task gen_rfifo_data_288_sequence;
begin
    #1200
    repeat(15) begin
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
    end
    end
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
        I_rlast <= 1'b1;
    end
    #1
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rlast <= 1'b0;
    end
    
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
        I_rlast <= 1'b1;
    end
    #1
    @(posedge I_aclk)
    begin
        I_rvalid <= 1'b0;
    end
    #600
    @(posedge I_aclk)
    I_rlast <= 1'b0;
end 
endtask;

task gen_rfifo_data_272_sequence;
begin
    #1200
    repeat(15) begin
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
    end
    end//end repeat 15
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
        I_rlast <= 1'b1;
    end
    #1
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rlast <= 1'b1;
    end
    
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b0;
        I_rlast <= 1'b0;
    end
end 
endtask;

task gen_rfifo_data_1024_sequence;
begin
    #1200
    repeat(4) begin
    repeat(15) begin
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
    end
    end//end 15
    #1
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
        I_rlast <= 1'b1;
    end
    #1
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b0;
        I_rlast <= 1'b0;
    end
    end//end 4
end 
endtask;

task gen_rfifo_data_128x129_sequence;
begin
    repeat(2) begin
    #1200
    repeat(15) begin
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
    end
    end//end repeat 15
    #1
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
        I_rlast <= 1'b1;
    end
    #1
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b0;
        I_rlast <= 1'b0;
    end
    end//end 2
    #500
    
    #1200
    repeat(7) begin
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
    end
    end//end repeat 7
    #1
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
        I_rlast <= 1'b1;
    end
    #1
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b0;
        I_rlast <= 1'b0;
    end
end 
endtask;

task gen_rfifo_data_288_unsequence;
begin
    #1200
    repeat(15) begin
    #200
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
    end
    #1
    @(posedge I_aclk)
    begin
        I_rvalid <= 1'b0;
    end
    end
    #200
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
        I_rlast <= 1'b1;
    end
    #1
    @(posedge I_aclk)
    begin
        I_rvalid <= 1'b0;
        I_rdata <= I_rdata + 1;
        I_rlast <= 1'b0;
    end
    
    #200
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
    end
    #1
    @(posedge I_aclk)
    begin
        I_rvalid <= 1'b0;
    end
    
    #200
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
        I_rlast <= 1'b1;
    end
    #1
    @(posedge I_aclk)
    begin
        I_rvalid <= 1'b0;
    end
    #600
    @(posedge I_aclk)
    I_rlast <= 1'b0;
//    end
end 
endtask;

task gen_rfifo_data_272_unsequence;
begin
    #1200
    repeat(15) begin
    #200
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
    end
    #1
    @(posedge I_aclk)
    begin
        I_rvalid <= 1'b0;
    end
    end//end repeat 15
    #200
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
        I_rlast <= 1'b1;
    end
    #1
    @(posedge I_aclk)
    begin
        I_rvalid <= 1'b0;
        I_rlast <= 1'b0;
    end
    
    #200
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
        I_rlast <= 1'b1;
    end
    #1
    @(posedge I_aclk)
    begin
        I_rvalid <= 1'b0;
        I_rlast <= 1'b0;
    end
    
end 
endtask;


task gen_rfifo_data_256_unsequence;
begin
    #1200
    repeat(15) begin
    #200
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
    end
    #1
    @(posedge I_aclk)
    begin
        I_rvalid <= 1'b0;
    end
    end//end 15
    #200
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
        I_rlast <= 1'b1;
    end
    #1
    @(posedge I_aclk)
    begin
        I_rvalid <= 1'b0;
        I_rdata <= I_rdata + 1;
        I_rlast <= 1'b0;
    end
    
end 
endtask;

task gen_rfifo_data_32x34_unsequence;//1024+64
begin
    repeat(4) begin
    #100
    repeat(15) begin
        @(posedge I_aclk) begin
            I_rdata <= I_rdata + 1;
            I_rvalid <= 1'b1;
        end
    end//end repeat 15
    #1
    @(posedge I_aclk) begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
        I_rlast <= 1'b1;
    end
    #1
    @(posedge I_aclk) begin
        I_rvalid <= 1'b0;
        I_rlast <= 1'b0;
    end
    end//end repeat 4
    
    #100
    repeat(3) begin
        @(posedge I_aclk) begin
            I_rdata <= I_rdata + 1;
            I_rvalid <= 1'b1;
        end
    end//end repeat 3
    #1
    @(posedge I_aclk)
    begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
        I_rlast <= 1'b1;
    end
    #1
    @(posedge I_aclk)
    begin
        I_rvalid <= 1'b0;
        I_rlast <= 1'b0;
    end
end 
endtask;

task byte48x48;
begin
    repeat(4) begin
      #80
      repeat(15)begin
      @(posedge I_aclk)
      begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
      end
      end//repeat 15
      #1
      @(posedge I_aclk) begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
        I_rlast <= 1'b1;
      end
      #1
      @(posedge I_aclk)begin
        I_rvalid <= 1'b0;
        I_rlast <= 1'b0;
      end
      end//repeat 4
      
      #1000
      repeat(15)begin
      @(posedge I_aclk)
      begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
      end
      end//repeat 15
      #1
      @(posedge I_aclk) begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
        I_rlast <= 1'b1;
      end
      #1
      @(posedge I_aclk)begin
        I_rvalid <= 1'b0;
        I_rlast <= 1'b0;
      end //end 5th burst
      
      #1200
      repeat(8) begin
      @(posedge I_aclk) begin
          I_rdata <= I_rdata + 1;
          I_rvalid <= 1'b1;
      end
      end//repeat 8
      #1
      @(posedge I_aclk)begin
          I_rvalid <= 1'b0;
      end
      
      #800
      repeat(7) begin
      @(posedge I_aclk) begin
          I_rdata <= I_rdata + 1;
          I_rvalid <= 1'b1;
      end
      end//repeat 7
      #1
      @(posedge I_aclk) begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
        I_rlast <= 1'b1;
      end
      #1
      @(posedge I_aclk)
      begin
      I_rdata <= I_rdata + 1;
      I_rlast <= 1'b0;
      end //end 6th burst
      
      #1
      repeat(7) begin
      @(posedge I_aclk) begin
          I_rdata <= I_rdata + 1;
          I_rvalid <= 1'b1;
      end
      end//repeat 8
      @(posedge I_aclk)begin
      I_rvalid <= 1'b0;
      end
      
      #500
      repeat(7) begin
      @(posedge I_aclk) begin
          I_rdata <= I_rdata + 1;
          I_rvalid <= 1'b1;
      end
      end//repeat 7
      #1
      @(posedge I_aclk) begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
        I_rlast <= 1'b1;
      end
      #1
      @(posedge I_aclk)
      begin
      I_rdata <= I_rdata + 1;
      I_rlast <= 1'b0;
      end //end 7th burst
      
      #1
      repeat(7) begin
      @(posedge I_aclk) begin
          I_rdata <= I_rdata + 1;
          I_rvalid <= 1'b1;
      end
      end//repeat 8
      @(posedge I_aclk)begin
          I_rvalid <= 1'b0;
      end
      
      #500
      repeat(7) begin
      @(posedge I_aclk) begin
          I_rdata <= I_rdata + 1;
          I_rvalid <= 1'b1;
      end
      end//repeat 7
      #1
      @(posedge I_aclk) begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
        I_rlast <= 1'b1;
      end
      #1
      @(posedge I_aclk)
      begin
      I_rdata <= I_rdata + 1;
      I_rlast <= 1'b0;
      end //end 8th burst
      
      #1
      repeat(7) begin
      @(posedge I_aclk) begin
          I_rdata <= I_rdata + 1;
          I_rvalid <= 1'b1;
      end
      end//repeat 8
      @(posedge I_aclk)begin
          I_rvalid <= 1'b0;
      end
      
      #500
      repeat(7) begin
      @(posedge I_aclk) begin
          I_rdata <= I_rdata + 1;
          I_rvalid <= 1'b1;
      end
      end//repeat 7
      #1
      @(posedge I_aclk) begin
        I_rdata <= I_rdata + 1;
        I_rvalid <= 1'b1;
        I_rlast <= 1'b1;
      end
      #1
      @(posedge I_aclk)
      begin
      I_rlast <= 1'b0;
      I_rvalid <= 1'b0;
      end //end 9th burst
      
end
endtask;


axi_test_top#(
    .C_DATA_WIDTH  (128),
    .C_ADDR_WIDTH  (32),
    .C_LITE_DWIDTH (32)
)axi_test_top(
    .I_aclk(I_aclk),
    .I_arst(~I_arst),
    //axi_mem
    .I_awready(I_awready),
    .I_bresp(),
    .I_bvalid(),
    .I_wready(1'b1),
    .I_bid(),
    .O_awlock(),
    .O_awid(),
    .O_awburst(),
    .O_awcache(),
    .O_awprot(),
    .O_awsize(),
    .O_bready(),
    .O_wstrb(),
    .O_awaddr(),
    .O_awlen(),
    .O_awvalid(),
    .O_wdata(),
    .O_wlast(),
    .O_wvalid(),
    //axi read
    .I_arready(I_arready),
    .I_rdata(I_rdata),
    .I_rvalid(I_rvalid),
    .I_rlast(I_rlast),
    .I_rresp(),
    .I_rid(),
    .O_arburst(),
    .O_arcache(),
    .O_arprot(),
    .O_arsize(),
    .O_arid(),
    .O_arlock(),
    .O_araddr(),
    .O_arlen(),
    .O_arvalid(O_arvalid),
    .O_rready(O_rready),
    //axi lite
    .O_lite_awready(S_lite_awready),
    .I_lite_awaddr(I_lite_awaddr),
    .I_lite_awvalid(I_lite_awvalid),
    .O_lite_wready(S_lite_wready),
    .I_lite_wdata(I_wdata),
    .I_lite_wvalid(I_wvalid),
    .I_lite_wstrb(),
    .I_lite_bready(),
    .O_lite_bresp(),//okay
    .O_lite_bvalid(),
    .O_lite_arready(S_lite_arready),
    .I_lite_araddr(I_lite_araddr),
    .I_lite_arvalid(I_lite_arvalid),
    .I_lite_rready(1'b1),
    .O_lite_rdata(S_lite_rdata),
    .O_lite_rvalid(),
    .O_lite_rresp()
 );
 
////====fsdb
initial begin
   	$helloworld;
  	$fsdbDumpvars("+fsdbfile+tb_dut_top.fsdb");
   	$fsdbDumpSVA;
end

endmodule
