////////////////////////////////////////////////////////////////////////////////////////////////////
//  
//  TASKS 
//  
////////////////////////////////////////////////////////////////////////////////////////////////////

// spi_reg :addr 00
// b8:[r ]:slv_ssi_sleep,
// b7:[r ]:slv_ssi_busy,
// b6:[r ]:mst_ssi_sleep,
// b5:[r ]:mst_ssi_busy,
// b4:[rw]:data0_rxd_sel,
// b3:[rw]:input_mask_val,
// b2:[rw]:input_mask_mode,
// b1:[rw]:master_ssin,
// b0:[rw]:master_mode

// reg             pclk                                          ; // APB Clock Signal
// reg             psel                                          ; // APB Peripheral Select Signal
// reg             penable                                       ; // Strobe Signal
// reg             pwrite                                        ; // Write Signal
// reg  [9:0]      paddr                                         ; // Address bus
// reg  [31:0]     pwdata                                        ; // Write data Bus
// wire [31:0]     prdata                                        ; // Read Data Bus
// reg  [31:0]     oprdata                                       ; // Get Read Data bus

////////////////////////////////////////////////////////////////////////////////////////////////////
//  reset 
////////////////////////////////////////////////////////////////////////////////////////////////////
task reset;
  begin
    presetn     = 1'b0      ;
    ssi_rst_n   = 1'b0      ;        
    paddr       = 10'd0     ;
    pwdata      = 32'd0     ; 
    psel        = 1'b0      ;
    penable     = 1'b0      ;
    pwrite      = 1'b0      ;
    #1333
      presetn   = 1'b1      ;
    #1133
      ssi_rst_n = 1'b1      ;        
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  pclkdly 
////////////////////////////////////////////////////////////////////////////////////////////////////
task pclkdly;
  input [31:0]  cnt   ;
  begin
    repeat(cnt)begin
      @(posedge pclk) ;
    end
    #1                ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  writereg 
////////////////////////////////////////////////////////////////////////////////////////////////////
task writereg ;
  input [ 9:0]  ipaddr    ; // Address bus
  input [31:0]  ipwdata   ; // Write data Bus
  begin
  //Setup Time
    paddr   <= ipaddr     ;
    pwdata  <= ipwdata    ;
    psel    <= 1'b1       ;
    penable <= 1'b0       ;
    pwrite  <= 1'b1       ;
    pclkdly(1)            ;
  //Write Time
    psel    <= 1'b1       ;
    penable <= 1'b1       ;
    pwrite  <= 1'b1       ;
    pclkdly(1)            ;
  //Release Time
    psel    <= 1'b0       ;
    penable <= 1'b0       ;
    pwrite  <= 1'b0       ;
    pclkdly(1)            ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  readreg 
////////////////////////////////////////////////////////////////////////////////////////////////////
task readreg ;
  input [ 9:0]  ipaddr    ; // Address bus
  begin
  //Setup Time
    paddr   <= ipaddr     ;
    psel    <= 1'b1       ;
    penable <= 1'b0       ;
    pwrite  <= 1'b0       ;
    pclkdly(1)            ;
  //Read Time
    psel    <= 1'b1       ;
    penable <= 1'b1       ;
    pwrite  <= 1'b0       ;
    pclkdly(1)            ;
  //Get Data Time
    oprdata = prdata      ;
    psel    <= 1'b0       ;
    penable <= 1'b0       ;
    pwrite  <= 1'b0       ;
    pclkdly(1)            ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wregssi_ctrl0
