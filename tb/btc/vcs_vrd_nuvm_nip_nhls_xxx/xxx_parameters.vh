//*********************************************************
// All timing parameters are in ns

// For IP parameters

// For Registers parameters
parameter ENABLE            = 1'b1    ;
parameter DISABLE           = 1'b0    ;
parameter MST_BASE          = 10'h200 ;  
parameter CTRLR0            = 8'h0    ; //  This register controls the serial data transfer. It is impossible
                                        //  to write to this register when...
