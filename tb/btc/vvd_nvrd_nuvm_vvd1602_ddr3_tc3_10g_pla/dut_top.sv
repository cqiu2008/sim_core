`timescale 1ns/1ps
//`include "intf/nr8120_intf.sv"
module dut_top (
//====Golble Signal 
input		I_rst_n				,
//====CLOCK
input		I_10m_clk			,	
input		I_25m_clk			,	
input		I_33m_clk			,	
input		I_40m_clk			,	
input		I_66m_clk			,	
input		I_312m5_clk		    ,	
input		I_156m25_clk		,	
input		I_125m_clk			
);
/////////////////////////////////
/////ddr def/////////////////////
///def
//***************************************************************************
// Traffic Gen related parameters
//***************************************************************************
   parameter C0_SIMULATION            = "TRUE";
//   parameter C0_BL_WIDTH              = 10;
   parameter C0_PORT_MODE             = "BI_MODE";
   parameter C0_DATA_MODE             = 4'b0010;
   parameter C0_TST_MEM_INSTR_MODE    = "R_W_INSTR_MODE";
   parameter C0_EYE_TEST              = "FALSE";
                                     // set EYE_TEST = "TRUE" to probe memory
                                     // signals. Traffic Generator will only
                                     // write to one single location and no
                                     // read transactions will be generated.
   parameter C0_DATA_PATTERN          = "DGEN_ALL";
                                      // For small devices, choose one only.
                                      // For large device, choose "DGEN_ALL"
                                      // "DGEN_HAMMER", "DGEN_WALKING1",
                                      // "DGEN_WALKING0","DGEN_ADDR","
                                      // "DGEN_NEIGHBOR","DGEN_PRBS","DGEN_ALL"
   parameter C0_CMD_PATTERN           = "CGEN_ALL";
                                      // "CGEN_PRBS","CGEN_FIXED","CGEN_BRAM",
                                      // "CGEN_SEQUENTIAL", "CGEN_ALL"
//   parameter C0_SEL_VICTIM_LINE       = 11;
//   parameter C0_ADDR_MODE             = 4'b0011;
   parameter C0_BEGIN_ADDRESS         = 32'h00000000;
   parameter C0_END_ADDRESS           = 32'h00000fff;
   parameter C0_PRBS_EADDR_MASK_POS   = 32'hff000000;

   //***************************************************************************
   // The following parameters refer to width of various ports
   //***************************************************************************
//   parameter C0_BANK_WIDTH            = 3;
                                     // # of memory Bank Address bits.
//   parameter C0_CK_WIDTH              = 1;
                                     // # of CK/CK# outputs to memory.
   parameter C0_COL_WIDTH             = 10;
                                     // # of memory Column Address bits.
   parameter C0_CS_WIDTH              = 1;
                                     // # of unique CS outputs to memory.
//   parameter C0_nCS_PER_RANK          = 1;
                                     // # of unique CS outputs per rank for phy
//   parameter C0_CKE_WIDTH             = 1;
                                     // # of CKE outputs to memory.
//   parameter C0_DATA_BUF_ADDR_WIDTH   = 5;
//   parameter C0_DQ_CNT_WIDTH          = 4;
                                     // = ceil(log2(DQ_WIDTH))
//   parameter C0_DQ_PER_DM             = 8;
   parameter C0_DM_WIDTH              = 2;
                                     // # of DM (data mask)
   parameter C0_DQ_WIDTH              = 16;
                                     // # of DQ (data)
   parameter C0_DQS_WIDTH             = 2;
   parameter C0_DQS_CNT_WIDTH         = 1;
                                     // = ceil(log2(DQS_WIDTH))
   parameter C0_DRAM_WIDTH            = 8;
                                     // # of DQ per DQS
   parameter C0_ECC                   = "OFF";
//   parameter C0_nBANK_MACHS           = 4;
   parameter C0_RANKS                 = 1;
                                     // # of Ranks.
   parameter C0_ODT_WIDTH             = 1;
                                     // # of ODT outputs to memory.
   parameter C0_ROW_WIDTH             = 14;
                                     // # of memory Row Address bits.
   parameter C0_ADDR_WIDTH            = 28;
                                     // # = RANK_WIDTH + BANK_WIDTH
                                     //     + ROW_WIDTH + COL_WIDTH;
                                     // Chip Select is always tied to low for
                                     // single rank devices
//   parameter C0_USE_CS_PORT          = 0;
                                     // # = 1, When CS output is enabled
                                     //   = 0, When CS output is disabled
                                     // If CS_N disabled, user must connect
                                     // DRAM CS_N input(s) to ground
//   parameter C0_USE_DM_PORT           = 0;
                                     // # = 1, When Data Mask option is enabled
                                     //   = 0, When Data Mask option is disbaled
                                     // When Data Mask option is disabled in
                                     // MIG Controller Options page, the logic
                                     // related to Data Mask should not get
                                     // synthesized
//   parameter C0_USE_ODT_PORT          = 1;
                                     // # = 1, When ODT output is enabled
                                     //   = 0, When ODT output is disabled
                                     // Parameter configuration for Dynamic ODT support:
                                     // USE_ODT_PORT = 0, RTT_NOM = "DISABLED", RTT_WR = "60/120".
                                     // This configuration allows to save ODT pin mapping from FPGA.
                                     // The user can tie the ODT input of DRAM to HIGH.

   //***************************************************************************
   // The following parameters are mode register settings
   //***************************************************************************
//   parameter C0_AL                    = "0";
                                     // DDR3 SDRAM:
                                     // Additive Latency (Mode Register 1).
                                     // # = "0", "CL-1", "CL-2".
                                     // DDR2 SDRAM:
                                     // Additive Latency (Extended Mode Register).
//   parameter C0_nAL                   = 0;
                                     // # Additive Latency in number of clock
                                     // cycles.
   parameter C0_BURST_MODE            = "8";
                                     // DDR3 SDRAM:
                                     // Burst Length (Mode Register 0).
                                     // # = "8", "4", "OTF".
                                     // DDR2 SDRAM:
                                     // Burst Length (Mode Register).
                                     // # = "8", "4".
//   parameter C0_BURST_TYPE            = "SEQ";
                                     // DDR3 SDRAM: Burst Type (Mode Register 0).
                                     // DDR2 SDRAM: Burst Type (Mode Register).
                                     // # = "SEQ" - (Sequential),
                                     //   = "INT" - (Interleaved).
//   parameter C0_CL                    = 9;
                                     // in number of clock cycles
                                     // DDR3 SDRAM: CAS Latency (Mode Register 0).
                                     // DDR2 SDRAM: CAS Latency (Mode Register).
//   parameter C0_CWL                   = 7;
                                     // in number of clock cycles
                                     // DDR3 SDRAM: CAS Write Latency (Mode Register 2).
                                     // DDR2 SDRAM: Can be ignored
//   parameter C0_OUTPUT_DRV            = "HIGH";
                                     // Output Driver Impedance Control (Mode Register 1).
                                     // # = "HIGH" - RZQ/7,
                                     //   = "LOW" - RZQ/6.
//   parameter C0_RTT_NOM               = "60";
                                     // RTT_NOM (ODT) (Mode Register 1).
                                     // # = "DISABLED" - RTT_NOM disabled,
                                     //   = "120" - RZQ/2,
                                     //   = "60"  - RZQ/4,
                                     //   = "40"  - RZQ/6.
//   parameter C0_RTT_WR                = "OFF";
                                     // RTT_WR (ODT) (Mode Register 2).
                                     // # = "OFF" - Dynamic ODT off,
                                     //   = "120" - RZQ/2,
                                     //   = "60"  - RZQ/4,
//   parameter C0_ADDR_CMD_MODE         = "1T" ;
                                     // # = "1T", "2T".
//   parameter C0_REG_CTRL              = "OFF";
                                     // # = "ON" - RDIMMs,
                                     //   = "OFF" - Components, SODIMMs, UDIMMs.
   parameter C0_CA_MIRROR             = "OFF";
                                     // C/A mirror opt for DDR3 dual rank
   
   //***************************************************************************
   // The following parameters are multiplier and divisor factors for PLLE2.
   // Based on the selected design frequency these parameters vary.
   //***************************************************************************
   parameter C0_CLKIN_PERIOD          = 4000;
                                     // Input Clock Period