////////////////////////////////////////////////////////////////////////////////////////////////////
// for SPI IP  RTL Parameter
// SSI_MAX_XFER_SIZE = 32
// SSI_SPI_MODE = 0 , (Only single spi mode)
task wregssi_ctrl0; 
  input [ 9: 0]BASE_ADDR      ;
  input        sste           ;// CTRLR0[24] slave select toggle enable
  input [ 1: 0]spi_frf        ;// CTRLR0[22:21] slave frame format 
  input [ 4: 0]dfs_32         ;// CTRLR0[20:16] data frame bits = dfs_32 + 1
  input [ 3: 0]cfs            ;// CTRLR0[15:12] control frame size = cfs + 1
  input        srl            ;// CTRLR0[11]  for testing purposes 
  input        slv_oe         ;// CTRLR0[10]  slv output enable 
  input [ 1: 0]tmod           ;// CTRLR0[9:8] Transfer Mode,==00 T/R,==01 only T ==10 only R
  input        scpol          ;// CTRLR0[7] =0, inactive when serial clock is low 
  input        scph           ;// CTRLR0[6] =0, data valid at 1st edge of serial clk
  input [ 5: 4]frf            ;// CTRLR0[5:4] =0, motorolla spi frame format 
  input [ 3: 0]dfs            ;// CTRLR0[3:0] when SSI_MAX_XFER_SIZE = 16, it is valid 
  reg   [31: 0]regin          ;
  begin
  //set the value for write
    regin[31:25] = 0          ;
    regin[24]    = sste       ;
    regin[23]    = 0          ;
    regin[22:21] = spi_frf    ;
    regin[20:16] = dfs_32     ;
    regin[15:12] = cfs        ;
    regin[11]    = srl        ;
    regin[10]    = slv_oe     ;
    regin[9:8]   = tmod       ;
    regin[7]     = scpol      ;
    regin[6]     = scph       ;
    regin[5:4]   = frf        ;
    regin[3:0]   = dfs        ;
  //write it to apb bus
    writereg(BASE_ADDR+CTRLR0,regin);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wregssi_ctrl1
////////////////////////////////////////////////////////////////////////////////////////////////////
// for SPI IP  RTL Parameter
// SSI_MAX_XFER_SIZE = 32
// SSI_SPI_MODE = 0 , (Only single spi mode)
task wregssi_ctrl1; 
  input [ 9: 0]BASE_ADDR      ;
  input [15: 0]ndf            ;// CTRLR1[15:0] Number of Data Frames 
  reg   [31: 0]regin          ;
  begin
  //set the value for write
    regin[31:16] = 0          ;
    regin[15: 0] = ndf        ; 
  //write it to apb bus
    writereg(BASE_ADDR+CTRLR1,regin);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wregssi_en 
////////////////////////////////////////////////////////////////////////////////////////////////////
task wregssi_en;
  input [ 9: 0]BASE_ADDR      ;
  input        en             ;
  reg   [31: 0]regin          ;
  begin
  //set the value for write
    regin[31:1] = 0           ;
    regin[0]    = en          ;
  //write it to apb bus
    writereg(BASE_ADDR+SSIENR,regin);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wregssi_mwcr(Microwave Control Register, Direction)
////////////////////////////////////////////////////////////////////////////////////////////////////
task wregssi_mwcr; 
  input [ 9: 0]BASE_ADDR      ;
  input        mhs            ;// MWCR[2] Handshake, = 1 handshae   , = 0 no
  input        mdd            ;// MWCR[1] Direction, = 1 transmit   , = 0 received 
  input        mwmod          ;// MWCR[0] sequential,= 1 sequential , = 0 non 
  reg   [31: 0]regin          ;
  begin
  //set the value for write
    regin[31: 3] = 0          ; 
    regin[2]     = mhs        ;
    regin[1]     = mdd        ;
    regin[0]     = mwmod      ;
  //write it to apb bus
    writereg(BASE_ADDR+MWCR,regin);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  rregssi_ser (Slave Enable Register)
////////////////////////////////////////////////////////////////////////////////////////////////////
task rregssi_ser; 
  input [ 9: 0]BASE_ADDR      ;
  begin
  //read it to apb bus
    readreg(BASE_ADDR+SER)  ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wregssi_baudr (Baud Rate Select)
////////////////////////////////////////////////////////////////////////////////////////////////////
task wregssi_baudr; 
  input [ 9: 0]BASE_ADDR      ;
  input [15: 0]sckdv          ;// SSI Clock Divider Fsclk_out = Fssi_clk/sckdv
  reg   [31: 0]regin          ;
  begin
  //set the value for write
    regin[31:16] = 16'd0      ;
    regin[15: 0] = sckdv      ; 
  //write it to apb bus
    writereg(BASE_ADDR+BAUDR,regin);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wregssi_txftlr (Transmit FIFO Threshold Level)
