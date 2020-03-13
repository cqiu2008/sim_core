`timescale 1ns / 1ps
`define IPEN  1

module tb_dut_top;

// `include "xxx_parameters.vh"
//`include "ssi_ip_parameters.vh"
// Ports Declaration
//realtime      tm_sck_neg = 0  ;
reg             rstn            ;//i,system reset
reg             clka            ;//i,clock a
reg             clkb            ;//i,clock b
reg             pulse_a_in      ;//i,pulse input  from clka
wire            pose_b_out      ;//o,posedge output in clkb active only 1 clk in clkb
wire            level_b_out     ;//o,level output in clkb 

parameter C_RANDOM  = 2'b00 ;
parameter C_FIX     = 2'b01 ;   
////////////////////////////////////////////////////////////////////////////////////////////////////
//  Initial some signals	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
  //initialize some regs that will be used
  rstn        = 1'b1  ;
  pulse_a_in  = 1'b0  ;
end

////////////////////////////////////////////////////////////////////////////////////////////////////
//		clk generator
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
  clka        = 1'b0  ;
end

always #13 clka =~clka ;

initial begin
  clkb        = 1'b1  ;
end

//always #({$random} % {8{1'b1}}) clkb =~clkb;
always #(29) clkb =~clkb;

////////////////////////////////////////////////////////////////////////////////////////////////////
//  task 
////////////////////////////////////////////////////////////////////////////////////////////////////

task dly;
  input [31:0] cnt;
  begin
    repeat(cnt) begin
      @(posedge clka);
    end
    #1;
  end
endtask

task reset;
  begin
    rstn = 1'b1 ;
    dly(133);
    rstn = 1'b0 ;
    dly(349);
    rstn = 1'b1 ;
  end
endtask

task pluse_a_in_gen;
  input [ 1:0] type1;
  input [31:0] num;
  input [31:0] times;
  begin
    repeat(times) begin
      case (type1)
        C_RANDOM:begin
            dly($random % 255);
            pulse_a_in = $random % 2; 
        end
        C_FIX   :begin
            pulse_a_in = 1'b0; 
            dly(num);
            pulse_a_in = 1'b1; 
            dly(num);
            pulse_a_in = 1'b0; 
        end
        default :dly(num);
      endcase
    end
  end
endtask


////////////////////////////////////////////////////////////////////////////////////////////////////
//  Model Instance 
////////////////////////////////////////////////////////////////////////////////////////////////////
sync_pulse U_sync_pulse(
  .rstn             (rstn              ),//i,system reset
  .clka             (clka              ),//i,clock a
  .clkb             (clkb              ),//i,clock b
  .pulse_a_in       (pulse_a_in        ),//i,pulse input  from clka
  .pose_b_out       (pose_b_out        ),//o,posedge output in clkb active only 1 clk in clkb
  .level_b_out      (level_b_out       ) //o,level output in clkb 
);

////////////////////////////////////////////////////////////////////////////////////////////////////
//	simulation body	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
  reset;
  pluse_a_in_gen(C_FIX    ,1,1);
  pluse_a_in_gen(C_RANDOM ,1,100);
  #300000
    $finish;
end

////////////////////////////////////////////////////////////////////////////////////////////////////
//  TASKS 
////////////////////////////////////////////////////////////////////////////////////////////////////
//`include xxx_tasks.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////
//  add sub testcase  
////////////////////////////////////////////////////////////////////////////////////////////////////
//`include "subtestcase.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////
//  generate fsdb	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
  $fsdbDumpvars("+fsdbfile+tb_dut_top.fsdb");
	$fsdbDumpMDA;
  $fsdbDumpSVA;
end

endmodule

