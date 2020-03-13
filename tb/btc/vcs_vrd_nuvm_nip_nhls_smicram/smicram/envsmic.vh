// Ports Declaration
// source clk                                        
reg           clk   ;
reg           cen   ;
reg           wr    ;
reg   [ 8: 0] addr  ;
reg   [31: 0] din   ;
reg   [ 1: 0] dly   ;
reg   [31: 0] bwen  ;
wire  [31: 0] dout  ;

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Initial some signals	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
//initialize some regs that will be used
// source ctrl              
  clk   =  1'b0  ;
  cen   =  1'b0  ;
  wr    =  1'b0  ;
  addr  =  9'b0  ;
  din   = 32'b0  ;
  dly   =  2'b1  ;
  bwen  = 32'b0  ;
end

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Model Instance 
////////////////////////////////////////////////////////////////////////////////////////////////////
smic40ram512x32 U_smic40ram512x32(
  .clk  ( clk  ),
  .cen  ( cen  ),
  .wr   ( wr   ),
  .addr ( addr ),
  .din  ( din  ),
  .dly  ( dly  ),
  .bwen ( bwen ),
  .dout ( dout ) 
);