////////////////////////////////////////////////////////////////////////////////////////////////////
// TX_ABW = 5;
task wregssi_txftlr; 
  input [       9: 0]BASE_ADDR      ;
  input [TX_ABW-1: 0]tft            ;// TXFTRL[y:0] Transmit FIFO Threshold 
  reg   [      31: 0]regin          ;
  begin
  //set the value for write
    regin        = tft              ; 
  //write it to apb bus
    writereg(BASE_ADDR+TXFTLR,regin);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  rregssi_txflr (Transmit FIFO Threshold Level)
////////////////////////////////////////////////////////////////////////////////////////////////////
task rregssi_txflr; 
  input [ 9: 0]BASE_ADDR      ;
  begin
  //read it to apb bus
    readreg(BASE_ADDR+TXFLR)  ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wregssi_rxftlr (Receive FIFO Threshold Level)
////////////////////////////////////////////////////////////////////////////////////////////////////
task wregssi_rxftlr; 
  input [       9: 0]BASE_ADDR      ;
  input [RX_ABW-1: 0]rft            ;// RXFTRL[y:0] Receive FIFO Threshold 
  reg   [      31: 0]regin          ;
  begin
  //set the value for write
    regin        = rft              ; 
  //write it to apb bus
    writereg(BASE_ADDR+RXFTLR,regin);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  rregssi_rxflr (Receive FIFO Threshold Level)
////////////////////////////////////////////////////////////////////////////////////////////////////
task rregssi_rxflr; 
  input [ 9: 0]BASE_ADDR      ;
  begin
  //read it to apb bus
    readreg(BASE_ADDR+RXFLR)  ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  rregssi_sr (Status Register)
////////////////////////////////////////////////////////////////////////////////////////////////////
task rregssi_sr; 
  input [ 9: 0]BASE_ADDR      ;
  begin
  //read it to apb bus
    readreg(BASE_ADDR+SR)     ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wregssi_imr (Interrupt Mask Register)
////////////////////////////////////////////////////////////////////////////////////////////////////
task wregssi_imr; 
  input [ 9: 0]BASE_ADDR      ; //IMR =1 not masked , =0 masked for every bit 
  input        mstim          ; //IMR[5],Multi-Master Contention Interrupt 
  input        rxfim          ; //IMR[4],Receive  FIFO Full Interrupt  Mask 
  input        rxoim          ; //IMR[3],Receive  FIFO Overflow Interrupt Mask  
  input        rxuim          ; //IMR[2],Receive  FIFO Underflow Interrupt Mask  
  input        txoim          ; //IMR[1],Transmit FIFO Overflow Interrupt Mask  
  input        txeim          ; //IMR[0],Transmit FIFO Empty Interrupt Mask  
  reg   [31: 0]regin          ;
  begin
  //set the value for write
    regin[31:6] = 0           ; 
    regin[5]    = mstim       ; 
    regin[4]    = rxfim       ; 
    regin[3]    = rxoim       ; 
    regin[2]    = rxuim       ; 
    regin[1]    = txoim       ; 
    regin[0]    = txeim       ; 
  //write it to apb bus
    writereg(BASE_ADDR+IMR,regin);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  rregssi_isr (Interrupt Status Register)
////////////////////////////////////////////////////////////////////////////////////////////////////
task rregssi_isr; 
  input [ 9: 0]BASE_ADDR      ;
  begin
  //read it to apb bus
    readreg(BASE_ADDR+ISR)    ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  rregssi_risr (Raw Interrupt Status Register)
////////////////////////////////////////////////////////////////////////////////////////////////////
task rregssi_risr; 
  input [ 9: 0]BASE_ADDR      ;
  begin
  //read it to apb bus
    readreg(BASE_ADDR+RISR)   ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  rregssi_txoicr(Transmit FIFO Overflow Interrupt Clear Registers)
///////////////////////////////////////////////////////////////////////////////////////////////////
task rregssi_txoicr; 
  input [ 9: 0]BASE_ADDR      ;
  begin
  //read it to apb bus
    readreg(BASE_ADDR+TXOICR) ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  rregssi_rxoicr(Receive FIFO Overflow Interrupt Clear Registers)
