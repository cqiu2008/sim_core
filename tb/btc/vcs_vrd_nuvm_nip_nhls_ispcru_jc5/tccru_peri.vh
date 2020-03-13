////////////////////////////////////////////////////////////////////////////////////////////////////
//		clk generator
////////////////////////////////////////////////////////////////////////////////////////////////////
//initial begin
//end
always #2.5 aclk_peri_2wrap  =~ aclk_peri_2wrap ;
always #5   pclk_peri_2wrap  =~ pclk_peri_2wrap ;

////////////////////////////////////////////////////////////////////////////////////////////////////
//	simulation body	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
//  rst_init;
  clkdly(300);
  reset;
  clkdly(30000);
  pd_peri_ckg_con     = 1; 
  clkdly(30000);
  pd_peri_ckg_con     = 0; 
  clkdly(30000);
  pd_peri_ckg_con     = 1; 


  pd_peri_ckg_con     = {$random} % 48'hffff_ffff_ff  ;
  pd_peri_srst_con    = {$random} % 48'hffff_ffff_ff  ;
  pd_core_srst_con    = {$random} % 28'hffff_fff      ;
  clkdly(30000);
  pd_peri_ckg_con     = {$random} % 48'hffff_ffff_ff  ;
  pd_peri_srst_con    = {$random} % 48'hffff_ffff_ff  ;
  pd_core_srst_con    = {$random} % 28'hffff_fff      ;
  clkdly(30000);

#300000
  $finish;
end
