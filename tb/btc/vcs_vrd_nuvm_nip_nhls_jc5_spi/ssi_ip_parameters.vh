//*********************************************************
// All timing parameters are in ns

// For IP parameters
parameter TX_ABW = 5;
parameter RX_ABW = 5;

// For Registers parameters
parameter ENABLE            = 1'b1    ;
parameter DISABLE           = 1'b0    ;
parameter MST_BASE          = 10'h200 ;  
parameter SLV_BASE          = 10'h100 ;  
parameter REG_BASE          = 10'h000 ;  
parameter XXX               = 0       ;

parameter CTRLR0            = 8'h0 ;  //  This register controls the serial data transfer. It is impossible
                                      //  to write to this register when...
parameter CTRLR1            = 8'h4 ;  //  This register exists only when the DW_apb_ssi is configured
                                      //  as a master device. When the DW_apb_ssi...
parameter SSIENR            = 8'h8 ;  //  This register enables and disables the DW_apb_ssi. Reset Value: = 8'h0
parameter MWCR              = 8'hc ;  //  This register controls the direction of the data word for the
                                      //  half-duplex Microwire serial protocol....
parameter SER               = 8'h10;  //  This register is valid only when the DW_apb_ssi is
                                      //  configured as a master device. When the DW_apb_ssi...
parameter BAUDR             = 8'h14;  //  This register is valid only when the DW_apb_ssi is
                                      //  configured as a master device. When the DW_apb_ssi...
parameter TXFTLR            = 8'h18;  //  This register controls the threshold value for the transmit
                                      //  FIFO memory. The DW_apb_ssi is enabled...
parameter RXFTLR            = 8'h1c;  //  This register controls the threshold value for the receive
                                      //  FIFO memory. The DW_apb_ssi is enabled...
parameter TXFLR             = 8'h20;  //  This register contains the number of valid data entries in the
                                      //  transmit FIFO memory. Reset Value:...
parameter RXFLR             = 8'h24;  //  This register contains the number of valid data entries in the
                                      //  receive FIFO memory. This register...
parameter SR                = 8'h28;  //  This is a read-only register used to indicate the current
                                      //  transfer status, FIFO status, and any...
parameter IMR               = 8'h2c;  //  This read/write reigster masks or enables all interrupts
                                      //  generated by the DW_apb_ssi. When the DW_apb_ssi...
parameter ISR               = 8'h30;  //  This register reports the status of the DW_apb_ssi interrupts
                                      //  after they have been masked. Reset...
parameter RISR              = 8'h34;  //  This read-only register reports the status of the DW_apb_ssi
                                      //  interrupts prior to masking. Reset...
parameter TXOICR            = 8'h38;  //  Transmit FIFO Overflow Interrupt Clear Register. Reset Value: = 8'h0
parameter RXOICR            = 8'h3c;  //  Receive FIFO Overflow Interrupt Clear Register. Reset Value: = 8'h0
parameter RXUICR            = 8'h40;  //  Receive FIFO Underflow Interrupt Clear Register. Reset Value: = 8'h0
parameter MSTICR            = 8'h44;  //  Multi-Master Interrupt Clear Register. Reset Value: = 8'h0
parameter ICR               = 8'h48;  //  Interrupt Clear Register. Reset Value: = 8'h0
parameter DMACR             = 8'h4c;  //  This register is only valid when DW_apb_ssi is configured
                                      //  with a set of DMA Controller interface...
parameter DMATDLR           = 8'h50;  //  This register is only valid when the DW_apb_ssi is
                                      //  configured with a set of DMA interface signals...
parameter DMARDLR           = 8'h54;  //  This register is only valid when DW_apb_ssi is configured
                                      //  with a set of DMA interface signals (SSI_HAS_DMA...
parameter IDR               = 8'h58;  //  This register contains the peripherals identification code,
                                      //  which is written into the register at...
parameter SSI_VERSION_ID    = 8'h5c;  //  This read-only register stores the specific DW_apb_ssi
                                      //  component version. Reset Value:...
parameter DRBASE            = 8'h60;  //  (for x = 0; x <= 35)  
                                      //  The DW_apb_ssi data register is a 16/32-bit (depending on
                                      //  SSI_MAX_XFER_SIZE) read/write buffer for the...
parameter RX_SAMPLE_DLY     = 8'hf0;  //  This register is only valid when the DW_apb_ssi is
                                      //  configured with rxd sample delay logic
                                      //  (SSI_HAS_RX_SAMPLE_DELAY==1)....
parameter SPI_CTRLR0        = 8'hf4;  //  This register is valid only when SSI_SPI_MODE is either set
                                      //  to "Dual" or "Quad" or "Octal" mode. This...
parameter TXD_DRIVE_EDGE    = 8'hf8;  //  This Register is valid only when SSI_HAS_DDR is equal to
                                      //  1. This register is used to control the...
parameter RSVD              = 8'hfc;  //  RSVD - Reserved address location.