//   parameter C0_CLKFBOUT_MULT         = 16;
                                     // write PLL VCO multiplier
//   parameter C0_DIVCLK_DIVIDE         = 3;
                                     // write PLL VCO divisor
//   parameter C0_CLKOUT0_DIVIDE        = 2;
                                     // VCO output divisor for PLL output clock (CLKOUT0)
//   parameter C0_CLKOUT1_DIVIDE        = 2;
                                     // VCO output divisor for PLL output clock (CLKOUT1)
//   parameter C0_CLKOUT2_DIVIDE        = 32;
                                     // VCO output divisor for PLL output clock (CLKOUT2)
//   parameter C0_CLKOUT3_DIVIDE        = 8;
                                     // VCO output divisor for PLL output clock (CLKOUT3)

   //***************************************************************************
   // Memory Timing Parameters. These parameters varies based on the selected
   // memory part.
   //***************************************************************************
//   parameter C0_tCKE                  = 5625;
                                     // memory tCKE paramter in pS
//   parameter C0_tFAW                  = 45000;
                                     // memory tRAW paramter in pS.
//   parameter C0_tRAS                  = 36000;
                                     // memory tRAS paramter in pS.
//   parameter C0_tRCD                  = 13500;
                                     // memory tRCD paramter in pS.
//   parameter C0_tREFI                 = 7800000;
                                     // memory tREFI paramter in pS.
//   parameter C0_tRFC                  = 160000;
                                     // memory tRFC paramter in pS.
//   parameter C0_tRP                   = 13500;
                                     // memory tRP paramter in pS.
//   parameter C0_tRRD                  = 7500;
                                     // memory tRRD paramter in pS.
//   parameter C0_tRTP                  = 7500;
                                     // memory tRTP paramter in pS.
//   parameter C0_tWTR                  = 7500;
                                     // memory tWTR paramter in pS.
//   parameter C0_tZQI                  = 128_000_000;
                                     // memory tZQI paramter in nS.
//   parameter C0_tZQCS                 = 64;
                                     // memory tZQCS paramter in clock cycles.

   //***************************************************************************
   // Simulation parameters
   //***************************************************************************
   parameter C0_SIM_BYPASS_INIT_CAL   = "FAST";
                                     // # = "SIM_INIT_CAL_FULL" -  Complete
                                     //              memory init &
                                     //              calibration sequence
                                     // # = "SKIP" - Not supported
                                     // # = "FAST" - Complete memory init & use
                                     //              abbreviated calib sequence

   //***************************************************************************
   // The following parameters varies based on the pin out entered in MIG GUI.
   // Do not change any of these parameters directly by editing the RTL.
   // Any changes required should be done through GUI and the design regenerated.
   //***************************************************************************
//   parameter C0_BYTE_LANES_B0         = 4'b1111;
                                     // Byte lanes used in an IO column.
//   parameter C0_BYTE_LANES_B1         = 4'b0000;
                                     // Byte lanes used in an IO column.
//   parameter C0_BYTE_LANES_B2         = 4'b0000;
                                     // Byte lanes used in an IO column.
//   parameter C0_BYTE_LANES_B3         = 4'b0000;
                                     // Byte lanes used in an IO column.
//   parameter C0_BYTE_LANES_B4         = 4'b0000;
                                     // Byte lanes used in an IO column.
//   parameter C0_DATA_CTL_B0           = 4'b1001;
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
//   parameter C0_DATA_CTL_B1           = 4'b0000;
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
//   parameter C0_DATA_CTL_B2           = 4'b0000;
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
//   parameter C0_DATA_CTL_B3           = 4'b0000;
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
//   parameter C0_DATA_CTL_B4           = 4'b0000;
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
//   parameter C0_PHY_0_BITLANES        = 48'h3FC_3FF_FFF_2FE;
//   parameter C0_PHY_1_BITLANES        = 48'h000_000_000_000;
//   parameter C0_PHY_2_BITLANES        = 48'h000_000_000_000;

   // control/address/data pin mapping parameters
//   parameter C0_CK_BYTE_MAP
//     = 144'h00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_02;
//   parameter C0_ADDR_MAP
//     = 192'h000_000_029_028_027_026_025_024_023_022_021_020_019_018_017_016;
//   parameter C0_BANK_MAP   = 36'h01B_01A_015;
//   parameter C0_CAS_MAP    = 12'h013;
//   parameter C0_CKE_ODT_BYTE_MAP = 8'h00;
//   parameter C0_CKE_MAP    = 96'h000_000_000_000_000_000_000_011;
//   parameter C0_ODT_MAP    = 96'h000_000_000_000_000_000_000_010;
//   parameter C0_CS_MAP     = 120'h000_000_000_000_000_000_000_000_000_000;
//   parameter C0_PARITY_MAP = 12'h000;
//   parameter C0_RAS_MAP    = 12'h014;
//   parameter C0_WE_MAP     = 12'h012;
//   parameter C0_DQS_BYTE_MAP
//     = 144'h00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_03_00;
//   parameter C0_DATA0_MAP  = 96'h001_002_003_004_005_006_007_009;
//   parameter C0_DATA1_MAP  = 96'h032_033_034_035_036_037_038_039;
//   parameter C0_DATA2_MAP  = 96'h000_000_000_000_000_000_000_000;
//   parameter C0_DATA3_MAP  = 96'h000_000_000_000_000_000_000_000;
//   parameter C0_DATA4_MAP  = 96'h000_000_000_000_000_000_000_000;
//   parameter C0_DATA5_MAP  = 96'h000_000_000_000_000_000_000_000;
//   parameter C0_DATA6_MAP  = 96'h000_000_000_000_000_000_000_000;
//   parameter C0_DATA7_MAP  = 96'h000_000_000_000_000_000_000_000;
//   parameter C0_DATA8_MAP  = 96'h000_000_000_000_000_000_000_000;
//   parameter C0_DATA9_MAP  = 96'h000_000_000_000_000_000_000_000;
//   parameter C0_DATA10_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter C0_DATA11_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter C0_DATA12_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter C0_DATA13_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter C0_DATA14_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter C0_DATA15_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter C0_DATA16_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter C0_DATA17_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter C0_MASK0_MAP  = 108'h000_000_000_000_000_000_000_000_000;
//   parameter C0_MASK1_MAP  = 108'h000_000_000_000_000_000_000_000_000;

//   parameter C0_SLOT_0_CONFIG         = 8'b0000_0001;
                                     // Mapping of Ranks.
//   parameter C0_SLOT_1_CONFIG         = 8'b0000_0000;
                                     // Mapping of Ranks.
//   parameter C0_MEM_ADDR_ORDER        = "BANK_ROW_COLUMN";
                                      //Possible Parameters
                                      //1.BANK_ROW_COLUMN : Address mapping is
                                      //                    in form of Bank Row Column.
                                      //2.ROW_BANK_COLUMN : Address mapping is
                                      //                    in the form of Row Bank Column.
                                      //3.TG_TEST : Scrambles Address bits
                                      //            for distributed Addressing.
   //***************************************************************************
   // IODELAY and PHY related parameters
   //***************************************************************************
//   parameter C0_IBUF_LPWR_MODE        = "OFF";
                                     // to phy_top
//   parameter C0_DATA_IO_IDLE_PWRDWN   = "ON";
                                     // # = "ON", "OFF"
//   parameter C0_DATA_IO_PRIM_TYPE     = "HP_LP";
                                     // # = "HP_LP", "HR_LP", "DEFAULT"
//   parameter C0_USER_REFRESH          = "OFF";
//   parameter C0_WRLVL                 = "ON";
                                     // # = "ON" - DDR3 SDRAM
                                     //   = "OFF" - DDR2 SDRAM.
//   parameter C0_ORDERING              = "NORM";
                                     // # = "NORM", "STRICT", "RELAXED".
//   parameter C0_CALIB_ROW_ADD         = 16'h0000;
                                     // Calibration row address will be used for
                                     // calibration read and write operations
//   parameter C0_CALIB_COL_ADD         = 12'h000;
                                     // Calibration column address will be used for
                                     // calibration read and write operations
