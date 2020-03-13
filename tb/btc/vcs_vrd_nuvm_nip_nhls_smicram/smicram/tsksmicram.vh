////////////////////////////////////////////////////////////////////////////////////////////////////
//  TASKS 
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
//  clkdly 
////////////////////////////////////////////////////////////////////////////////////////////////////
task clkdly(bit [31:0]num);
  begin
    repeat(num)begin
      @(posedge clk);
    end
    #1;
  end
endtask

`define CACTIVE 1'b0
`define WACTIVE 1'b0
`define RACTIVE 1'b1
////////////////////////////////////////////////////////////////////////////////////////////////////
// wmem   
// decription
// Signals are latched on the rising-edge of the clock.
// When CEN is low and WEN is high the memory will be in read  operation
// When CEN is low and WEN is low  the memory will be in write operation
// WEN  (     write enable  active 0 )
// BWEN ( bit-write enable  active 0 every bit)
// CEN  (     chip enable   active 0 ) 
// Attention
// BWEN, if you want not change the bit , you shoulde set it 1
// For example , you want write date but not change the  bit0 an bit2
//               you should set the BWEN=32'h5
////////////////////////////////////////////////////////////////////////////////////////////////////
task wmem(
  bit  [31:0]num    ,
  bit  [31:0]bwenIn ,
  logic[31:0]addrIn ,
  logic[31:0]wdataIn
);
  begin
    addr  = addrIn[8:0]   ;
    din   = wdataIn       ;
    bwen  = bwenIn        ; 
    cen   = ~`CACTIVE     ; 
    wr    = ~`WACTIVE     ; 
    repeat(num) begin
      clkdly(1)           ;
      cen   =`CACTIVE     ; 
      wr    =`WACTIVE     ; 
      addr  = addr+1      ;
      din   = din+1       ; 
    end
    clkdly(1)             ;
    cen   = ~`CACTIVE     ; 
    wr    = ~`WACTIVE     ; 
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
// rmem   
////////////////////////////////////////////////////////////////////////////////////////////////////
task rmem(
   bit [31:0]num,
  logic[31:0]addrIn
);
  begin
    addr  = addrIn[8:0]   ;
    bwen  = 32'hffff      ;
    cen   = ~`CACTIVE     ; 
    wr    = ~`RACTIVE     ; 
    repeat(num) begin
      clkdly(1)           ;
      cen   = `CACTIVE    ; 
      wr    = `RACTIVE    ; 
      addr  = addr+1      ;
    end
    clkdly(1)             ;
    cen   = ~`CACTIVE     ; 
    wr    = ~`RACTIVE     ; 
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  reset
////////////////////////////////////////////////////////////////////////////////////////////////////
task reset;
  begin
    //npor        = 1'b1          ;
  end
endtask
