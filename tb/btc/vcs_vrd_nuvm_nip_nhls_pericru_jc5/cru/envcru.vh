// Ports Declaration
// source clk                                        
reg          ls_test_clk_src                  ;// i
reg          ls_test_clk_ahb                  ;// i
reg          ls_test_clk_apb                  ;// i
reg          ls_test_clk_mbist                ;// i
reg          occ_ate_clk_ddr                  ;// i
reg          occ_ate_clk_cpub                 ;// i
reg          occ_ate_clk_npu                  ;// i
reg          npor                             ;// i
reg          npor_to_cru                      ;// i
reg          rstn_pd                          ;// i 
reg          wdt_rstn                         ;// i
reg          io_pll_pd                        ;// i
reg          soc_test_mode                    ;// i
reg          soc_scan_mode                    ;// i
reg          soc_mbist_mode                   ;// i
reg          mbist_clk_cpub                   ;// i
reg          ddr_phy_test_mode                ;// i
reg          soc_scan_ls_mode                 ;// i
reg          soc_scan_hs_mode                 ;// i
reg          soc_mbist_ls_mode                ;// i
reg          soc_mbist_hs_mode                ;// i
reg [ 1: 0]  test_item_sel                    ;// i
reg          pll_test_mode                    ;// i
reg          saradc_test_mode                 ;// i
reg          otgphy_bist_mode                 ;// i
reg          efuse_test_mode                  ;// i
reg [ 4: 0]  testclk_sel_ext                  ;// i
reg          tsadc_shut                       ;// i 
reg [ 3: 0]  warmrstreq                       ;// i ca5 doesn't support this feature. tie to 0;
reg [99: 0]  shift_in_test_reg                ;// i
reg          shift_sel                        ;// i
reg          apll_pwrdwn_pmu                  ;// i
reg          pmu_lf_ena                       ;// i switch to 32k
reg          pmu_24m_ena                      ;// i switch to osc
reg          pmurstn                          ;// i from pmu
reg          xin_osc                          ;// i osc clk source 
reg          pclk_en_scfg_ao                  ;// i 
reg          presetn_scfgao_src               ;// i 
reg          clk_rtc32k_from_pvtm             ;// i 
reg          clk_rtc32k_from_io               ;// i 
reg          pd_ca5_dwn_clk_en                ;// i from pmu modify 4 --> 1 core 
reg          pd_cpub_dwn_clk_en               ;// i from pmu 
reg          pd_cpul_dwn_clk_en               ;// i from pmu 
reg          pd_npu_dwn_clk_en                ;// i from pmu 
reg          pd_ddr_dwn_clk_en                ;// i from pmu 
reg          pd_isp_dwn_clk_en                ;// i from pmu 
reg          pd_lcdc_dwn_clk_en               ;// i from pmu 
reg          pd_otg_dwn_clk_en                ;// i from pmu 
reg          pd_peri_clk_src_gating           ;// i from pmu
reg          pd_ca5_dwn_rst_n                 ;// i from pmu modify 4 --> 1 core 
reg          pd_cpub_dwn_rst_n                ;// i from pmu 
reg          pd_cpul_dwn_rst_n                ;// i from pmu 
reg          pd_npu_dwn_rst_n                 ;// i from pmu 
reg          pd_ddr_dwn_rst_n                 ;// i from pmu 
reg          pd_isp_dwn_rst_n                 ;// i from pmu 
reg          pd_lcdc_dwn_rst_n                ;// i from pmu 
reg          pd_otg_dwn_rst_n                 ;// i from pmu 
reg          pd_ca5_dwn_clkrst_n              ;// i from pmu modify 4 --> 1 core 
reg          pd_cpub_dwn_clkrst_n             ;// i from pmu 
reg          pd_cpul_dwn_clkrst_n             ;// i from pmu 
reg          pd_npu_dwn_clkrst_n              ;// i from pmu 
reg          pd_ddr_dwn_clkrst_n              ;// i from pmu 
reg          pd_isp_dwn_clkrst_n              ;// i from pmu 
reg          pd_lcdc_dwn_clkrst_n             ;// i from pmu 
reg          pd_otg_dwn_clkrst_n              ;// i from pmu 
reg          clk_otgphy0_ref                  ;// i 
reg          clk_otgphy0_utmi                 ;// i 
reg          clk_otgphy1_ref                  ;// i 
reg          clk_otgphy1_utmi                 ;// i 
reg          standbywfi                       ;// i modify 4 to 1
reg          standbywfe                       ;// i modify 4 to 1
reg          nFIQ                             ;// i    
reg          nIRQ                             ;// i 
reg [ 3: 0]  wfi_ckg_con                      ;// i
reg          wfe_ckg_con                      ;// i
reg          otgphy0_pllck480                 ;// i 
reg          clk_rmgii_extio                  ;// i 
reg [15: 0]  scfg_ao_peri_ckg_con             ;// i from ao_scfg
reg [15: 0]  scfg_ao_peri_rst_src             ;// i from ao_scfg
reg          sclk_i2s1_masked_pin             ;// i from sclk
reg          mclk_i2s1_masked_pin             ;// i from io
reg          apll_clk_out                     ;// i	PLL, clock out
reg          apll_lkdt                        ;// i	PLL, lock out 
reg          io_ca5_swclktck                  ;// i
reg          psel                             ;// cru_ao  i active high 
reg          penable                          ;// cru_ao  i active low 
reg          pwrite                           ;// cru_ao  i active high 
reg [ 7: 0]  paddr                            ;// cru_ao  i 
reg [31: 0]  pwdata                           ;// cru_ao  i 
reg          pclk_cru                         ;// cru apb i 
reg          presetn_cru                      ;// cru apb i 
reg          psel_cru                         ;// cru apb i 
reg          penable_cru                      ;// cru apb i 
reg          pwrite_cru                       ;// cru apb i 
reg  [14: 0] paddr_cru                        ;// cru apb i 
reg  [31: 0] pwdata_cru                       ;// cru apb i 
wire [31: 0] prdata                           ;// cru_ao  o 
wire [31: 0] prdata_cru                       ;// cru apb o  

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Initial some signals	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
//initialize some regs that will be used
// source ctrl              
  ls_test_clk_src         = 1'b0    ;// i
  ls_test_clk_ahb         = 1'b0    ;// i
  ls_test_clk_apb         = 1'b0    ;// i
  ls_test_clk_mbist       = 1'b0    ;// i
  occ_ate_clk_ddr         = 1'b0    ;// i
  occ_ate_clk_cpub        = 1'b0    ;// i
  occ_ate_clk_npu         = 1'b0    ;// i
  npor                    = 1'b0    ;// i
  npor_to_cru             = 1'b0    ;// i
  rstn_pd                 = 1'b0    ;// i 
  wdt_rstn                = 1'b0    ;// i
  io_pll_pd               = 1'b0    ;// i
  soc_test_mode           = 1'b0    ;// i
  soc_scan_mode           = 1'b0    ;// i
  soc_mbist_mode          = 1'b0    ;// i
  mbist_clk_cpub          = 1'b0    ;// i
  ddr_phy_test_mode       = 1'b0    ;// i
  soc_scan_ls_mode        = 1'b0    ;// i
  soc_scan_hs_mode        = 1'b0    ;// i
  soc_mbist_ls_mode       = 1'b0    ;// i
  soc_mbist_hs_mode       = 1'b0    ;// i
  test_item_sel           = 2'b0    ;// i [ 1: 0]
  pll_test_mode           = 1'b0    ;// i
  saradc_test_mode        = 1'b0    ;// i
  otgphy_bist_mode        = 1'b0    ;// i
  efuse_test_mode         = 1'b0    ;// i
  testclk_sel_ext         = 5'b0    ;// i [ 4: 0]
  tsadc_shut              = 1'b0    ;// i 
  shift_in_test_reg       = 100'd0  ;// i [99: 0] 
  shift_sel               = 1'b0    ;// i
  apll_pwrdwn_pmu         = 1'b0    ;// i
  pmu_lf_ena              = 1'b0    ;// i switch to 32k
  pmu_24m_ena             = 1'b0    ;// i switch to osc
  pmurstn                 = 1'b0    ;// i from pmu
  xin_osc                 = 1'b0    ;// i osc clk source 
  pclk_en_scfg_ao         = 1'b0    ;// i 
  presetn_scfgao_src      = 1'b0    ;// i 
  clk_rtc32k_from_pvtm    = 1'b0    ;// i 
  clk_rtc32k_from_io      = 1'b0    ;// i 
  pd_ca5_dwn_clk_en       = 1'b0    ;// i from pmu modify 4 --> 1 core 
  pd_cpub_dwn_clk_en      = 1'b0    ;// i from pmu 
  pd_cpul_dwn_clk_en      = 1'b0    ;// i from pmu 
  pd_npu_dwn_clk_en       = 1'b0    ;// i from pmu 
  pd_ddr_dwn_clk_en       = 1'b0    ;// i from pmu 
  pd_isp_dwn_clk_en       = 1'b0    ;// i from pmu 
  pd_lcdc_dwn_clk_en      = 1'b0    ;// i from pmu 
  pd_otg_dwn_clk_en       = 1'b0    ;// i from pmu 
  pd_peri_clk_src_gating  = 1'b0    ;// i from pmu
  pd_ca5_dwn_rst_n        = 1'b0    ;// i from pmu modify 4 --> 1 core 
  pd_cpub_dwn_rst_n       = 1'b0    ;// i from pmu 
  pd_cpul_dwn_rst_n       = 1'b0    ;// i from pmu 
  pd_npu_dwn_rst_n        = 1'b0    ;// i from pmu 
  pd_ddr_dwn_rst_n        = 1'b0    ;// i from pmu 
  pd_isp_dwn_rst_n        = 1'b0    ;// i from pmu 
  pd_lcdc_dwn_rst_n       = 1'b0    ;// i from pmu 
  pd_otg_dwn_rst_n        = 1'b0    ;// i from pmu 
  pd_ca5_dwn_clkrst_n     = 1'b0    ;// i from pmu modify 4 --> 1 core 
  pd_cpub_dwn_clkrst_n    = 1'b0    ;// i from pmu 
  pd_cpul_dwn_clkrst_n    = 1'b0    ;// i from pmu 
  pd_npu_dwn_clkrst_n     = 1'b0    ;// i from pmu 
  pd_ddr_dwn_clkrst_n     = 1'b0    ;// i from pmu 
  pd_isp_dwn_clkrst_n     = 1'b0    ;// i from pmu 
  pd_lcdc_dwn_clkrst_n    = 1'b0    ;// i from pmu 
  pd_otg_dwn_clkrst_n     = 1'b0    ;// i from pmu 
  clk_otgphy0_ref         = 1'b0    ;// i 
  clk_otgphy0_utmi        = 1'b0    ;// i 
  clk_otgphy1_ref         = 1'b0    ;// i 
  clk_otgphy1_utmi        = 1'b0    ;// i 
  standbywfi              = 1'b0    ;// i modify 4 to 1
  standbywfe              = 1'b0    ;// i modify 4 to 1
  nFIQ                    = 1'b0    ;// i    
  nIRQ                    = 1'b0    ;// i 
  wfi_ckg_con             = 4'b0    ;// i
  wfe_ckg_con             = 1'b0    ;// i
  otgphy0_pllck480        = 1'b0    ;// i 
  clk_rmgii_extio         = 1'b0    ;// i 
  scfg_ao_peri_ckg_con    = 16'b0   ;// i[15: 0] from ao_scfg
  scfg_ao_peri_rst_src    = 16'b0   ;// i[15: 0] from ao_scfg
  sclk_i2s1_masked_pin    = 1'b0    ;// i from sclk
  mclk_i2s1_masked_pin    = 1'b0    ;// i from io
  apll_clk_out            = 1'b0    ;// i	PLL, clock out
  apll_lkdt               = 1'b0    ;// i	PLL, lock out 
  io_ca5_swclktck         = 1'b0    ;// i
  psel                    = 1'b0    ;// cru_ao  i active high 
  penable                 = 1'b0    ;// cru_ao  i active low 
  pwrite                  = 1'b0    ;// cru_ao  i active high 
  paddr                   = 8'b0    ;// cru_ao  i[ 7: 0] 
  pwdata                  = 32'b0   ;// cru_ao  i[31: 0] 
  pclk_cru                = 1'b0    ;// cru apb i 
  presetn_cru             = 1'b0    ;// cru apb i 
  psel_cru                = 1'b0    ;// cru apb i 
  penable_cru             = 1'b0    ;// cru apb i 
  pwrite_cru              = 1'b0    ;// cru apb i 
  paddr_cru               = 15'b0   ;// cru apb i[14: 0]
  pwdata_cru              = 32'b0   ;// cru apb i[31: 0]
