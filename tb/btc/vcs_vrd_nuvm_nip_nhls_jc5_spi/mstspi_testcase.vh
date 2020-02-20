////////////////////////////////////////////////////////////////////////////////////////////////////
//  master spi testcase  
////////////////////////////////////////////////////////////////////////////////////////////////////
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
  rregssi_idr(MST_BASE);
  rregssi_idr(SLV_BASE);
  // Disable DW_apb_ssi 
  wregssi_en(MST_BASE,DISABLE);
  //Configure Master by write CTRLR0,CTRLR1,BAUDR,TXFTLR,
  //RXFTLR,MWCR,IMR,SER

  ssictrl_init;

  // Enable DW_apb_ssi 
  wregssi_en(MST_BASE,ENABLE);

  // Write control & data to Tx FIFO
  // Transfer in progress

  //$display("\033[1;35;46m the color  \033[0m");
  $display("\033[1;45m SPI Running here ..... \033[0m");
//   
//   //------------------------------
//   // Program some pages
//   //------------------------------
//   $display("**********************************************");
//   $display("          Erase blk0 ");
//   $display("**********************************************");
//   set_features(8'hA0, 8'h0);
//   standby(100);
//   write_enable;
//   standby(100);
//   erase_block(0);
//   nop(20000);
//   
//   //should still be busy
//   get_features(8'hC0);
//   serial_read(8'h01, 0, 3); 
//   standby(100);
//   
//   wait_ready;
//   standby(100);
//   // should not be busy now
//   get_features(8'hC0);
//   serial_read(8'h0, 0, 3);
//   standby(100);
//   nop(15);
//   
//   write_enable;
//   standby(100);
//   //program_page (block, page, column, data, size, pattern)
//   $display("**********************************************");
//   $display("          PROGRAM blk0 page0");
//   $display("**********************************************");
//   program_page(0,0,0,  8'h00, 2112, 2'b01);  //blk0, page0
//   nop(20000);
//   wait_ready;
//   standby(100);
//     
//   $display("**********************************************");
//   $display("          PROGRAM blk1 page0");
//   $display("**********************************************");
//   //program a new location
//   write_enable;
//   standby(100);
//   program_page(1,0,0,  8'hDD, 2112, 2);     //blk1, page0
//   wait_ready;
//   standby(100);
//   
//   $display("**********************************************");
//   $display("          PROGRAM blk0 page3");
//   $display("**********************************************");
//   //program a new location
//   write_enable;
//   standby(100);
//   program_page(0,3,0,  8'hBB, 2112, 2);     //blk0, page3
//   #20000;
//   get_features(8'hC0);
//   serial_read(8'h01, 0, 2);
//   standby(100);
//   wait_ready;
//   standby(100);
//   
//   $display("**********************************************");
//   $display("     PROGRAM blk0 page4 with random data input");
//   $display("**********************************************");
//   write_enable;
//   standby(100);
//   //add random data input and program a new location
//   random_data_write(16, 8'h47, 210, 0);      //blk0, page4;
//   standby(100);
//   random_data_write(5, 8'h53, 15, 0);
//   standby(100);
//   execute_program(0,4); //finish the random data input 
//   standby(100);
//   nop(200000);
//   
//   //status read
//   get_features(8'hC0);
//   serial_read(8'h01, 0, 3);
//   standby(100);
//   wait_ready;
//   get_features(8'hC0);
//   serial_read(8'h00, 0, 2);
//   standby(100);
//   
//   //----------------------------------
//   // Read/Verify all programmed data
//   //----------------------------------
//   $display("**********************************************");
//   $display("          READ VERIFY");
//   $display("**********************************************");
//   
//   //start page read
//   read_page(0,0);                   //read blk0, page0;
//   standby(100);
//   nop(5);
//   nop(100000);
//   //now read out of data reg
//   random_data_read(0);
//   //         data, pattern, size
//   serial_read(8'h00, 1, 2112);
//   standby(100);
//   
//   random_data_read_x2(8'h64);
//   //         data, pattern, size
//   serial_read(8'h00+8'h64, 1, 2112-8'h64);
//   standby(100);
//   
//   random_data_read_x2(2110);
//   //         data, pattern, size
//   serial_read(8'h00+2110, 1, 1);
//   standby(100);
//   
//   random_data_read_x4(8'h91);
//   //         data, pattern, size
//   serial_read(8'h00+8'h91, 1, 2112-8'h91);
//   standby(100);
//   
//   random_data_read_x4(2100);
//   //         data, pattern, size
//   serial_read(8'h00+2100, 1, 6);
//   standby(100);
//   
//   $display("**********************************************");
//   $display("          READ blk0, page1");
//   $display("**********************************************");
//   //start page read
//   read_page(0,1);             //read blk0, page1;
//   standby(100);
//   wait_ready;
//   //now read out of data reg
//   random_data_read(0);
//   //         data, pattern, size
//   serial_read(8'hFF, 0, 2112);
//   standby(100);
//   
//   $display("**********************************************");
//   $display("          READ blk0, page3");
//   $display("**********************************************");
//   //start page read
//   read_page(0,3);             //read blk0, page3;
//   standby(100);
//   wait_ready;
//   //now read out of data reg
//   random_data_read(0);
//   //         data, pattern, size
//   serial_read(8'hBB, 2, 2112);
//   standby(100);
//   
//   $display("**********************************************");
//   $display("          READ blk0, page4");
//   $display("**********************************************");
//   //start page read
//   read_page(0,4);            //read blk0, page4;
//   standby(100);
//   wait_ready;
//   //now read out of data reg
//   random_data_read(0);
//   //         data, pattern, size
//   serial_read(8'hBB, 2, 5);
//   serial_read(8'h53, 0, 15);
//   serial_read(8'h47, 0, 206);
//   serial_read(8'hD9, 2, 1000);
//   standby(100);
//   
//   $display("**********************************************");
//   $display("          READ blk1, page0");
//   $display("**********************************************");
//   //this data should also be valid
//   read_page(1,0);             //read blk1, page0;
//   standby(100);
//   nop(5);
//   nop(100000);
//   random_data_read(16'h1000);
//   serial_read(8'hDD, 2'b10, 2112);
//   standby(100);
//   
//   //------------------------------
//   // Internal Data Move
//   //------------------------------
//   $display("**********************************************");
//   $display("          Internal Data Move");
//   $display("**********************************************");
//   write_enable;
//   standby(100);
//   read_page(1,0);
//   standby(100);
//   wait_ready;
//   random_data_write(16'h1005, 8'h53, 15, 0);
//   standby(100);
//   execute_program(1,5); //program blk0 page5; 
//   standby(100);
//   wait_ready;
//   
//   read_page(1,5);
//   standby(100);
//   wait_ready;
//   random_data_read(16'h1000);
//   serial_read(8'hDD, 2'b10, 5);
//   serial_read(8'h53, 2'b00, 15);
//   serial_read(8'hC9, 2'b10, 5);
//   standby(100);
//   
//   //------------------------------
//   // ERASE
//   //------------------------------
//   $display("**********************************************");
//   $display("          ERASE blk0 with wel enable");
//   $display("**********************************************");
//   write_enable;
//   standby(100);
//   erase_block(0);
//   standby(100);
//   wait_ready;
//   
//   //start page read, this should have been erase
//   read_page(0,0);
//   standby(100);
//   wait_ready;
//   //now read out of data reg
//   random_data_read(0);
//   serial_read(8'hFF, 2'b00, 2112);
//   standby(100);
//   
//   read_page(0,3);
//   standby(100);
//   wait_ready;
//   //now read out of data reg
//   random_data_read(0);
//   serial_read(8'hFF, 2'b00, 2112);
//   standby(100);
//   
//   read_page(0,4);
//   standby(100);
//   wait_ready;
//   //now read out of data reg
//   random_data_read(0);
//   serial_read(8'hFF, 2'b00, 2112);
//   standby(100);
//   
//   read_page(0,5);
//   standby(100);
//   wait_ready;
//   //now read out of data reg
//   random_data_read(0);
//   serial_read(8'hFF, 2'b00, 2112);
//   standby(100);
//   
//   //old data in block 1 should still be valid
//   read_page(1,0);
//   standby(100);
//   wait_ready;
//   random_data_read(16'h1000);
//   serial_read(8'hDD, 2'b10, 2112);
//   standby(100);
//   
//   $display("**********************************************");
//   $display("          ERASE blk1 without wel enable");
//   $display("**********************************************");
//   erase_block(1);
//   standby(100);
//   wait_ready;
//   
//   //old data in block 1 should still be valid
//   read_page(1,0);
//   standby(100);
//   wait_ready;
//   random_data_read(16'h1000);
//   serial_read(8'hDD, 2'b10, 2112);
//   standby(100);
//   
//   $display("**********************************************");
//   $display("          ERASE blk1 with wel enable");
//   $display("**********************************************");
//   write_enable;
//   standby(100);
//   erase_block(1);
//   standby(100);
//   wait_ready;
//   
//   //old data in block 1 should still be valid
//   read_page(1,5);
//   standby(100);
//   wait_ready;
//   random_data_read(16'h1000);
//   serial_read(8'hFF, 2'b0, 2112);
//   standby(100);
//   
//   $display("SIMULATION ENDING NORMALLY");
//   
//   test_done =1;
// end
  writereg(10'h00,0);
  writereg(10'h00,1);
  readreg(10'h00);
  readreg(MST_BASE+SSI_VERSION_ID);
  readreg(SLV_BASE+SSI_VERSION_ID);

  #300000
  $finish;
end
// 
// 
