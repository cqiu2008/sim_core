
//*********************************************************

// All timing parameters are in ns
parameter tCK_min     =  7.5; // max Clock frequency 133MHz
parameter tCD_min     =   3.375; //Hold# non-active hold time relative to SCK
parameter tCH_min     =   3.375; //Clock HIGH time
parameter tHC_min     =   3.375; //Hold# non-active setup time relative to SCK
parameter tHD_min     =   3.375; //Hold# setup time relative to SCK
parameter tHZ_max     =  7; //Hold to output High-Z
parameter tLZ_max     =  7; //Hold# to output Low-Z
parameter tV_max      =   5; //Clock low to output valid
parameter tWH_min     =   3.375; //Clock HIGH time
parameter tWL_min     =   3.375; //Clock LOW time
parameter tWPH_min    = 100; //WP# hold time
parameter tWPS_min    =  20; //WP# setup time
parameter VCC_SPI     =  30; //Clock LOW time

parameter NPP         =   4; // number of partial page programs 
parameter npp_size    = 544; // number of bytes per partial page.  
parameter tCFT_min    =   VCC_SPI/10; //Clock Fall time
parameter tCRT_min    =   VCC_SPI/10; //Clock Rise time
parameter tCS_min     =  30; //Command deselect time
parameter tCSH_min    =   2.5; //Command hold time
parameter tCSS_min    =   2.5; //Command setup time
parameter tDIS_max    =   6; //Output disable time
parameter tHDDAT_min  =   1.75; //Data input hold time
parameter tHO_min     =   0; //Output hold time
parameter tSUDAT_min  =   2.5; //Data input setup time

// delays
parameter tRST_rdy    =      5_000; // tRST during ready
parameter tRST_read   =     75_000; // tRST during read
parameter tRST_prog   =     80_000; // tRST during program
parameter tRST_erase  =    570_000; // tRST during erase
parameter tRST_pwr    =  1_250_000; // tRST during powerup for SPI
parameter tPROG_typ   =    220_000; // typical program time
parameter tPROG_max   =    600_000; // typical program time
parameter tRD_max     =     70_000; // max read time
parameter tERS_typ    =  2_000_000; // max erase time
parameter tERS_max    = 10_000_000; // max erase time
parameter tRCBSY_max  =     50_000; // max Data transfer time from data register to cache register
parameter NOP         =          4; // max program to same 512B sector without erase


parameter ID_BYTE_0   = 8'h2C;
`ifdef D_1Gb
   `ifdef V33
     parameter ID_BYTE_1   = 8'h14;
   `else
     parameter ID_BYTE_1   = 8'h15;
   `endif   
`else `ifdef D_4Gb
   `ifdef V33
     parameter ID_BYTE_1   = 8'h36;
   `else
     parameter ID_BYTE_1   = 8'h37;
   `endif   
`else  // D_2Gb
   `ifdef V33
     parameter ID_BYTE_1   = 8'h24;
   `else
     parameter ID_BYTE_1   = 8'h25;
   `endif   
`endif `endif
parameter NUM_OTP_PAGES = 12; // 10 actual OTP pages, 1 for param page, 1 for UID page

// Device size parameters
parameter COL_BITS  =     12; 
parameter DQ_BITS   =      8;
`ifdef D_1Gb
parameter ROW_BITS  =     16;
`else
parameter ROW_BITS  =     17;
`endif
parameter PAGE_BITS =      6;
parameter BLCK_BITS =     ROW_BITS - PAGE_BITS;  
parameter FEAT_BITS =      8;

`ifdef D_1Gb
parameter NUM_PLANE =      1;
`else
parameter NUM_PLANE =      2;

`endif

`ifdef D_4Gb
parameter NUM_DIE = 2;
`else
parameter NUM_DIE = 1;
`endif


`ifdef FullMem   // Only do this if you require the full memmory size.
    `ifdef D_1Gb
       parameter NUM_ROW   =  65536;  // PagesXBlocks
    `else
       parameter NUM_ROW   =  15872;  // PagesXBlocks
    `endif
    parameter NUM_PAGE  =     64;
    parameter NUM_COL   =   2176;
`else
	//change this parameter if need for more memory space during simulation
    parameter NUM_ROW   =  2048;  // for fast sim load, actual mem_array size is NUM_COL * num_row
    parameter NUM_PAGE  =    64;
    parameter NUM_COL   =  2176;
`endif


//these control the SPI mode that determines clock behavior during standby
//   to keep clock low during standby  : CPOH = CPHA = 0
//   to keep clock high during standby : CPOH = CPHA = 1
parameter CPOL = 0;
parameter CPHA = 0;

