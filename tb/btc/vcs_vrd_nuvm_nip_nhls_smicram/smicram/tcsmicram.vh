////////////////////////////////////////////////////////////////////////////////////////////////////
//		clk generator
////////////////////////////////////////////////////////////////////////////////////////////////////
//initial begin
//end
always #20  clk =~ clk  ; //   25MHz

////////////////////////////////////////////////////////////////////////////////////////////////////
//	simulation body	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
//  rst_init;
  clkdly(300);
  msg = "reset ....";
  reset;
  clkdly(3);
  msg = "after reset ....";
  clkdly(3);
  msg = "write mem 20 data....";
  wmem(20,0,0,3);
  msg = "write mem 123 data....";
  wmem(123,0,40,40);
  msg = "read mem 400 data....";
  rmem(400,0);
  clkdly(300);
  msg = "write mem 20 data with bwen = 32'h5,means reserved the bit0 and bit2";
  wmem(20,32'h5,9'h100,32'hffff_fff0);
  msg = "read mem 20 data with bwen = 32'h5....";
  rmem(20,9'h100);

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
  clkdly(1);
  msg = "Testcase cru has been finished";
  $finish;
end
