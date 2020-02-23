`timescale 1ns / 1ps
//`define IPEN  1

module tb_dut_top;

//`include "xxx_parameters.vh"
// Ports Declaration
reg         npor                          ;// i
reg         soc_test_mode                 ;// i
reg         soc_scan_mode                 ;// i
reg         soc_mbist_mode                ;// i
// clock from io                          
reg         io_ca5_swclktck               ;// i from jtag external pin
// clock from cru_top                    
reg         chiprstn                      ;// i
reg         scan_clk_func                 ;// i
reg         mbist_clk_cpub                ;// i
reg  [3:0]  pd_ca5_dwn_clk_en             ;// i
reg         clk_cpub_2wrap_occ            ;// i source
reg  [3:0]  pclk_cpub_div_con             ;// i
reg  [2:0]  aclk_cpub_div_con             ;// i
reg  [3:0]  periphclk_div_con             ;// i new ca5 periphclk divide value
reg         cpub_unrst_test               ;// i
reg  [14:0] pd_cpub_ckg_con               ;// i                       
reg  [31:0] pd_cpub_srst_con              ;// i  
reg  [3:0]  standbywfi                    ;// i connect to a5 standbywfi_o only b0 useful
reg  [3:0]  standbywfe                    ;// i connect to a5 standbywfe_o only b0 useful
// reg        standbywfil2                ;// i no l2 cache
reg  [3:0]  nFIQ                          ;// i connect to a5 nfiqout_o
reg  [3:0]  nIRQ                          ;// i connect to a5 nirqout_o  
reg  [15:0] wfi_ckg_con                   ;// i
reg  [15:0] wfe_ckg_con                   ;// i
// reg [15:0] wfil2_ckg_con               ;// i no l2 cache
// clock to ip 
wire        clk_cpub_g                    ;// o connect a5 clk_i
wire        periphclk_g                   ;// o new connect a5 periphclk_i 
wire        periphclken                   ;// o new connect a5 periphclken_i  
wire        aclken_cpub                   ;// o connect a5 aclkens_i , connect a5 aclkenm0_i en 
wire        pclken_dbg                    ;// o connect a5 
wire        aclk_cpub_sgn                 ;// o //TO NOC
wire        pclk_dbg_sgn                  ;// o //TO NOC (sgn&ocp)
wire        pclksys_daplite               ;// o //TO DAPLITE
wire        pclkdbg_daplite               ;// o //TO DAPLITE
wire        clk_swclktck_daplite          ;// o //TO DAPLITE
wire        syscpub_clock_gate_disable_i  ;// o 
// reset to ip
wire [3:0]  ncoreporeset_ca5              ;// o 
wire [3:0]  ncorereset_ca5                ;// o connect a5 ncpureset_i
wire [3:0]  ndbgreset_ca5                 ;// o connect a5 ndbgreset_i
//wire       nl2reset_ca5                 ;// o old connect delete
wire        nmbistreset_ca5               ;// o 
wire        nsocdbgreset_ca5              ;// o connect a5 nosocdbgreset_i 
//wire       netmreset_ca5                ;// o no need connect a5 netmreset_i 
wire        nperiphreset_ca5              ;// o new connect a5 nperiphreset_i
wire        nscureset_ca5                 ;// o new connect a5 scu clk nscureset_i
wire [3:0]  nwdreset_ca5                  ;// o new connect a5 watch dog nwdreset_i
wire        nporrst_daplite               ;// o 
wire        prstn_daplite                 ;// o 
wire        ntrst_daplite                 ;// o 
wire        syscpubreset_ni_sgn           ;// o connect to noc
wire [3:0]  sub_core_clk_en               ;// o  

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Initial some signals	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
  //initialize some regs that will be used
  npor                   = 1'b0       ;// i
  soc_test_mode          = 1'b0       ;// i
  soc_scan_mode          = 1'b0       ;// i
  soc_mbist_mode         = 1'b0       ;// i
  io_ca5_swclktck        = 1'b0       ;// i from jtag external pin
  chiprstn               = 1'b0       ;// i
  scan_clk_func          = 1'b0       ;// i
  mbist_clk_cpub         = 1'b0       ;// i
  pd_ca5_dwn_clk_en      = 4'b0       ;// i
  clk_cpub_2wrap_occ     = 1'b0       ;// i source
  pclk_cpub_div_con      = 4'b0       ;// i
  aclk_cpub_div_con      = 3'b0       ;// i
  periphclk_div_con      = 4'b0       ;// i new ca5 periphclk divide value
  cpub_unrst_test        = 1'b0       ;// i
  pd_cpub_ckg_con        =15'b0       ;// i                       
  pd_cpub_srst_con       =32'b0       ;// i  
  standbywfi             = 4'b0       ;// i connect to a5 standbywfi_o only b0 useful
  standbywfe             = 4'b0       ;// i connect to a5 standbywfe_o only b0 useful
  nFIQ                   = 4'b0       ;// i connect to a5 nfiqout_o
  nIRQ                   = 4'b0       ;// i connect to a5 nirqout_o  
  wfi_ckg_con            =16'b0       ;// i
  wfe_ckg_con            =16'b0       ;// i