end

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Model Instance 
////////////////////////////////////////////////////////////////////////////////////////////////////
cru_wrapper U_cru_wrapper(
  .ls_test_clk_src                   ( ls_test_clk_src                ),// i
  .ls_test_clk_ahb                   ( ls_test_clk_ahb                ),// i
  .ls_test_clk_apb                   ( ls_test_clk_apb                ),// i
  .ls_test_clk_mbist                 ( ls_test_clk_mbist              ),// i
  .occ_ate_clk_ddr                   ( occ_ate_clk_ddr                ),// i
  .occ_ate_clk_cpub                  ( occ_ate_clk_cpub               ),// i
  .occ_ate_clk_npu                   ( occ_ate_clk_npu                ),// i
  .npor                              ( npor                           ),// i
  .npor_to_cru                       ( npor_to_cru                    ),// i
  .rstn_pd                           ( rstn_pd                        ),// i 
  .wdt_rstn                          ( wdt_rstn                       ),// i
  .io_pll_pd                         ( io_pll_pd                      ),// i
  .soc_test_mode                     ( soc_test_mode                  ),// i
  .soc_scan_mode                     ( soc_scan_mode                  ),// i
  .soc_mbist_mode                    ( soc_mbist_mode                 ),// i
  .mbist_clk_cpub                    ( mbist_clk_cpub                 ),// i
  .ddr_phy_test_mode                 ( ddr_phy_test_mode              ),// i
  .soc_scan_ls_mode                  ( soc_scan_ls_mode               ),// i
  .soc_scan_hs_mode                  ( soc_scan_hs_mode               ),// i
  .soc_mbist_ls_mode                 ( soc_mbist_ls_mode              ),// i
  .soc_mbist_hs_mode                 ( soc_mbist_hs_mode              ),// i
  .test_item_sel                     ( test_item_sel                  ),// i
  .pll_test_mode                     ( pll_test_mode                  ),// i
  .saradc_test_mode                  ( saradc_test_mode               ),// i
  .otgphy_bist_mode                  ( otgphy_bist_mode               ),// i
  .efuse_test_mode                   ( efuse_test_mode                ),// i
  .testclk_sel_ext                   ( testclk_sel_ext                ),// i
  .tsadc_shut                        ( tsadc_shut                     ),// i 
  .warmrstreq                        ( warmrstreq                     ),// i ca5 doesn't support this feature. tie to 0;
  .shift_in_test_reg                 ( shift_in_test_reg              ),// i
  .shift_sel                         ( shift_sel                      ),// i
  .apll_pwrdwn_pmu                   ( apll_pwrdwn_pmu                ),// i
  .pmu_lf_ena                        ( pmu_lf_ena                     ),// i switch to 32k
  .pmu_24m_ena                       ( pmu_24m_ena                    ),// i switch to osc
  .pmurstn                           ( pmurstn                        ),// i from pmu
  .xin_osc                           ( xin_osc                        ),// i osc clk source 
  .pclk_en_scfg_ao                   ( pclk_en_scfg_ao                ),// i 
  .presetn_scfgao_src                ( presetn_scfgao_src             ),// i 
  .clk_rtc32k_from_pvtm              ( clk_rtc32k_from_pvtm           ),// i 
  .clk_rtc32k_from_io                ( clk_rtc32k_from_io             ),// i 
  .pd_ca5_dwn_clk_en                 ( pd_ca5_dwn_clk_en              ),// i from pmu modify 4 --> 1 core 
  .pd_cpub_dwn_clk_en                ( pd_cpub_dwn_clk_en             ),// i from pmu 
  .pd_cpul_dwn_clk_en                ( pd_cpul_dwn_clk_en             ),// i from pmu 
  .pd_npu_dwn_clk_en                 ( pd_npu_dwn_clk_en              ),// i from pmu 
  .pd_ddr_dwn_clk_en                 ( pd_ddr_dwn_clk_en              ),// i from pmu 
  .pd_isp_dwn_clk_en                 ( pd_isp_dwn_clk_en              ),// i from pmu 
  .pd_lcdc_dwn_clk_en                ( pd_lcdc_dwn_clk_en             ),// i from pmu 
  .pd_otg_dwn_clk_en                 ( pd_otg_dwn_clk_en              ),// i from pmu 
  .pd_peri_clk_src_gating            ( pd_peri_clk_src_gating         ),// i from pmu
  .pd_ca5_dwn_rst_n                  ( pd_ca5_dwn_rst_n               ),// i from pmu modify 4 --> 1 core 
  .pd_cpub_dwn_rst_n                 ( pd_cpub_dwn_rst_n              ),// i from pmu 
  .pd_cpul_dwn_rst_n                 ( pd_cpul_dwn_rst_n              ),// i from pmu 
  .pd_npu_dwn_rst_n                  ( pd_npu_dwn_rst_n               ),// i from pmu 
  .pd_ddr_dwn_rst_n                  ( pd_ddr_dwn_rst_n               ),// i from pmu 
  .pd_isp_dwn_rst_n                  ( pd_isp_dwn_rst_n               ),// i from pmu 
  .pd_lcdc_dwn_rst_n                 ( pd_lcdc_dwn_rst_n              ),// i from pmu 
  .pd_otg_dwn_rst_n                  ( pd_otg_dwn_rst_n               ),// i from pmu 
  .pd_ca5_dwn_clkrst_n               ( pd_ca5_dwn_clkrst_n            ),// i from pmu modify 4 --> 1 core 
  .pd_cpub_dwn_clkrst_n              ( pd_cpub_dwn_clkrst_n           ),// i from pmu 
  .pd_cpul_dwn_clkrst_n              ( pd_cpul_dwn_clkrst_n           ),// i from pmu 
  .pd_npu_dwn_clkrst_n               ( pd_npu_dwn_clkrst_n            ),// i from pmu 
  .pd_ddr_dwn_clkrst_n               ( pd_ddr_dwn_clkrst_n            ),// i from pmu 
  .pd_isp_dwn_clkrst_n               ( pd_isp_dwn_clkrst_n            ),// i from pmu 
  .pd_lcdc_dwn_clkrst_n              ( pd_lcdc_dwn_clkrst_n           ),// i from pmu 
  .pd_otg_dwn_clkrst_n               ( pd_otg_dwn_clkrst_n            ),// i from pmu 
  .clk_otgphy0_ref                   ( clk_otgphy0_ref                ),// i 
  .clk_otgphy0_utmi                  ( clk_otgphy0_utmi               ),// i 
  .clk_otgphy1_ref                   ( clk_otgphy1_ref                ),// i 
  .clk_otgphy1_utmi                  ( clk_otgphy1_utmi               ),// i 
  .standbywfi                        ( standbywfi                     ),// i modify 4 to 1
  .standbywfe                        ( standbywfe                     ),// i modify 4 to 1
  .nFIQ                              ( nFIQ                           ),// i    
  .nIRQ                              ( nIRQ                           ),// i 
  .wfi_ckg_con                       ( wfi_ckg_con                    ),// i
  .wfe_ckg_con                       ( wfe_ckg_con                    ),// i
  .otgphy0_pllck480                  ( otgphy0_pllck480               ),// i 
  .clk_rmgii_extio                   ( clk_rmgii_extio                ),// i 
  .scfg_ao_peri_ckg_con              ( scfg_ao_peri_ckg_con           ),// i from ao_scfg
  .scfg_ao_peri_rst_src              ( scfg_ao_peri_rst_src           ),// i from ao_scfg
  .sclk_i2s1_masked_pin              ( sclk_i2s1_masked_pin           ),// i from sclk
  .mclk_i2s1_masked_pin              ( mclk_i2s1_masked_pin           ),// i from io
  .apll_clk_out                      ( apll_clk_out                   ),// i	PLL, clock out
  .apll_lkdt                         ( apll_lkdt                      ),// i	PLL, lock out 
  .io_ca5_swclktck                   ( io_ca5_swclktck                ),// i
  .psel                              ( psel                           ),// cru_ao  i active high 
  .penable                           ( penable                        ),// cru_ao  i active low 
  .pwrite                            ( pwrite                         ),// cru_ao  i active high 
  .paddr                             ( paddr                          ),// cru_ao  i 
  .pwdata                            ( pwdata                         ),// cru_ao  i 
  .prdata                            ( prdata                         ),// cru_ao  o 
  .pclk_cru                          ( pclk_cru                       ),// cru apb i 
  .presetn_cru                       ( presetn_cru                    ),// cru apb i 
  .psel_cru                          ( psel_cru                       ),// cru apb i 
  .penable_cru                       ( penable_cru                    ),// cru apb i 
  .pwrite_cru                        ( pwrite_cru                     ),// cru apb i 
  .paddr_cru                         ( paddr_cru                      ),// cru apb i 
  .pwdata_cru                        ( pwdata_cru                     ),// cru apb i 
  .prdata_cru                        ( prdata_cru                     ) // cru apb o  
);

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Monitor , display the clock frequency number
////////////////////////////////////////////////////////////////////////////////////////////////////
`include "monitor/monitor.vh"
monitor U_MON();