//   parameter C0_CALIB_BA_ADD          = 3'h0;
                                     // Calibration bank address will be used for
                                     // calibration read and write operations
   parameter C0_TCQ                   = 100;
   //***************************************************************************
   // IODELAY and PHY related parameters
   //***************************************************************************
//   parameter IODELAY_GRP           = "MIG_DOUBLE_DDR3_IODELAY_MIG";
                                     // It is associated to a set of IODELAYs with
                                     // an IDELAYCTRL that have same IODELAY CONTROLLER
                                     // clock frequency.
//   parameter SYSCLK_TYPE           = "NO_BUFFER";
                                     // System clock type DIFFERENTIAL, SINGLE_ENDED,
                                     // NO_BUFFER
//   parameter REFCLK_TYPE           = "NO_BUFFER";
                                     // Reference clock type DIFFERENTIAL, SINGLE_ENDED,
                                     // NO_BUFFER, USE_SYSTEM_CLOCK
   parameter RST_ACT_LOW           = 0;
                                     // =1 for active low reset,
                                     // =0 for active high.
//   parameter CAL_WIDTH             = "HALF";
//   parameter STARVE_LIMIT          = 2;
                                     // # = 2,3,4.

   //***************************************************************************
   // Referece clock frequency parameters
   //***************************************************************************
   parameter REFCLK_FREQ           = 200.0;
                                     // IODELAYCTRL reference clock frequency
   //***************************************************************************
   // System clock frequency parameters
   //***************************************************************************
   parameter C0_tCK                   = 1500;
                                     // memory tCK paramter.
                     // # = Clock Period in pS.
   parameter C0_nCK_PER_CLK           = 4;
                                     // # of memory CKs per fabric CLK

   

   //***************************************************************************
   // Debug and Internal parameters
   //***************************************************************************
   parameter C0_DEBUG_PORT            = "OFF";
                                     // # = "ON" Enable debug signals/controls.
                                     //   = "OFF" Disable debug signals/controls.
   //***************************************************************************
   // Debug and Internal parameters
   //***************************************************************************
   parameter DRAM_TYPE             = "DDR3";

    
   //***************************************************************************
   // Traffic Gen related parameters
   //***************************************************************************
   parameter C1_SIMULATION            = "TRUE";
//   parameter C1_BL_WIDTH              = 10;
   parameter C1_PORT_MODE             = "BI_MODE";
   parameter C1_DATA_MODE             = 4'b0010;
   parameter C1_TST_MEM_INSTR_MODE    = "R_W_INSTR_MODE";
   parameter C1_EYE_TEST              = "FALSE";
                                     // set EYE_TEST = "TRUE" to probe memory
                                     // signals. Traffic Generator will only
                                     // write to one single location and no
                                     // read transactions will be generated.
   parameter C1_DATA_PATTERN          = "DGEN_ALL";
                                      // For small devices, choose one only.
                                      // For large device, choose "DGEN_ALL"
                                      // "DGEN_HAMMER", "DGEN_WALKING1",
                                      // "DGEN_WALKING0","DGEN_ADDR","
                                      // "DGEN_NEIGHBOR","DGEN_PRBS","DGEN_ALL"
   parameter C1_CMD_PATTERN           = "CGEN_ALL";
                                      // "CGEN_PRBS","CGEN_FIXED","CGEN_BRAM",
                                      // "CGEN_SEQUENTIAL", "CGEN_ALL"
//   parameter C1_SEL_VICTIM_LINE       = 11;
//   parameter C1_ADDR_MODE             = 4'b0011;
   parameter C1_BEGIN_ADDRESS         = 32'h00000000;
   parameter C1_END_ADDRESS           = 32'h00000fff;
   parameter C1_PRBS_EADDR_MASK_POS   = 32'hff000000;

   //***************************************************************************
   // The following parameters refer to width of various ports
   //***************************************************************************
//   parameter C1_BANK_WIDTH            = 3;
                                     // # of memory Bank Address bits.
//   parameter C1_CK_WIDTH              = 1;
                                     // # of CK/CK# outputs to memory.
   parameter C1_COL_WIDTH             = 10;
                                     // # of memory Column Address bits.
   parameter C1_CS_WIDTH              = 1;
                                     // # of unique CS outputs to memory.
//   parameter C1_nCS_PER_RANK          = 1;
                                     // # of unique CS outputs per rank for phy
//   parameter C1_CKE_WIDTH             = 1;
                                     // # of CKE outputs to memory.
//   parameter C1_DATA_BUF_ADDR_WIDTH   = 5;
//   parameter C1_DQ_CNT_WIDTH          = 4;
                                     // = ceil(log2(DQ_WIDTH))
//   parameter C1_DQ_PER_DM             = 8;
   parameter C1_DM_WIDTH              = 2;
                                     // # of DM (data mask)
   parameter C1_DQ_WIDTH              = 16;
                                     // # of DQ (data)
   parameter C1_DQS_WIDTH             = 2;
   parameter C1_DQS_CNT_WIDTH         = 1;
                                     // = ceil(log2(DQS_WIDTH))
   parameter C1_DRAM_WIDTH            = 8;
                                     // # of DQ per DQS
   parameter C1_ECC                   = "OFF";
//   parameter C1_nBANK_MACHS           = 4;
   parameter C1_RANKS                 = 1;
                                     // # of Ranks.
   parameter C1_ODT_WIDTH             = 1;
                                     // # of ODT outputs to memory.
   parameter C1_ROW_WIDTH             = 14;
                                     // # of memory Row Address bits.
   parameter C1_ADDR_WIDTH            = 28;
                                     // # = RANK_WIDTH + BANK_WIDTH
                                     //     + ROW_WIDTH + COL_WIDTH;
                                     // Chip Select is always tied to low for
                                     // single rank devices
//   parameter C1_USE_CS_PORT          = 0;
                                     // # = 1, When CS output is enabled
                                     //   = 0, When CS output is disabled
                                     // If CS_N disabled, user must connect
                                     // DRAM CS_N input(s) to ground
//   parameter C1_USE_DM_PORT           = 0;
                                     // # = 1, When Data Mask option is enabled
                                     //   = 0, When Data Mask option is disbaled
                                     // When Data Mask option is disabled in
                                     // MIG Controller Options page, the logic
                                     // related to Data Mask should not get
                                     // synthesized
//   parameter C1_USE_ODT_PORT          = 1;
                                     // # = 1, When ODT output is enabled
                                     //   = 0, When ODT output is disabled
                                     // Parameter configuration for Dynamic ODT support:
                                     // USE_ODT_PORT = 0, RTT_NOM = "DISABLED", RTT_WR = "60/120".
                                     // This configuration allows to save ODT pin mapping from FPGA.
                                     // The user can tie the ODT input of DRAM to HIGH.

   //***************************************************************************
   // The following parameters are mode register settings
   //***************************************************************************
//   parameter C1_AL                    = "0";
                                     // DDR3 SDRAM:
                                     // Additive Latency (Mode Register 1).
                                     // # = "0", "CL-1", "CL-2".
                                     // DDR2 SDRAM:
                                     // Additive Latency (Extended Mode Register).
//   parameter C1_nAL                   = 0;
                                     // # Additive Latency in number of clock
                                     // cycles.
   parameter C1_BURST_MODE            = "8";
                                     // DDR3 SDRAM:
                                     // Burst Length (Mode Register 0).
                                     // # = "8", "4", "OTF".
                                     // DDR2 SDRAM:
                                     // Burst Length (Mode Register).
                                     // # = "8", "4".
//   parameter C1_BURST_TYPE            = "SEQ";
                                     // DDR3 SDRAM: Burst Type (Mode Register 0).
                                     // DDR2 SDRAM: Burst Type (Mode Register).
                                     // # = "SEQ" - (Sequential),
                                     //   = "INT" - (Interleaved).
//   parameter C1_CL                    = 9;
                                     // in number of clock cycles
                                     // DDR3 SDRAM: CAS Latency (Mode Register 0).
                                     // DDR2 SDRAM: CAS Latency (Mode Register).
//   parameter C1_CWL                   = 7;
                                     // in number of clock cycles
                                     // DDR3 SDRAM: CAS Write Latency (Mode Register 2).
                                     // DDR2 SDRAM: Can be ignored
//   parameter C1_OUTPUT_DRV            = "HIGH";
                                     // Output Driver Impedance Control (Mode Register 1).
                                     // # = "HIGH" - RZQ/7,
                                     //   = "LOW" - RZQ/6.