end

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Model Instance 
////////////////////////////////////////////////////////////////////////////////////////////////////
cru_cpub_wrapper U_cru_cpub_wrapper( 
.npor                          (npor                          ),// i
.soc_test_mode                 (soc_test_mode                 ),// i
.soc_scan_mode                 (soc_scan_mode                 ),// i
.soc_mbist_mode                (soc_mbist_mode                ),// i
.io_ca5_swclktck               (io_ca5_swclktck               ),// i from jtag external pin
.chiprstn                      (chiprstn                      ),// i
.scan_clk_func                 (scan_clk_func                 ),// i
.mbist_clk_cpub                (mbist_clk_cpub                ),// i
.pd_ca5_dwn_clk_en             (pd_ca5_dwn_clk_en             ),// i
.clk_cpub_2wrap_occ            (clk_cpub_2wrap_occ            ),// i source
.pclk_cpub_div_con             (pclk_cpub_div_con             ),// i
.aclk_cpub_div_con             (aclk_cpub_div_con             ),// i
.periphclk_div_con             (periphclk_div_con             ),// i new ca5 periphclk divide value
.cpub_unrst_test               (cpub_unrst_test               ),// i
.pd_cpub_ckg_con               (pd_cpub_ckg_con               ),// i                       
.pd_cpub_srst_con              (pd_cpub_srst_con              ),// i  
.standbywfi                    (standbywfi                    ),// i connect to a5 standbywfi_o only b0 useful
.standbywfe                    (standbywfe                    ),// i connect to a5 standbywfe_o only b0 useful
.nFIQ                          (nFIQ                          ),// i connect to a5 nfiqout_o
.nIRQ                          (nIRQ                          ),// i connect to a5 nirqout_o  
.wfi_ckg_con                   (wfi_ckg_con                   ),// i
.wfe_ckg_con                   (wfe_ckg_con                   ),// i
.clk_cpub_g                    (clk_cpub_g                    ),// o connect a5 clk_i
.periphclk_g                   (periphclk_g                   ),// o new connect a5 periphclk_i 
.periphclken                   (periphclken                   ),// o new connect a5 periphclken_i  
.aclken_cpub                   (aclken_cpub                   ),// o connect a5 aclkens_i , connect a5 aclkenm0_i en 
.pclken_dbg                    (pclken_dbg                    ),// o connect a5 
.aclk_cpub_sgn                 (aclk_cpub_sgn                 ),// o //TO NOC
.pclk_dbg_sgn                  (pclk_dbg_sgn                  ),// o //TO NOC (sgn&ocp)
.pclksys_daplite               (pclksys_daplite               ),// o //TO DAPLITE
.pclkdbg_daplite               (pclkdbg_daplite               ),// o //TO DAPLITE
.clk_swclktck_daplite          (clk_swclktck_daplite          ),// o //TO DAPLITE
.syscpub_clock_gate_disable_i  (syscpub_clock_gate_disable_i  ),// o 
.ncoreporeset_ca5              (ncoreporeset_ca5              ),// o 
.ncorereset_ca5                (ncorereset_ca5                ),// o connect a5 ncpureset_i
.ndbgreset_ca5                 (ndbgreset_ca5                 ),// o connect a5 ndbgreset_i
.nmbistreset_ca5               (nmbistreset_ca5               ),// o 
.nsocdbgreset_ca5              (nsocdbgreset_ca5              ),// o connect a5 nosocdbgreset_i 
.nperiphreset_ca5              (nperiphreset_ca5              ),// o new connect a5 nperiphreset_i
.nscureset_ca5                 (nscureset_ca5                 ),// o new connect a5 scu clk nscureset_i
.nwdreset_ca5                  (nwdreset_ca5                  ),// o new connect a5 watch dog nwdreset_i
.nporrst_daplite               (nporrst_daplite               ),// o 
.prstn_daplite                 (prstn_daplite                 ),// o 
.ntrst_daplite                 (ntrst_daplite                 ),// o 
.syscpubreset_ni_sgn           (syscpubreset_ni_sgn           ),// o connect to noc
.sub_core_clk_en               (sub_core_clk_en               ) // 
);
//`ifdef IPEN 
//`else
//`endif

////////////////////////////////////////////////////////////////////////////////////////////////////
//		clk generator
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
	xxx = 0;
end
always #10 xxx =~xxx ;

////////////////////////////////////////////////////////////////////////////////////////////////////
//	simulation body	
////////////////////////////////////////////////////////////////////////////////////////////////////
// initial begin
//   rst_init;
// #300000
//   $finish;
// end

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

