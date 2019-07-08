//--------------------------------------------------------------------------------------------------
//File Name    : asyn_fifo 
//Author       : asyn_fifo 
//--------------------------------------------------------------------------------------------------
//Module Hierarchy :
//asyn_fifo_inst |-asyn_fifo
//--------------------------------------------------------------------------------------------------
//Release History :
//Version         Date           Author        Description
// 1.0          2019-01-01       asyn_fifo        1st draft
//--------------------------------------------------------------------------------------------------
//Main Function Tree:
//a)asyn_fifo: 
//Description Function:
//asyn_fifo
//--------------------------------------------------------------------------------------------------
module asyn_fifo #(
        parameter ASIZE = 4 ,
        parameter DSIZE = 8 
        )(
input                   I_wrst    ,
input                   I_wclk    ,
input                   I_winc    ,
input      [DSIZE-1:0]  I_wdata   ,
output reg              O_wfull   ,
input                   I_rrst    ,
input                   I_rclk    ,
input                   I_rinc    ,
output reg [DSIZE-1:0]  O_rdata   ,
output reg              O_rempty    
);

////////////////////////////////////////////////////////////////////////////////////////////////////
// Naming specification                                                                         
// (1) w+"xxx" name type , means write clock domain                                             
//        such as wrst,wclk,winc,wdata, wptr, waddr,wfull, and so on                            
// (2) r+"xxx" name type , means read clock domain                                              
//        such as rrst,rclk,rinc,rdata, rptr, raddr,rempty, and so on                           
// (3) w+q2+"xxx" name type , w means write clock domain, q2 means delay 2 clocks               
//        such as wq2_rptr                                                                      
// (4) r+q2+"xxx" name type , r means read clock domain, q2 means delay 2 clocks                
//        such as rq2_wptr                                                                      
////////////////////////////////////////////////////////////////////////////////////////////////////
wire    [ASIZE-1:0]    S_waddr       ;
reg     [ASIZE  :0]    S_wptr        ;
wire    [ASIZE-1:0]    S_raddr       ;
reg     [ASIZE  :0]    S_rptr        ;
////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                
//    __    __    __    __    __    __    __    __    __    __    __    __    __    __    __    __
// __|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  
//                                                                                                
//                                                                                                
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
//        u0_wptr_full                                                                           
////////////////////////////////////////////////////////////////////////////////////////////////////
reg  [ASIZE  :0] S_wbin        ;
wire [ASIZE  :0] S_wgraynext   ; 
wire [ASIZE  :0] S_wbinnext    ; 
wire             S_wfull_val   ;
reg  [ASIZE  :0] S_rq1_wptr = 0;
reg  [ASIZE  :0] S_rq2_wptr = 0;
reg  [ASIZE  :0] S_wq1_rptr = 0;
reg  [ASIZE  :0] S_wq2_rptr = 0;
// GRAYSTYLE2 pointer
always @(posedge I_wclk)begin
    if(I_wrst)begin
        S_wbin <= 0           	;
        S_wptr <= 0           	;
    end
    else begin
        S_wbin <= S_wbinnext    ;
        S_wptr <= S_wgraynext   ;
    end
end
// Memory write-address pointer (okay to use binary to address memory)
assign S_waddr = S_wbin[ASIZE-1:0];
// wbin add winc when no full 
assign S_wbinnext = S_wbin + (I_winc & ~O_wfull);
// Bin to Gray convert 
assign S_wgraynext = (S_wbinnext >> 1) ^ S_wbinnext;
// Simplified version of the three necessary full-tests
assign S_wfull_val = (S_wgraynext=={~S_wq2_rptr[ASIZE:ASIZE-1],
                                S_wq2_rptr[ASIZE-2:0]});
// Write full 
always @(posedge I_wclk)begin
    if(I_wrst)begin
        O_wfull <= 1'b0;
    end
    else begin
        O_wfull <= S_wfull_val;
    end
end
////////////////////////////////////////////////////////////////////////////////////////////////////
//        u0_fifomem                                                                       
////////////////////////////////////////////////////////////////////////////////////////////////////
// mem assign 
localparam DEPTH = 1 << ASIZE;
(* ram_style="block" *)reg [DSIZE-1:0] mem [0:DEPTH-1];
// write_process
always @(posedge I_wclk)begin
    if(I_winc && (!O_wfull))begin
        mem[S_waddr] <= I_wdata;
    end
end
// read process 
always @(posedge I_rclk)begin
    O_rdata <= mem[S_raddr];
end
////////////////////////////////////////////////////////////////////////////////////////////////////
//        u0_rptr_empty                                                                           
////////////////////////////////////////////////////////////////////////////////////////////////////
reg  [ASIZE  :0] S_rbin        ;
wire [ASIZE  :0] S_rgraynext   ; 
wire [ASIZE  :0] S_rbinnext    ; 
wire             S_rempty_val  ;
// GRAYSTYLE2 pointer
always @(posedge I_rclk)begin
    if(I_rrst)begin
        S_rbin <= 0             ;
        S_rptr <= 0             ;
    end
    else begin
        S_rbin <= S_rbinnext    ;
        S_rptr <= S_rgraynext   ;
    end
end
// Memory read-address pointer (okay to use binary to address memory)
assign S_raddr = S_rbin[ASIZE-1:0];
// rbin add rinc when no empty
assign S_rbinnext = S_rbin + (I_rinc & ~O_rempty);
// Bin to Gray convert 
assign S_rgraynext = (S_rbinnext >> 1) ^ S_rbinnext;
// FIFO empty when the next rptr ==  synchronized wptr or on reset
assign S_rempty_val = (S_rgraynext == S_rq2_wptr);
// O_rempty
always @(posedge I_rclk)begin
    if(I_rrst)begin
        O_rempty <= 1'b1       ;
    end
    else begin
        O_rempty <= S_rempty_val ; 
    end
end
////////////////////////////////////////////////////////////////////////////////////////////////////
//        u0_sync_w2r                                                                                
////////////////////////////////////////////////////////////////////////////////////////////////////
always @(posedge I_rclk)begin
    if(I_rrst)begin
        S_rq1_wptr <= 1'b0          ;
    end
    else begin
        S_rq1_wptr <= S_wptr        ; 
    end
end
always @(posedge I_rclk)begin
    S_rq2_wptr <= S_rq1_wptr    ; 
end
////////////////////////////////////////////////////////////////////////////////////////////////////
//        u0_sync_r2w                                                                             
////////////////////////////////////////////////////////////////////////////////////////////////////
always @(posedge I_wclk)begin
    if(I_wrst)begin
        S_wq1_rptr <= 1'b0          ;
    end
    else begin
        S_wq1_rptr <= S_rptr        ; 
    end
end
always @(posedge I_wclk)begin
    S_wq2_rptr <= S_wq1_rptr    ; 
end

endmodule
