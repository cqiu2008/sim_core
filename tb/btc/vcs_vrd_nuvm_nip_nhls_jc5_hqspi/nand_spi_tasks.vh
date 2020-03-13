////////////////////////////////////////////////////////////////////////////////////////////////////
//  
//  TASKS 
//  
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
//  latch_read 
////////////////////////////////////////////////////////////////////////////////////////////////////
wire SO_preedge;
assign #1 SO_preedge = so_so1;

task latch_read;
  integer index;
  begin
    index = 7;
    if (x4_output_mode) begin
      repeat (2)begin
        @(negedge SCK);
  	    // in x4 mode, hold pin is ufsed as output
        rd_data[index  ] <= hold_so3;
        rd_data[index-1] <= wpn_so2;
        rd_data[index-2] <= SO_preedge;
        rd_data[index-3] <= si_so0;
        index = index -4;
      end
    end 
    else if (x2_output_mode) begin
      repeat (4)begin
        @(negedge SCK);
        if (HOLD_N ) begin
          rd_data[index  ] <= SO_preedge;
  	      rd_data[index-1] <= si_so0;
          index = index -2;
        end 
        else begin
          wait(HOLD_N);
          wait (so_so1 !== 1'bz);
          //@(posedge SCK);
  	      @(negedge SCK);
          rd_data[index  ] <= so_so1;
  	      rd_data[index-1] <= si_so0;
          index = index -2;
        end
      end
    end 
    else begin // x1_output_mode
      repeat (8)begin
        @(negedge SCK);
        if (HOLD_N) begin
          rd_data[index] <= SO_preedge;
          index = index -1;
        end 
        else begin
          wait(HOLD_N);
          wait (so_so1 !== 1'bz);
          //@(posedge SCK);
  	      @(negedge SCK);
          rd_data[index] <= so_so1;
          index = index -1;
        end
      end
    end
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  latch_data
////////////////////////////////////////////////////////////////////////////////////////////////////
reg last_holdn = 1;
always @(posedge SCK) last_holdn <= HOLD_N ;

task latch_data;
  input [DQ_BITS -1 :0] data;
  integer index;
  begin
    data_in = 1;
    index = 7;
    wait(last_holdn);
    repeat (8)begin
      SI <= data[index];
      index = index -1;
      @(posedge SCK);
      #1;
      wait(last_holdn);
      @(negedge SCK);
    end
    //@(posedge SCK) #tHDDAT_min; // make sure to hold data long enough after clock edge
    data_in = 0;
    //#1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  latch_data_x4
////////////////////////////////////////////////////////////////////////////////////////////////////
task latch_data_x4;
  input [DQ_BITS -1 :0] data;
  integer index;
  begin
    data_in = 1;
    index = 7;
    //wait(last_holdn);
    repeat (2)begin
      HOLD_N  <= data[index];
  	  WP_N    <= data[index-1];
  	  SO      <= data[index-2];
  	  SI      <= data[index-3];
      index   = index -4;
      @(posedge SCK);
      #1;
      //wait(last_holdn);
      @(negedge SCK);
    end
    //@(posedge SCK) #tHDDAT_min; // make sure to hold data long enough after clock edge
    data_in = 0;
    //#1;
  end
endtask	

////////////////////////////////////////////////////////////////////////////////////////////////////
//  latch_command
////////////////////////////////////////////////////////////////////////////////////////////////////
task latch_command;
  input [7:0] cmd;
  integer index;
  begin
    if (CS_N)
      @(negedge SCK);
    CS_N  <= 0;
    index = 7;
    repeat (8)begin
      SI <= cmd[index];
      index = index -1;
      @(negedge SCK);
    end
    //#1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  latch_address
////////////////////////////////////////////////////////////////////////////////////////////////////
task latch_address;
  input [23:0] addr;
  input [3:0] size;
  integer index, cnt;
  begin
    address_in = 1;
    index = size * 8 -1;
    cnt = size * 8;
    //SI = addr[index];
    repeat (cnt)begin
      SI = addr[index];
      index = index -1;
      @(negedge SCK);
    end
    address_in = 0;
    //#1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  latch_address_x2
////////////////////////////////////////////////////////////////////////////////////////////////////
task latch_address_x2;
  input [23:0] addr;
  input [3:0] size;
  integer index, cnt;
  begin
    address_in = 1;
    index = size * 8 -1;
    cnt = 8;
    //SI = addr[index];
    repeat (cnt)begin
      SO = addr[index];
      SI = addr[index-1];
      index = index -2;
      @(negedge SCK);
    end
    address_in = 0;
    //#1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  latch_address_x4
////////////////////////////////////////////////////////////////////////////////////////////////////
task latch_address_x4;
  input [23:0] addr;
  input [3:0] size;
  integer index, cnt;
  begin
    address_in = 1;
    index = size * 8 -1;
    cnt = 4;
    //SI = addr[index];
    repeat (cnt)begin
      HOLD_N = addr[index];
      WP_N   = addr[index-1];
      SO     = addr[index-2];
      SI     = addr[index-3];
      index = index -4;
      @(negedge SCK);
    end
    address_in = 0;
    //#1;
  end
endtask
	
////////////////////////////////////////////////////////////////////////////////////////////////////
//  idle
////////////////////////////////////////////////////////////////////////////////////////////////////
task idle;
  begin
    CS_N = 1;        
  end
endtask
    
////////////////////////////////////////////////////////////////////////////////////////////////////
//  standby
////////////////////////////////////////////////////////////////////////////////////////////////////
task standby;
  input real delay;
  begin
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
  begin
    latch_command (8'h06);
    CS_N <= 1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  write_disable 
////////////////////////////////////////////////////////////////////////////////////////////////////
task write_disable;
  begin
    latch_command (8'h04);
    CS_N <= 1;
  end
endtask
    
////////////////////////////////////////////////////////////////////////////////////////////////////
//  Status Read 
////////////////////////////////////////////////////////////////////////////////////////////////////
// Status Read (70h)
task status_read;
  begin
    $display ("tb.status_read at time %t", $time);
    get_features (8'hC0);
    CS_N <=1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  get_features 
////////////////////////////////////////////////////////////////////////////////////////////////////
task get_features;
  input [7 : 0] feature_address;
  begin
    latch_command (8'h0F);
    latch_address (feature_address, 1);
    //CS_N <=1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  set_features 
////////////////////////////////////////////////////////////////////////////////////////////////////
task set_features;
  input [7 : 0] feature_address;
  //these are defined as only 8 bit features regardless of DQ_BITS width
  input [7:0] p1;
  begin
    latch_command (8'h1F);
    latch_address (feature_address, 1);
    latch_data (p1);
    CS_N <=1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  erase_block 
////////////////////////////////////////////////////////////////////////////////////////////////////
task erase_block;
  input [BLCK_BITS - 1 : 0] blck_addr;
  reg [ROW_BITS - 1 : 0] row_addr;
  begin
    row_addr = {blck_addr, {PAGE_BITS{1'b0}}};
    // Decode Command
    latch_command (8'hD8);
    latch_address (row_addr, 3);
    standby(100);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  read_page 
////////////////////////////////////////////////////////////////////////////////////////////////////
task read_page;
  input [BLCK_BITS - 1 : 0] blck_addr;
  input [PAGE_BITS - 1 : 0] page_addr;
  reg [ROW_BITS -1 : 0] row_addr;
  begin
    row_addr = {blck_addr, page_addr};
    latch_command (8'h13);
    latch_address (row_addr, 3);
    CS_N <= 1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  read_cache
////////////////////////////////////////////////////////////////////////////////////////////////////
task read_cache;
  input [BLCK_BITS - 1 : 0] blck_addr;
  input [PAGE_BITS - 1 : 0] page_addr;
  reg [ROW_BITS -1 : 0] row_addr;
  begin
    row_addr = {blck_addr, page_addr};
    latch_command (8'h30);
    latch_address (row_addr, 3);
    CS_N <= 1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  random_data_read 
////////////////////////////////////////////////////////////////////////////////////////////////////
task random_data_read;
  input [ROW_BITS - 1 : 0] col_addr;
  begin
    latch_command (8'h03); // opcode can also be 8'h0b
    latch_address (col_addr, 2);
    latch_address (8'h00, 1);
    //CS_N <= 1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  random_data_read_spnor_03
////////////////////////////////////////////////////////////////////////////////////////////////////
task random_data_read_spnor_03;
  input [ROW_BITS - 1 : 0] col_addr;
  begin
    latch_command (8'h03); // opcode can also be 8'h03
	  latch_address (8'h00, 1);
    latch_address (col_addr, 2);
		//CS_N <= 1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  random_data_read_spnor
////////////////////////////////////////////////////////////////////////////////////////////////////
task random_data_read_spnor;
  input [ROW_BITS - 1 : 0] col_addr;
  begin
    latch_command (8'h0B); // opcode can also be 8'h03
	  latch_address (8'h00, 1);
    latch_address (col_addr, 2);
    latch_address (8'h00, 1);
		//CS_N <= 1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  random_data_read_x2
////////////////////////////////////////////////////////////////////////////////////////////////////
task random_data_read_x2;
  input [ROW_BITS - 1 : 0] col_addr;
  begin
    latch_command (8'h3B);
    latch_address (col_addr, 2);
	  SI <= 1'bz;
	  SO <= 1'bz;
    //latch_address (8'h00, 1);
	  repeat (8) begin // keep SI highZ during dummy bits
	    @(negedge SCK);
	  end
	  x2_output_mode = 1;
		//CS_N <= 1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  random_data_read_dual_io
////////////////////////////////////////////////////////////////////////////////////////////////////
task random_data_read_dual_io;
  input [ROW_BITS - 1 : 0] col_addr;
  begin
    latch_command (8'hBB);
    latch_address_x2 (col_addr, 2);
	  SI <= 1'bz;
	  SO <= 1'bz;
    //latch_address (8'h00, 1);
	  repeat (4) begin // keep SI highZ during dummy bits
	    @(negedge SCK);
	  end
	  x2_output_mode = 1;
		//CS_N <= 1;
 end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  random_data_read_x4
////////////////////////////////////////////////////////////////////////////////////////////////////
task random_data_read_x4;
  input [ROW_BITS - 1 : 0] col_addr;
  begin
    latch_command (8'h6B);
    latch_address (col_addr, 2);
    SI <= 1'bz;
    SO <= 1'bz;
    HOLD_N <= 1'bz;
    WP_N <= 1'bz;
    //latch_address (8'h00, 1);
    repeat (8) begin // keep SI highZ during dummy bits
      @(negedge SCK);
    end
    x4_output_mode = 1;
	  //CS_N <= 1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  random_data_read_quad_io
////////////////////////////////////////////////////////////////////////////////////////////////////
task random_data_read_quad_io;
  input [ROW_BITS - 1 : 0] col_addr;
  begin
    latch_command (8'hEB);
    latch_address_x4 (col_addr, 2);
    SI <= 1'bz;
    SO <= 1'bz;
    HOLD_N <= 1'bz;
    WP_N <= 1'bz;
    //latch_address (8'h00, 1);
    repeat (4) begin // keep SI highZ during dummy bits
      @(negedge SCK);
    end
    x4_output_mode = 1;
  	//CS_N <= 1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  program_page 
////////////////////////////////////////////////////////////////////////////////////////////////////
task program_page;
  input [BLCK_BITS - 1 : 0] blck_addr;
  input [PAGE_BITS - 1 : 0] page_addr;
  input [COL_BITS  - 1 : 0] col_addr;
  input [DQ_BITS   - 1 : 0] data;
  input [COL_BITS  - 1 : 0] size;
  input [            1 : 0] pattern;
  reg [ROW_BITS - 1 : 0] row_addr;
  reg   [COL_BITS  - 1 : 0] i;
  begin
    row_addr = {blck_addr, page_addr};
    latch_command (8'h02);
    if (NUM_PLANE >1) begin
      latch_address ((col_addr+ (blck_addr[0] << COL_BITS)) , 2);
    end
    else begin
      latch_address (col_addr, 2);	
    end
    write_data(data, size, pattern);
    standby(100);
    latch_command(8'h10);
    latch_address(row_addr, 3);
    standby(100);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  program_page_x4
////////////////////////////////////////////////////////////////////////////////////////////////////
task program_page_x4;
  input [BLCK_BITS - 1 : 0] blck_addr;
  input [PAGE_BITS - 1 : 0] page_addr;
  input [COL_BITS  - 1 : 0] col_addr;
  input [DQ_BITS   - 1 : 0] data;
  input [COL_BITS  - 1 : 0] size;
  input [            1 : 0] pattern;
  reg   [ROW_BITS  - 1 : 0] row_addr;
  reg   [COL_BITS  - 1 : 0] i;
  begin
    row_addr = {blck_addr, page_addr};
    latch_command (8'h32);
    if (NUM_PLANE >1) begin
      latch_address ((col_addr+ (blck_addr[0] << COL_BITS)) , 2);
    end
    else begin
      latch_address (col_addr, 2);	
    end
    write_data_x4 (data, size, pattern);
    standby(100);
    SI <= 1'bz;
    SO <= 1'bz;
    HOLD_N <= 1'b1;
    WP_N <= 1'b1;
    standby(100);
    latch_command(8'h10);
    latch_address(row_addr, 3);
    standby(100);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  execute_program 
////////////////////////////////////////////////////////////////////////////////////////////////////
//this task simply finishes off a random data input by adding the 8'h10
// command with the row address
task execute_program;
  input [BLCK_BITS - 1 : 0] blck_addr;
  input [PAGE_BITS - 1 : 0] page_addr;
  reg [ROW_BITS - 1 : 0] row_addr;
  begin
    row_addr = {blck_addr, page_addr};
    latch_command(8'h10);
    latch_address(row_addr, 3);
    standby(100);
  end
endtask    
  
////////////////////////////////////////////////////////////////////////////////////////////////////
//  write_data 
////////////////////////////////////////////////////////////////////////////////////////////////////
// write data pattern, addresses already input
task write_data;
  input [DQ_BITS - 1 : 0] data;
  input [COL_BITS  - 1 : 0] size;
  input             [1 : 0] pattern;
  integer i;
  begin
    // Decode Pattern
    for (i = 0; i <= size - 1; i = i + 1) begin
      case (pattern)
          2'b00 : latch_data (data);
          2'b01 : latch_data (data + i);
          2'b10 : latch_data (data - i);
          2'b11 : latch_data ({$random} % {DQ_BITS{1'b1}});
      endcase
	    //$display("input data is %h at cycle %h", data, i);
    end
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  write_data_x4
////////////////////////////////////////////////////////////////////////////////////////////////////
task write_data_x4;
  input [DQ_BITS - 1 : 0] data;
  input [COL_BITS  - 1 : 0] size;
  input             [1 : 0] pattern;
  integer i;
  begin
    // Decode Pattern
    for (i = 0; i <= size - 1; i = i + 1) begin
      case (pattern)
        2'b00 : latch_data_x4 (data);
        2'b01 : latch_data_x4 (data + i);
        2'b10 : latch_data_x4 (data - i);
        2'b11 : latch_data_x4 ({$random} % {DQ_BITS{1'b1}});
      endcase
    end
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  random_data_write 
////////////////////////////////////////////////////////////////////////////////////////////////////
task random_data_write;
  input [COL_BITS      : 0] col_addr;
  input [DQ_BITS   - 1 : 0] data;
  input [COL_BITS  - 1 : 0] size;
  input [            1 : 0] pattern;
  integer i;
  begin
    latch_command (8'h84);
    latch_address (col_addr, 2);
    write_data(data, size, pattern);
    CS_N <= 1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  random_data_write_x4
////////////////////////////////////////////////////////////////////////////////////////////////////
task random_data_write_x4;
  input [COL_BITS  : 0] col_addr;
  input [DQ_BITS - 1 : 0] data;
  input [COL_BITS  - 1 : 0] size;
  input             [1 : 0] pattern;
  integer i;
  begin
    latch_command (8'h34);
    latch_address (col_addr, 2);
	  write_data_x4(data, size, pattern);
	  standby(100);
    SI <= 1'bz;
    SO <= 1'bz;
    HOLD_N <= 1'b1;
    WP_N <= 1'b1;
	  standby(100);
	  CS_N <= 1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  OTP_protect 
////////////////////////////////////////////////////////////////////////////////////////////////////
task OTP_protect;
  begin
	//set some value in the OTP Features reg
	//set_features(OTP_addr);
  // SMK : TODO
	end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  reset 
////////////////////////////////////////////////////////////////////////////////////////////////////
// reset (FFh) - 
task reset;
  begin
    latch_command (8'hFF);
    CS_N <= 1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wait_ready 
////////////////////////////////////////////////////////////////////////////////////////////////////
task wait_ready;
  begin
    wait (~uut.uut_0.busy);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wait_cache_ready
////////////////////////////////////////////////////////////////////////////////////////////////////
task wait_cache_ready;
  begin
    wait (~uut.uut_0.crbsy);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  read_id 
////////////////////////////////////////////////////////////////////////////////////////////////////
// Read ID (90h) - 
task read_id;
  begin
    latch_command (8'h9F); //read_id
    latch_address (8'h00,1); //dummy byte        
    //follow it with a serial_read
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  serial_read 
////////////////////////////////////////////////////////////////////////////////////////////////////
//pulse Re_n (async) or wait for Dqs (sync) and compares output data to expected value
task serial_read;
  input [DQ_BITS -1: 0] data;
  input [1:0] pattern;
  input [ROW_BITS -1: 0] size;
  integer i;
  begin
    // Serial Read
    $display ("At time %0t,  READ DATA : size=%0d,\t data=%0h,\t pattern=%0d", $realtime, size, data, pattern);
    wait(so_so1 !== 1'bz);
    for (i = 0; i <= size - 1; i = i + 1) begin
      latch_and_check_data(data);
      case (pattern)
        2'b00 : ;
        2'b01 : data = data + 1;
        2'b10 : data = data - 1;
        2'b11 : data = 0;
      endcase
    end
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  latch_and_check_data
////////////////////////////////////////////////////////////////////////////////////////////////////
task latch_and_check_data;
  input [DQ_BITS -1: 0] exp_data;
  begin
    wait (~rd_verify); //if a verify is already taking place, wait for it to finish
    rd_dq <= exp_data;
    // rd_dq holds the expected data, now read in the actual data
    latch_read;
    rd_verify <= 1'b1; //signal that we're ready to compare
    #1;
  end
endtask

always @ (posedge rd_verify ) begin
// Verify the data word after output delay
  if (rd_data !== rd_dq) begin
    $display ("%m at time %t: ERROR: Read data miscompare: Expected = %h, Actual = %h", $time, rd_dq, rd_data);
  end
  rd_verify <= #1 1'b0;
end

// End-of-test triggered in 'subtest.vh'
always @(posedge test_done) begin : all_done
  #5000
  $display ("%0t, Simulation is Complete. test_done=%0h", $realtime, test_done);
  //$stop(0);
  $finish;
end

wire DEADMAN_REQ = 1'b0;
integer   DEADMAN_TIMER = 0;
parameter DEADMAN_LIMIT = 70000000 ;
always @ (posedge SCK)begin
	if (DEADMAN_REQ == 1'b1)
	  DEADMAN_TIMER = 0;
	else
		DEADMAN_TIMER = DEADMAN_TIMER + 1 ;
	if (DEADMAN_TIMER == DEADMAN_LIMIT)begin
	  $display ("SWM: No Activity in %d Clocks.  Deadman Timer at time %t!!", DEADMAN_TIMER, $time);    
	  $stop();
	end
end

`ifdef INIT_MEM
  initial begin
    #1;
    //
    //preloading of mem_array can be done here
    // This approach is more flexible than readmemh
    //
    //        memory_write(block,page,col, mem_select, data)
    //              mem_select : 0 = flash memory array
    //                           1 = OTP array
    //                           2 = special config data array
    uut.uut_0.memory_write(0,0,0, 0, 8'h00);
    uut.uut_0.memory_write(0,0,1, 0, 8'h01);
    uut.uut_0.memory_write(0,0,2, 0, 8'h02);
    uut.uut_0.memory_write(0,0,3, 0, 8'h03);
    uut.uut_0.memory_write(0,0,4, 0, 8'h04);
    uut.uut_0.memory_write(0,0,5, 0, 8'h05);
    uut.uut_0.memory_write(0,0,6, 0, 8'h06);
  end
`endif

