`timescale 1ns / 1ps
//`define IPEN  1

`define SMIC40RAM 
//  `define PERICRU 1 

module tb_dut_top;
////////////////////////////////////////////////////////////////////////////////////////////////////
//  Common  
////////////////////////////////////////////////////////////////////////////////////////////////////
reg[1024*8:1] msg = 0               ;

always @( msg ) begin
  //$display("[%t] %0s",$realtime,msg);
  $display("\033[1;45m [%t] %0s \033[0m",$realtime,msg);
end
////////////////////////////////////////////////////////////////////////////////////////////////////
//  Environment 
////////////////////////////////////////////////////////////////////////////////////////////////////
`ifdef SMIC40RAM
  `include "smicram/envsmic.vh"
`endif

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Tasks
////////////////////////////////////////////////////////////////////////////////////////////////////
// task clkdly(bit [31:0]num, ref logic inter_clk);
//   begin
//     repeat(num)begin
//       @(posedge inter_clk);
//     end
//     #1;
//   end
// endtask

`ifdef SMIC40RAM
  `include "smicram/tsksmicram.vh"
`endif

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Testcase 
////////////////////////////////////////////////////////////////////////////////////////////////////
`ifdef SMIC40RAM
  `include "smicram/tcsmicram.vh"
`endif

////////////////////////////////////////////////////////////////////////////////////////////////////
//  generate fsdb	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
  $fsdbDumpvars("+fsdbfile+tb_dut_top.fsdb");
	$fsdbDumpMDA;
  $fsdbDumpSVA;
end

endmodule