//-------------------------------------------
//   ONFI Setup
//-------------------------------------------
//need to keep this in params file since ever NAND device will have different values
reg [7:0]        onfi_params_array [NUM_COL-1 : 0]; // packed array

//-------------------------------------------
//  MEMORY Initialization 
//-------------------------------------------
parameter [40*8:1] memory_file = "NAND_SPI_MEM.vmf";

task setup_params_array;
    integer k;
    begin
    // Here we set the values of the read-only ONFI parameters.
    // These are defined by the ONFI spec
    // and are the default power-on values for the ONFI FEATURES supported by this device.
    //-------------------------------------
    // Parameter page signature
    onfi_params_array[0] = 8'h4F; // 'O'
    onfi_params_array[1] = 8'h4E; // 'N'
    onfi_params_array[2] = 8'h46; // 'F'
    onfi_params_array[3] = 8'h49; // 'I'
    // ONFI revision number
    onfi_params_array[4] = 8'h00; // ONFI n/a
    onfi_params_array[5] = 8'h00;
    // Features supported
    onfi_params_array[6] = 8'h00;
    onfi_params_array[7] = 8'h00;
    // optional command supported
    onfi_params_array[8] = 8'h06;
    onfi_params_array[9] = 8'h00;
    // Reserved
    for (k=10; k<=31 ; k=k+1) begin
        onfi_params_array[k] = 8'h00;
    end
    // Manufacturer ID
    onfi_params_array[32] = 8'h4D; //M
    onfi_params_array[33] = 8'h49; //I
    onfi_params_array[34] = 8'h43; //C
    onfi_params_array[35] = 8'h52; //R
    onfi_params_array[36] = 8'h4F; //O
    onfi_params_array[37] = 8'h4E; //N
    onfi_params_array[38] = 8'h20;
    onfi_params_array[39] = 8'h20;
    onfi_params_array[40] = 8'h20;
    onfi_params_array[41] = 8'h20;
    onfi_params_array[42] = 8'h20;
    onfi_params_array[43] = 8'h20;    
    // Device model
    onfi_params_array[44] = 8'h4D; //M
    onfi_params_array[45] = 8'h54; //T
    onfi_params_array[46] = 8'h32; //2
    onfi_params_array[47] = 8'h39; //9
    onfi_params_array[48] = 8'h46; //F
    `ifdef D_1Gb
    onfi_params_array[49] = 8'h31; //1
    `else `ifdef D_4Gb
    onfi_params_array[49] = 8'h34; //4
    `else
    onfi_params_array[49] = 8'h32; //2
    `endif `endif
    onfi_params_array[50] = 8'h47; //G
    onfi_params_array[51] = 8'h30; //0
    onfi_params_array[52] = 8'h31; //1
    onfi_params_array[53] = 8'h41; //A
    onfi_params_array[54] = 8'h42; //B
    `ifdef V33
    onfi_params_array[55] = 8'h41; //A
    `else
    onfi_params_array[55] = 8'h42; //B
    `endif
    onfi_params_array[56] = 8'h47; //G    
    onfi_params_array[57] = 8'h44; //D
    `ifdef SOP
    onfi_params_array[58] = 8'h53; //S
    onfi_params_array[59] = 8'h46; //F
    `else `ifdef DFN
    onfi_params_array[58] = 8'h31; //1
    onfi_params_array[59] = 8'h32; //2
    `else //TBGA
    onfi_params_array[58] = 8'h57; //W
    onfi_params_array[59] = 8'h39; //9
    `endif `endif
    onfi_params_array[60] = 8'h20;
    onfi_params_array[61] = 8'h20;
    onfi_params_array[62] = 8'h20;
    onfi_params_array[63] = 8'h20;

    // manufacturer ID
    onfi_params_array[64] = 8'h2C;
    // Date code
    onfi_params_array[65] = 8'h00; 
    onfi_params_array[66] = 8'h00; 
    // reserved
    for (k=67; k<=79 ; k=k+1) begin
        onfi_params_array[k] = 8'h00;
    end
    // Number of data bytes per page
    onfi_params_array[80] = 8'h00;
    onfi_params_array[81] = 8'h08;
    onfi_params_array[82] = 8'h00;
    onfi_params_array[83] = 8'h00;
    // Number of spare bytes per page        
    onfi_params_array[84] = 8'h80;
    onfi_params_array[85] = 8'h00;

    // Number of data bytes per partial page
    onfi_params_array[86] = 8'h00;    
    onfi_params_array[87] = 8'h02;    
    onfi_params_array[88] = 8'h00;    
    onfi_params_array[89] = 8'h00;    
    // Number of spare bytes per partial page
    onfi_params_array[90] = 8'h20;
    onfi_params_array[91] = 8'h00;

    // Number of pages per block
    onfi_params_array[92] = 8'h40;
    onfi_params_array[93] = 8'h00;
    onfi_params_array[94] = 8'h00;
    onfi_params_array[95] = 8'h00;
    // Number of blocks per unit
    onfi_params_array[96] = 8'h00;
    `ifdef D_1Gb
    onfi_params_array[97] = 8'h04;
    `else
    onfi_params_array[97] = 8'h08;
    `endif
    onfi_params_array[98] = 8'h00;
    onfi_params_array[99] = 8'h00;
    // Number of units
    `ifdef D_4Gb
    onfi_params_array[100] = 8'h02;
    `else
    onfi_params_array[100] = 8'h01;
    `endif
    // Number of address cycles
    onfi_params_array[101] = 8'h00;
    // Number of bits per cell
    onfi_params_array[102] = 8'h01;
    // Bad blocks maximum per unit
    `ifdef D_1Gb
    onfi_params_array[103] = 8'h14;
    `else
    onfi_params_array[103] = 8'h28;
    `endif
    onfi_params_array[104] = 8'h00;
    // Block endurance
    onfi_params_array[105] = 8'h06;
    onfi_params_array[106] = 8'h04;
    // Guaranteed valid blocks at beginning of target
    onfi_params_array[107] = 8'h01;
    // Block endurance for guaranteed valid blocks
    onfi_params_array[108] = 8'h00;
    onfi_params_array[109] = 8'h00;
    // Number of program per page
    onfi_params_array[110] = 8'h04;
    // Partial programming attributes
    onfi_params_array[111] = 8'h00;
    // Number of ECC bits
    onfi_params_array[112] = 8'h00;
    // Number of interleaved address bits
    onfi_params_array[113] = 8'h00;
    // Interleaved operation attributes
    onfi_params_array[114] = 8'h00;
    // reserved
    for (k=115; k<=127 ; k=k+1) begin
        onfi_params_array[k] = 8'h00;
    end
    // IO pin capacitance
    onfi_params_array[128] = 8'h08;
    // Timing mode support
    onfi_params_array[129] = 8'h00;    
    onfi_params_array[130] = 8'h00;

    // Program cache timing mode support
    onfi_params_array[131] = 8'h00;    
    onfi_params_array[132] = 8'h00;

    // tPROG max page program time
    onfi_params_array[133] = 8'h58;
    onfi_params_array[134] = 8'h02;
    // tBERS max block erase time
    onfi_params_array[135] = 8'h10;
    onfi_params_array[136] = 8'h27;
    // tR max page read time        
    onfi_params_array[137] = 8'h19;
    onfi_params_array[138] = 8'h00;
    // tCCS min change column setup time (same as tWHR)
    onfi_params_array[139] = 8'h00;
    onfi_params_array[140] = 8'h00;

    //reserved
    for (k=141; k<=163; k=k+1) begin
        onfi_params_array[k] = 8'h00;
    end
    // Vendor-specific revision number    
    onfi_params_array[164] = 8'h01;
    onfi_params_array[165] = 8'h00;
    //vendor-specific
    `ifdef D_1Gb
    onfi_params_array[166] = 8'h00;
    `else
    onfi_params_array[166] = 8'h01;
    `endif
    onfi_params_array[167] = 8'h00;
    onfi_params_array[168] = 8'h00;
    onfi_params_array[169] = 8'h00;
    onfi_params_array[170] = 8'h00;
    onfi_params_array[171] = 8'h00;
    onfi_params_array[172] = 8'h00;
    onfi_params_array[173] = 8'h00;
    onfi_params_array[174] = 8'h00;
    onfi_params_array[175] = 8'h02;
    onfi_params_array[176] = 8'h02;
    onfi_params_array[177] = 8'hB0;
    onfi_params_array[178] = 8'h0A;
    onfi_params_array[179] = 8'hB0;
    for (k=180; k<=247; k=k+1) begin
        onfi_params_array[k] = 8'h00;
    end
    onfi_params_array[248] = 8'h08;
    `ifdef D_4Gb
    onfi_params_array[249] = 8'h01;
    `else
    onfi_params_array[249] = 8'h00;
    `endif
    onfi_params_array[250] = 8'h00;
    onfi_params_array[251] = 8'h00;
    onfi_params_array[252] = 8'h00;
    onfi_params_array[253] = 8'h01;

    // Integrity CRC
    onfi_params_array[254] = 8'h00; // set at test
    onfi_params_array[255] = 8'h00;

    end
endtask
