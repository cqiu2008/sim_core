`timescale 1 ns / 1 ns
module tb_lzw_top();
//===Inputs
reg           I_rst                 ;/// 全局复位系统
reg           I_125m_clk   = 1'b0   ;/// system clock
reg           I_250m_clk   = 1'b0   ;/// system clock

//===gmii 
reg   [7:0]   I_gmii_data  = 8'h0   ;
reg           I_compress_en= 1'h0   ;

wire          S_125m_rst            ;/// 125m reset
wire          S_250m_rst            ;/// 250m reset
wire [13:0]   S_compress_data       ;
wire          S_compress_data_en    ;
wire [22:0]   S_dictionary_data     ;
wire [13:0]   S_dictionary_addr     ;
wire          S_dictionary_wren     ;


always #4  I_125m_clk =!I_125m_clk  ;
always #2  I_250m_clk =!I_250m_clk  ;

//====simulation body
initial begin
    task_rst;
    task_delay(10);
    repeat(10)
    begin
        task_l2_test;
    end
end

sync_reset sync_reset_125m_sysclk
(
    .I_reset       (I_rst               ),
    .I_clk         (I_125m_clk          ),
    .O_sync_reset  (S_125m_rst          )
);

sync_reset sync_reset_250m_sysclk
(
    .I_reset       (I_rst               ),
    .I_clk         (I_250m_clk          ),
    .O_sync_reset  (S_250m_rst          )
);

lzw_forward_compress   lzw_forward_compress_inst
(
.I_sys_clk                (I_250m_clk         ), 
.I_sys_rst                (S_250m_rst         ),         
.I_tx_data                (I_gmii_data        ),
.I_tx_data_en             (I_compress_en      ),
.I_dictionary_lock        (1'b0               ),             
.I_state_clr              (1'b0               ), 
.O_compress_data          (S_compress_data    ),                   
.O_compress_data_en       (S_compress_data_en ),
.O_rx_dictionary_data     (S_dictionary_data  ),
.O_rx_dictionary_addr     (S_dictionary_addr  ),
.O_rx_dictionary_data_en  (S_dictionary_wren  ),
.O_uncompress_data_cnt    (                   ),
.O_compress_data_cnt      (                   ),
.O_tx_package_cnt         (                   )
);


lzw_backward_decompress   lzw_backward_decompress_inst
(
.I_sys_clk                (I_250m_clk         ), 
.I_sys_rst                (S_250m_rst         ),         
.I_state_clr              (1'b0               ), 
.I_compress_data          (S_compress_data    ),                   
.I_compress_data_en       (S_compress_data_en ),
.I_dictionary_sync_data   (S_dictionary_data  ),
.I_dictionary_sync_addr   (S_dictionary_addr  ),
.I_dictionary_sync_wren   (S_dictionary_wren  ),
.O_payload_data           (                   ),
.O_payload_data_en        (                   )
);


//====delay task 
task task_delay;
  input [31:0]delay_num ;
  begin
  repeat (delay_num)
  @(posedge I_125m_clk);
  end
endtask

//====rst task
task task_rst;
  begin
   I_rst <= 1'b0 ;
   task_delay(20);
   I_rst <= 1'b1 ;
   task_delay(20);
   I_rst <= 1'b0 ;
  end
endtask


task task_l2_test;
integer i;
    begin 
       for (i = 1; i <= 92; i = i + 1)
         begin
         @(posedge I_125m_clk)
             if ((i >= 1) && (i <= 7))
             begin
                 I_gmii_data     =  8'h55;//preamble
                 I_compress_en   =  0    ;
             end
             else if (i == 8)
             begin
                 I_gmii_data     =  8'hd5;//pleamble
                 I_compress_en   =  0    ;
             end
             else if ((i >= 9) && (i <= 14))
             begin
                 I_gmii_data     =  8'hda;//da
                 I_compress_en   =  0    ;
             end 
             else if ((i >= 15) && (i <= 20))
             begin
                 I_gmii_data     =  8'h5a;//sa
                 I_compress_en   =  0    ;
             end
             else if (i == 21)
             begin
                 I_gmii_data     =  8'ha ;//plplpl
                 I_compress_en   =  1    ;
             end
             else if (i == 22)
             begin
                 I_gmii_data     =  8'hb ;//plplpl
                 I_compress_en   =  1    ;
             end
             else if (i == 23)
             begin
                 I_gmii_data     =  8'ha ;//plplpl
                 I_compress_en   =  1    ;
             end
             else if (i == 24)
             begin
                 I_gmii_data     =  8'hb ;//plplpl
                 I_compress_en   =  1    ;
             end
             else if (i == 25)
             begin
                 I_gmii_data     =  8'hc ;//plplpl
                 I_compress_en   =  1    ;
             end
             else if (i == 26)
             begin
                 I_gmii_data     =  8'hb ;//plplpl
                 I_compress_en   =  1    ;
             end
             else if (i == 27)
             begin
                 I_gmii_data     =  8'ha ;//plplpl
                 I_compress_en   =  1    ;
             end
             else if (i == 28)
             begin
                 I_gmii_data     =  8'hb ;//plplpl
                 I_compress_en   =  1    ;
             end
             else if (i == 29)
             begin
                 I_gmii_data     =  8'hc ;//plplpl
                 I_compress_en   =  1    ;
             end
             else if (i == 30)
             begin
                 I_gmii_data     =  8'hc ;//plplpl
                 I_compress_en   =  1    ;
             end
             else if (i == 31)
             begin
                 I_gmii_data     =  8'hc ;//plplpl
                 I_compress_en   =  1    ;
             end
             else if (i == 32)
             begin
                 I_gmii_data     =  8'hc ;//plplpl
                 I_compress_en   =  1    ;
             end
             else if ((i >= 33) && (i <= 80))
             begin
                 I_gmii_data     =  8'hc ;//plplpl
                 I_compress_en   =  1    ;
             end
             else if ((i >= 81) && (i <= 84))
             begin
                 I_gmii_data     =  8'h04;//crc
                 I_compress_en   =  0    ;
             end
             else
             begin
                 I_gmii_data     =  8'h00;
                 I_compress_en   =  0    ;
             end
         end
     end 
endtask 

////====fsdb
initial begin
   	$helloworld;
  	$fsdbDumpvars("+fsdbfile+tb_dut_top.fsdb");
   	$fsdbDumpSVA;
end

endmodule




