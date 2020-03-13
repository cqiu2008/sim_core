////////////////////////////////////////////////////////////////////////////////////////////////////
//		clk generator
////////////////////////////////////////////////////////////////////////////////////////////////////
//initial begin
//end
always #20.833  xin_osc           =~ xin_osc            ; //   24MHz
always #5       pclk_cru          =~ pclk_cru           ; //  100MHz 
always #500     ls_test_clk_src   =~ ls_test_clk_src    ; //  1MHz
always #500     ls_test_clk_ahb   =~ ls_test_clk_ahb    ; //  1MHz
always #500     ls_test_clk_apb   =~ ls_test_clk_apb    ; //  1MHz
always #500     ls_test_clk_mbist =~ ls_test_clk_mbist  ; //  1MHz

////////////////////////////////////////////////////////////////////////////////////////////////////
//	simulation body	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
//  rst_init;
  pclkdly(300);
  msg = "reset ....";
  reset;
  pclkdly(30000);
  msg = "after reset ....";

 // pd_peri_ckg_con     = {$random} % 48'hffff_ffff_ff  ;
 // pd_peri_srst_con    = {$random} % 48'hffff_ffff_ff  ;
 // pd_core_srst_con    = {$random} % 28'hffff_fff      ;
 // clkdly(30000);
 // pd_peri_ckg_con     = {$random} % 48'hffff_ffff_ff  ;
 // pd_peri_srst_con    = {$random} % 48'hffff_ffff_ff  ;
 // pd_core_srst_con    = {$random} % 28'hffff_fff      ;
 // clkdly(30000);

#300000
  msg = "Complited ....";
  pclkdly(1);
  msg = "Testcase cru has been finished";
  $finish;
end