///////////////////////////////////////////////////////////////////////////////////////////////////
task rregssi_rxoicr; 
  input [ 9: 0]BASE_ADDR      ;
  begin
  //read it to apb bus
    readreg(BASE_ADDR+RXOICR) ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  rregssi_rxuicr(Receive FIFO Underflow Interrupt Clear Registers)
///////////////////////////////////////////////////////////////////////////////////////////////////
task rregssi_rxuicr; 
  input [ 9: 0]BASE_ADDR      ;
  begin
  //read it to apb bus
    readreg(BASE_ADDR+RXUICR) ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  rregssi_msticr (Multi-Master Interrupt Clear Register)
///////////////////////////////////////////////////////////////////////////////////////////////////
task rregssi_msticr; 
  input [ 9: 0]BASE_ADDR      ;
  begin
  //read it to apb bus
    readreg(BASE_ADDR+MSTICR) ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  rregssi_icr (Interrupt Clear Register)
///////////////////////////////////////////////////////////////////////////////////////////////////
task rregssi_icr; 
  input [ 9: 0]BASE_ADDR      ;
  begin
  //read it to apb bus
    readreg(BASE_ADDR+ICR)    ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wregssi_dmacr (DMA Control Register)
////////////////////////////////////////////////////////////////////////////////////////////////////
task wregssi_dmacr; 
  input [ 9: 0]BASE_ADDR      ;
  input        tdmae          ;// DMACR[1] =1 Transmit DMA Enable  
  input        rdmae          ;// DMACR[0] =1 Receive  DMA Enable  
  reg   [31: 0]regin          ;
  begin
  //set the value for write
    regin[31: 2] = 0          ; 
    regin[1]     = tdmae      ; 
    regin[0]     = rdmae      ; 
  //write it to apb bus
    writereg(BASE_ADDR+DMACR,regin);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wregssi_dmatdlr (DMA Transmit Data Level)
////////////////////////////////////////////////////////////////////////////////////////////////////
task wregssi_dmatdlr; 
  input [       9: 0]BASE_ADDR      ;
  input [TX_ABW-1: 0]dmatdlr        ;// DMATDLR[x:0] Transmit Data Level
  reg   [      31: 0]regin          ;
  begin
  //set the value for write
    regin[31: TX_ABW] = 0           ; 
    regin[TX_ABW-1:0] = dmatdlr     ;
  //write it to apb bus
    writereg(BASE_ADDR+DMATDLR,regin);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wregssi_dmardlr (DMA Receive Data Level)
////////////////////////////////////////////////////////////////////////////////////////////////////
task wregssi_dmardlr; 
  input [       9: 0]BASE_ADDR      ;
  input [RX_ABW-1: 0]dmardlr        ;// DMARDLR[x:0] Receive Data Level
  reg   [      31: 0]regin          ;
  begin
  //set the value for write
    regin[31: RX_ABW] = 0           ; 
    regin[RX_ABW-1:0] = dmardlr     ;
  //write it to apb bus
    writereg(BASE_ADDR+DMARDLR,regin);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  rregssi_idr (Identification Register)
///////////////////////////////////////////////////////////////////////////////////////////////////
task rregssi_idr; 
  input [ 9: 0]BASE_ADDR      ;
  begin
  //read it to apb bus
    readreg(BASE_ADDR+IDR)    ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  rregssi_ssi_version_id (coreKit version ID Register)
///////////////////////////////////////////////////////////////////////////////////////////////////
task rregssi_ssi_version_id; 
  input [ 9: 0]BASE_ADDR      ;
  begin
  //read it to apb bus
    readreg(BASE_ADDR+SSI_VERSION_ID) ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wregssi_drx (for x=0; x<=35, Data register x)
///////////////////////////////////////////////////////////////////////////////////////////////////
// Note: The DR register in the DW_apb_ssi occupied 36 number of 32-bit registers.
//       address locations of memory map to facilitate  AHB burst transfers.
// Writing to any of these address locations has the same effect as pushing the data 
//       from the pwdata bus into the transmit fifo.
// Reading from any of these locations has  the same effect as popping data from the receive
//       fifo onto the prdata bus.
task wregssi_drx; 
  input [ 9: 0]BASE_ADDR      ;
  input [31: 0]drin           ;
  reg   [31: 0]regin          ;
  begin
  //set the value for write
    regin[31: 0] = drin       ; 
  //write it to apb bus
    writereg(BASE_ADDR+DRBASE,regin);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  rregssi_drx (for x=0; x<=35, Data register x)