//   parameter C1_RTT_NOM               = "60";
                                     // RTT_NOM (ODT) (Mode Register 1).
                                     // # = "DISABLED" - RTT_NOM disabled,
                                     //   = "120" - RZQ/2,
                                     //   = "60"  - RZQ/4,
                                     //   = "40"  - RZQ/6.
//   parameter C1_RTT_WR                = "OFF";
                                     // RTT_WR (ODT) (Mode Register 2).
                                     // # = "OFF" - Dynamic ODT off,
                                     //   = "120" - RZQ/2,
                                     //   = "60"  - RZQ/4,
//   parameter C1_ADDR_CMD_MODE         = "1T" ;
                                     // # = "1T", "2T".
//   parameter C1_REG_CTRL              = "OFF";
                                     // # = "ON" - RDIMMs,
                                     //   = "OFF" - Components, SODIMMs, UDIMMs.
   parameter C1_CA_MIRROR             = "OFF";
                                     // C/A mirror opt for DDR3 dual rank
   
   //***************************************************************************
   // The following parameters are multiplier and divisor factors for PLLE2.
   // Based on the selected design frequency these parameters vary.
   //***************************************************************************
   parameter C1_CLKIN_PERIOD          = 4000;
                                     // Input Clock Period
//   parameter C1_CLKFBOUT_MULT         = 16;
                                     // write PLL VCO multiplier
//   parameter C1_DIVCLK_DIVIDE         = 3;
                                     // write PLL VCO divisor
//   parameter C1_CLKOUT0_DIVIDE        = 2;
                                     // VCO output divisor for PLL output clock (CLKOUT0)
//   parameter C1_CLKOUT1_DIVIDE        = 2;
                                     // VCO output divisor for PLL output clock (CLKOUT1)
//   parameter C1_CLKOUT2_DIVIDE        = 32;
                                     // VCO output divisor for PLL output clock (CLKOUT2)
//   parameter C1_CLKOUT3_DIVIDE        = 8;
                                     // VCO output divisor for PLL output clock (CLKOUT3)

   //***************************************************************************
   // Memory Timing Parameters. These parameters varies based on the selected
   // memory part.
   //***************************************************************************
//   parameter C1_tCKE                  = 5625;
                                     // memory tCKE paramter in pS
//   parameter C1_tFAW                  = 45000;
                                     // memory tRAW paramter in pS.
//   parameter C1_tRAS                  = 36000;
                                     // memory tRAS paramter in pS.
//   parameter C1_tRCD                  = 13500;
                                     // memory tRCD paramter in pS.
//   parameter C1_tREFI                 = 7800000;
                                     // memory tREFI paramter in pS.
//   parameter C1_tRFC                  = 160000;
                                     // memory tRFC paramter in pS.
//   parameter C1_tRP                   = 13500;
                                     // memory tRP paramter in pS.
//   parameter C1_tRRD                  = 7500;
                                     // memory tRRD paramter in pS.
//   parameter C1_tRTP                  = 7500;
                                     // memory tRTP paramter in pS.
//   parameter C1_tWTR                  = 7500;
                                     // memory tWTR paramter in pS.
//   parameter C1_tZQI                  = 128_000_000;
                                     // memory tZQI paramter in nS.
//   parameter C1_tZQCS                 = 64;
                                     // memory tZQCS paramter in clock cycles.

   //***************************************************************************
   // Simulation parameters
   //***************************************************************************
   parameter C1_SIM_BYPASS_INIT_CAL   = "FAST";
                                     // # = "SIM_INIT_CAL_FULL" -  Complete
                                     //              memory init &
                                     //              calibration sequence
                                     // # = "SKIP" - Not supported
                                     // # = "FAST" - Complete memory init & use
                                     //              abbreviated calib sequence

   //***************************************************************************
   // The following parameters varies based on the pin out entered in MIG GUI.
   // Do not change any of these parameters directly by editing the RTL.
   // Any changes required should be done through GUI and the design regenerated.
   //***************************************************************************
//   parameter C1_BYTE_LANES_B0         = 4'b1111;
                                     // Byte lanes used in an IO column.
//   parameter C1_BYTE_LANES_B1         = 4'b0000;
                                     // Byte lanes used in an IO column.
//   parameter C1_BYTE_LANES_B2         = 4'b0000;
                                     // Byte lanes used in an IO column.
//   parameter C1_BYTE_LANES_B3         = 4'b0000;
                                     // Byte lanes used in an IO column.
//   parameter C1_BYTE_LANES_B4         = 4'b0000;
                                     // Byte lanes used in an IO column.
//   parameter C1_DATA_CTL_B0           = 4'b1001;
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
//   parameter C1_DATA_CTL_B1           = 4'b0000;
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
//   parameter C1_DATA_CTL_B2           = 4'b0000;
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
//   parameter C1_DATA_CTL_B3           = 4'b0000;
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
//   parameter C1_DATA_CTL_B4           = 4'b0000;
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
//   parameter C1_PHY_0_BITLANES        = 48'h3FC_3FF_FFF_2FE;
//   parameter C1_PHY_1_BITLANES        = 48'h000_000_000_000;
//   parameter C1_PHY_2_BITLANES        = 48'h000_000_000_000;

   // control/address/data pin mapping parameters
//   parameter C1_CK_BYTE_MAP
//     = 144'h00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_02;
//   parameter C1_ADDR_MAP
//     = 192'h000_000_029_028_027_026_025_024_023_022_021_020_019_018_017_016;
//   parameter C1_BANK_MAP   = 36'h01B_01A_015;
//   parameter C1_CAS_MAP    = 12'h013;
//   parameter C1_CKE_ODT_BYTE_MAP = 8'h00;
//   parameter C1_CKE_MAP    = 96'h000_000_000_000_000_000_000_011;
//   parameter C1_ODT_MAP    = 96'h000_000_000_000_000_000_000_010;
//   parameter C1_CS_MAP     = 120'h000_000_000_000_000_000_000_000_000_000;
//   parameter C1_PARITY_MAP = 12'h000;
//   parameter C1_RAS_MAP    = 12'h014;
//   parameter C1_WE_MAP     = 12'h012;
//   parameter C1_DQS_BYTE_MAP
//     = 144'h00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_03_00;
//   parameter C1_DATA0_MAP  = 96'h001_002_003_004_005_006_007_009;
//   parameter C1_DATA1_MAP  = 96'h032_033_034_035_036_037_038_039;
//   parameter C1_DATA2_MAP  = 96'h000_000_000_000_000_000_000_000;
//   parameter C1_DATA3_MAP  = 96'h000_000_000_000_000_000_000_000;
//   parameter C1_DATA4_MAP  = 96'h000_000_000_000_000_000_000_000;
//   parameter C1_DATA5_MAP  = 96'h000_000_000_000_000_000_000_000;
//   parameter C1_DATA6_MAP  = 96'h000_000_000_000_000_000_000_000;
//   parameter C1_DATA7_MAP  = 96'h000_000_000_000_000_000_000_000;
//   parameter C1_DATA8_MAP  = 96'h000_000_000_000_000_000_000_000;
//   parameter C1_DATA9_MAP  = 96'h000_000_000_000_000_000_000_000;
//   parameter C1_DATA10_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter C1_DATA11_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter C1_DATA12_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter C1_DATA13_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter C1_DATA14_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter C1_DATA15_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter C1_DATA16_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter C1_DATA17_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter C1_MASK0_MAP  = 108'h000_000_000_000_000_000_000_000_000;
//   parameter C1_MASK1_MAP  = 108'h000_000_000_000_000_000_000_000_000;

//   parameter C1_SLOT_0_CONFIG         = 8'b0000_0001;
                                     // Mapping of Ranks.
//   parameter C1_SLOT_1_CONFIG         = 8'b0000_0000;
                                     // Mapping of Ranks.
//   parameter C1_MEM_ADDR_ORDER        = "BANK_ROW_COLUMN";
                                      //Possible Parameters
                                      //1.BANK_ROW_COLUMN : Address mapping is
                                      //                    in form of Bank Row Column.
                                      //2.ROW_BANK_COLUMN : Address mapping is
                                      //                    in the form of Row Bank Column.
                                      //3.TG_TEST : Scrambles Address bits
                                      //            for distributed Addressing.
   //***************************************************************************
   // IODELAY and PHY related parameters
   //***************************************************************************
