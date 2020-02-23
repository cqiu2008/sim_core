/*******************************************************************************
*
* Confidential:  This file and all files delivered herewith are Micron Confidential Information.
*
*    File Name:  nand_die_model.V
*        Model:  BUS Functional
*    Simulator:  ModelSim
* Dependencies:  nand_parameters.vh
*
*        Email:  modelsupport@micron.com
*      Company:  Micron Technology, Inc.
*  Part Number:  MT29F
*
*  Description:  Micron NAND Verilog Model
*
*   Limitation:
*
*         Note:  This model does not model bit errors on read or write.
                 This model is a superset of all supported Micron NAND devices.
                 The model is configured for a particular device's parameters 
                 and features by the required include file, nand_parameters.vh.
*
*   Disclaimer:  THESE DESIGNS ARE PROVIDED "AS IS" WITH NO WARRANTY
*                WHATSOEVER AND MICRON SPECIFICALLY DISCLAIMS ANY
*                IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR
*                A PARTICULAR PURPOSE, OR AGAINST INFRINGEMENT.
*
*                Copyright © 2012 Micron Semiconductor Products, Inc.
*                All rights reserved
*
*   1.00 yhliu  6/2/15:Initial version.

*                        
*******************************************************************************/

`timescale 1ns/1ps

module nand_spi_chip (
	inout SI,
	input SCK,
	input CS_N,
	inout HOLD_N,
	inout WP_N,
	inout SO
	);

`include "nand_spi_chip_parameters.vh"

//set this to one for more debug and info messages
parameter DEBUG = 1;
parameter mds = 2'b00;

parameter COL_ADDR_BYTES  = 2;
parameter ROW_ADDR_BYTES  = 3;
parameter FEAT_ADDR_BYTES = 1;


wire hold_n = HOLD_N; 
//---------------------
// Internal Variables
//---------------------
reg erase_task     = 0;   // read command bits from SI
reg program_task   = 0;   // read address bits from SI
reg load_task      = 0;    // read data input bits from SI
reg dataout_enable = 0;   // enable output on SO
reg so_int         = 0;           // internal buffer for output bit
reg si_so0_int     = 0;           // internal buffer for output bit
reg wpn_so2_int    = 0;           // internal buffer for output bit
reg hold_so3_int   = 0;           // internal buffer for output bit
reg x2_output_mode = 0;
reg x4_output_mode = 0;
reg x4_input_mode  = 0;
reg dual_io_mode   = 0;
reg quad_io_mode   = 0;
reg die_select;
reg thisDieNumber;
reg wp_hold_dis    = 0; // WP#/HOLD# disable
wire hold_device   = (~hold_n && ~CS_N && ~x4_output_mode && ~x4_input_mode && ~quad_io_mode && ~wp_hold_dis);  //indicates when hold is active
wire device_active = (~CS_N && (hold_n || x4_output_mode || x4_input_mode || quad_io_mode || wp_hold_dis)); //indicates normal device operation
reg enable_read    = 0; //prepares the device to output data on SO
reg special_op     = 0; //tells the device to output status bits instead of data bits
reg reset_completed_once = 1'b0; // indicates that reset sequence completed at least once.  
reg hold_n_d;
wire device_active_d = (~CS_N && (hold_n_d || x4_output_mode || x4_input_mode || quad_io_mode || wp_hold_dis)); //used by output data

//
// Get/Set Features variables
//
reg busy           = 0; // device busy (used in status register)
reg crbsy          = 0;
reg wel            = 0; //write enable latch (used in status register)
reg erase_fail     = 0; //attempt to erase a locked block failed
reg prog_fail      = 0; // attempt to program a locked block failed

reg [3:0] bp       = 4'hf; //block protection bits, default to locked on startup
reg tb             = 1;
reg brwd           = 0; //used in block lock status register

reg [2:0] cfg       = 3'b0;
reg lot_en         = 0;
reg ecc_en         = 0;
reg ds0            = 0;