///////////////////////////////////////////////////////////////////////////////////////////////////
// Note: The DR register in the DW_apb_ssi occupied 36 number of 32-bit registers.
//       address locations of memory map to facilitate  AHB burst transfers.
// Writing to any of these address locations has the same effect as pushing the data 
//       from the pwdata bus into the transmit fifo.
// Reading from any of these locations has  the same effect as popping data from the receive
//       fifo onto the prdata bus.
task rregssi_drx; 
  input [ 9: 0]BASE_ADDR      ;
  reg   [31: 0]regin          ;
  begin
  //read it to apb bus
    readreg(BASE_ADDR+DRBASE)  ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wregssi_rx_sample_dly
////////////////////////////////////////////////////////////////////////////////////////////////////
task wregssi_rx_sample_dly; 
  input [ 9: 0]BASE_ADDR      ;
  input [ 7: 0]rsd            ;// RX_SAMPLE_DLY[7:0] 
  reg   [31: 0]regin          ;
  begin
  //set the value for write
    regin[31: 8] = 0          ; 
    regin[ 7: 0] = rsd        ; 
  //write it to apb bus
    writereg(BASE_ADDR+RX_SAMPLE_DLY,regin);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wregssi_spi_ctrlr0 (SPI Control Register)
////////////////////////////////////////////////////////////////////////////////////////////////////
task wregssi_spi_ctrlr0; 
  input [ 9: 0]BASE_ADDR      ;
  input        spi_rxds_en    ;// SPI_CTRLR0[18] Read data strobe enable bit 
  input        inst_ddr_en    ;// SPI_CTRLR0[17] Instruction DDR Enable bit 
  input        spi_ddr_en     ;// SPI_CTRLR0[16] SPI DDR Enable bit
  input [ 4: 0]wait_cycles    ;// SPI_CTRLR0[15:11] Wait cycles 
  input [ 1: 0]inst_l         ;// SPI_CTRLR0[ 9: 8] Instruction Length 
  input [ 3: 0]addr_l         ;// SPI_CTRLR0[ 5: 2] Address Length 
  input [ 1: 0]trans_type     ;// SPI_CTRLR0[ 1: 0] Address and instruction transfer format
  reg   [31: 0]regin          ;
  begin
  //set the value for write
    regin[31:19] = 0          ; 
    regin[18]    = spi_rxds_en; 
    regin[17]    = inst_ddr_en; 
    regin[16]    = spi_ddr_en ; 
    regin[15:11] = wait_cycles; 
    regin[10]    = 0          ; 
    regin[ 9: 8] = inst_l     ; 
    regin[ 7: 6] = 0          ; 
    regin[ 5: 2] = addr_l     ; 
    regin[ 1: 0] = trans_type ;  
  //write it to apb bus
    writereg(BASE_ADDR+SPI_CTRLR0,regin);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wregssi_txd_drive_edge (Transmit Driver Edge Register)
////////////////////////////////////////////////////////////////////////////////////////////////////
task wregssi_txd_drive_edge; 
  input [ 9: 0]BASE_ADDR      ;
  input [ 7: 0]tde            ;// TXD_DRIVE_EDGE[7:0] TXD Drive edge 
  reg   [31: 0]regin          ;
  begin
  //set the value for write
    regin[31: 8] = 0          ; 
    regin[ 7: 0] = tde        ; 
  //write it to apb bus
    writereg(BASE_ADDR+TXD_DRIVE_EDGE,regin);
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wregssi_xxx
////////////////////////////////////////////////////////////////////////////////////////////////////
task wregssi_xxx; 
  input [ 9: 0]BASE_ADDR      ;
  input [15: 0]xxx            ;// CTRLR1[15:0] Number of Data Frames 
  reg   [31: 0]regin          ;
  begin
  //set the value for write
    regin[15: 0] = xxx        ; 
  //write it to apb bus
    writereg(BASE_ADDR+XXX,regin);
  end
endtask