//   parameter C1_IBUF_LPWR_MODE        = "OFF";
                                     // to phy_top
//   parameter C1_DATA_IO_IDLE_PWRDWN   = "ON";
                                     // # = "ON", "OFF"
//   parameter C1_DATA_IO_PRIM_TYPE     = "HP_LP";
                                     // # = "HP_LP", "HR_LP", "DEFAULT"
//   parameter C1_USER_REFRESH          = "OFF";
//   parameter C1_WRLVL                 = "ON";
                                     // # = "ON" - DDR3 SDRAM
                                     //   = "OFF" - DDR2 SDRAM.
//   parameter C1_ORDERING              = "NORM";
                                     // # = "NORM", "STRICT", "RELAXED".
//   parameter C1_CALIB_ROW_ADD         = 16'h0000;
                                     // Calibration row address will be used for
                                     // calibration read and write operations
//   parameter C1_CALIB_COL_ADD         = 12'h000;
                                     // Calibration column address will be used for
                                     // calibration read and write operations
//   parameter C1_CALIB_BA_ADD          = 3'h0;
                                     // Calibration bank address will be used for
                                     // calibration read and write operations
   parameter C1_TCQ                   = 100;
   

   
   //***************************************************************************
   // System clock frequency parameters
   //***************************************************************************
   parameter C1_tCK                   = 1500;
                                     // memory tCK paramter.
                     // # = Clock Period in pS.
   parameter C1_nCK_PER_CLK           = 4;
                                     // # of memory CKs per fabric CLK

   

   //***************************************************************************
   // Debug and Internal parameters
   //***************************************************************************
   parameter C1_DEBUG_PORT            = "OFF";
                                     // # = "ON" Enable debug signals/controls.
                                     //   = "OFF" Disable debug signals/controls.
  
  //**************************************************************************//
  // Local parameters Declarations
  //**************************************************************************//
  localparam real C0_TPROP_DQS          = 0.00;
                                       // Delay for DQS signal during Write Operation
  localparam real C0_TPROP_DQS_RD       = 0.00;
                       // Delay for DQS signal during Read Operation
  localparam real C0_TPROP_PCB_CTRL     = 0.00;
                       // Delay for Address and Ctrl signals
  localparam real C0_TPROP_PCB_DATA     = 0.00;
                       // Delay for data signal during Write operation
  localparam real C0_TPROP_PCB_DATA_RD  = 0.00;
                       // Delay for data signal during Read operation
  localparam C0_MEMORY_WIDTH            = 16;
  localparam C0_NUM_COMP                = C0_DQ_WIDTH/C0_MEMORY_WIDTH;
  localparam C0_ECC_TEST 		   	= "OFF" ;
  localparam C0_ERR_INSERT = (C0_ECC_TEST == "ON") ? "OFF" : C0_ECC ;
  

  localparam real REFCLK_PERIOD = (1000000.0/(2*REFCLK_FREQ));
  localparam RESET_PERIOD = 200000; //in pSec  
  localparam real C0_SYSCLK_PERIOD = C0_tCK;
  localparam real C1_TPROP_DQS          = 0.00;
                                       // Delay for DQS signal during Write Operation
  localparam real C1_TPROP_DQS_RD       = 0.00;
                       // Delay for DQS signal during Read Operation
  localparam real C1_TPROP_PCB_CTRL     = 0.00;
                       // Delay for Address and Ctrl signals
  localparam real C1_TPROP_PCB_DATA     = 0.00;
                       // Delay for data signal during Write operation
  localparam real C1_TPROP_PCB_DATA_RD  = 0.00;
                       // Delay for data signal during Read operation

  localparam C1_MEMORY_WIDTH            = 16;
  localparam C1_NUM_COMP                = C1_DQ_WIDTH/C1_MEMORY_WIDTH;
  localparam C1_ECC_TEST 		   	= "OFF" ;
  localparam C1_ERR_INSERT = (C1_ECC_TEST == "ON") ? "OFF" : C1_ECC ;
  localparam real C1_SYSCLK_PERIOD = C1_tCK;
   wire                               c0_ddr3_reset_n;
  wire [C0_DQ_WIDTH-1:0]                c0_ddr3_dq_fpga;
  wire [C0_DQS_WIDTH-1:0]               c0_ddr3_dqs_p_fpga;
  wire [C0_DQS_WIDTH-1:0]               c0_ddr3_dqs_n_fpga;
  wire [C0_ROW_WIDTH-1:0]               c0_ddr3_addr_fpga;
  wire [3-1:0]              c0_ddr3_ba_fpga;
  wire                               c0_ddr3_ras_n_fpga;
  wire                               c0_ddr3_cas_n_fpga;
  wire                               c0_ddr3_we_n_fpga;
  wire [1-1:0]               c0_ddr3_cke_fpga;
  wire [1-1:0]                c0_ddr3_ck_p_fpga;
  wire [1-1:0]                c0_ddr3_ck_n_fpga;
  wire                               init_calib_complete;
  wire                               tg_compare_error;
  wire [C0_ODT_WIDTH-1:0]               c0_ddr3_odt_fpga;
  reg [C0_ODT_WIDTH-1:0]                c0_ddr3_odt_sdram_tmp;
  wire [C0_DQ_WIDTH-1:0]                c0_ddr3_dq_sdram;
  reg [C0_ROW_WIDTH-1:0]                c0_ddr3_addr_sdram [0:1];
  reg [3-1:0]               c0_ddr3_ba_sdram [0:1];
  reg                                c0_ddr3_ras_n_sdram;
  reg                                c0_ddr3_cas_n_sdram;
  reg                                c0_ddr3_we_n_sdram;
  wire [(C0_CS_WIDTH*1)-1:0] c0_ddr3_cs_n_sdram;
  wire [C0_ODT_WIDTH-1:0]               c0_ddr3_odt_sdram;
  reg [1-1:0]                c0_ddr3_cke_sdram;
  wire [C0_DM_WIDTH-1:0]                c0_ddr3_dm_sdram;
  wire [C0_DQS_WIDTH-1:0]               c0_ddr3_dqs_p_sdram;
  wire [C0_DQS_WIDTH-1:0]               c0_ddr3_dqs_n_sdram;
  reg [1-1:0]                 c0_ddr3_ck_p_sdram;
  reg [1-1:0]                 c0_ddr3_ck_n_sdram;

  wire                               c1_ddr3_reset_n;
  wire [C1_DQ_WIDTH-1:0]                c1_ddr3_dq_fpga;
  wire [C1_DQS_WIDTH-1:0]               c1_ddr3_dqs_p_fpga;
  wire [C1_DQS_WIDTH-1:0]               c1_ddr3_dqs_n_fpga;
  wire [C1_ROW_WIDTH-1:0]               c1_ddr3_addr_fpga;
  wire [3-1:0]              c1_ddr3_ba_fpga;
  wire                               c1_ddr3_ras_n_fpga;
  wire                               c1_ddr3_cas_n_fpga;
  wire                               c1_ddr3_we_n_fpga;
  wire [1-1:0]               c1_ddr3_cke_fpga;
  wire [1-1:0]                c1_ddr3_ck_p_fpga;
  wire [1-1:0]                c1_ddr3_ck_n_fpga;
  
  wire [C1_ODT_WIDTH-1:0]               c1_ddr3_odt_fpga;
  reg [C1_ODT_WIDTH-1:0]                c1_ddr3_odt_sdram_tmp;
  wire [C1_DQ_WIDTH-1:0]                c1_ddr3_dq_sdram;
  reg [C1_ROW_WIDTH-1:0]                c1_ddr3_addr_sdram [0:1];
  reg [3-1:0]               c1_ddr3_ba_sdram [0:1];
  reg                                c1_ddr3_ras_n_sdram;
  reg                                c1_ddr3_cas_n_sdram;
  reg                                c1_ddr3_we_n_sdram;
  wire [(C1_CS_WIDTH*1)-1:0] c1_ddr3_cs_n_sdram;
  wire [C1_ODT_WIDTH-1:0]               c1_ddr3_odt_sdram;
  reg [1-1:0]                c1_ddr3_cke_sdram;
  wire [C1_DM_WIDTH-1:0]                c1_ddr3_dm_sdram;
  wire [C1_DQS_WIDTH-1:0]               c1_ddr3_dqs_p_sdram;
  wire [C1_DQS_WIDTH-1:0]               c1_ddr3_dqs_n_sdram;
  reg [1-1:0]                 c1_ddr3_ck_p_sdram;
  reg [1-1:0]                 c1_ddr3_ck_n_sdram;