reg otp_protect    = 0; //cfg[2:0] = 110
wire otp_enable = (cfg[2:0] == 3'b010) ? 1'b1 : 1'b0; //cfg[2:0] = 010
reg spi_nor_read   = 0; //cfg[2:0] = 101



// status registers
wire [7:0] lock_features = {brwd, bp[3:0], tb, wp_hold_dis, 1'b0}; // block lock status reg
wire [7:0] config_features  = {cfg[2], cfg[1], lot_en, ecc_en, 2'b0, cfg[0], 1'b0};
wire [7:0] status_reg    = {crbsy, 3'b0, prog_fail, erase_fail, wel, busy}; // array status reg
wire [7:0] die_select_reg = {1'b0,ds0,6'b0};

// memory array
reg [DQ_BITS - 1 : 0]           mem_array [0 : (NUM_COL * NUM_ROW) -1]; //Main flash memory array
reg [NPP-1       : 0]           mem_array_npp [0 : NUM_ROW -1]; //Number of Program Page Partials to memory locations
reg [(ROW_BITS+COL_BITS) -1 :0] memory_addr [0 : NUM_ROW -1];
integer                         memory_index;
integer                         memory_used = 0;

// OTP has a separate area
reg [DQ_BITS -1 : 0] otp_array [0:(NUM_OTP_PAGES*NUM_COL)-1];    
reg [NUM_OTP_PAGES -1:0] otp_used = 0;

//
// Counters
//
reg [ROW_BITS -1:0] index = 0;       // byte index.  used for the current bit location of address and data bytes
reg [COL_BITS -1:0] data_index = 0;  // cache reg index.  keeps track of where we are for cache_reg input/output bytes
integer i,j;

//
// Buffers 
//
reg [7:0] byte_reg    = 0; //temporary data input buffer
reg [7:0] cmd_reg     =  0;             // command buffer
reg [7:0] lastCmd     =  0;            // previous recognized command
reg [(COL_ADDR_BYTES * 8) -1 :0]  col_addr_reg  = 0; // column address buffer
reg [(ROW_ADDR_BYTES * 8) -1 :0]  row_addr_reg  = 0; // row address buffer
reg [FEAT_BITS -1 :0]             feat_addr_reg = 0; // feature address buffer
//this could be any configuration, conceptually easier to code it for byte storage
reg [7:0] cache_reg [0: NUM_PLANE -1][ 0 : NUM_COL-1];   // local cache buffer
reg [7:0] data_reg [0: NUM_PLANE -1][ 0: NUM_COL-1];  // local data buffer

// Misc
reg finish_erase = 0;
reg finish_reset = 0;  // When this goes high, the reset has completed and model ready.  
reg finish_prog  = 0;  // When this goes high, the array programming cleanup operations will trigger
reg finish_load  = 0;  // When this goes high, the page read cleanup operations will trigger
reg finish_cache_rd = 0;  //when this goes high, the cache read cleanup operation will trigger

reg cache_op = 0;
reg cache_last = 0;

reg active_plane  = 0;
reg cache_rd_active_plane = 0; // used to designate which plane should be copying data from data register to cache register

reg [NPP-1:0] npp           = 0;
reg [NPP-1:0] npp_set       = 0;
reg [NPP-1:0] npp_clr_n     = {NPP{1'b1}};
reg [NPP-1:0] npp_prg_clr_n = {NPP{1'b1}};

//mux this special_reg to select the appropriate features status register
// assigning the mux selector here makes it easier to code the data output operation
wire [7:0] special_reg   = (feat_addr_reg === 8'hA0) ? lock_features : (feat_addr_reg === 8'hB0) ?  config_features :  (feat_addr_reg === 8'hC0) ? status_reg : die_select_reg;

//
// Output wires
//
// SPI interface signals and initial values
assign SO = dataout_enable ? so_int : 1'bz;
wire [7:0] output_byte  = cache_reg[active_plane][data_index]; //current data output byte

//Continuous Assignments
wire si_so0_wire; 
wire wpn_so2_wire;
wire hold_so3_wire;

assign SI	= si_so0_wire;
assign WP_N	= wpn_so2_wire;
assign HOLD_N	= hold_so3_wire;

assign si_so0_wire	= ((x2_output_mode || x4_output_mode) && dataout_enable) ? si_so0_int : 1'bz;
assign wpn_so2_wire	= (x4_output_mode && dataout_enable) ? wpn_so2_int : 1'bz;
assign hold_so3_wire	= (x4_output_mode && dataout_enable) ? hold_so3_int : 1'bz;

//State parameters
reg [2:0] spi_state= 0;          // current state of controller
parameter CMD_STATE      = 3'b000;
parameter ADDR_STATE     = 3'b001;
parameter DATAIN_STATE   = 3'b010;
parameter IDLE_STATE     = 3'b111;

reg [2:0] addr_sel    =  0;      // selects which address is being input
parameter COL_ADDR_SEL    = 3'b000;
parameter ROW_ADDR_SEL    = 3'b001;
parameter FEAT_ADDR_SEL   = 3'b010;
parameter DUMMY_ADDR_SEL  = 3'b011;
parameter DUMMY1_ADDR_SEL = 3'b111; // used for SPI NOR read. dummy cycle prior to column address


reg [1:0] op_type;               //keep track of what type of data occurs with the current command
parameter NODATA_OP      = 2'b00;
parameter DATAIN_OP      = 2'b01;
parameter DATAOUT_OP     = 2'b10;

//---------------------------
// ERROR reporting variables
//---------------------------
parameter   ERR_MAX_REPORTED =  -1; // >0 = report errors up to ERR_MAX_REPORTED, <0 = report all errors
parameter   ERR_MAX =           -1;  // >0 = stop the simulation after ERR_MAX has been reached, <0 = never stop the simulation
localparam   ERR_CODES =         10; // track up to 10 different error codes
localparam   MSGLENGTH =        256;
reg  [8*MSGLENGTH:1]           msg;
integer     ERR_MAX_INT =  ERR_MAX;
wire [ERR_CODES : 1]       EXP_ERR;
assign EXP_ERR = {ERR_CODES {1'b0}}; // the model expects no errors.  Can only be changed for debug by 'force' statement in testbench.
// Enumerated error codes (0 = unused)
localparam   ERR_MISC   =  1;
localparam   ERR_CMD    =  2;
localparam   ERR_STATUS =  3;
localparam   ERR_CACHE  =  4;
localparam   ERR_ADDR   =  5;  //seq page, 2plane, page read cache mode, internal data move addressing restrictions
localparam   ERR_MEM    =  6;
localparam   ERR_LOCK   =  7;
localparam   ERR_OTP    =  8;
localparam   ERR_TIM    =  9; //timing errors
localparam   ERR_NPP    = 10;

integer     errcount [1:ERR_CODES];
integer     warnings;
integer     errors;
integer     failures;
reg [8*12-1:0] err_strings [1:ERR_CODES];
real        delay;

initial begin : INIT_ERRORS
    warnings = 0;
    errors = 0;
    failures = 0;
    for (i=1; i<=ERR_CODES; i=i+1) begin
        errcount[i] = 0;
    end
    err_strings[ERR_MISC    ] =         "MISC";
    err_strings[ERR_CMD     ] =          "CMD";
    err_strings[ERR_STATUS  ] =       "STATUS";
    err_strings[ERR_CACHE   ] =        "CACHE";
    err_strings[ERR_ADDR    ] =         "ADDR";
    err_strings[ERR_MEM     ] =          "MEM";
    err_strings[ERR_LOCK    ] =         "LOCK";
    err_strings[ERR_NPP     ] = "Partial Page";
    err_strings[ERR_TIM     ] =       "Timing";
end 

//*********************************************************
//            INITIALIZATION
//*********************************************************
initial begin
    //In multiple die configurations, we need a way to individually identify each device
    if (mds[1] == 1) // Dual Die
          thisDieNumber = mds[0];
    else
          thisDieNumber = 0;
    die_select  <= (thisDieNumber == 1'b0) ? 1'b1 : 1'b0; 


    //initialize the data buffer to all FF's
    clear_cache_register;
    for(memory_index=0; memory_index < NUM_ROW -1 ; memory_index = memory_index + 1) begin
        mem_array_npp[memory_index] = 0;
        for (i=0; i<=NUM_COL-1; i=i+1) begin
               mem_array [memory_index*NUM_COL + i] = {DQ_BITS{1'b1}};
        end
    end
    memory_index = 0;
    if (thisDieNumber == 1'b0) begin
        $readmemh(memory_file, mem_array);
        $display("[%0t ns] ==INFO== Load memory content from (%0s) file.", $time, memory_file);
        memory_used  = memory_used + 1'b1;
        memory_addr[memory_index] = 0;
        memory_index = memory_index + 1'b1;
    end
    for(j=2; j < NUM_OTP_PAGES -1 ; j = j + 1) begin
        for (i=0; i<=NUM_COL-1; i=i+1) begin
               otp_array [j*NUM_COL + i] = {DQ_BITS{1'b1}};
        end
    end
    otp_used[1:0] = 2'b11; // first 2 otp pages are actually UID and parameter page values
    //Set manufacturer's ID to 128'h05060708_090A0B0C_0D0E0F10_11121314 until defined
    for (i=0; i < 512 ; i=i+32) begin
	for (j=0;j<16;j=j+1) begin
	    otp_array [0*NUM_COL + i+j] = 8'h05+j;
	    otp_array [0*NUM_COL + i+j+16] = 8'hFA-j;
	end
    end
    for (i=512; i<=NUM_COL-1; i=i+1) begin
	otp_array [0*NUM_COL + i] = {DQ_BITS{1'b1}};
    end
    setup_params_array;
    for (i=0; i<=767; i=i+1) begin
	otp_array [1*NUM_COL + i] = onfi_params_array[i%256];
    end
    for (i=768; i<=NUM_COL-1; i=i+1) begin
	otp_array [1*NUM_COL + i] = {DQ_BITS{1'b1}};
    end
    $sformat(msg, "Entering Alternative power up sequence...");
    INFO(msg);
    `ifdef SHORT_RESET
    	delay  = tRST_rdy;
    `else
    	delay  = tRST_pwr;
    `endif 
    finish_reset = 0;
    finish_reset <= #delay 1'b1;
    busy	 = 1;
    busy	<= #delay 1'b0;
end

//*********************************************************
//            TASKS
//*********************************************************

//---------------------------------------------------
// TASK: INFO("msg")
//---------------------------------------------------
task INFO;
   input [MSGLENGTH*8:1] msg;
begin
  $display("%m at time %0t: %0s", $time, msg);
end
endtask

//---------------------------------------------------
// TASK: WARN("msg")
//---------------------------------------------------
task WARN;
   input [MSGLENGTH*8:1] msg;
begin
  $display("%m at time %0t: %0s", $time, msg);
  warnings = warnings + 1;
end
endtask

//---------------------------------------------------
// TASK: ERROR(errcode, "msg")
//---------------------------------------------------
task ERROR;
   input [7:0] errcode;
   input [MSGLENGTH*8:1] msg;
begin
    if ($realtime > 0) begin
        errcount[errcode] = errcount[errcode] + 1;
        errors = errors + 1;

        if ((errcount[errcode] <= ERR_MAX_REPORTED) || (ERR_MAX_REPORTED < 0))
            if ((EXP_ERR[errcode] === 1) && ((errcount[errcode] <= ERR_MAX_INT) || (ERR_MAX_INT < 0))) begin
                $display("Caught expected violation at time %0t: %0s", $time, msg);        
            end else begin
                $display("%m at time %0t: %0s", $time, msg);
            end
        if (errcount[errcode] == ERR_MAX_REPORTED) begin
            $sformat(msg, "Reporting for %s has been disabled because ERR_MAX_REPORTED has been reached.", err_strings[errcode]);
            INFO(msg);
        end

        //overall model maximum error limit
        if ((errcount[errcode] > ERR_MAX_INT) && (ERR_MAX_INT >= 0)) begin
            STOP;
        end
    end
end
endtask

//---------------------------------------------------
// TASK: FAIL("msg")
//---------------------------------------------------
task FAIL;
   input [MSGLENGTH*8:1] msg;
begin
   $display("%m at time %0t: %0s", $realtime, msg);
   failures = failures + 1;
   STOP;
end
endtask

//---------------------------------------------------
// TASK: Stop()
//---------------------------------------------------
task STOP;
begin
  $display("%m at time %0t: %d warnings, %d errors, %d failures", $time, warnings, errors, failures);
  $stop(0);
end
endtask

//-----------------------------------------------------------------
// TASK : clear_cache_register 
// Completely clears a cache register to all FF's to prepare
// for data input.
//-----------------------------------------------------------------
task clear_cache_register;
    integer pl_cnt;
    reg [COL_BITS -1:0] i;
begin
   for (pl_cnt = 0; pl_cnt < NUM_PLANE; pl_cnt = pl_cnt +1) begin
     for (i = 0; i <= NUM_COL - 1; i = i + 1) begin
     	cache_reg[pl_cnt][i] = {DQ_BITS {1'b1}};
     end
   end
end
endtask

//-----------------------------------------------------------------
// TASK : copy_cachereg_to_datareg
//  Simple copy of cache_reg to the data_reg 
//-----------------------------------------------------------------
task copy_cachereg_to_datareg;
   input  plane;
   reg [COL_BITS -1:0] i;
begin
     for (i = 0; i <= NUM_COL - 1; i = i + 1) begin
     	data_reg[plane][i] = cache_reg[plane][i];
     end
end
endtask


//---------------------------------------------------------
//  check to see if current command is valid.  
//  If so, set the next state appropriately.
//---------------------------------------------------------
task check_command;
begin
    #1;
    if (~reset_completed_once) begin
        if (NUM_DIE > 1) begin
          if (cmd_reg !== 8'hFF ) begin
            $sformat(msg, "FATAL : RESET must be first command issued after powerup.");
            FAIL(msg);
          end
	end
	else begin
          if (cmd_reg !== 8'hFF && cmd_reg != 8'h0F ) begin
            $sformat(msg, "FATAL : RESET or Get Feature must be first command issued after powerup.");
            FAIL(msg);
          end
	end
    end

    case (cmd_reg)
    //------------------------------------------- x
    //  Command (8'h02) : PROGRAM LOAD 
    //------------------------------------------- x
    8'h02 : begin
              if (die_select && ~busy && ~crbsy) begin
                    addr_sel  <= COL_ADDR_SEL;
                    spi_state <= ADDR_STATE;
                    index     <= (COL_ADDR_BYTES * 8) -1;
                    lastCmd   <= 8'h02;
                    op_type   <= DATAIN_OP;
                    clear_cache_register;
                    npp_clr_n <= 0;
                    npp_clr_n <= #1 {NPP{1'b1}};
	      end
	      else begin	      
	         if (busy || crbsy) begin
        	      $sformat(msg, "INVALID COMMAND.  CMD=0x%2H during device busy or cache read busy", cmd_reg);
        	      ERROR(ERR_CMD, msg);
		 end
        	 spi_state <= IDLE_STATE;	    
	      end
            end
    //------------------------------------------- x
    //  Command (8'h03) : READ FROM CACHE
    //------------------------------------------- x
    8'h03, 8'h0B : begin
              if (die_select && ~busy) begin
                lastCmd   <= cmd_reg;
		if (spi_nor_read) begin
                  addr_sel  <= DUMMY1_ADDR_SEL;
                  index     <= (1 * 8) -1; // one byte dummy cycle before column address cycle
		end
		else begin
                  addr_sel  <= COL_ADDR_SEL;
                  index     <= (COL_ADDR_BYTES * 8) -1;
		end
                spi_state <= ADDR_STATE;
                op_type   <= DATAOUT_OP;
                npp_clr_n <= 0;
                npp_clr_n <= #1 {NPP{1'b1}};
	      end
	      else begin	      
	         if (busy ) begin
        	      $sformat(msg, "INVALID COMMAND.  CMD=0x%2H during device busy", cmd_reg);
        	      ERROR(ERR_CMD, msg);
		 end
        	 spi_state <= IDLE_STATE;	    
	      end
            end
    //------------------------------------------- x
    //  Command (8'h04) : WRITE DISABLE
    //------------------------------------------- x
    8'h04 : begin
              if (die_select && ~busy && ~crbsy) begin
                wel       <= 0;
                spi_state <= IDLE_STATE;
                lastCmd   <= 8'h04;
                npp_clr_n <= 0;
                npp_clr_n <= #1 {NPP{1'b1}};
	      end
	      else begin	      
	         if (busy || crbsy) begin
        	      $sformat(msg, "INVALID COMMAND.  CMD=0x%2H during device busy", cmd_reg);
        	      ERROR(ERR_CMD, msg);
		 end
        	 spi_state <= IDLE_STATE;	    
	      end
            end
    //------------------------------------------- x
    //  Command (8'h06) : WRITE ENABLE
    //------------------------------------------- x
    8'h06 : begin
              if (die_select && ~busy && ~crbsy) begin
                wel       <= 1;
                spi_state <= IDLE_STATE;
                lastCmd   <= 8'h06;
                npp_clr_n <= 0;
                npp_clr_n <= #1 {NPP{1'b1}};
	      end
	      else begin	      
	         if (busy || crbsy) begin
        	      $sformat(msg, "INVALID COMMAND.  CMD=0x%2H during device busy", cmd_reg);
        	      ERROR(ERR_CMD, msg);
		 end
        	 spi_state <= IDLE_STATE;	    
	      end
            end
    //------------------------------------------- x
    //  Command (8'h0F) : GET FEATURE
    //------------------------------------------- x
    8'h0F : begin
              if (die_select) begin
                lastCmd   <= 8'h0F;
                spi_state <= ADDR_STATE;
                index     <= (FEAT_ADDR_BYTES * 8) -1;
                addr_sel  <= FEAT_ADDR_SEL;
                op_type   <= DATAOUT_OP;
                npp_clr_n <= 0;
                npp_clr_n <= #1 {NPP{1'b1}};
	      end
	      else begin
        	 spi_state <= IDLE_STATE;	    
	      end
            end
    //------------------------------------------- x
    //  Command (8'h10) : PROGRAM EXECUTE
    //------------------------------------------- x
    8'h10 : begin
              if (die_select  && ~busy && ~crbsy) begin
                if (verify_wel(cmd_reg)) begin
                    //clear the program fail flag if it is set
                    prog_fail = 0;
                    spi_state <= ADDR_STATE;
                    index     <= (ROW_ADDR_BYTES * 8) -1;
                    addr_sel  <= ROW_ADDR_SEL;
                    lastCmd   <= 8'h10;
                    op_type   <= NODATA_OP;
                end else begin
        	    $sformat(msg, "Cannot execute CMD=%2hh.  WEL Bit is not set.", cmd_reg);
        	    ERROR(ERR_CMD, msg);
        	    spi_state <= IDLE_STATE;	    
                    $display("%t, Command %2hh was not preceeded by required Write Enable Command 0x06.", $time, cmd_reg);
                end
	      end
	      else begin	      
	         if (busy || crbsy) begin
        	      $sformat(msg, "INVALID COMMAND.  CMD=0x%2H during device busy", cmd_reg);
        	      ERROR(ERR_CMD, msg);
		 end
        	 spi_state <= IDLE_STATE;	    
	      end
	      
            end
    //------------------------------------------- x
    //  Command (8'h13) : PAGE READ
    //------------------------------------------- x
    8'h13 : begin
              if (die_select && ~busy && ~crbsy) begin
                spi_state <= ADDR_STATE;
                index     <= (ROW_ADDR_BYTES * 8) -1;
                addr_sel  <= ROW_ADDR_SEL;
                lastCmd   <= 8'h13;
                op_type   <= NODATA_OP;
                npp_clr_n <= 0;
                npp_clr_n <= #1 {NPP{1'b1}};
	      end
	      else begin	      
	         if (busy || crbsy) begin
        	      $sformat(msg, "INVALID COMMAND.  CMD=0x%2H during device busy", cmd_reg);
        	      ERROR(ERR_CMD, msg);
		 end
        	 spi_state <= IDLE_STATE;	    
	      end
            end
    //------------------------------------------- x
    //  Command (8'h1F) : SET FEATURE
    //------------------------------------------- x
    8'h1F : begin
              if (~busy && ~crbsy) begin
                lastCmd   <= 8'h1F;
                spi_state <= ADDR_STATE;
                index     <= (FEAT_ADDR_BYTES * 8) -1;
                addr_sel  <= FEAT_ADDR_SEL;
                op_type   <= DATAIN_OP;
                npp_clr_n <= 0;
                npp_clr_n <= #1 {NPP{1'b1}};
	      end
	      else begin	      
        	 $sformat(msg, "INVALID COMMAND.  CMD=0x%2H during device busy", cmd_reg);
        	 ERROR(ERR_CMD, msg);
        	 spi_state <= IDLE_STATE;	    
	      end
            end
    //------------------------------------------- x
    //  Command (8'h30) : PAGE READ CACHE
    //------------------------------------------- x
    8'h30 : begin
              if (die_select && ~busy && ~crbsy) begin
                spi_state <= ADDR_STATE;
                index     <= (ROW_ADDR_BYTES * 8) -1;
                addr_sel  <= ROW_ADDR_SEL;
                lastCmd   <= 8'h30;
                op_type   <= NODATA_OP;
                npp_clr_n <= 0;
                npp_clr_n <= #1 {NPP{1'b1}};
		cache_op  <= 1;
		cache_last <= 0;
	      end
	      else begin	      
	         if (busy || crbsy) begin
        	      $sformat(msg, "INVALID COMMAND.  CMD=0x%2H during device busy", cmd_reg);
        	      ERROR(ERR_CMD, msg);
		 end
        	 spi_state <= IDLE_STATE;	    
	      end
            end
    //------------------------------------------- x
    //  Command (8'h32) : PROGRAM LOAD x4
    //------------------------------------------- x
    8'h32 : begin
              if (die_select && ~busy && ~crbsy) begin
                  addr_sel  <= COL_ADDR_SEL;
                  spi_state <= ADDR_STATE;
                  index     <= (COL_ADDR_BYTES * 8) -1;
                  lastCmd   <= 8'h32;
                  op_type   <= DATAIN_OP;
		  x4_input_mode <= 1;
                  clear_cache_register;
                  npp_clr_n <= 0;
                  npp_clr_n <= #1 {NPP{1'b1}};
	      end
	      else begin	      
	         if (busy || crbsy) begin
        	      $sformat(msg, "INVALID COMMAND.  CMD=0x%2H during device busy", cmd_reg);
        	      ERROR(ERR_CMD, msg);
		 end
        	 spi_state <= IDLE_STATE;	    
	      end
            end
    //-------------------------------------------
    //  Command (8'h34) : PROG LOAD RANDOM DATA x4
    //-------------------------------------------
    8'h34 : begin
              if (die_select && ~busy && ~crbsy) begin
                spi_state <= ADDR_STATE;
                index     <= (COL_ADDR_BYTES * 8) -1;
                addr_sel  <= COL_ADDR_SEL;
                lastCmd   <= 8'h34;
                op_type   <= DATAIN_OP;
		x4_input_mode <= 1;
	      end
	      else begin	      
	         if (busy || crbsy) begin
        	      $sformat(msg, "INVALID COMMAND.  CMD=0x%2H during device busy", cmd_reg);
        	      ERROR(ERR_CMD, msg);
		 end
        	 spi_state <= IDLE_STATE;	    
	      end
            end
    //------------------------------------------- x
    //  Command (8'h3B) : READ FROM CACHE x2
    //------------------------------------------- x
    8'h3B : begin
              if (die_select && ~busy ) begin
                lastCmd   <= cmd_reg;
                addr_sel  <= COL_ADDR_SEL;
                index     <= (COL_ADDR_BYTES * 8) -1;
                spi_state <= ADDR_STATE;
                op_type   <= DATAOUT_OP;
                npp_clr_n <= 0;
                npp_clr_n <= #1 {NPP{1'b1}};
		x2_output_mode <= 1;
	      end
	      else begin	      
	         if (busy) begin
        	      $sformat(msg, "INVALID COMMAND.  CMD=0x%2H during device busy", cmd_reg);
        	      ERROR(ERR_CMD, msg);
		 end
        	 spi_state <= IDLE_STATE;	    
	      end
            end
    //------------------------------------------- x
    //  Command (8'h3F) : PAGE READ CACHE LAST
    //------------------------------------------- x
    8'h3F : begin
              if (die_select && ~busy && ~crbsy) begin
                lastCmd   <= 8'h3F;
                op_type   <= NODATA_OP;
                npp_clr_n <= 0;
                npp_clr_n <= #1 {NPP{1'b1}};
		cache_op  <= 1;
		cache_last <= 1;
		#1;
		read_page;
	      end
	      else begin	      
	         if (busy || crbsy) begin
        	      $sformat(msg, "INVALID COMMAND.  CMD=0x%2H during device busy", cmd_reg);
        	      ERROR(ERR_CMD, msg);
		 end
        	 spi_state <= IDLE_STATE;	    
	      end
            end
    //------------------------------------------- x
    //  Command (8'h6B) : READ FROM CACHE x4
    //------------------------------------------- x
    8'h6B : begin
              if (die_select && ~busy ) begin
                lastCmd   <= cmd_reg;
                addr_sel  <= COL_ADDR_SEL;
                index     <= (COL_ADDR_BYTES * 8) -1;
                spi_state <= ADDR_STATE;
                op_type   <= DATAOUT_OP;
                npp_clr_n <= 0;
                npp_clr_n <= #1 {NPP{1'b1}};
		x4_output_mode <= 1;
	      end
	      else begin	      
	         if (busy ) begin
        	      $sformat(msg, "INVALID COMMAND.  CMD=0x%2H during device busy", cmd_reg);
        	      ERROR(ERR_CMD, msg);
		 end
        	 spi_state <= IDLE_STATE;	    
	      end
            end
    //-------------------------------------------
    //  Command (8'h84) : PROG LOAD RANDOM DATA
    //-------------------------------------------
    8'h84 : begin
              if (die_select && ~busy && ~crbsy) begin
                spi_state <= ADDR_STATE;
                index     <= (COL_ADDR_BYTES * 8) -1;
                addr_sel  <= COL_ADDR_SEL;
                lastCmd   <= 8'h84;
                op_type   <= DATAIN_OP;
	      end
	      else begin	      
	         if (busy || crbsy) begin
        	      $sformat(msg, "INVALID COMMAND.  CMD=0x%2H during device busy", cmd_reg);
        	      ERROR(ERR_CMD, msg);
		 end
        	 spi_state <= IDLE_STATE;	    
	      end
            end
    //-------------------------------------------
    //  Command (8'hD8) : BLOCK ERASE
    //-------------------------------------------
    8'hD8 : begin
              if (die_select && ~busy && ~crbsy) begin
                if (verify_wel(cmd_reg)) begin
                    //clear the erase fail flag if it is set
                    erase_fail = 0;
	            spi_state <= ADDR_STATE;
    	            index     <= (ROW_ADDR_BYTES * 8) -1;
        	    addr_sel  <= ROW_ADDR_SEL;
            	    lastCmd   <= 8'hD8;
                    op_type   <= NODATA_OP;
                    npp_clr_n <= 0;
                    npp_clr_n <= #1 {NPP{1'b1}};
		end else begin
        	    $sformat(msg, "Cannot execute CMD=%2hh.  WEL Bit is not set.", cmd_reg);
        	    ERROR(ERR_CMD, msg);
        	    spi_state <= IDLE_STATE;	    
                    $display("%t, Command %2hh was not preceeded by required Write Enable Command 0x06.", $time, cmd_reg);
		end
	      end
	      else begin	      
	         if (busy || crbsy) begin
        	      $sformat(msg, "INVALID COMMAND.  CMD=0x%2H during device busy", cmd_reg);
        	      ERROR(ERR_CMD, msg);
		 end
        	 spi_state <= IDLE_STATE;	    
	      end
            end
    //-------------------------------------------
    //  Command (8'h9F) : READ ID
    //-------------------------------------------
    8'h9F : begin
              if (die_select && ~busy && ~crbsy) begin
                lastCmd   <= 8'h9F;
                spi_state <= ADDR_STATE;
                index     <= (1 * 8) -1; //one dummy byte
                addr_sel  <= DUMMY_ADDR_SEL;
                op_type   <= DATAOUT_OP;
                npp_clr_n <= 0;
                npp_clr_n <= #1 {NPP{1'b1}};
	      end
	      else begin	      
	         if (busy || crbsy) begin
        	      $sformat(msg, "INVALID COMMAND.  CMD=0x%2H during device busy", cmd_reg);
        	      ERROR(ERR_CMD, msg);
		 end
        	 spi_state <= IDLE_STATE;	    
	      end
            end
    //------------------------------------------- x
    //  Command (8'hBB) : READ FROM CACHE Dual IO
    //------------------------------------------- x
    8'hBB : begin
              if (die_select && ~busy ) begin
                lastCmd   <= cmd_reg;
                addr_sel  <= COL_ADDR_SEL;
                index     <= (COL_ADDR_BYTES * 8) -1;
                spi_state <= ADDR_STATE;
                op_type   <= DATAOUT_OP;
                npp_clr_n <= 0;
                npp_clr_n <= #1 {NPP{1'b1}};
		dual_io_mode <= 1;
		x2_output_mode <= 1;
	      end
	      else begin	      
	         if (busy) begin
        	      $sformat(msg, "INVALID COMMAND.  CMD=0x%2H during device busy", cmd_reg);
        	      ERROR(ERR_CMD, msg);
		 end
        	 spi_state <= IDLE_STATE;	    
	      end
            end
    //------------------------------------------- x
    //  Command (8'hEB) : READ FROM CACHE Quad IO
    //------------------------------------------- x
    8'hEB : begin
              if (die_select && ~busy ) begin
                lastCmd   <= cmd_reg;
                addr_sel  <= COL_ADDR_SEL;
                index     <= (COL_ADDR_BYTES * 8) -1;
                spi_state <= ADDR_STATE;
                op_type   <= DATAOUT_OP;
                npp_clr_n <= 0;
                npp_clr_n <= #1 {NPP{1'b1}};
		quad_io_mode <= 1;
		x4_output_mode <= 1;
	      end
	      else begin	      
	         if (busy ) begin
        	      $sformat(msg, "INVALID COMMAND.  CMD=0x%2H during device busy", cmd_reg);
        	      ERROR(ERR_CMD, msg);
		 end
        	 spi_state <= IDLE_STATE;	    
	      end	      
            end
    //-------------------------------------------
    //  Command (8'hFF) : RESET
    //-------------------------------------------
    8'hFF : begin
                reset;
                npp_clr_n <= 0;
                npp_clr_n <= #1 {NPP{1'b1}};
            end
    //-------------------------------------------
    //         INVALID  COMMAND
    //-------------------------------------------
   default: begin
                report_invalid_command(cmd_reg);
            end
    endcase
end
endtask

task reset;
begin
    if (reset_completed_once) begin
        if (busy) begin
            if (load_task) begin
                delay = tRST_read;
		disable read_page;
		load_task = 0;
		if (crbsy)
		crbsy <= #delay 0;
		cache_op = 0;
		cache_last = 0;
		
            end else if (program_task) begin
                delay = tRST_prog;
		disable program_page;
		program_task = 0;
		
            end else if (erase_task) begin
                delay = tRST_erase;
		disable erase_block;
		erase_task = 0;
            end else begin
                delay = tRST_rdy;
            end
	end else if (crbsy) begin
            delay = tRST_read;
	    disable complete_load;
	    crbsy <= #delay 0;
	    cache_op = 0;
	    finish_cache_rd <= #delay 0;	
        end else begin
            delay = tRST_rdy;
        end
    end else begin // first reset during powerup
        `ifdef SHORT_RESET
            delay  = tRST_rdy;
        `else
            delay  = tRST_pwr;
        `endif 
    end

    if (DEBUG) begin $sformat(msg, "Entering reset."); INFO(msg); end
    busy         = 1;
    busy        <= #delay 1'b0;
    lastCmd     <= 8'hFF;
    spi_state   <= IDLE_STATE;
    ds0         <= 0;
    die_select  <= (thisDieNumber == 1'b0) ? 1'b1 : 1'b0; 
    clear_cache_register;
    wel         <= 0;
    cfg[2:0]    <= 3'b0;
    finish_reset = 0;
    finish_reset <= #delay 1'b1;

end
endtask

always @(posedge finish_reset) begin
    if (DEBUG) begin $sformat(msg, "Reset Complete."); INFO(msg); end
    if (thisDieNumber == 1'b0) begin
      //load page 0 data into cache register after reset    
      for (i = 0; i < NUM_COL; i = i + 1) begin 
     	  if (memory_addr_exists(0)) begin
     	      cache_reg[0][i] = mem_array[memory_index*NUM_COL + i];
     	  end else begin
     	      cache_reg[0][i] = {DQ_BITS{1'b1}};
     	  end
      end
      copy_cachereg_to_datareg(0);
    end
    
    reset_completed_once <= 1'b1;
end

//---------------------------------------------------------
//  Output Error indicating an inavlid command
//---------------------------------------------------------
task report_invalid_command;
    input [7:0] badCmd;
begin
    $sformat(msg, "ERROR: INVALID COMMAND.  CMD=0x%2H", badCmd);
    ERROR(ERR_CMD, msg);
    spi_state <= IDLE_STATE;
end
endtask

//---------------------------------------------------------
//  check to see if current address is valid.
//  If so, set the next state appropriately.
//---------------------------------------------------------
task check_address;
begin
    // if this is a random data read, we need to go back for one more dummy address byte
    if (((lastCmd == 8'h03) || (lastCmd == 8'h0B)) && (addr_sel == DUMMY1_ADDR_SEL)) begin
        spi_state <= ADDR_STATE;
        index	  <= (COL_ADDR_BYTES * 8) -1;
        addr_sel  <= COL_ADDR_SEL;
    end else if ((((lastCmd == 8'h03) && ~spi_nor_read) || (lastCmd == 8'h0B) || (lastCmd == 8'h3B) || (lastCmd == 8'h6B) || (lastCmd == 8'hBB) || (lastCmd == 8'hEB)) && (addr_sel == COL_ADDR_SEL)) begin
        spi_state <= ADDR_STATE;
        index     <= ((lastCmd == 8'hBB) || (lastCmd == 8'hEB)) ? 3: (1 * 8) -1; //one dummy byte
        addr_sel  <= DUMMY_ADDR_SEL;        
    end else begin
        case (op_type) 
        DATAIN_OP  :  begin
                spi_state   <= DATAIN_STATE;
                index       <= 0;             // reset the byte index
                if (lastCmd == 8'h1F) begin
                    // SMK : Do something here to indicate features input
                    case (feat_addr_reg) 
                        8'hA0, 8'hB0 : begin
                            special_op <= 1;
                        end
			8'hD0: begin
			      if (NUM_DIE > 1) begin
                                 special_op <= 1;
			      end
			      else begin
                                if (DEBUG) begin $sformat(msg, "Invalid Feature address 8'hD0 for signle die address."); WARN(msg); end
			      
			      end
			end
                        default : begin
                            if (DEBUG) begin $sformat(msg, "Invalid Feature address."); WARN(msg); end
                        end
                    endcase
                end else begin
                    data_index  <= col_addr_reg;  // set the data reg index to the input column address
                end
            end
        DATAOUT_OP : begin
                enable_read <= 1;
                index       <= 0;
                spi_state   <= IDLE_STATE;
                //reset column address if a random data read was executed
                if ((lastCmd == 8'h03) || (lastCmd == 8'h0B) || (lastCmd == 8'h3B) || (lastCmd == 8'h6B)|| (lastCmd == 8'hBB) || (lastCmd == 8'hEB)) begin
                    data_index  <= col_addr_reg;  // set the data reg index to the input column address
                end
                if (lastCmd == 8'h0F) begin
                    case (feat_addr_reg)
                        8'hA0, 8'hB0, 8'hC0 : begin
                            special_op <= 1;
                        end
			8'hD0: begin
			      if (NUM_DIE > 1) begin
                                 special_op <= 1;
			      end
			      else begin
                                if (DEBUG) begin $sformat(msg, "Invalid Feature address 8'hD0 for signle die address."); WARN(msg); end
			      
			      end
			end
                        default : begin
                            if (DEBUG) begin $sformat(msg, "Invalid Feature address."); WARN(msg); end
                        end
                    endcase
                end else if (lastCmd == 8'h9F) begin
                    data_index = 0;
                    clear_cache_register;
		    active_plane = 0;
                    cache_reg[0][0] = ID_BYTE_0;
                    cache_reg[0][1] = ID_BYTE_1;
                    //doesn't matter what any extra data is acccording to datasheet
                end
            end
        default : begin
                if (lastCmd == 8'hD8) begin
                    erase_block;
                end
                if (lastCmd == 8'h10) begin
                    program_page;
                end
                if (lastCmd == 8'h13 || lastCmd == 8'h30 ) begin
                    read_page;
                end
                spi_state   <= IDLE_STATE;
            end
        endcase
    end
end
endtask


//---------------------------------------------------------
//  unlocked_block : checks input address against bp[3:0]
//---------------------------------------------------------
function unlocked_block;
    input [ROW_BITS-1:0] row_addr;
    reg [BLCK_BITS -1:0] block_addr;
    reg [BLCK_BITS :0]   block_limit;
begin
    unlocked_block = 0;
    block_addr = row_addr[ROW_BITS-1:PAGE_BITS];
    //set the block max address
    block_limit = 1 << BLCK_BITS; 
    if (bp[3:0] == 4'b0000) begin
       unlocked_block = 1;
    end
    else begin
      if (tb == 1) begin // bottom locked
         if (NUM_DIE >1) begin
	    if (thisDieNumber == 1) begin // Die 1
	      if (bp[3:0] <4'b1011) begin
     	    	 unlocked_block = 1;	      
	      end
	    end
	    else begin
	     	if (bp[3:0] <4'b1011) begin
     	     	  //now set up the actual boundary based on the block protection bits
     	     	  block_limit = block_limit >> (10-bp[3:0]); 
     	     	  //now check to see if we're in the allowed range
     	     	  if (block_addr >= block_limit) begin
     	     	      unlocked_block = 1;
     	     	  end
	     	end//bp check	   
	    end	 
	 end
	 else begin
	   if (bp[3:0] <4'b1011) begin
     	     //now set up the actual boundary based on the block protection bits
     	     block_limit = block_limit >> (11-bp[3:0]); 

     	     //now check to see if we're in the allowed range
     	     if (block_addr >= block_limit) begin
     	    	 unlocked_block = 1;
     	     end
	   end//bp check
	 end//NUM_DIE
      end//bottom
      else begin // top locked
         if (NUM_DIE >1 )begin
	    if (thisDieNumber == 1) begin // Die 1
	         if (bp[3:0] <4'b1011) begin
     	           //now set up the actual boundary based on the block protection bits
     	           block_limit = block_limit - (1<<(BLCK_BITS  + bp[3:0] -10)); 
     	           //now check to see if we're in the allowed range
     	           if (block_addr < block_limit) begin
     	               unlocked_block = 1;
     	           end
	         end// bp check	    
	    end
	    else begin
	      if (bp[3:0] <4'b1011) begin // die0
     	    	 unlocked_block = 1;	      
	      end	    
	    end
	 end
	 else begin
	   if (bp[3:0] <4'b1011) begin
     	     //now set up the actual boundary based on the block protection bits
     	     block_limit = block_limit - (1<<(BLCK_BITS  + bp[3:0] -11)); 
     	     //now check to see if we're in the allowed range
     	     if (block_addr < block_limit) begin
     	    	 unlocked_block = 1;
     	     end
	   end// bp check
	 end//NUM_DIE
       end// top 
    end       
end
endfunction

//---------------------------------------------------------
//  erase_block : erases an entire block of data
//---------------------------------------------------------
task erase_block;
    reg [ROW_BITS -1 : 0] i_cnt;
    reg [BLCK_BITS -1: 0] erase_block_addr;
    integer i, j;
begin

    erase_task = 1;

    if (otp_enable) begin //OTP_enable

        $sformat(msg, "OTP Pages cannot be erased.");
        ERROR(ERR_OTP, msg);
        
    end else begin
        if (unlocked_block(row_addr_reg)) begin        
            erase_block_addr = row_addr_reg[BLCK_BITS -1 + PAGE_BITS : PAGE_BITS];

            //use associative array erase block here
            for (i=0; i<memory_used; i=i+1) begin : mem_loop
                //check to see if existing used address location matches block being erased
                if (memory_addr[i][(ROW_BITS) -1 : PAGE_BITS] === erase_block_addr) begin
                    for (j=0; j<NUM_COL; j=j+1) begin
                        mem_array[i*NUM_COL + j] = {DQ_BITS{1'b1}};
                    end
                    mem_array_npp[i] = 0;
                end
            end
    
            busy = 1;
            finish_erase <= #tERS_typ 1'b1;
            if (DEBUG) begin $sformat(msg, "Erasing block %0h ...", erase_block_addr); INFO(msg); end

        end else begin
            erase_fail <= 1;
            $sformat (msg, "ERASE operation failed.  Block is locked.");
            ERROR(ERR_LOCK, msg);
        end
	wel <= 0;
    end
end
endtask

always @(posedge finish_erase) begin
    erase_task = 0;
    busy = 0;
    finish_erase <= #1 0;
    if (DEBUG) $display ("%0t, Erase complete.", $time);
end

//---------------------------------------------------------
//  program page : programs the data_register data into 
//                  the flash array
//---------------------------------------------------------
task program_page;
    reg [COL_BITS : 0] i_cnt;
begin

    program_task = 1;
    if (otp_enable && otp_protect) begin
        $sformat (msg, "OTP PROGRAM operation failed.  OTP PROTECT bit has been set.");
        ERROR(ERR_OTP, msg);
        prog_fail <= 1;
    end else if (otp_enable && ~otp_protect) begin
        if ((row_addr_reg >= NUM_OTP_PAGES) || (row_addr_reg < 2)) begin
            $sformat (msg, "OTP PROGRAM operation failed.  Address out of range.");
            ERROR(ERR_OTP, msg);
            prog_fail <= 1;
        end else begin
            //check to see if OTP page is already programmed
            if (otp_used[row_addr_reg]) begin
                $sformat (msg, "OTP PROGRAM operation failed.  OTP Page %2d has already been programmed.", row_addr_reg);
                ERROR(ERR_OTP, msg);
                prog_fail <= 1;
            end else begin
                //valid OTP page program
                for (i_cnt = 0; i_cnt < NUM_COL; i_cnt = i_cnt + 1) begin : otp_col_loop
		    otp_array[row_addr_reg*NUM_COL + i_cnt] =  cache_reg[0][i_cnt];
                end
                otp_used[row_addr_reg] = 1;
                busy = 1;
                finish_prog <= #tPROG_typ 1'b1;
            end
        end
    end else if (cfg[2:0] == 3'b110) begin // enable OTP Protect 
        if (~otp_protect) begin

           busy = 1;
	   otp_protect <= #tPROG_typ 1'b1;
           finish_prog <= #tPROG_typ 1'b1;
	end
	else begin
            $sformat (msg, "Program sequence is issued again after the OTP area has already been protected!"); WARN(msg);
            busy = 1;
            finish_prog <= #tPROG_typ 1'b1;
	end
	
    end else if (cfg[2:0] == 3'b101) begin //SPI NOR Read Protocal
        if (~spi_nor_read) begin
           busy = 1;
	   spi_nor_read <= #tPROG_typ 1;
           finish_prog <= #tPROG_typ 1'b1;
	end
	else begin
           $sformat (msg, "Program sequence is issued again after SPI NOR Read Protocol is enabled!"); WARN(msg);
           busy = 1;
           finish_prog <= #tPROG_typ 1'b1;
	end
	
	
    end else begin

        if (unlocked_block(row_addr_reg)) begin        
            if (DEBUG) begin $sformat(msg, "Program Start to addr: block=%0h, page=%0h", row_addr_reg[ROW_BITS-1:PAGE_BITS], row_addr_reg[PAGE_BITS-1:0]); INFO(msg); end

            //if associative array has no entry for this address, add it in and bump up the memory_used
            if (~memory_addr_exists(row_addr_reg)) begin
                memory_addr[memory_index] = row_addr_reg;
                memory_used = memory_used + 1;
            end

            //check to see if we've exceed the memory limit for this sim, otherwise program the array
            if (memory_used > NUM_ROW) begin
                $sformat (msg, "Memory overflow.  Write to Address %h will be lost.\nYou must increase the NUM_ROW parameter.", {row_addr_reg,i});
                FAIL(msg);
            end else begin
                //now loop through the data reg and program each byte    
                for (i_cnt = 0; i_cnt < NUM_COL; i_cnt = i_cnt + 1) begin : col_loop
                    mem_array[memory_index*NUM_COL + i_cnt] =  cache_reg[active_plane][i_cnt] & mem_array [memory_index*NUM_COL + i_cnt];
                end
                if( (mem_array_npp[memory_index][0] & npp[0]) |
                    (mem_array_npp[memory_index][1] & npp[1]) |
                    (mem_array_npp[memory_index][2] & npp[2]) |
                    (mem_array_npp[memory_index][3] & npp[3]) ) begin
                    $sformat (msg, "Number of Partial Programs exceeded for memory row %h, page %h.", memory_addr[memory_index][(ROW_BITS-1) : PAGE_BITS], memory_addr[memory_index][(PAGE_BITS-1) : 0]); ERROR(ERR_NPP, msg);
                end
                mem_array_npp[memory_index] = (npp | mem_array_npp[memory_index]); 
                npp_prg_clr_n               =   0;
                npp_prg_clr_n              <= #1 {NPP{1'b1}};
            end
            busy = 1;
            finish_prog <= #tPROG_typ 1'b1;
            
        end else begin //else the block was locked
            prog_fail <= 1;
            $sformat (msg, "PROGRAM operation failed.  Block is locked.");
            ERROR(ERR_LOCK, msg);
        end //unlocked_block
    end
    wel <= 0;

end
endtask

always @(posedge finish_prog) begin
    program_task = 0;
    busy = 0;
    finish_prog <= #1 0;
    //program complete
    if (DEBUG) $display("%t, Program Complete", $time);
end


//---------------------------------------------------------
// read page : Loads the data register from 
//                  the flash array
//---------------------------------------------------------
task read_page;
    reg page_addr_good;
    reg [COL_BITS : 0] i_cnt;
begin

    load_task = 1;
    
    if (otp_enable) begin //OTP_enable
        if (row_addr_reg >= NUM_OTP_PAGES) begin
            $sformat (msg, "OTP READ operation failed.  Address out of range.");
            ERROR(ERR_ADDR, msg);
        end else begin
            //check to see if OTP page is already programmed
            //valid OTP page program
            for (i_cnt = 0; i_cnt < NUM_COL; i_cnt = i_cnt + 1) begin : otp_col_loop
                if (otp_used[row_addr_reg]) begin
                    cache_reg[0][i_cnt] = otp_array[row_addr_reg*NUM_COL + i_cnt];
                end else begin
                    cache_reg[0][i_cnt] = {DQ_BITS{1'b1}};
                end
            end
            //now go busy until the load is complete
            busy = 1;
            finish_load <= #tRD_max 1'b1;
        end
    end else if (cfg[2:0] == 3'b110 || cfg[2:0] == 3'b101) begin
        for (i_cnt = 0; i_cnt < NUM_COL; i_cnt = i_cnt + 1) begin 
            if ((cfg[2:0] == 3'b110 && otp_protect)|| (cfg[2:0] == 3'b101 && spi_nor_read)) begin
                cache_reg[0][i_cnt] = {DQ_BITS{1'b0}};
            end else begin
                cache_reg[0][i_cnt] = {DQ_BITS{1'b1}};
            end
        end
	busy = 1;
	finish_load <= #tRD_max 1'b1;
    end else if (lastCmd == 8'h30 || lastCmd == 8'h3f) begin
        for (i_cnt = 0; i_cnt < NUM_COL; i_cnt = i_cnt + 1) begin : col_loop_cache
            cache_reg[cache_rd_active_plane][i_cnt] = data_reg[cache_rd_active_plane][i_cnt];
        end
 
        //copy data register to cache register
        //now go busy until the load is complete
	if (lastCmd == 8'h30) crbsy = 1;
        busy = 1;
        finish_load <= #tRCBSY_max 1'b1;
    end else begin
        if (DEBUG) $display("%t, PAGE READ Start for address: block=%0h, page=%0h", $time, row_addr_reg[ROW_BITS-1:PAGE_BITS], row_addr_reg[PAGE_BITS-1:0]);
        page_addr_good = 0;
 
        if (memory_addr_exists(row_addr_reg)) begin
            //calling memory_addr_exists sets the value of memory_index 
            page_addr_good = 1;
        end
        //now loop through the data reg and load each byte    
        for (i_cnt = 0; i_cnt < NUM_COL; i_cnt = i_cnt + 1) begin : col_loop_nocache
           if (page_addr_good) begin
                cache_reg[active_plane][i_cnt] = mem_array[memory_index*NUM_COL + i_cnt];
            end else begin
                cache_reg[active_plane][i_cnt] = {DQ_BITS{1'b1}};
            end
        end
	copy_cachereg_to_datareg(active_plane);
        //now go busy until the load is complete
        busy = 1;
        finish_load <= #tRD_max 1'b1;
    end //OTP_enable

end
endtask




always @(posedge finish_load) begin : complete_load
    load_task = 0;
    busy = 0;
    finish_load = 0;
    cache_rd_active_plane = active_plane;
    if (cache_op && ~cache_last) begin
        for (i = 0; i < NUM_COL; i = i + 1) begin  : col_loop_cacherd
        if (memory_addr_exists(row_addr_reg)) begin
            data_reg[active_plane][i] = mem_array[memory_index*NUM_COL + i];
        end else begin
            data_reg[active_plane][i] = {DQ_BITS{1'b1}};
        end
        end

        finish_cache_rd <= #tRD_max 1'b1;
    end
    else if (cache_op && cache_last) begin
       cache_op = 0;
       cache_last = 0;    
    end
    //program complete
    if (DEBUG) $display("%t, PAGE READ Complete", $time);
end

always @(posedge finish_cache_rd) begin
    crbsy = 0;
    cache_op = 0;
    finish_cache_rd = 0;
    //program complete
    if (DEBUG) $display("%t, CACHE READ Complete", $time);
end



//-----------------------------------------------------------------
// FUNCTION : memory_addr_exists (addr)
// Checks to see if memory address is already used in
// associative array.
 //-----------------------------------------------------------------
function memory_addr_exists;
    input [ROW_BITS -1:0] addr;
begin : index
    memory_addr_exists = 0;
    for (memory_index=0; memory_index<memory_used; memory_index=memory_index+1) begin
        if (memory_addr[memory_index] == addr) begin
            memory_addr_exists = 1;
            disable index;
        end
    end
end
endfunction

//---------------------------------------------------------
//  program/erase operations require the wel bit
//  gets set with the WRITE ENABLE cmd first
//---------------------------------------------------------
function verify_wel;
    input [7:0] cmd;
begin
    if (wel) begin
        verify_wel = 1;
    end else begin
        verify_wel = 0;
    end
end
endfunction

//*********************************************************
//         ALWAYS  Blocks
//*********************************************************

always @(posedge SCK) begin
    //only valid if HOLD# is not active
    if (device_active) begin
        // determine what to do based on the current state
        case (spi_state)

            //===============
            //COMMAND INPUT
            //===============
            CMD_STATE     : begin
                cmd_reg[index] <= SI;
                if (index == 0) begin
                    //check_command will verify this command is valid 
                    //  and set the next state appropriately
                    check_command;              
                end                
                index = index -1;         
            end

            //===============
            //ADDRESS INPUT
            //===============
            ADDR_STATE    : begin
                case (addr_sel)
                //these cannot be non-blocking if we want to run check_address during this
                // same timestamp
                COL_ADDR_SEL  : begin
		                  if (quad_io_mode) begin
		                    col_addr_reg[index]     = HOLD_N;
		                    col_addr_reg[index -1]  = WP_N;
		                    col_addr_reg[index -2]  = SO;
		                    col_addr_reg[index -3]  = SI;
				    index = index -3;
				  
				  end
				  else if (dual_io_mode) begin
		                    col_addr_reg[index]     = SO;
		                    col_addr_reg[index -1]  = SI;
				    index = index -1;
				  end
				  else begin				
		                    col_addr_reg[index]  = SI;
				  end
				end
                ROW_ADDR_SEL  : row_addr_reg[index]  = SI;
                FEAT_ADDR_SEL : feat_addr_reg[index] = SI;
                endcase
                        
                if (index == 0) begin
		    if (NUM_PLANE >1) 		    
		       active_plane = (addr_sel == COL_ADDR_SEL) ? col_addr_reg[12] : (addr_sel == ROW_ADDR_SEL) ? row_addr_reg[PAGE_BITS] : active_plane;		    
		    else 
		       active_plane = 0;
                    //check_address will verify this address is valid 
                    //  and set the next state appropriately
                    check_address;
                end                
                index = index -1;         
            end

            //===============
            // DATA INPUT
            //===============
            DATAIN_STATE  : begin
	   	if (x4_input_mode) begin
	   	    byte_reg[7 - index]   = HOLD_N;
	   	    byte_reg[6 - index]   = WP_N;
	   	    byte_reg[5 - index] = SO;
	   	    byte_reg[4 - index] = SI;	 
	   	    index = index + 3; // x4 mode => index should increment by 4, but later code will already increment it by 1
		end
		else       
                    byte_reg[7-index] = SI;
                if (index == 7) begin
                    if (special_op) begin
                        spi_state <= IDLE_STATE;
                        //state machine goes idle after we set the new features reg values
                        case (feat_addr_reg)
                        8'hA0 : begin
                        //wire [7:0] lock_features = {brwd, bp[3:0], tb, wp_hold_dis, 1'b0}; // block lock status reg
                            if ((brwd && ~WP_N && ~wp_hold_dis) || lot_en) begin
                                $sformat(msg, "Block Lock register cannot be changed when WP_N is low and BRWD bit is set or Lot enable is set.");
                                ERROR(ERR_LOCK, msg);
                            end else begin
                                brwd = byte_reg[7] ;
                                bp[3:0] = byte_reg[6:3];
				tb   = byte_reg[2];
                                //bits 1 reserved
                            end
			    wp_hold_dis = byte_reg[1];
                        end
                        8'hB0 : begin
                        //wire [7:0] config_features  = {cfg[2], cfg[1], lot_en, ecc_en , 2'b0, cfg[0], 1'b0};
                              cfg[2]	= byte_reg[7];
                              cfg[1]	= byte_reg[6];
			      cfg[0]	= byte_reg[1];
			    if (!lot_en) begin // once lock tight  is enabled, it can't be disabled 
			      lot_en    = byte_reg[5];
			    end
                            ecc_en    = byte_reg[4];
                            //bits 5:0 reserved
                        end
			8'hD0: begin
			    ds0 = byte_reg[6];
			    die_select = (ds0 == thisDieNumber) ? 1'b1 : 1'b0;
					
			end
                        default : begin
                        end
                        endcase
                    end else begin
                        cache_reg[active_plane][data_index] = byte_reg;
                        byte_reg <= 8'hFF;

                        if(data_index < npp_size) begin 
                            npp_set[0] <=    1'b1; 
                            npp_set[0] <= #1 1'b0;
                        end else if(data_index < (2*npp_size)) begin 
                            npp_set[1] <=    1'b1; 
                            npp_set[1] <= #1 1'b0;
                        end else if(data_index < (3*npp_size)) begin 
                            npp_set[2] <=    1'b1; 
                            npp_set[2] <= #1 1'b0;
                        end else if(data_index < (4*npp_size)) begin 
                            npp_set[3] <=    1'b1; 
                            npp_set[3] <= #1 1'b0;
                        end                         
                        //check to see if at the end of the page
                        // if so, ignore the rest of the data input
                        if ((data_index +1) == NUM_COL) begin
                            spi_state <= IDLE_STATE;
                        end else begin
                            data_index = data_index +1;
                        end
                    end
                end                
                //reset the byte index if at the end of the byte
                index <= (index + 1) % 8;         
            end

            default : begin
                //===============
                //IDLE state 
                //===============
            end
        endcase
    end
end

always @(npp_set or npp_clr_n or npp_prg_clr_n) begin 
    npp <= (npp_set | npp) & npp_clr_n & npp_prg_clr_n; // hold npp until cleared.
end  


always @ (posedge SCK) begin
   hold_n_d <= hold_n;
end
//===================
// DATA OUTPUT
//===================
always @(negedge SCK) begin
    //data output
    if (enable_read && ~busy && device_active_d && ~special_op) begin
        //grab the byte of output data from the cache
        //always output MSB first
	if (x4_output_mode) begin
	    hold_so3_int<= #tV_max output_byte[7 - index];
	    wpn_so2_int	<= #tV_max output_byte[6 - index];
	    so_int	<= #tV_max output_byte[5 - index];
	    si_so0_int	<= #tV_max output_byte[4 - index];	
	    index = index + 3; // x4 mode => index should increment by 4, but later code will already increment it by 1
	end else if (x2_output_mode) begin
	    so_int	<= #tV_max output_byte[7 - index];
	    si_so0_int	<= #tV_max output_byte[6 - index];
	    index = index + 1; // x2 mode => index should increment by 2, but later code will already increment it by 1      
	end else begin // x1_output_mode
	    so_int	<= #tV_max output_byte[7 - index];
	end
        //if at the end of the byte, increment the cache_reg index
        if (index == 7) begin
            if ((data_index+1) == NUM_COL) begin
                // SMK :: this should occur after the hold time is met
//                dataout_enable <= #tDIS_max 0; 
                enable_read <= #tDIS_max 0;
            end  else begin
                data_index = data_index +1;
            end          
        end
        //reset the byte index if at the end of a byte
        index = (index + 1) % 8;         
    end else if (enable_read && device_active_d && special_op) begin
        //status register output
        so_int <= #tV_max special_reg[7 - index];
        //reset the byte index if at the end of a byte
        // keep outputting status bits until the CS# pin goes inactive
        index = (index + 1) % 8;         
    end
end


reg dataout_en_nxt =1'b0;
reg dataout_en_nxt1 =1'b0;
always @(negedge SCK) begin
    if(dataout_en_nxt1) begin 
        dataout_enable <= #tDIS_max 0; 
        dataout_en_nxt1 <= 1'b0;
    end else if(dataout_en_nxt) begin 
        dataout_en_nxt1 <= 1'b1; 
        dataout_en_nxt  <= 1'b0;
    end else if (enable_read && ~busy && device_active_d && ~special_op) begin
        if (index == 7 & ((data_index+1) == NUM_COL)) begin
            dataout_en_nxt <= 1'b1;
        end
    end
end


//make sure the output buffer is enabled at the right time
always @(posedge enable_read) begin
    @(negedge SCK) dataout_enable <= #tV_max 1'b1;
end

// Disable further input/output and transition signals back to standby values
always @(posedge CS_N) begin
    dataout_enable <= #tDIS_max 1'b0;
    enable_read <= 0;
    special_op <= 0;
    x2_output_mode <= #tDIS_max 0;
    x4_output_mode <= #tDIS_max 0;
    dual_io_mode   <= #tDIS_max 0;
    quad_io_mode   <= #tDIS_max 0;
    x4_input_mode  <= 0;
end

//  HOLD# pin timing
always @(posedge hold_device) begin
    dataout_enable <= #tHZ_max 1'b0;
end

always @(posedge hold_n) begin
    if (~CS_N && enable_read) begin
        dataout_enable <= #tLZ_max 1'b1;
    end
end

    
// Enable device and ready for command input
always @(negedge CS_N) begin
    index <= 7; //each command is one byte wide
    spi_state <= CMD_STATE;
end

//Misc messages
always @(otp_enable) begin
    if (finish_reset) begin
        if (otp_enable) begin
            $sformat(msg, "Entering OTP mode ...");
            INFO(msg);
        end else begin
            $sformat(msg, "Exiting OTP mode ...");
            INFO(msg);
        end
    end
end


//===================
// TIMING CHECKS
//===================

realtime tm_cs_n_r   =0;
realtime tm_cs_n_f   =0;
realtime tm_wp_n_r   =0;
realtime tm_wp_n_f   =0;
realtime tm_hold_n_r =0;
realtime tm_hold_n_f =0;
realtime tm_si       =0;
realtime tm_so       =0;
realtime tm_sck_r    =0;
realtime tm_sck_f    =0;
realtime tm_first_hclk_r = 0;
reg last_hold_n = 1;

always @(SCK) begin
    if (($realtime - tm_cs_n_f) < tCSS_min) begin $sformat(msg, "tCSS min violation by %0t", tCSS_min - ($realtime - tm_cs_n_f)); ERROR(ERR_TIM,msg);end
    if (SCK) begin
        if ((($realtime - tm_sck_r) < tCK_min) && (tm_sck_r != 0)) begin $sformat(msg, "tCK min violation by %0t", tCK_min - ($realtime - tm_sck_r)); ERROR(ERR_TIM,msg);end
        if (($realtime - tm_sck_f) < tWL_min) begin $sformat(msg, "tWL min violation by %0t", tWL_min - ($realtime - tm_sck_f)); ERROR(ERR_TIM,msg);end
        tm_sck_r <= $realtime;
        if ((($realtime - tm_si) < tSUDAT_min) && ~CS_N && ~x4_output_mode && ~x2_output_mode && ~quad_io_mode && ~dual_io_mode && die_select) begin $sformat(msg, "tSUDAT min violation by %0t", tSUDAT_min - ($realtime - tm_si)); ERROR(ERR_TIM,msg);end
	if (~CS_N && ~x4_output_mode && ~quad_io_mode && ~x4_input_mode && ~wp_hold_dis && die_select) begin
          if (($realtime - tm_hold_n_f) < tHD_min) begin $sformat(msg, "tHD min violation by %0t", tHD_min - ($realtime - tm_hold_n_f)); ERROR(ERR_TIM,msg);end
          if (($realtime - tm_hold_n_r) < tHC_min) begin $sformat(msg, "tHC min violation by %0t", tHC_min - ($realtime - tm_hold_n_r)); ERROR(ERR_TIM,msg);end
          //this is a special case where we need to keep track of the first posedge clk after HOLD# goes low
          if (~hold_n && last_hold_n) tm_first_hclk_r <= $realtime;
	end
    end else begin
        tm_sck_f <= $realtime;
        if (($realtime - tm_sck_r) < tWH_min) begin $sformat(msg, "tWH min violation by %0t", tWH_min - ($realtime - tm_sck_r)); ERROR(ERR_TIM,msg);end
    end
    last_hold_n <= hold_n;
end

always @(hold_n) begin
  if (~CS_N && ~x4_output_mode && ~quad_io_mode && ~x4_input_mode && ~wp_hold_dis && die_select) begin
    if (hold_n) begin
        tm_hold_n_r <= $realtime;
        if (($realtime - tm_first_hclk_r) < tCD_min) begin $sformat(msg, "tCD min violation by %0t", tCD_min - ($realtime - tm_first_hclk_r)); ERROR(ERR_TIM,msg);end
    end else begin
        tm_hold_n_f <= $realtime;
        if (($realtime - tm_sck_r) < tCH_min) begin $sformat(msg, "tCH min violation by %0t", tCH_min - ($realtime - tm_sck_r)); ERROR(ERR_TIM,msg);end
    end
  end
end

always @(SI) begin
    tm_si <= $realtime;
    if ((($realtime - tm_sck_r) < tHDDAT_min) && ~x4_output_mode && ~x2_output_mode && ~quad_io_mode && ~dual_io_mode && die_select) begin 
	$sformat(msg, "tHDDAT min violation by %0t", tHDDAT_min - ($realtime - tm_sck_r)); ERROR(ERR_TIM,msg);
    end
end

always @(WP_N) begin
    if (~CS_N && ~x4_output_mode && ~quad_io_mode && ~x4_input_mode && ~wp_hold_dis && die_select) begin
        $sformat(msg, "WP_N may only switch when CS# is inactive.");
        ERROR(ERR_MISC, msg);
    end
    if (WP_N) begin
        tm_wp_n_r <= $realtime;
    end else if (~WP_N) begin
        tm_wp_n_f <= $realtime;
        //tWPH_min check
        if ((($realtime - tm_cs_n_r) < tWPH_min) && ~x4_output_mode && ~quad_io_mode && ~x4_input_mode && ~wp_hold_dis && die_select) begin $sformat(msg, "tWPH min violation by %0t", tWPH_min - ($realtime - tm_cs_n_r)); ERROR(ERR_TIM,msg);end
    end
end

always@(CS_N) begin
    if (($realtime - tm_sck_r) < tCSH_min) begin $sformat(msg, "tCSH min violation by %0t", tCSH_min - ($realtime - tm_sck_r)); ERROR(ERR_TIM,msg);end
    if (CS_N) begin
        tm_cs_n_r <= $realtime;
    end else begin
        tm_cs_n_f <= $realtime;
        if ((($realtime - tm_cs_n_r) < tCS_min) && (tm_cs_n_r != 0)) begin $sformat(msg, "tCS min violation by %0t", tCS_min - ($realtime - tm_cs_n_r)); ERROR(ERR_TIM,msg);end
        if (($realtime - tm_wp_n_r) < tWPS_min) begin $sformat(msg, "tWPS min violation by %0t", tWPS_min - ($realtime - tm_wp_n_r)); ERROR(ERR_TIM,msg);end
    end
end

endmodule

