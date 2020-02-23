////////////////////////////////////////////////////////////////////////////////////////////////////
//  master spi testcase  
////////////////////////////////////////////////////////////////////////////////////////////////////
integer i;
reg [  7:0] pcontent  ;
reg [ 31:0] ppattern  ;
reg [ 31:0] psize     ;

initial begin

  //This test creates four errors
  force tb_dut_top.uut.uut_0.ERR_MAX_INT = 4;
  // 7 = LOCK, 8 = OTP
  force tb_dut_top.uut.uut_0.EXP_ERR[2] = 1'b1;
  force tb_dut_top.uut.uut_0.EXP_ERR[7] = 1'b1;
  force tb_dut_top.uut.uut_0.EXP_ERR[8] = 1'b1;
  
  #55;  
  //reset must be first command issued on powerup
  reset_sig;
  reset;
  standby(100);

  wait_ready;
  
  //------------------------------
  // Program some pages
  //------------------------------
  $display("\033[1;42m ********************************************** \033[0m");
  $display("\033[1;42m  Erase blk0                                    \033[0m");
  $display("\033[1;42m ********************************************** \033[0m");
  set_features(8'hA0, 8'h0);
  standby(100);
  write_enable;
  standby(100);
  erase_block(0);
  nop(20000);
  //should still be busy
  get_features(8'hC0);
  //serial_read(8'h01, 0, 3); 
  standby(100);
  wait_ready;
  standby(100);
  // should not be busy now
  get_features(8'hC0);
  //serial_read(8'h0, 0, 3);
  standby(100);
  nop(15);

  write_enable;
  standby(100);
  //program_page (block, page, column, data, size, pattern)
  $display("\033[1;42m ********************************************** \033[0m");
  $display("\033[1;42m  PROGRAM blk0 page0                            \033[0m");
  $display("\033[1;42m ********************************************** \033[0m");
  pcontent = 8'h5f;
  ppattern = 0    ;
  psize    = 120  ;//must be 4 timse,such as 0,4,8,12,16...120
  //program_page(0,0,0,  8'h00, 2112, 2'b01);  //blk0, page0
  program_page(0,0,0,pcontent, psize, ppattern);  //blk0, page0
  nop(20000);
  wait_ready;
  standby(100);

  //----------------------------------
  // Read/Verify all programmed data
  //----------------------------------
  $display("\033[1;42m ********************************************** \033[0m");
  $display("\033[1;42m  READ VERIFY                                   \033[0m");
  $display("\033[1;42m ********************************************** \033[0m");
  //start page read
  read_page(0,0);                   //read blk0, page0;
  //standby(100);
  nop(5);
  nop(100000);
  //                     addr,    data,  pattern,  size
  random_data_read_check(   0,pcontent, ppattern, psize);
  standby(100);
  
  $display("SIMULATION ENDING NORMALLY");
  test_done =1;
  writereg(10'h00,0);
  writereg(10'h00,1);
  readreg(10'h00);
  readreg(MST_BASE+SSI_VERSION_ID);
  readreg(SLV_BASE+SSI_VERSION_ID);
  $display("\033[1;45m SPI Running here ..... \033[0m");
  #300000

  $finish;
end