///////////////////////////////////////////////////////////////

// IO_LOCALBUS_B_DATA
wire		S_tx_gmii_dv_p00	;
wire [7:0]	S_tx_gmii_d_p00		;

//// ddr clk
reg			c0_sys_clk_i		;
reg			c1_sys_clk_i		;
reg			clk_ref_i			;


initial 
begin
	c0_sys_clk_i = 1'b0;
	c1_sys_clk_i = 1'b0;
	clk_ref_i	 = 1'b0;
end
always 
begin
	c0_sys_clk_i = #2 ~c0_sys_clk_i;
end

always 
begin
	c1_sys_clk_i = #2 ~c1_sys_clk_i;
end

always 
begin
	clk_ref_i	= #2 ~clk_ref_i;
end





wire [15:0] IO_cpu_data			;
wire		S_ddr_rdy			;
assign S_156m25_clk_n 	= ~ I_156m25_clk;
assign S_125m_clk_n 	= ~ I_125m_clk 	;
assign S_312m5_clk_n 	= ~ I_312m5_clk	;

//assign 	IO_cpu_data = dut_if.S_brd_data_en ? dut_if.S_brd_data:16'hz; 
assign dut_if.S_sub_lb_clk = I_312m5_clk ;


assign U0_rcu_pla_top_32bit.I_for_xgmii_hc_txd = S_ddr_rdy ? dut_if.S_xgmii_txd : 32'h07070707;
assign U0_rcu_pla_top_32bit.I_for_xgmii_hc_txc = S_ddr_rdy ? dut_if.S_xgmii_txc : 4'hf;
assign U0_rcu_pla_top_32bit.I_for_xgmii_hc_num = S_ddr_rdy ? dut_if.S_xgmii_txport_num: 2'h00;

assign U0_rcu_pla_top_32bit.I_back_xgmii_rxd = S_ddr_rdy ? U0_rcu_pla_top_32bit.O_for_xgmii_pla_txd : 32'h07070707;
assign U0_rcu_pla_top_32bit.I_back_xgmii_rxc = S_ddr_rdy ?U0_rcu_pla_top_32bit.O_for_xgmii_pla_txc : 4'hf;

assign dut_if.S_xgmii_rxd = S_ddr_rdy ? U0_rcu_pla_top_32bit.O_back_xgmii_pla_rxd : 32'h07070707;
assign dut_if.S_xgmii_rxc = S_ddr_rdy ? U0_rcu_pla_top_32bit.O_back_xgmii_pla_rxc : 4'hf;
assign dut_if.S_xgmii_rxport_num = S_ddr_rdy ? U0_rcu_pla_top_32bit.O_back_xgmii_pla_num   : 2'h0; 



/*
assign dut_if.S_xgmii_rxd = dut_if.S_xgmii_txd	; 
assign dut_if.S_xgmii_rxc = dut_if.S_xgmii_txc	; 
assign dut_if.S_xgmii_rxport_num = dut_if.S_xgmii_txport_num; 
*/

rcu_pla_top_32bit U0_rcu_pla_top_32bit(
.O_ddr_rdy               (S_ddr_rdy),
.I_pla_312m5_clk         (I_312m5_clk				),
.I_pla_rst               (!I_rst_n					),

.I_lb_clk                (I_312m5_clk				), 
.I_lb_cs_n               (dut_if.S_sub_cs_n			),        
.I_lb_we_n               (dut_if.S_sub_wr_n			),        
.I_lb_rd_n               (dut_if.S_sub_rd_n			),     
.I_lb_addr               (dut_if.S_sub_addr			),     
.I_lb_wr_data            (dut_if.S_sub_din			),      
.O_lb_rd_data            (     ),

.I_for_xgmii_hc_txd      (  ),
.I_for_xgmii_hc_txc      (  ),
.I_for_xgmii_hc_num      (  ), 
.O_for_xgmii_pla_txd     (  ),
.O_for_xgmii_pla_txc     (  ),

.I_back_xgmii_rxd        (	),
.I_back_xgmii_rxc        (	),
.O_back_xgmii_pla_rxd    (  ),    
.O_back_xgmii_pla_rxc    (  ), 
.O_back_xgmii_pla_num    (  ),
.O_pla_for_ff_pause      (	),////组1PLA对应子端口Pause   
///ddr io
.c0_ddr3_dq              (c0_ddr3_dq_fpga),
.c0_ddr3_dqs_n           (c0_ddr3_dqs_n_fpga),
.c0_ddr3_dqs_p           (c0_ddr3_dqs_p_fpga),
.c0_ddr3_addr            (c0_ddr3_addr_fpga),
.c0_ddr3_ba              (c0_ddr3_ba_fpga),
.c0_ddr3_ras_n           (c0_ddr3_ras_n_fpga),
.c0_ddr3_cas_n           (c0_ddr3_cas_n_fpga),
.c0_ddr3_we_n            (c0_ddr3_we_n_fpga),
.c0_ddr3_reset_n         (c0_ddr3_reset_n),
.c0_ddr3_ck_p            (c0_ddr3_ck_p_fpga),
.c0_ddr3_ck_n            (c0_ddr3_ck_n_fpga),
.c0_ddr3_cke             (c0_ddr3_cke_fpga),
.c0_ddr3_odt             (c0_ddr3_odt_fpga),
.c0_sys_clk_i            (c0_sys_clk_i),    
.clk_ref_i               (clk_ref_i),
.c1_ddr3_dq              (c1_ddr3_dq_fpga),
.c1_ddr3_dqs_n           (c1_ddr3_dqs_n_fpga),
.c1_ddr3_dqs_p           (c1_ddr3_dqs_p_fpga),
.c1_ddr3_addr            (c1_ddr3_addr_fpga),
.c1_ddr3_ba              (c1_ddr3_ba_fpga),
.c1_ddr3_ras_n           (c1_ddr3_ras_n_fpga),
.c1_ddr3_cas_n           (c1_ddr3_cas_n_fpga),
.c1_ddr3_we_n            (c1_ddr3_we_n_fpga),
.c1_ddr3_reset_n         (c1_ddr3_reset_n),
.c1_ddr3_ck_p            (c1_ddr3_ck_p_fpga),
.c1_ddr3_ck_n            (c1_ddr3_ck_n_fpga),
.c1_ddr3_cke             (c1_ddr3_cke_fpga),
.c1_ddr3_odt             (c1_ddr3_odt_fpga),
.O_c0_app_rdy			 (),  
.c1_sys_clk_i            (c1_sys_clk_i),
.init_calib_complete	 (init_calib_complete)
///.tg_compare_error    (tg_compare_error), 
);


