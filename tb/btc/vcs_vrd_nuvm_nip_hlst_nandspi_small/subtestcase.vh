integer i;

initial begin

  //This test creates four errors
  force tb_dut_top.uut.uut_0.ERR_MAX_INT = 4;
  // 7 = LOCK, 8 = OTP
  force tb_dut_top.uut.uut_0.EXP_ERR[2] = 1'b1;
  force tb_dut_top.uut.uut_0.EXP_ERR[7] = 1'b1;
  force tb_dut_top.uut.uut_0.EXP_ERR[8] = 1'b1;
  
  #55;  
  //reset must be first command issued on powerup
  reset;
  standby(100);
  wait_ready;
  
  //------------------------------
  // Program some pages
  //------------------------------
  $display("**********************************************");
  $display("          Erase blk0 ");
  $display("**********************************************");
  set_features(8'hA0, 8'h0);
  standby(100);
  write_enable;
  standby(100);
  erase_block(0);
  nop(20000);
  
  //should still be busy
  get_features(8'hC0);
  //           data, pattern,size
  serial_read(8'h01,       0,   3); 
  standby(100);
  
  wait_ready;
  standby(100);
  // should not be busy now
  get_features(8'hC0);
  serial_read(8'h0, 0, 3);
  standby(100);
  nop(15);
  
  write_enable;
  standby(100);
  //program_page (block, page, column, data, size, pattern)
  $display("**********************************************");
  $display("          PROGRAM blk0 page0");
  $display("**********************************************");
  //program_page(0,0,0,  8'h5f, 2112, 2'b00);  //blk0, page0
  program_page(0,0,0,  8'h5f, 16, 2'b00);  //blk0, page0
  nop(20000);
  wait_ready;
  standby(100);
    
  //status read
  // get_features(8'hC0);
  // serial_read(8'h01, 0, 3);
  // standby(100);
  // wait_ready;
  // get_features(8'hC0);
  // serial_read(8'h00, 0, 2);
  // standby(100);
  
  //----------------------------------
  // Read/Verify all programmed data
  //----------------------------------
  $display("**********************************************");
  $display("          READ VERIFY");
  $display("**********************************************");
  
  //start page read
  read_page(0,0);                   //read blk0, page0;
  standby(100);
  nop(5);
  nop(100000);
  //now read out of data reg
  random_data_read(0);
  //         data, pattern, size
  //serial_read(8'h00, 1, 2112);
  //serial_read(8'h5f, 0, 2112);
  //serial_read(8'h5f, 0, 2112);
  serial_read(8'h5f, 0, 16);
  standby(100);

  $display("SIMULATION ENDING NORMALLY");
  // 
  test_done =1;
end

