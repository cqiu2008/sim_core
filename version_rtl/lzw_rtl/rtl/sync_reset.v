`timescale 1 ps/1 ps

module sync_reset
(
input        I_reset        ,   // Asynchronous reset
input        I_clk          ,   // System clock
output       O_sync_reset       // Synchronous reset
);

// flip-flop pipeline for reset duration stretch
(* ASYNC_REG = "TRUE" *)reg   [3:0]  R_reset_pipe;  

//---------------------------------------------------------------------------
// reset circuitry
//---------------------------------------------------------------------------
always@(posedge I_clk or posedge I_reset)
begin
    if (I_reset == 1'b1)
        R_reset_pipe <= 4'b1111;
    else
        R_reset_pipe <= {R_reset_pipe[2:0], I_reset};
end

assign O_sync_reset = R_reset_pipe[3] ;

endmodule 