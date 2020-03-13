////////////////////////////////////////////////////////////////////////////////////////////////////
//  
//  TASKS 
//  
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
//  ssictrl_init
////////////////////////////////////////////////////////////////////////////////////////////////////
task ssictrl_init;
  begin
    writereg(REG_BASE+0,3);
    //[ 9: 0]BASE_ADDR ;// 0 
    //       sste      ;// 1 CTRLR0[24] slave select toggle enable
    //[ 1: 0]spi_frf   ;// 2 CTRLR0[22:21] slave frame format 
    //[ 4: 0]dfs_32    ;// 3 CTRLR0[20:16] data frame bits = dfs_32 + 1
    //[ 3: 0]cfs       ;// 4 CTRLR0[15:12] control frame size = cfs + 1
    //       srl       ;// 5 CTRLR0[11]  for testing purposes 
    //       slv_oe    ;// 6 CTRLR0[10]  slv output enable 
    //[ 1: 0]tmod      ;// 7 CTRLR0[9:8] Transfer Mode,==00 T/R,==01 only T ==10 only R
    //       scpol     ;// 8 CTRLR0[7] =0, inactive when serial clock is low 
    //       scph      ;// 9 CTRLR0[6] =0, data valid at 1st edge of serial clk
    //[ 5: 4]frf       ;//10 CTRLR0[5:4] =0, motorolla spi frame format 
    //[ 3: 0]dfs       ;//11 CTRLR0[3:0] when SSI_MAX_XFER_SIZE = 16, it is valid 
    //            BASE_ADDR ,sste,spi_frf,dfs_32,cfs,srl,slv_oe,tmod,scpol,scph,frf,dfs
    wregssi_ctrl0(MST_BASE  ,   0,      0,    23,  7,  0,     0,   0,    0,   0,  0,  0);
    wregssi_ctrl1(MST_BASE,0);
    wregssi_baudr(MST_BASE,6);
    wregssi_txftlr(MST_BASE,8'h10);
    wregssi_rxftlr(MST_BASE,8'h10);
    wregssi_imr(MST_BASE,0,0,0,0,0,0);
    wregssi_ser(MST_BASE,1);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  setssi_bytes
////////////////////////////////////////////////////////////////////////////////////////////////////
task setssi_bytes;
  input [ 7: 0] in_bytes  ;
  reg   [15: 0] in_bits   ;
  begin
    //S1 Disable DW_apb_ssi 
    wregssi_en(MST_BASE,DISABLE)                                                          ;
    //S2:Configure Master by write  CTRLR0,CTRLR1,BAUDR,TXFTLR,
    //                              RXFTLR,MWCR,IMR,SER
    in_bits = in_bytes * 8 - 1                                                            ;
    writereg(REG_BASE+0,3)                                                                ;
    //            BASE_ADDR ,sste,spi_frf, dfs_32,cfs,srl,slv_oe,tmod,scpol,scph,frf,dfs
    wregssi_ctrl0(MST_BASE  ,   0,      0,in_bits,  7,  0,     0,   0,    0,   0,  0,  0) ;
    wregssi_ctrl1(MST_BASE,0)                                                             ;
    wregssi_baudr(MST_BASE,6)                                                             ;
    wregssi_txftlr(MST_BASE,8'h10)                                                        ;
    wregssi_rxftlr(MST_BASE,8'h10)                                                        ;
    wregssi_imr(MST_BASE,0,0,0,0,0,0)                                                     ;
    wregssi_ser(MST_BASE,1)                                                               ;
    //S3 Enable DW_apb_ssi 
    wregssi_en(MST_BASE,ENABLE)                                                           ;
  end
endtask
     
// ////////////////////////////////////////////////////////////////////////////////////////////////////
// //  latch_read 
// ////////////////////////////////////////////////////////////////////////////////////////////////////
// wire SO_preedge;
// assign #1 SO_preedge = so_so1;
// 
// task latch_read;
//   integer index;
//   begin
//     index = 7;
//     if (x4_output_mode) begin
//       repeat (2)begin
//         @(negedge SCK);
//   	    // in x4 mode, hold pin is ufsed as output
//         rd_data[index  ] <= hold_so3;
//         rd_data[index-1] <= wpn_so2;
//         rd_data[index-2] <= SO_preedge;
//         rd_data[index-3] <= si_so0;
//         index = index -4;
//       end
//     end 
//     else if (x2_output_mode) begin
//       repeat (4)begin
//         @(negedge SCK);
//         if (HOLD_N ) begin
//           rd_data[index  ] <= SO_preedge;
//   	      rd_data[index-1] <= si_so0;
//           index = index -2;
//         end 
//         else begin
//           wait(HOLD_N);
//           wait (so_so1 !== 1'bz);
//           //@(posedge SCK);
//   	      @(negedge SCK);
//           rd_data[index  ] <= so_so1;
//   	      rd_data[index-1] <= si_so0;
//           index = index -2;
//         end
//       end
//     end 
//     else begin // x1_output_mode
//       repeat (8)begin
//         @(negedge SCK);
//         if (HOLD_N) begin
//           rd_data[index] <= SO_preedge;
//           index = index -1;
//         end 
//         else begin
//           wait(HOLD_N);
//           wait (so_so1 !== 1'bz);
//           //@(posedge SCK);
//   	      @(negedge SCK);
//           rd_data[index] <= so_so1;
//           index = index -1;
//         end
//       end
//     end
//   end
// endtask
// 
// ////////////////////////////////////////////////////////////////////////////////////////////////////
// //  latch_data
// ////////////////////////////////////////////////////////////////////////////////////////////////////
// reg last_holdn = 1;
// always @(posedge SCK) last_holdn <= HOLD_N ;
// 
// task latch_data;
//   input [DQ_BITS -1 :0] data;
//   integer index;
//   begin
//     data_in = 1;
//     index = 7;
//     wait(last_holdn);
//     repeat (8)begin
//       SI <= data[index];
//       index = index -1;
//       @(posedge SCK);
//       #1;
//       wait(last_holdn);
//       @(negedge SCK);
//     end
//     //@(posedge SCK) #tHDDAT_min; // make sure to hold data long enough after clock edge
//     data_in = 0;
//     //#1;
//   end
// endtask
// 
// ////////////////////////////////////////////////////////////////////////////////////////////////////
// //  latch_data_x4
// ////////////////////////////////////////////////////////////////////////////////////////////////////
// task latch_data_x4;
//   input [DQ_BITS -1 :0] data;
//   integer index;
//   begin
//     data_in = 1;
//     index = 7;
//     //wait(last_holdn);
//     repeat (2)begin
//       HOLD_N  <= data[index];
//   	  WP_N    <= data[index-1];
//   	  SO      <= data[index-2];
//   	  SI      <= data[index-3];
//       index   = index -4;
//       @(posedge SCK);
//       #1;
//       //wait(last_holdn);
//       @(negedge SCK);
//     end
//     //@(posedge SCK) #tHDDAT_min; // make sure to hold data long enough after clock edge
//     data_in = 0;
//     //#1;
//   end
// endtask	
// 
// ////////////////////////////////////////////////////////////////////////////////////////////////////
// //  latch_command
// ////////////////////////////////////////////////////////////////////////////////////////////////////
// task latch_command;
//   input [7:0] cmd;
//   integer index;
//   begin
//     if (CS_N)
//       @(negedge SCK);
//     CS_N  <= 0;
//     index = 7;
//     repeat (8)begin
//       SI <= cmd[index];
//       index = index -1;
//       @(negedge SCK);
//     end
//     //#1;
//   end
// endtask
// 
// ////////////////////////////////////////////////////////////////////////////////////////////////////
// //  latch_address
// ////////////////////////////////////////////////////////////////////////////////////////////////////
// task latch_address;
//   input [23:0] addr;
//   input [3:0] size;
//   integer index, cnt;
//   begin
//     address_in = 1;
//     index = size * 8 -1;
//     cnt = size * 8;
//     //SI = addr[index];
//     repeat (cnt)begin
//       SI = addr[index];
//       index = index -1;
//       @(negedge SCK);
//     end
//     address_in = 0;
//     //#1;
//   end
// endtask
// 
// ////////////////////////////////////////////////////////////////////////////////////////////////////
// //  latch_address_x2
// ////////////////////////////////////////////////////////////////////////////////////////////////////
// task latch_address_x2;
//   input [23:0] addr;
//   input [3:0] size;
//   integer index, cnt;
//   begin
//     address_in = 1;
//     index = size * 8 -1;
//     cnt = 8;
//     //SI = addr[index];
//     repeat (cnt)begin
//       SO = addr[index];
//       SI = addr[index-1];
//       index = index -2;
//       @(negedge SCK);
//     end
//     address_in = 0;
//     //#1;
//   end
// endtask
// 
// ////////////////////////////////////////////////////////////////////////////////////////////////////
// //  latch_address_x4
// ////////////////////////////////////////////////////////////////////////////////////////////////////
// task latch_address_x4;
//   input [23:0] addr;
//   input [3:0] size;
//   integer index, cnt;
//   begin
//     address_in = 1;
//     index = size * 8 -1;
//     cnt = 4;
//     //SI = addr[index];
//     repeat (cnt)begin
//       HOLD_N = addr[index];
//       WP_N   = addr[index-1];
//       SO     = addr[index-2];
//       SI     = addr[index-3];
//       index = index -4;
//       @(negedge SCK);
//     end
//     address_in = 0;
//     //#1;
//   end
// endtask
// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
//  idle
////////////////////////////////////////////////////////////////////////////////////////////////////
task idle;
  begin
  `ifdef IPEN
  `else
    CS_N = 1;        
  `endif
  end
endtask
    
////////////////////////////////////////////////////////////////////////////////////////////////////
//  standby
////////////////////////////////////////////////////////////////////////////////////////////////////
task standby;
  input real delay;
  begin
  `ifdef IPEN 
    pclkdly(delay);
  `else 
    CS_N <= 1;
    if (x4_output_mode || x2_output_mode)begin
      SI <= #(tDIS_max+1) 0; // +1 to allow highZ for 1ns
    end
    if (x4_output_mode) begin
      HOLD_N <= #(tDIS_max+1) 1;
      WP_N <= #(tDIS_max+1) 1;
    end
      x2_output_mode = 0;
      x4_output_mode = 0;
      #delay;
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  nop 
////////////////////////////////////////////////////////////////////////////////////////////////////
task nop;
  input real delay;
  begin
    #delay;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  write_enable 
////////////////////////////////////////////////////////////////////////////////////////////////////
task write_enable;
    reg [ 31: 0] regin          ;
  begin
  `ifdef IPEN
    setssi_bytes(1)             ;
    regin[31:24] = 8'hff        ;
    regin[23:16] = 8'hff        ;
    regin[15: 8] = 8'hff        ;
    regin[ 7: 0] = 8'h06        ; 
    wregssi_drx(MST_BASE,regin) ;
    pclkdly(300)                ;
    wregssi_en(MST_BASE,DISABLE);
  `else
    latch_command (8'h06)       ;
    CS_N <= 1                   ;
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  write_disable 
////////////////////////////////////////////////////////////////////////////////////////////////////
task write_disable;
    reg [ 31: 0] regin          ;
  begin
  `ifdef IPEN
    setssi_bytes(1);
    regin[31:24] = 8'hff        ;
    regin[23:16] = 8'hff        ;
    regin[15: 8] = 8'hff        ;
    regin[ 7: 0] = 8'h04        ; 
    wregssi_drx(MST_BASE,regin) ;
    pclkdly(300)                ;
    wregssi_en(MST_BASE,DISABLE);
  `else
    latch_command (8'h04)       ;
    CS_N <= 1                   ;
  `endif
  end
endtask
    
////////////////////////////////////////////////////////////////////////////////////////////////////
//  Status Read 
////////////////////////////////////////////////////////////////////////////////////////////////////
// Status Read (70h)
task status_read;
  begin
  `ifdef IPEN
    $display ("tb.status_read at time %t", $time);
    get_features (8'hC0);
  `else
    $display ("tb.status_read at time %t", $time);
    get_features (8'hC0);
    CS_N <=1;
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  get_features 
////////////////////////////////////////////////////////////////////////////////////////////////////
task get_features;
  input [ 7: 0] feature_address         ;
  reg   [31: 0] regin                   ;
  integer   i                           ;
  begin
  `ifdef IPEN
    //send the inst and address
    setssi_bytes(1)                     ;
    regin[31: 8] = 24'h0                ;
    //S1, send cmd
    regin[ 7: 0] = 8'h0F                ;
    wregssi_drx(MST_BASE,regin)         ; 
    //S2, send address 
    regin[ 7: 0] = feature_address      ;
    wregssi_drx(MST_BASE,regin)         ; 
    //S3, send dummy data[question by cqiu ???,we want to get 3 Bytes ,so send 3 Bytes dummy data] 
    for(i = 0 ; i< 3; i = i+1)begin
      wregssi_drx(MST_BASE,0)           ; 
    end
    pclkdly(300)                        ;
    wregssi_en(MST_BASE,DISABLE)        ;
  `else
    latch_command (8'h0F)               ;
    latch_address (feature_address, 1)  ;
    //CS_N <=1;
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  set_features 
////////////////////////////////////////////////////////////////////////////////////////////////////
task set_features;
  input [ 7: 0] feature_address         ;
  //these are defined as only 8 bit features regardless of DQ_BITS width
  input [ 7: 0] p1                      ;
  reg   [31: 0] regin                   ;
  integer i;
  begin
  `ifdef IPEN
    setssi_bytes(3)                     ;
    regin[31:24] = 8'hff                ;
    regin[23:16] = 8'h1f                ;
    regin[15: 8] = feature_address      ; 
    regin[ 7: 0] = p1                   ; 
    wregssi_drx(MST_BASE,regin)         ;
    pclkdly(300)                        ;
    wregssi_en(MST_BASE,DISABLE)        ;
  `else
    latch_command (8'h1F)               ;
    latch_address (feature_address, 1)  ;
    latch_data (p1)                     ;
    CS_N <=1                            ;
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  erase_block 
////////////////////////////////////////////////////////////////////////////////////////////////////
task erase_block;
  input [BLCK_BITS - 1: 0] blck_addr            ;
  reg   [ROW_BITS - 1 : 0] row_addr             ;
  reg   [           31: 0] regin                ;
  begin
  `ifdef IPEN
    row_addr = {blck_addr, {PAGE_BITS{1'b0}}}   ;
    // Decode Command
    regin[31:24] = 8'hd8                        ;
    regin[23: 0] = row_addr                     ; 
    setssi_bytes(4)                             ;
    wregssi_drx(MST_BASE,regin)                 ;
    pclkdly(300)                                ;
    wregssi_en(MST_BASE,DISABLE)                ;
  `else
    row_addr = {blck_addr, {PAGE_BITS{1'b0}}}   ;
    // Decode Command
    latch_command (8'hD8)                       ;
    latch_address (row_addr, 3)                 ;
    standby(100)                                ;
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  read_page 
////////////////////////////////////////////////////////////////////////////////////////////////////
task read_page;
  input [BLCK_BITS - 1 : 0] blck_addr   ;
  input [PAGE_BITS - 1 : 0] page_addr   ;
  reg   [ROW_BITS  - 1 : 0] row_addr    ;
  reg   [           31: 0] regin        ;
  begin
  `ifdef IPEN
    row_addr = {blck_addr, page_addr}   ;
    regin[31:24] = 8'h13                ;
    regin[23: 0] = row_addr             ; 
    setssi_bytes(4)                     ;
    wregssi_drx(MST_BASE,regin)         ;
    pclkdly(300)                        ;
    wregssi_en(MST_BASE,DISABLE)        ;
  `else
    row_addr = {blck_addr, page_addr}   ;
    latch_command (8'h13)               ;
    latch_address (row_addr, 3)         ;
    CS_N <= 1                           ;
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  read_cache
////////////////////////////////////////////////////////////////////////////////////////////////////
task read_cache;
  input [BLCK_BITS - 1 : 0] blck_addr   ;
  input [PAGE_BITS - 1 : 0] page_addr   ;
  reg   [  ROW_BITS -1 : 0] row_addr    ;
  reg   [           31:  0] regin       ;
  begin
  `ifdef IPEN
    row_addr = {blck_addr, page_addr}   ;
    regin[31:24] = 8'h30                ;
    regin[23: 0] = row_addr             ; 
    setssi_bytes(4)                     ;
    wregssi_drx(MST_BASE,regin)         ;
    pclkdly(300)                        ;
    wregssi_en(MST_BASE,DISABLE)        ;
  `else
    row_addr = {blck_addr, page_addr}   ;
    latch_command (8'h30)               ;
    latch_address (row_addr, 3)         ;
    CS_N <= 1                           ;
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  random_data_read_check 
////////////////////////////////////////////////////////////////////////////////////////////////////
task random_data_read_check             ;
  input [ROW_BITS - 1 : 0] col_addr     ;
  input [DQ_BITS  - 1 : 0] data         ;
  input [           1 : 0] pattern      ;
  input [ROW_BITS - 1 : 0] size         ;
  reg   [           31: 0] regin        ;
  begin
  //S1 set cmd and address
    regin[31:24] = 8'h03                ;
    regin[23: 8] = col_addr             ; 
    regin[ 7: 0] = 8'h00                ; 
    setssi_bytes(4)                     ;
    wregssi_drx(MST_BASE,regin)         ;
  //S2 get data 
    // Serial Read
    $display ("At time %0t,  READ DATA : size=%0d,\t data=%0h,\t pattern=%0d", $realtime, size, data, pattern);
    //wait(so_so1 !== 1'bz)             ;
    write_data(8'h0,size,0)             ;
    standby(100)                        ;
    pclkdly(size * 100)                 ;
    wregssi_en(MST_BASE,DISABLE)        ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  random_data_read 
////////////////////////////////////////////////////////////////////////////////////////////////////
task random_data_read                   ;
  input [ROW_BITS - 1 : 0] col_addr     ;
  reg   [           31: 0] regin        ;
  begin
  `ifdef IPEN
    regin[31:24] = 8'h03                ;
    regin[23: 8] = col_addr             ; 
    regin[ 7: 0] = 8'h00                ; 
    setssi_bytes(4)                     ;
    wregssi_drx(MST_BASE,regin)         ;
    pclkdly(300)                        ;
    wregssi_en(MST_BASE,DISABLE)        ;
  `else
    latch_command (8'h03)               ;// opcode can also be 8'h0b
    latch_address (col_addr, 2)         ;
    latch_address (8'h00, 1)            ;
    //CS_N <= 1                         ;
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  random_data_read_spnor_03
////////////////////////////////////////////////////////////////////////////////////////////////////
task random_data_read_spnor_03          ;
  input [ROW_BITS - 1 : 0] col_addr     ;
  reg   [           31: 0] regin        ;
  begin
  `ifdef IPEN
    regin[31:24] = 8'h03                ;
    regin[23:16] = 8'h00                ; 
    regin[15: 0] = col_addr             ; 
    setssi_bytes(4)                     ;
    wregssi_drx(MST_BASE,regin)         ;
    pclkdly(300)                        ;
    wregssi_en(MST_BASE,DISABLE)        ;
  `else
    latch_command (8'h03)               ;// opcode can also be 8'h03
    latch_address (8'h00, 1)            ;
    latch_address (col_addr, 2)         ;
    //CS_N <= 1                         ;
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  random_data_read_spnor
////////////////////////////////////////////////////////////////////////////////////////////////////
task random_data_read_spnor             ;
  input [ROW_BITS - 1 : 0] col_addr     ;
  reg   [           31: 0] regin        ;
  begin
  `ifdef IPEN
    setssi_bytes(1)                     ;
    wregssi_drx(MST_BASE,8'h0B)         ;
    wregssi_drx(MST_BASE,8'h00)         ;
    wregssi_drx(MST_BASE,col_addr[15:8]);
    wregssi_drx(MST_BASE,col_addr[ 7:0]);
    wregssi_drx(MST_BASE,8'h00)         ;
    pclkdly(300)                        ;
    wregssi_en(MST_BASE,DISABLE)        ;
  `else
    latch_command (8'h0B)               ;// opcode can also be 8'h03
    latch_address (8'h00, 1)            ;
    latch_address (col_addr, 2)         ;
    latch_address (8'h00, 1)            ;
    //CS_N <= 1                         ;
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  random_data_read_x2
////////////////////////////////////////////////////////////////////////////////////////////////////
task random_data_read_x2                ;
  input [ROW_BITS - 1 : 0] col_addr     ;
  reg   [           31: 0] regin        ;
  begin
  `ifdef IPEN
    setssi_bytes(4)                     ;
    regin[31:24] = 8'h3B                ;
    regin[23: 8] = col_addr             ; 
    regin[ 7: 0] = 0                    ; 
    wregssi_drx(MST_BASE,regin)         ;
    pclkdly(300)                        ;
    wregssi_en(MST_BASE,DISABLE)        ;
  `else
    latch_command (8'h3B)               ;
    latch_address (col_addr, 2)         ;
    SI <= 1'bz                          ;
    SO <= 1'bz                          ;
    //latch_address (8'h00, 1)          ;
	  repeat (8) begin // keep SI highZ during dummy bits
	    @(negedge SCK)                    ;
	  end
	  x2_output_mode = 1                  ;
    //CS_N <= 1                         ;
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  random_data_read_dual_io
////////////////////////////////////////////////////////////////////////////////////////////////////
//maybe err by cqiu none
task random_data_read_dual_io           ;
  input [ROW_BITS - 1 : 0] col_addr     ;
  begin
  `ifdef IPEN
  `else
    latch_command (8'hBB)               ;
    latch_address_x2 (col_addr, 2)      ;
    SI <= 1'bz                          ;
    SO <= 1'bz                          ;
    //latch_address (8'h00, 1)          ;
	  repeat (4) begin // keep SI highZ during dummy bits
	    @(negedge SCK)                    ;
	  end
	  x2_output_mode = 1                  ;
		//CS_N <= 1                                                                                       ;
  `endif
 end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  random_data_read_x4
////////////////////////////////////////////////////////////////////////////////////////////////////
task random_data_read_x4                ;
  input [ROW_BITS - 1 : 0] col_addr     ;
  reg   [           31: 0] regin        ;
  begin
  `ifdef IPEN
    setssi_bytes(4)                     ;
    regin[31:24] = 8'h6B                ;
    regin[23: 8] = col_addr             ; 
    regin[ 7: 0] = 0                    ; 
    wregssi_drx(MST_BASE,regin)         ;
    pclkdly(300)                        ;
    wregssi_en(MST_BASE,DISABLE)        ;
  `else
    latch_command (8'h6B)               ;
    latch_address (col_addr, 2)         ;
    SI <= 1'bz                          ;
    SO <= 1'bz                          ;
    HOLD_N <= 1'bz                      ;
    WP_N <= 1'bz                        ;
    //latch_address (8'h00, 1)          ;
    repeat (8) begin // keep SI highZ during dummy bits
      @(negedge SCK)                    ;
    end
    x4_output_mode = 1                  ;
    //CS_N <= 1                         ;
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  random_data_read_quad_io
////////////////////////////////////////////////////////////////////////////////////////////////////
//maybe err by cqiu
task random_data_read_quad_io           ;
  input [ROW_BITS - 1 : 0] col_addr     ;
  begin
  `ifdef IPEN
  `else
    latch_command (8'hEB)               ;
    latch_address_x4 (col_addr, 2)      ;
    SI <= 1'bz                          ;
    SO <= 1'bz                          ;
    HOLD_N <= 1'bz                      ;
    WP_N <= 1'bz                        ;
    //latch_address (8'h00, 1)          ;
    repeat (4) begin // keep SI highZ during dummy bits
      @(negedge SCK)                    ;
    end
    x4_output_mode = 1                  ;
    //CS_N <= 1                         ;
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  program_page 
////////////////////////////////////////////////////////////////////////////////////////////////////
task program_page                                                 ;
  input [BLCK_BITS - 1 : 0] blck_addr                             ;//BLCK_BITS=10 or 11
  input [PAGE_BITS - 1 : 0] page_addr                             ;//PAGE_BITS=6
  input [COL_BITS  - 1 : 0] col_addr                              ;//COL_BITS=12
  input [DQ_BITS   - 1 : 0] data                                  ;//DQ_BITS=8
  input [COL_BITS  - 1 : 0] size                                  ;//COL_BITS=12
  input [            1 : 0] pattern                               ;
  reg   [ROW_BITS  - 1 : 0] row_addr                              ;//ROW_BITS=16 or 17
  reg   [COL_BITS  - 1 : 0] i                                     ;//COL_BITS=12
  reg   [          31  : 0] regin                                 ;
  begin
  `ifdef IPEN
    //S1, send cmd and addr, and one byte data
    setssi_bytes(4)                                               ;
    regin[31:24] = 8'h02                                          ; 
    if (NUM_PLANE >1) begin//NUM_PLANE=1 or 2
      regin[23: 8] = ((col_addr+ (blck_addr[0] << COL_BITS)))     ;
    end
    else begin
      regin[23: 8] = ((col_addr))                                 ;
    end
    regin[ 7: 0] = data                                           ; 
    wregssi_drx(MST_BASE,regin)                                   ; 
    //S2, send data 
    write_data(data, size, pattern)                               ;
    pclkdly(size * 100)                                           ;
    wregssi_en(MST_BASE,DISABLE)                                  ;
    pclkdly(10)                                                   ;
    //S3, send cmd 
    setssi_bytes(4)                                               ;
    row_addr = {blck_addr, page_addr}                             ;
    standby(100)                                                  ;
    regin[31:24] = 8'h10                                          ; 
    regin[23: 0] = row_addr                                       ; 
    wregssi_drx(MST_BASE,regin)                                   ; 
    standby(100)                                                  ;
    pclkdly(300)                                                  ;
    wregssi_en(MST_BASE,DISABLE)                                  ;
  `else
    row_addr = {blck_addr, page_addr}                             ;
    latch_command (8'h02)                                         ;
    if (NUM_PLANE >1) begin//NUM_PLANE=1 or 2
      latch_address ((col_addr+ (blck_addr[0] << COL_BITS)) , 2)  ;
    end
    else begin
      latch_address (col_addr, 2)                                 ;	
    end
    write_data(data, size, pattern)                               ;
    standby(100)                                                  ;
    latch_command(8'h10)                                          ;
    latch_address(row_addr, 3)                                    ;
    standby(100)                                                  ;
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  program_page_x4
////////////////////////////////////////////////////////////////////////////////////////////////////
task program_page_x4                                              ;
  input [BLCK_BITS - 1 : 0] blck_addr                             ;
  input [PAGE_BITS - 1 : 0] page_addr                             ;
  input [COL_BITS  - 1 : 0] col_addr                              ;
  input [DQ_BITS   - 1 : 0] data                                  ;
  input [COL_BITS  - 1 : 0] size                                  ;
  input [            1 : 0] pattern                               ;
  reg   [ROW_BITS  - 1 : 0] row_addr                              ;
  reg   [COL_BITS  - 1 : 0] i                                     ;
  begin
  `ifdef IPEN
  `else
    row_addr = {blck_addr, page_addr}                             ;
    latch_command (8'h32)                                         ;
    if (NUM_PLANE >1) begin
      latch_address ((col_addr+ (blck_addr[0] << COL_BITS)) , 2)  ;
    end
    else begin
      latch_address (col_addr, 2)                                 ;	
    end
    write_data_x4 (data, size, pattern)                           ;
    standby(100)                                                  ;
    SI <= 1'bz                                                    ;
    SO <= 1'bz                                                    ;
    HOLD_N <= 1'b1                                                ;
    WP_N <= 1'b1                                                  ;
    standby(100)                                                  ;
    latch_command(8'h10)                                          ;
    latch_address(row_addr, 3)                                    ;
    standby(100)                                                  ;
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  execute_program 
////////////////////////////////////////////////////////////////////////////////////////////////////
//this task simply finishes off a random data input by adding the 8'h10
// command with the row address
task execute_program                    ;
  input [BLCK_BITS - 1 : 0] blck_addr   ;
  input [PAGE_BITS - 1 : 0] page_addr   ;
  reg   [ROW_BITS  - 1 : 0] row_addr    ;
  reg   [            31: 0] regin       ;
  begin
  `ifdef IPEN
    row_addr = {blck_addr, page_addr}   ;
    setssi_bytes(4)                     ;
    regin[31:24] = 8'h10                ;
    regin[23: 0] = row_addr             ; 
    wregssi_drx(MST_BASE,regin)         ;
    pclkdly(300)                        ;
    wregssi_en(MST_BASE,DISABLE)        ;
  `else
    row_addr = {blck_addr, page_addr}   ;
    latch_command(8'h10)                ;
    latch_address(row_addr, 3)          ;
    standby(100)                        ;
  `endif
  end
endtask    
  
////////////////////////////////////////////////////////////////////////////////////////////////////
//  write_data 
////////////////////////////////////////////////////////////////////////////////////////////////////
// write data pattern, addresses already input
task write_data                                           ;
  input [DQ_BITS   - 1 : 0] data                          ;
  input [COL_BITS  - 1 : 0] size                          ;
  input [            1 : 0] pattern                       ;
  integer i                                               ;
  reg   [            31: 0] regin                         ;
  begin
  `ifdef IPEN
    for( i = 0 ; i < size  ; i = i + 4)begin
      case (pattern)
          2'b00 : begin
            regin[31:24] = data[7:0]                      ;
            regin[23:16] = data[7:0]                      ;
            regin[15:08] = data[7:0]                      ;
            regin[ 7: 0] = data[7:0]                      ;
          end 
          2'b01 : begin
            regin[31:24] = { data + i + 3 }               ;
            regin[23:16] = { data + i + 2 }               ;
            regin[15:08] = { data + i + 1 }               ;
            regin[ 7: 0] = { data + i + 0 }               ;
          end
          2'b10 : begin
            regin[31:24] = { data - i - 3 }               ;
            regin[23:16] = { data - i - 2 }               ;
            regin[15:08] = { data - i - 1 }               ;
            regin[ 7: 0] = { data - i - 0 }               ;
          end
          2'b11 : begin
            regin = { {{$random} % {(4*DQ_BITS){1'b1}}} } ;
          end
          default:begin
            regin[31:24] = data[7:0]                      ;
            regin[23:16] = data[7:0]                      ;
            regin[15:08] = data[7:0]                      ;
            regin[ 7: 0] = data[7:0]                      ;
          end 
      endcase
      wregssi_drx(MST_BASE, regin)                        ;
    end
  `else
    // Decode Pattern
    for (i = 0; i <= size - 1; i = i + 1) begin
      case (pattern)
          2'b00 : latch_data (data)                       ;
          2'b01 : latch_data (data + i)                   ;
          2'b10 : latch_data (data - i)                   ;
          2'b11 : latch_data ({$random} % {DQ_BITS{1'b1}});
      endcase
      //$display("input data is %h at cycle %h", data, i) ;
    end
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  write_data_x4
////////////////////////////////////////////////////////////////////////////////////////////////////
task write_data_x4                                          ;
  input [DQ_BITS   - 1 : 0] data                            ;
  input [COL_BITS  - 1 : 0] size                            ;
  input [            1 : 0] pattern                         ;
  integer i                                                 ;
  begin
  `ifdef IPEN
  `else
    // Decode Pattern
    for (i = 0; i <= size - 1; i = i + 1) begin
      case (pattern)
        2'b00 : latch_data_x4 (data)                        ;
        2'b01 : latch_data_x4 (data + i)                    ;
        2'b10 : latch_data_x4 (data - i)                    ;
        2'b11 : latch_data_x4 ({$random} % {DQ_BITS{1'b1}}) ;
      endcase
    end
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  random_data_write 
////////////////////////////////////////////////////////////////////////////////////////////////////
task random_data_write                                      ;
  input [COL_BITS      : 0] col_addr                        ;
  input [DQ_BITS   - 1 : 0] data                            ;
  input [COL_BITS  - 1 : 0] size                            ;
  input [            1 : 0] pattern                         ;
  integer i                                                 ;
  reg   [            31: 0] regin                           ;
  begin
  `ifdef IPEN
    //S1, send cmd and addr, and one byte data
    setssi_bytes(4)                                         ;
    regin[31:24] = 8'h84                                    ; 
    regin[23: 8] = col_addr                                 ; 
    regin[ 7: 0] = data                                     ; 
    wregssi_drx(MST_BASE,regin)                             ; 
    //S2, send data 
    write_data(data, size, pattern)                         ;
  `else
    latch_command (8'h84)                                   ;
    latch_address (col_addr, 2)                             ;
    write_data(data, size, pattern)                         ;
    CS_N <= 1                                               ;
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  random_data_write_x4
////////////////////////////////////////////////////////////////////////////////////////////////////
task random_data_write_x4                                   ;
  input [COL_BITS  : 0] col_addr                            ;
  input [DQ_BITS - 1 : 0] data                              ;
  input [COL_BITS  - 1 : 0] size                            ;
  input             [1 : 0] pattern                         ;
  integer i                                                 ;
  begin
  `ifdef IPEN
  `else
    latch_command (8'h34)                                   ;
    latch_address (col_addr, 2)                             ;
    write_data_x4(data, size, pattern)                      ;
    standby(100)                                            ;
    SI <= 1'bz                                              ;
    SO <= 1'bz                                              ;
    HOLD_N <= 1'b1                                          ;
    WP_N <= 1'b1                                            ;
    standby(100)                                            ;
    CS_N <= 1                                               ;
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  OTP_protect 
////////////////////////////////////////////////////////////////////////////////////////////////////
task OTP_protect                ;
  begin
  `ifdef IPEN
  `else
	//set some value in the OTP Features reg
  //set_features(OTP_addr)      ;
  // SMK : TODO
  `endif
	end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  reset 
////////////////////////////////////////////////////////////////////////////////////////////////////
// reset (FFh) - 
task reset                      ;
    reg [ 31: 0] regin          ;
  begin
  `ifdef IPEN
    setssi_bytes(1)             ;
    regin[31:24] = 8'hFF        ;
    regin[23:16] = 8'hFF        ;
    regin[15: 8] = 8'hFF        ;
    regin[ 7: 0] = 8'hFF        ; 
    wregssi_drx(MST_BASE,regin) ;
    pclkdly(300)                ;
    wregssi_en(MST_BASE,DISABLE);
  `else
    latch_command (8'hFF)       ;
    CS_N <= 1                   ;
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wait_ready 
////////////////////////////////////////////////////////////////////////////////////////////////////
task wait_ready                 ;
  begin
    wait (~uut.uut_0.busy)      ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wait_cache_ready
////////////////////////////////////////////////////////////////////////////////////////////////////
task wait_cache_ready           ;
  begin
    wait (~uut.uut_0.crbsy)     ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  read_id 
////////////////////////////////////////////////////////////////////////////////////////////////////
// Read ID (90h) - 
task read_id                    ;
    reg [ 31: 0] regin          ;
  begin
  `ifdef IPEN
    setssi_bytes(2)             ;
    regin[31:24] = 8'hff        ;
    regin[23:16] = 8'hff        ;
    regin[15: 8] = 8'h9F        ;
    regin[ 7: 0] = 8'h00        ; 
    wregssi_drx(MST_BASE,regin) ;
    pclkdly(300)                ;
    wregssi_en(MST_BASE,DISABLE);
  `else
    latch_command (8'h9F  )     ; //read_id
    latch_address (8'h00,1)     ; //dummy byte        
    //follow it with a serial_read
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  serial_read 
////////////////////////////////////////////////////////////////////////////////////////////////////
//pulse Re_n (async) or wait for Dqs (sync) and compares output data to expected value
task serial_read                                                                    ;
  input [DQ_BITS -1: 0] data                                                        ;
  input [1:0] pattern                                                               ;
  input [ROW_BITS -1: 0] size                                                       ;
  integer i                                                                         ;
  begin
  `ifdef IPEN
  `else
    // Serial Read
    $display ("At time %0t,  READ DATA : \
      size=%0d,\t data=%0h,\t pattern=%0d", $realtime, size, data, pattern)         ;
    wait(so_so1 !== 1'bz)                                                           ;
    for (i = 0; i <= size - 1; i = i + 1) begin
      latch_and_check_data(data);
      case (pattern)
        2'b00 :                                                                     ;
        2'b01 : data = data + 1                                                     ;
        2'b10 : data = data - 1                                                     ;
        2'b11 : data = 0                                                            ;
      endcase
    end
  `endif
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  latch_and_check_data
////////////////////////////////////////////////////////////////////////////////////////////////////
task latch_and_check_data         ;
  input [DQ_BITS -1: 0] exp_data  ;
  begin
  `ifdef IPEN
  `else
    wait (~rd_verify)             ; //if a verify is already taking place, wait for it to finish
    rd_dq <= exp_data             ;
    // rd_dq holds the expected data, now read in the actual data
    latch_read                    ;
    rd_verify <= 1'b1             ; //signal that we're ready to compare
    #1                            ;
  `endif
  end
endtask

always @ (posedge rd_verify ) begin
// Verify the data word after output delay
  if (rd_data !== rd_dq) begin
    $display ("%m at time %t: \
      ERROR: Read data miscompare: Expected = %h, Actual = %h", $time, rd_dq, rd_data)  ;
  end
  rd_verify <= #1 1'b0                                                                  ;
end

// End-of-test triggered in 'subtest.vh'
always @(posedge test_done) begin : all_done
  #5000
  $display ("%0t, Simulation is Complete. test_done=%0h", $realtime, test_done)         ;
  //$stop(0)                                                                            ;
  $finish                                                                               ;
end

wire DEADMAN_REQ = 1'b0                                                                 ;
integer   DEADMAN_TIMER = 0                                                             ;
parameter DEADMAN_LIMIT = 70000000                                                      ;
always @ (posedge SCK)begin
	if (DEADMAN_REQ == 1'b1)
    DEADMAN_TIMER = 0                                                                   ;
	else
    DEADMAN_TIMER = DEADMAN_TIMER + 1                                                   ;
	if (DEADMAN_TIMER == DEADMAN_LIMIT)begin
	  $display ("SWM: No Activity in %d Clocks \
      Deadman Timer at time %t!!", DEADMAN_TIMER, $time)                                ;    
	  $stop()                                                                             ;
	end
end

`ifdef INIT_MEM
  initial begin
    #1                                                                                  ;
    //
    //preloading of mem_array can be done here
    // This approach is more flexible than readmemh
    //
    //        memory_write(block,page,col, mem_select, data)
    //              mem_select : 0 = flash memory array
    //                           1 = OTP array
    //                           2 = special config data array
    uut.uut_0.memory_write(0,0,0, 0, 8'h00)   ;
    uut.uut_0.memory_write(0,0,1, 0, 8'h01)   ;
    uut.uut_0.memory_write(0,0,2, 0, 8'h02)   ;
    uut.uut_0.memory_write(0,0,3, 0, 8'h03)   ;
    uut.uut_0.memory_write(0,0,4, 0, 8'h04)   ;
    uut.uut_0.memory_write(0,0,5, 0, 8'h05)   ;
    uut.uut_0.memory_write(0,0,6, 0, 8'h06)   ;
  end
`endif

