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
//  rst_init                                                        ;
  pclkdly(300)                                                      ;
  reset                                                             ;
  pclkdly(30000)                                                    ;
  pd_peri_ckg_con     = 1                                           ; 
  pclkdly(30000)                                                    ;
  pd_peri_ckg_con     = 0                                           ; 
  pclkdly(30000)                                                    ;
  pd_peri_ckg_con     = 1                                           ; 
  pd_peri_ckg_con     = {$random} % 48'hffff_ffff_ff                ;
  pd_peri_srst_con    = {$random} % 48'hffff_ffff_ff                ;
  pd_core_srst_con    = {$random} % 28'hffff_fff                    ;
  pclkdly(30000)                                                    ;
  pd_peri_ckg_con     = {$random} % 48'hffff_ffff_ff                ;
  pd_peri_srst_con    = {$random} % 48'hffff_ffff_ff                ;
  pd_core_srst_con    = {$random} % 28'hffff_fff                    ;
  pclkdly(30000)                                                    ;
#300000
  $display("\033[1;45m Testcase cru_peri has been finished\033[0m") ;
  $finish                                                           ;
end