//==== ddr controller simulate
  always @( * ) begin
    c0_ddr3_ck_p_sdram      <=  #(C0_TPROP_PCB_CTRL) c0_ddr3_ck_p_fpga;
    c0_ddr3_ck_n_sdram      <=  #(C0_TPROP_PCB_CTRL) c0_ddr3_ck_n_fpga;
    c0_ddr3_addr_sdram[0]   <=  #(C0_TPROP_PCB_CTRL) c0_ddr3_addr_fpga;
    c0_ddr3_addr_sdram[1]   <=  #(C0_TPROP_PCB_CTRL) (C0_CA_MIRROR == "ON") ?
                                                 {c0_ddr3_addr_fpga[C0_ROW_WIDTH-1:9],
                                                  c0_ddr3_addr_fpga[7], c0_ddr3_addr_fpga[8],
                                                  c0_ddr3_addr_fpga[5], c0_ddr3_addr_fpga[6],
                                                  c0_ddr3_addr_fpga[3], c0_ddr3_addr_fpga[4],
                                                  c0_ddr3_addr_fpga[2:0]} :
                                                 c0_ddr3_addr_fpga;
    c0_ddr3_ba_sdram[0]     <=  #(C0_TPROP_PCB_CTRL) c0_ddr3_ba_fpga;
    c0_ddr3_ba_sdram[1]     <=  #(C0_TPROP_PCB_CTRL) (C0_CA_MIRROR == "ON") ?
                                                 {c0_ddr3_ba_fpga[3-1:2],
                                                  c0_ddr3_ba_fpga[0],
                                                  c0_ddr3_ba_fpga[1]} :
                                                 c0_ddr3_ba_fpga;
    c0_ddr3_ras_n_sdram     <=  #(C0_TPROP_PCB_CTRL) c0_ddr3_ras_n_fpga;
    c0_ddr3_cas_n_sdram     <=  #(C0_TPROP_PCB_CTRL) c0_ddr3_cas_n_fpga;
    c0_ddr3_we_n_sdram      <=  #(C0_TPROP_PCB_CTRL) c0_ddr3_we_n_fpga;
    c0_ddr3_cke_sdram       <=  #(C0_TPROP_PCB_CTRL) c0_ddr3_cke_fpga;
  end
    

  assign c0_ddr3_cs_n_sdram =  {(C0_CS_WIDTH*1){1'b0}};
    

  assign c0_ddr3_dm_sdram =  {C0_DM_WIDTH{1'b0}};//DM signal generation
    

  always @( * )
    c0_ddr3_odt_sdram_tmp  <=  #(C0_TPROP_PCB_CTRL) c0_ddr3_odt_fpga;
  assign c0_ddr3_odt_sdram =  c0_ddr3_odt_sdram_tmp;
    

// Controlling the bi-directional BUS

  genvar c0_dqwd;
  generate
    for (c0_dqwd = 1;c0_dqwd < C0_DQ_WIDTH;c0_dqwd = c0_dqwd+1) begin : c0_dq_delay
      WireDelay #
       (
        .Delay_g    (C0_TPROP_PCB_DATA),
        .Delay_rd   (C0_TPROP_PCB_DATA_RD),
        .ERR_INSERT ("OFF")
       )
      c0_u_delay_dq
       (
        .A             (c0_ddr3_dq_fpga[c0_dqwd]),
        .B             (c0_ddr3_dq_sdram[c0_dqwd]),
        .reset         (sys_rst_n),
        .phy_init_done (init_calib_complete)
       );
    end
    // For ECC ON case error is inserted on LSB bit from DRAM to FPGA
          WireDelay #
       (
        .Delay_g    (C0_TPROP_PCB_DATA),
        .Delay_rd   (C0_TPROP_PCB_DATA_RD),
        .ERR_INSERT (C0_ERR_INSERT)
       )
      c0_u_delay_dq_0
       (
        .A             (c0_ddr3_dq_fpga[0]),
        .B             (c0_ddr3_dq_sdram[0]),
        .reset         (sys_rst_n),
        .phy_init_done (init_calib_complete)
       );
  endgenerate

  genvar c0_dqswd;
  generate
    for (c0_dqswd = 0;c0_dqswd < C0_DQS_WIDTH;c0_dqswd = c0_dqswd+1) begin : c0_dqs_delay
      WireDelay #
       (
        .Delay_g    (C0_TPROP_DQS),
        .Delay_rd   (C0_TPROP_DQS_RD),
        .ERR_INSERT ("OFF")
       )
      c0_u_delay_dqs_p
       (
        .A             (c0_ddr3_dqs_p_fpga[c0_dqswd]),
        .B             (c0_ddr3_dqs_p_sdram[c0_dqswd]),
        .reset         (sys_rst_n),
        .phy_init_done (init_calib_complete)
       );

      WireDelay #
       (
        .Delay_g    (C0_TPROP_DQS),
        .Delay_rd   (C0_TPROP_DQS_RD),
        .ERR_INSERT ("OFF")
       )
      c0_u_delay_dqs_n
       (
        .A             (c0_ddr3_dqs_n_fpga[c0_dqswd]),
        .B             (c0_ddr3_dqs_n_sdram[c0_dqswd]),
        .reset         (sys_rst_n),
        .phy_init_done (init_calib_complete)
       );
    end
  endgenerate
    

    

  always @( * ) begin
    c1_ddr3_ck_p_sdram      <=  #(C1_TPROP_PCB_CTRL) c1_ddr3_ck_p_fpga;
    c1_ddr3_ck_n_sdram      <=  #(C1_TPROP_PCB_CTRL) c1_ddr3_ck_n_fpga;
    c1_ddr3_addr_sdram[0]   <=  #(C1_TPROP_PCB_CTRL) c1_ddr3_addr_fpga;
    c1_ddr3_addr_sdram[1]   <=  #(C1_TPROP_PCB_CTRL) (C1_CA_MIRROR == "ON") ?
                                                 {c1_ddr3_addr_fpga[C1_ROW_WIDTH-1:9],
                                                  c1_ddr3_addr_fpga[7], c1_ddr3_addr_fpga[8],
                                                  c1_ddr3_addr_fpga[5], c1_ddr3_addr_fpga[6],
                                                  c1_ddr3_addr_fpga[3], c1_ddr3_addr_fpga[4],
                                                  c1_ddr3_addr_fpga[2:0]} :
                                                 c1_ddr3_addr_fpga;
    c1_ddr3_ba_sdram[0]     <=  #(C1_TPROP_PCB_CTRL) c1_ddr3_ba_fpga;
    c1_ddr3_ba_sdram[1]     <=  #(C1_TPROP_PCB_CTRL) (C1_CA_MIRROR == "ON") ?
                                                 {c1_ddr3_ba_fpga[3-1:2],
                                                  c1_ddr3_ba_fpga[0],
                                                  c1_ddr3_ba_fpga[1]} :
                                                 c1_ddr3_ba_fpga;
    c1_ddr3_ras_n_sdram     <=  #(C1_TPROP_PCB_CTRL) c1_ddr3_ras_n_fpga;
    c1_ddr3_cas_n_sdram     <=  #(C1_TPROP_PCB_CTRL) c1_ddr3_cas_n_fpga;
    c1_ddr3_we_n_sdram      <=  #(C1_TPROP_PCB_CTRL) c1_ddr3_we_n_fpga;
    c1_ddr3_cke_sdram       <=  #(C1_TPROP_PCB_CTRL) c1_ddr3_cke_fpga;
  end
    

  assign c1_ddr3_cs_n_sdram =  {(C1_CS_WIDTH*1){1'b0}};
    

  assign c1_ddr3_dm_sdram =  {C1_DM_WIDTH{1'b0}};//DM signal generation
    

  always @( * )
    c1_ddr3_odt_sdram_tmp  <=  #(C1_TPROP_PCB_CTRL) c1_ddr3_odt_fpga;
  assign c1_ddr3_odt_sdram =  c1_ddr3_odt_sdram_tmp;
    

// Controlling the bi-directional BUS

  genvar c1_dqwd;
  generate
    for (c1_dqwd = 1;c1_dqwd < C1_DQ_WIDTH;c1_dqwd = c1_dqwd+1) begin : c1_dq_delay
      WireDelay #
       (
        .Delay_g    (C1_TPROP_PCB_DATA),
        .Delay_rd   (C1_TPROP_PCB_DATA_RD),
        .ERR_INSERT ("OFF")
       )
      c1_u_delay_dq
       (
        .A             (c1_ddr3_dq_fpga[c1_dqwd]),
        .B             (c1_ddr3_dq_sdram[c1_dqwd]),
        .reset         (sys_rst_n),
        .phy_init_done (init_calib_complete)
       );
    end
    // For ECC ON case error is inserted on LSB bit from DRAM to FPGA
          WireDelay #
       (
        .Delay_g    (C1_TPROP_PCB_DATA),
        .Delay_rd   (C1_TPROP_PCB_DATA_RD),
        .ERR_INSERT (C1_ERR_INSERT)
       )
      c1_u_delay_dq_0
       (
        .A             (c1_ddr3_dq_fpga[0]),
        .B             (c1_ddr3_dq_sdram[0]),
        .reset         (sys_rst_n),
        .phy_init_done (init_calib_complete)
       );
  endgenerate

  genvar c1_dqswd;
  generate
    for (c1_dqswd = 0;c1_dqswd < C1_DQS_WIDTH;c1_dqswd = c1_dqswd+1) begin : c1_dqs_delay
      WireDelay #
       (
        .Delay_g    (C1_TPROP_DQS),
        .Delay_rd   (C1_TPROP_DQS_RD),
        .ERR_INSERT ("OFF")
       )
      c1_u_delay_dqs_p
       (
        .A             (c1_ddr3_dqs_p_fpga[c1_dqswd]),
        .B             (c1_ddr3_dqs_p_sdram[c1_dqswd]),
        .reset         (sys_rst_n),
        .phy_init_done (init_calib_complete)
       );

      WireDelay #
       (
        .Delay_g    (C1_TPROP_DQS),
        .Delay_rd   (C1_TPROP_DQS_RD),
        .ERR_INSERT ("OFF")
       )
      c1_u_delay_dqs_n
       (
        .A             (c1_ddr3_dqs_n_fpga[c1_dqswd]),
        .B             (c1_ddr3_dqs_n_sdram[c1_dqswd]),
        .reset         (sys_rst_n),
        .phy_init_done (init_calib_complete)
       );
    end
  endgenerate
    

    

  //===========================================================================
  //                         FPGA Memory Controller
  //===========================================================================


  //**************************************************************************//
  // Memory Models instantiations
  //**************************************************************************//

  genvar c0_r,c0_i;
  generate
    for (c0_r = 0; c0_r < C0_CS_WIDTH; c0_r = c0_r + 1) begin: c0_mem_rnk
      if(C0_DQ_WIDTH/16) begin: mem
        for (c0_i = 0; c0_i < C0_NUM_COMP; c0_i = c0_i + 1) begin: c0_gen_mem
          c0_ddr3_model c0_u_comp_ddr3
            (
             .rst_n   (c0_ddr3_reset_n),
             .ck      (c0_ddr3_ck_p_sdram),
             .ck_n    (c0_ddr3_ck_n_sdram),
             .cke     (c0_ddr3_cke_sdram[c0_r]),
             .cs_n    (c0_ddr3_cs_n_sdram[c0_r]),
             .ras_n   (c0_ddr3_ras_n_sdram),
             .cas_n   (c0_ddr3_cas_n_sdram),
             .we_n    (c0_ddr3_we_n_sdram),
             .dm_tdqs (c0_ddr3_dm_sdram[(2*(c0_i+1)-1):(2*c0_i)]),
             .ba      (c0_ddr3_ba_sdram[c0_r]),
             .addr    (c0_ddr3_addr_sdram[c0_r]),
             .dq      (c0_ddr3_dq_sdram[16*(c0_i+1)-1:16*(c0_i)]),
             .dqs     (c0_ddr3_dqs_p_sdram[(2*(c0_i+1)-1):(2*c0_i)]),
             .dqs_n   (c0_ddr3_dqs_n_sdram[(2*(c0_i+1)-1):(2*c0_i)]),
             .tdqs_n  (),
             .odt     (c0_ddr3_odt_sdram[c0_r])
             );
        end
      end
      if (C0_DQ_WIDTH%16) begin: c0_gen_mem_extrabits
        c0_ddr3_model c0_u_comp_ddr3
          (
           .rst_n   (c0_ddr3_reset_n),
           .ck      (c0_ddr3_ck_p_sdram),
           .ck_n    (c0_ddr3_ck_n_sdram),
           .cke     (c0_ddr3_cke_sdram[c0_r]),
           .cs_n    (c0_ddr3_cs_n_sdram[c0_r]),
           .ras_n   (c0_ddr3_ras_n_sdram),
           .cas_n   (c0_ddr3_cas_n_sdram),
           .we_n    (c0_ddr3_we_n_sdram),
           .dm_tdqs ({c0_ddr3_dm_sdram[C0_DM_WIDTH-1],c0_ddr3_dm_sdram[C0_DM_WIDTH-1]}),
           .ba      (c0_ddr3_ba_sdram[c0_r]),
           .addr    (c0_ddr3_addr_sdram[c0_r]),
           .dq      ({c0_ddr3_dq_sdram[C0_DQ_WIDTH-1:(C0_DQ_WIDTH-8)],
                      c0_ddr3_dq_sdram[C0_DQ_WIDTH-1:(C0_DQ_WIDTH-8)]}),
           .dqs     ({c0_ddr3_dqs_p_sdram[C0_DQS_WIDTH-1],
                      c0_ddr3_dqs_p_sdram[C0_DQS_WIDTH-1]}),
           .dqs_n   ({c0_ddr3_dqs_n_sdram[C0_DQS_WIDTH-1],
                      c0_ddr3_dqs_n_sdram[C0_DQS_WIDTH-1]}),
           .tdqs_n  (),
           .odt     (c0_ddr3_odt_sdram[c0_r])
           );
      end
    end
  endgenerate
    
    
  genvar c1_r,c1_i;
  generate
    for (c1_r = 0; c1_r < C1_CS_WIDTH; c1_r = c1_r + 1) begin: c1_mem_rnk
      if(C1_DQ_WIDTH/16) begin: mem
        for (c1_i = 0; c1_i < C1_NUM_COMP; c1_i = c1_i + 1) begin: c1_gen_mem
          c1_ddr3_model c1_u_comp_ddr3
            (
             .rst_n   (c1_ddr3_reset_n),
             .ck      (c1_ddr3_ck_p_sdram),
             .ck_n    (c1_ddr3_ck_n_sdram),
             .cke     (c1_ddr3_cke_sdram[c1_r]),
             .cs_n    (c1_ddr3_cs_n_sdram[c1_r]),
             .ras_n   (c1_ddr3_ras_n_sdram),
             .cas_n   (c1_ddr3_cas_n_sdram),
             .we_n    (c1_ddr3_we_n_sdram),
             .dm_tdqs (c1_ddr3_dm_sdram[(2*(c1_i+1)-1):(2*c1_i)]),
             .ba      (c1_ddr3_ba_sdram[c1_r]),
             .addr    (c1_ddr3_addr_sdram[c1_r]),
             .dq      (c1_ddr3_dq_sdram[16*(c1_i+1)-1:16*(c1_i)]),
             .dqs     (c1_ddr3_dqs_p_sdram[(2*(c1_i+1)-1):(2*c1_i)]),
             .dqs_n   (c1_ddr3_dqs_n_sdram[(2*(c1_i+1)-1):(2*c1_i)]),
             .tdqs_n  (),
             .odt     (c1_ddr3_odt_sdram[c1_r])
             );
        end
      end
      if (C1_DQ_WIDTH%16) begin: c1_gen_mem_extrabits
        c1_ddr3_model c1_u_comp_ddr3
          (
           .rst_n   (c1_ddr3_reset_n),
           .ck      (c1_ddr3_ck_p_sdram),
           .ck_n    (c1_ddr3_ck_n_sdram),
           .cke     (c1_ddr3_cke_sdram[c1_r]),
           .cs_n    (c1_ddr3_cs_n_sdram[c1_r]),
           .ras_n   (c1_ddr3_ras_n_sdram),
           .cas_n   (c1_ddr3_cas_n_sdram),
           .we_n    (c1_ddr3_we_n_sdram),
           .dm_tdqs ({c1_ddr3_dm_sdram[C1_DM_WIDTH-1],c1_ddr3_dm_sdram[C1_DM_WIDTH-1]}),
           .ba      (c1_ddr3_ba_sdram[c1_r]),
           .addr    (c1_ddr3_addr_sdram[c1_r]),
           .dq      ({c1_ddr3_dq_sdram[C1_DQ_WIDTH-1:(C1_DQ_WIDTH-8)],
                      c1_ddr3_dq_sdram[C1_DQ_WIDTH-1:(C1_DQ_WIDTH-8)]}),
           .dqs     ({c1_ddr3_dqs_p_sdram[C1_DQS_WIDTH-1],
                      c1_ddr3_dqs_p_sdram[C1_DQS_WIDTH-1]}),
           .dqs_n   ({c1_ddr3_dqs_n_sdram[C1_DQS_WIDTH-1],
                      c1_ddr3_dqs_n_sdram[C1_DQS_WIDTH-1]}),
           .tdqs_n  (),
           .odt     (c1_ddr3_odt_sdram[c1_r])
           );
      end
    end
  endgenerate

endmodule 
