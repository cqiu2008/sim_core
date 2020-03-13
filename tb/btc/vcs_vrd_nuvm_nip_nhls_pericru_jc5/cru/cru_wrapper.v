module cru_wrapper(
input  wire         ls_test_clk_src                   ,// i
input  wire         ls_test_clk_ahb                   ,// i
input  wire         ls_test_clk_apb                   ,// i
input  wire         ls_test_clk_mbist                 ,// i
input  wire         occ_ate_clk_ddr                   ,// i
input  wire         occ_ate_clk_cpub                  ,// i
input  wire         occ_ate_clk_npu                   ,// i
input  wire         npor                              ,// i
input  wire         npor_to_cru                       ,// i
input  wire         rstn_pd                           ,// i 
input  wire         wdt_rstn                          ,// i
input  wire         io_pll_pd                         ,// i
input  wire         soc_test_mode                     ,// i
input  wire         soc_scan_mode                     ,// i
input  wire         soc_mbist_mode                    ,// i
input  wire         mbist_clk_cpub                    ,// i
input  wire         ddr_phy_test_mode                 ,// i
input  wire         soc_scan_ls_mode                  ,// i
input  wire         soc_scan_hs_mode                  ,// i
input  wire         soc_mbist_ls_mode                 ,// i
input  wire         soc_mbist_hs_mode                 ,// i
input  wire [ 1: 0] test_item_sel                     ,// i
input  wire         pll_test_mode                     ,// i
input  wire         saradc_test_mode                  ,// i
input  wire         otgphy_bist_mode                  ,// i
input  wire         efuse_test_mode                   ,// i
input  wire [ 4: 0] testclk_sel_ext                   ,// i
input  wire         tsadc_shut                        ,// i 
input  wire [ 3: 0] warmrstreq                        ,// i ca5 doesn't support this feature. tie to 0;
input  wire [99: 0] shift_in_test_reg                 ,// i
input  wire         shift_sel                         ,// i
input  wire         apll_pwrdwn_pmu                   ,// i
input  wire         pmu_lf_ena                        ,// i switch to 32k
input  wire         pmu_24m_ena                       ,// i switch to osc
input  wire         pmurstn                           ,// i from pmu
input  wire         xin_osc                           ,// i osc clk source 
input  wire         pclk_en_scfg_ao                   ,// i 
input  wire         presetn_scfgao_src                ,// i 
input  wire         clk_rtc32k_from_pvtm              ,// i 
input  wire         clk_rtc32k_from_io                ,// i 
input  wire         pd_ca5_dwn_clk_en                 ,// i from pmu modify 4 --> 1 core 
input  wire         pd_cpub_dwn_clk_en                ,// i from pmu 
input  wire         pd_cpul_dwn_clk_en                ,// i from pmu 
input  wire         pd_npu_dwn_clk_en                 ,// i from pmu 
input  wire         pd_ddr_dwn_clk_en                 ,// i from pmu 
input  wire         pd_isp_dwn_clk_en                 ,// i from pmu 
input  wire         pd_lcdc_dwn_clk_en                ,// i from pmu 
input  wire         pd_otg_dwn_clk_en                 ,// i from pmu 
input  wire         pd_peri_clk_src_gating            ,// i from pmu
input  wire         pd_ca5_dwn_rst_n                  ,// i from pmu modify 4 --> 1 core 
input  wire         pd_cpub_dwn_rst_n                 ,// i from pmu 
input  wire         pd_cpul_dwn_rst_n                 ,// i from pmu 
input  wire         pd_npu_dwn_rst_n                  ,// i from pmu 
input  wire         pd_ddr_dwn_rst_n                  ,// i from pmu 
input  wire         pd_isp_dwn_rst_n                  ,// i from pmu 
input  wire         pd_lcdc_dwn_rst_n                 ,// i from pmu 
input  wire         pd_otg_dwn_rst_n                  ,// i from pmu 
input  wire         pd_ca5_dwn_clkrst_n               ,// i from pmu modify 4 --> 1 core 
input  wire         pd_cpub_dwn_clkrst_n              ,// i from pmu 
input  wire         pd_cpul_dwn_clkrst_n              ,// i from pmu 
input  wire         pd_npu_dwn_clkrst_n               ,// i from pmu 
input  wire         pd_ddr_dwn_clkrst_n               ,// i from pmu 
input  wire         pd_isp_dwn_clkrst_n               ,// i from pmu 
input  wire         pd_lcdc_dwn_clkrst_n              ,// i from pmu 
input  wire         pd_otg_dwn_clkrst_n               ,// i from pmu 
input  wire         clk_otgphy0_ref                   ,// i 
input  wire         clk_otgphy0_utmi                  ,// i 
input  wire         clk_otgphy1_ref                   ,// i 
input  wire         clk_otgphy1_utmi                  ,// i 
input  wire         standbywfi                        ,// i modify 4 to 1
input  wire         standbywfe                        ,// i modify 4 to 1
input  wire         otgphy0_pllck480                  ,// i 
input  wire [15: 0] scfg_ao_peri_ckg_con              ,// i from ao_scfg
input  wire [15: 0] scfg_ao_peri_rst_src              ,// i from ao_scfg
input  wire         sclk_i2s1_masked_pin              ,// i from sclk
input  wire         mclk_i2s1_masked_pin              ,// i from io
input  wire         apll_clk_out                      ,// i	PLL, clock out
input  wire         apll_lkdt                         ,// i	PLL, lock out 
input  wire         io_ca5_swclktck                   ,// i
input  wire         nFIQ                              ,// i    
input  wire         nIRQ                              ,// i 
input  wire [ 3: 0] wfi_ckg_con                       ,// i
input  wire         wfe_ckg_con                       ,// i
input  wire         psel                              ,// cru_ao  i active high 
input  wire         penable                           ,// cru_ao  i active low 
input  wire         pwrite                            ,// cru_ao  i active high 
input  wire [ 7: 0] paddr                             ,// cru_ao  i 
input  wire [31: 0] pwdata                            ,// cru_ao  i 
output reg  [31: 0] prdata                            ,// cru_ao  o 
input  wire         pclk_cru                          ,// cru apb i 
input  wire         presetn_cru                       ,// cru apb i 
input  wire         psel_cru                          ,// cru apb i 
input  wire         penable_cru                       ,// cru apb i 
input  wire         pwrite_cru                        ,// cru apb i 
input  wire [14: 0] paddr_cru                         ,// cru apb i 
input  wire [31: 0] pwdata_cru                        ,// cru apb i 
output wire [31: 0] prdata_cru                         // cru apb o  
);

wire         pmurstn_mask                      ;// o 
wire         clk_rtc_32k                       ;// i
wire         clk_rtc32k                        ;// i
wire         xin_osc_func_div                  ;// i
wire         xin_osc_func                      ;// o
wire         xin_osc_half                      ;// o 
wire         xin_osc_bist                      ;// o
wire         scan_clk_func                     ;// o
wire         scan_clk_ahb                      ;// o
wire         outclock_test                     ;// o
wire [31: 0] pd_ao_srst_con                    ;// i
wire [15: 0] pd_ao_srst_con_tmp                ;// i

assign  pd_ao_srst_con = {16'd0,pd_ao_srst_con_tmp};

wire         glb_sft_pllrst_pd                 ;// o to pd_aocru
wire         glb_1st_srstn_req                 ;// o
wire         glb_2nd_srstn_req                 ;// o
wire         pmu_srstn_req                     ;// o  
wire         scan_clk_apb                      ;// o

wire         chiprstn                          ;// o connect pd_peri 's "chiprstn" signals  
wire         chiprstn_pd_cpub                  ;// o connect pd_cpub 's "chiprstn" signals  
wire         chiprstn_pd_cpul                  ;// o connect pd_cpul 's "chiprstn" signals  
wire         chiprstn_pd_ddr                   ;// o connect pd_ddr  's "chiprstn" signals  
wire         chiprstn_pd_isp                   ;// o connect pd_isp  's "chiprstn" signals   
wire         chiprstn_pd_lcdc                  ;// o connect pd_lcdc 's "chiprstn" signals  
wire         chiprstn_pd_otg                   ;// o connect pd_otg  's "chiprstn" signals  
wire         chiprstn_pd_npu                   ;// o connect pd_npu  's "chiprstn" signals  

wire         prstn_ddrphy                      ;// o connect to io_wrapper's phy 
wire         resetn_ddrphy                     ;// o connect to io_wrapper's phy 
wire         resetn_saradc_phy                 ;// o connect to io_wrapper's phy 
wire         resetn_efuse_phy                  ;// o connect to io_wrapper's phy 
wire         resetn_otgphy0_por                ;// o connect to io_wrapper's phy
wire         resetn_otgphy0_utmi               ;// o connect to io_wrapper's phy
wire         resetn_otgphy1_por                ;// o connect to io_wrapper's phy
wire         resetn_otgphy1_utmi               ;// o connect to io_wrapper's phy

wire [15: 0] cru_sdio_con0                     ;// o connect peripheral sdio delay line
wire [15: 0] cru_sdio_con1                     ;// o connect peripheral sdio delay line
wire [15: 0] cru_emmc_con0                     ;// o connect peripheral sdio delay line
wire [15: 0] cru_emmc_con1                     ;// o connect peripheral sdio delay line
wire [ 3: 0] cru_wfi_ckg_con                   ;// o modify 16 to 4 
wire [ 3: 0] cru_wfe_ckg_con                   ;// o modify 16 to 4
wire [ 3: 0] cru_wfil2_ckg_con                 ;// o modify 16 to 4

wire         clk_cpub_2wrap_occ                ;// o
wire [ 2: 0] aclk_cpub_div_con                 ;// o
wire [ 3: 0] pclk_cpub_div_con                 ;// o
wire [ 3: 0] phclk_cpub_div_con                ;// o new add
wire [14: 0] pd_cpub_ckg_con                   ;// o new modify width                     
wire [31: 0] pd_cpub_srst_con                  ;// o new modify width                                         
wire         cpub_unrst_test                   ;// o

wire         fclk_cpul_2wrap                   ;// o
wire [15: 0] pd_cpul_ckg_con                   ;// o  
wire [15: 0] pd_cpul_srst_con                  ;// o  

wire [15: 0] pd_ddr_ckg_con                    ;// o modify width 
wire [15: 0] pd_ddr_srst_con                   ;// o modify width 
wire         pclk_ddr_2wrap                    ;// o new add 
wire         pclk_ddrphy                       ;// o new add 
wire         clk_ddrphy1x_2wrap_occ            ;// o 
wire         clk24_ddr_mon_2wrap               ;// o

wire [ 7: 0] pd_otg_ckg_con                    ;// o  
wire [ 7: 0] pd_otg_srst_con                   ;// o  
wire [ 7: 0] pd_crypto_ckg_con                 ;// o  
wire [ 7: 0] pd_crypto_srst_con                ;// o  
wire [ 6: 0] pd_gmac_ckg_con                   ;// o add new    
wire         pd_gmac_sel_con                   ;// o add new    
wire         pd_gmac_srst_con                  ;// o add new    
wire [ 3: 0] pclk_gmac_div_con                 ;// o add new pclk divider
wire [ 1: 0] pd_gmac_speed_con                 ;// o add new [0::10M] [1::100M] [default = 1]
wire         clk_rmii_gmac_2wrapper            ;// o add new gmac  
wire         hclk_otg_2wrap                    ;// o otg 
wire         clk_efuse_2wrap                   ;// o

wire         aclk_isp_2wrap                    ;// o from top cru
wire         pclk_isp_2wrap                    ;// o del from top cru 
wire         clk_isp_2wrap                     ;// o from top cru
wire [ 7: 0] pd_isp_ckg_con                    ;// o from top cru
wire [ 7: 0] pd_isp_srst_con                   ;// o from top cru
wire         cam_refclk_iout                   ;// o

wire         aclk_lcdc_2wrap                   ;// o
wire         mclk_lcdc_2wrap                   ;// o
wire         dclk_lcdc_2wrap                   ;// o pixel clock
wire [ 7: 0] pd_lcdc_ckg_con                   ;// o
wire [ 7: 0] pd_lcdc_srst_con                  ;// o
wire [ 3: 0] pclk_lcdc_div_con                 ;// o

wire         xclk_npu_2wrap_occ                ;// o 
wire [ 7: 0] pd_npu_ckg_con                    ;// o  
wire [ 7: 0] pd_npu_srst_con                   ;// o  
wire [ 3: 0] pclk_npu_div_con                  ;// o add new  

wire         aclk_peri_2wrap                   ;// o
wire         pclk_peri_2wrap                   ;// o
wire [47: 0] pd_peri_ckg_con                   ;// o
wire [ 7: 0] pd_misc_ckg_con                   ;// o add new
wire [47: 0] pd_peri_srst_con                  ;// o modify witdh 63->47
wire [ 7: 0] pd_misc_srst_con                  ;// o add new
wire [31: 0] pd_core_srst_con                  ;// o add new

wire         pclk_ao_2wrap                     ;// o connect to cru_ao

wire         clk_saradc_2wrap                  ;// o
wire         clk_gpio_2wrap                    ;// o
wire         clk_timerx6_ns_2wrap              ;// o
wire         clk_timerx2_s_2wrap               ;// o

wire         clk_2x_hqspi_2wrap                ;// o add new
wire         clk_spi1_2wrap                    ;// o
wire         clk_spi0_2wrap                    ;// o 
wire         clk_2x_emmc_2wrap                 ;// o
wire         clk_2x_sdio_2wrap                 ;// o
wire         clk_i2c0_2wrap                    ;// o  
wire         clk_i2c1_2wrap                    ;// o  
wire         clk_i2c2_2wrap                    ;// o  
wire         clk_i2c3_2wrap                    ;// o  
wire         clk_i2c4_2wrap                    ;// o add new  
wire         clk_i2c5_2wrap                    ;// o add new   

wire         sclk_i2s0_to_ao                   ;// o to ao
wire         sclk_i2s0_from_ao                 ;// i from pd_ao
wire         mclk_i2s0_from_ao                 ;// i from pd_ao
wire         sclk_i2s0_masked_pin              ;// i from io
wire         mclk_i2s0_masked_pin              ;// i from io
wire         mclk_i2s0_iout                    ;// o to io
wire         mclk_i2s0_iout_oen                ;// o to io

wire         sclk_i2s1_2wrap                   ;// o to i2s1
wire         mclk_i2s1_iout                    ;// o to io
wire         mclk_i2s1_iout_oen                ;// o to io

wire         clk_can0_2wrap                    ;// o modify 
wire         clk_can1_2wrap                    ;// o add new
wire         mclk_pwm0_2wrap                   ;// o  
wire         mclk_pwm1_2wrap                   ;// o  
wire         mclk_pwm2_2wrap                   ;// o  
wire         mclk_pwm3_2wrap                   ;// o  
wire         mclk_pwm4_2wrap                   ;// o add new  
wire         mclk_pwm5_2wrap                   ;// o add new   
wire         mclk_pwm6_2wrap                   ;// o add new   

wire         clk_uart0_2wrap                   ;// o  
wire         clk_uart1_2wrap                   ;// o  
wire         clk_uart2_2wrap                   ;// o  
wire         clk_uart3_2wrap                   ;// o  
wire         clk_uart4_2wrap                   ;// o add new  
wire         clk_uart5_2wrap                   ;// o add new   

wire         clk_assi0_2wrap                   ;// o add new 
wire         clk_assi1_2wrap                   ;// o add new 
wire         clk_assi2_2wrap                   ;// o add new 
wire         clk_assi3_2wrap                   ;// o add new 

wire [ 3: 0] apll_n                            ;// o	// Input 4-bit divider control pins.
wire [ 7: 0] apll_m                            ;// o	// Feed Back 8-bit divider control pins.
wire         apll_pdrst                        ;// o	// PDRST =0 should be used in normal PLL operation.
wire [ 1: 0] apll_od                           ;// o // Output divider control pin
wire         apll_bp                           ;// o // PLL bypass mode selection

////////////////////////////////////////////////////////////////////////////////////////////////////
//  cru_ao
////////////////////////////////////////////////////////////////////////////////////////////////////
cru_ao U_cru_ao(
.soc_test_mode                ( soc_test_mode         ),// i 
.soc_scan_mode                ( soc_scan_mode         ),// i 
.scan_clk_apb                 ( scan_clk_apb          ),// i 
.scan_clk_func                ( scan_clk_func         ),// i 
.npor                         ( npor                  ),// i 
.npor_to_cru                  ( npor_to_cru           ),// i 
.rstn_pd                      ( rstn_pd               ),// i 
.pd_ao_srst_con               ( pd_ao_srst_con        ),// i 
.pclk_ao_2wrap                ( pclk_ao_2wrap         ),// i clk source
.psel                         ( psel                  ),// i active high 
.penable                      ( penable               ),// i active low 
.pwrite                       ( pwrite                ),// i active high 
.paddr                        ( paddr                 ),// i 
.pwdata                       ( pwdata                ),// i 
.prdata                       ( prdata                ),// o 
.pmurstn_mask                 ( pmurstn_mask          ),// o 
.pmu_lf_ena                   ( pmu_lf_ena            ),// i switch to 32k
.pmu_24m_ena                  ( pmu_24m_ena           ),// i switch to osc
.pmurstn                      ( pmurstn               ),// i from pmu
.xin_osc                      ( xin_osc               ),// i osc clk source 
.sclk_i2s0_to_ao              ( sclk_i2s0_to_ao       ),// i from top cru
.sclk_i2s0_from_ao            ( sclk_i2s0_from_ao     ),// o to top cru
.mclk_i2s0_from_ao            ( mclk_i2s0_from_ao     ),// o to top cru
.sclk_i2s0_masked_pin         ( sclk_i2s0_masked_pin  ),// i from io
.mclk_i2s0_masked_pin         ( mclk_i2s0_masked_pin  ),// i from io
.mclk_i2s0_iout               ( mclk_i2s0_iout        ),// o to io
.mclk_i2s0_iout_oen           ( mclk_i2s0_iout_oen    ),// o to io
.pclk_en_scfg_ao              ( pclk_en_scfg_ao       ),// i 
.presetn_scfgao_src           ( presetn_scfgao_src    ),// i 
.prstn_pmu                    ( prstn_pmu             ),// o 
.prstn_gpio0                  ( prstn_gpio0           ),// o 
.prstn_uart0                  ( prstn_uart0           ),// o 
.s_rst_n_uart0                ( s_rst_n_uart0         ),// o 
.prstn_timerx2                ( prstn_timerx2         ),// o 
.prstn_sram                   ( prstn_sram            ),// o 
.prstn_cfg_ao                 ( prstn_cfg_ao          ),// o 
.prstn_i2s0                   ( prstn_i2s0            ),// o 
.prstn_scfg_ao                ( prstn_scfg_ao         ),// o 
.hrstn_vad                    ( hrstn_vad             ),// o 
.sysao_reset_ni_sgn           ( sysao_reset_ni_sgn    ),// o 
.srstn_i2s0                   ( srstn_i2s0            ),// o 
.resetn_pvtm                  ( resetn_pvtm           ),// o 
.resetn_vad                   ( resetn_vad            ),// o 
.dbclk_res_n_gpio0            ( dbclk_res_n_gpio0     ),// o 
.dbclk_gpio0                  ( dbclk_gpio0           ),// o 
.sclk_uart0                   ( sclk_uart0            ),// o 
.sclk_i2s0                    ( sclk_i2s0             ),// o 
.sclkn_i2s0                   ( sclkn_i2s0            ),// o 
.clk_pvtm                     ( clk_pvtm              ),// o 
.clk_timer0                   ( clk_timer0            ),// o 
.clk_timer1                   ( clk_timer1            ),// o 
.pclk_pmu                     ( pclk_pmu              ),// o 
.pclk_gpio0                   ( pclk_gpio0            ),// o 
.pclk_uart0                   ( pclk_uart0            ),// o 
.pclk_timerx2                 ( pclk_timerx2          ),// o 
.pclk_sram                    ( pclk_sram             ),// o 
.pclk_cfg_ao                  ( pclk_cfg_ao           ),// o 
.pclk_scfg_ao                 ( pclk_scfg_ao          ),// o 
.pclk_i2s0                    ( pclk_i2s0             ),// o 
.clk_vad                      ( clk_vad               ),// o 
.hclk_vad                     ( hclk_vad              ),// o 
.pclk_sgn                     ( pclk_sgn              ),// o 
.clk_pmu                      ( clk_pmu               ),// o 
.pclk_pdm                     ( pclk_pdm              ),// o add new
.sclk_pdm                     ( sclk_pdm              ),// o add new connect to sys_clk
.prstn_pdm                    ( prstn_pdm             ),// o add new connect to nreset_r
.srstn_pdm                    ( srstn_pdm             ),// o add new connect to nreset_f 
.pclk_i2c0                    ( pclk_i2c0             ),// o add new
.clk_i2c0                     ( clk_i2c0              ),// o add new
.prstn_i2c0                   ( prstn_i2c0            ),// o add new
.i2c0_ic_rstn                 ( i2c0_ic_rstn          ),// o add new
.clk_ibex                     ( clk_ibex              ),// o add new
.ibex_rstn                    ( ibex_rstn             ),// o add new
.clk_rtc                      ( clk_rtc_32k           ),// o add new
.pclk_rtc                     ( pclk_rtc              ),// o add new
.prstn_rtc                    ( prstn_rtc             ),// o add new
.rstn_rtc                     ( rstn_rtc              ),// o add new
.clk_ref_usbphy0              ( clk_ref_usbphy0       ),// o 
.clk_ref_usbphy1              ( clk_ref_usbphy1       ),// o 
.clk_rtc32k_from_pvtm         ( clk_rtc32k_from_pvtm  ),// i 
.clk_rtc32k_from_io           ( clk_rtc32k_from_io    ),// i 
.clk_rtc32k                   ( clk_rtc32k            ),// o  //to top cru&pmu
.xin_osc_func_div             ( xin_osc_func_div      ) // o  //to top cru
);

////////////////////////////////////////////////////////////////////////////////////////////////////
//  cru
////////////////////////////////////////////////////////////////////////////////////////////////////
cru U_cru(
.pclk_cru                     ( pclk_cru                          ),// i
.presetn                      ( presetn_cru                       ),// i
.psel_cru                     ( psel_cru                          ),// i
.penable                      ( penable_cru                       ),// i
.pwrite                       ( pwrite_cru                        ),// i
.paddr                        ( paddr_cru                         ),// i
.pwdata                       ( pwdata_cru                        ),// i
.prdata_cru                   ( prdata_cru                        ),// o 
.ls_test_clk_src              ( ls_test_clk_src                   ),// i
.ls_test_clk_ahb              ( ls_test_clk_ahb                   ),// i
.ls_test_clk_apb              ( ls_test_clk_apb                   ),// i
.ls_test_clk_mbist            ( ls_test_clk_mbist                 ),// i
.occ_ate_clk_ddr              ( occ_ate_clk_ddr                   ),// i
.occ_ate_clk_cpub             ( occ_ate_clk_cpub                  ),// i
.occ_ate_clk_npu              ( occ_ate_clk_npu                   ),// i
.clk_rtc_32k                  ( clk_rtc_32k                       ),// i
.xin_osc                      ( xin_osc                           ),// i from pmu
.xin_osc_func_div             ( xin_osc_func_div                  ),// i
.xin_osc_func                 ( xin_osc_func                      ),// o
.xin_osc_half                 ( xin_osc_half                      ),// o 
.xin_osc_bist                 ( xin_osc_bist                      ),// o
.scan_clk_func                ( scan_clk_func                     ),// o
.scan_clk_ahb                 ( scan_clk_ahb                      ),// o
.scan_clk_apb                 ( scan_clk_apb                      ),// o
.outclock_test                ( outclock_test                     ),// o
.npor                         ( npor                              ),// i
.wdt_rstn                     ( wdt_rstn                          ),// i
.io_pll_pd                    ( io_pll_pd                         ),// i
.pllrstn                      ( pllrstn                           ),// o 
.soc_test_mode                ( soc_test_mode                     ),// i
.ddr_phy_test_mode            ( ddr_phy_test_mode                 ),// i
.soc_scan_ls_mode             ( soc_scan_ls_mode                  ),// i
.soc_scan_hs_mode             ( soc_scan_hs_mode                  ),// i
.soc_mbist_ls_mode            ( soc_mbist_ls_mode                 ),// i
.soc_mbist_hs_mode            ( soc_mbist_hs_mode                 ),// i
.test_item_sel                ( test_item_sel                     ),// i
.pll_test_mode                ( pll_test_mode                     ),// i
.saradc_test_mode             ( saradc_test_mode                  ),// i
.otgphy_bist_mode             ( otgphy_bist_mode                  ),// i
.efuse_test_mode              ( efuse_test_mode                   ),// i
.testclk_sel_ext              ( testclk_sel_ext                   ),// i
.tsadc_shut                   ( tsadc_shut                        ),// i 
.shift_in_test_reg            ( shift_in_test_reg                 ),// i
.shift_sel                    ( shift_sel                         ),// i
.apll_pwrdwn_pmu              ( apll_pwrdwn_pmu                   ),// i
.glb_sft_pllrst_pd            ( glb_sft_pllrst_pd                 ),// o to pd_aocru
.glb_1st_srstn_req            ( glb_1st_srstn_req                 ),// o
.glb_2nd_srstn_req            ( glb_2nd_srstn_req                 ),// o
.pmu_srstn_req                ( pmu_srstn_req                     ),// o  
.pd_ca5_dwn_clk_en            ( pd_ca5_dwn_clk_en                 ),// i from pmu modify 4 --> 1 core 
.pd_cpub_dwn_clk_en           ( pd_cpub_dwn_clk_en                ),// i from pmu 
.pd_cpul_dwn_clk_en           ( pd_cpul_dwn_clk_en                ),// i from pmu 
.pd_npu_dwn_clk_en            ( pd_npu_dwn_clk_en                 ),// i from pmu 
.pd_ddr_dwn_clk_en            ( pd_ddr_dwn_clk_en                 ),// i from pmu 
.pd_isp_dwn_clk_en            ( pd_isp_dwn_clk_en                 ),// i from pmu 
.pd_lcdc_dwn_clk_en           ( pd_lcdc_dwn_clk_en                ),// i from pmu 
.pd_otg_dwn_clk_en            ( pd_otg_dwn_clk_en                 ),// i from pmu 
.pd_peri_clk_src_gating       ( pd_peri_clk_src_gating            ),// i from pmu
.pd_ca5_dwn_rst_n             ( pd_ca5_dwn_rst_n                  ),// i from pmu modify 4 --> 1 core 
.pd_cpub_dwn_rst_n            ( pd_cpub_dwn_rst_n                 ),// i from pmu 
.pd_cpul_dwn_rst_n            ( pd_cpul_dwn_rst_n                 ),// i from pmu 
.pd_npu_dwn_rst_n             ( pd_npu_dwn_rst_n                  ),// i from pmu 
.pd_ddr_dwn_rst_n             ( pd_ddr_dwn_rst_n                  ),// i from pmu 
.pd_isp_dwn_rst_n             ( pd_isp_dwn_rst_n                  ),// i from pmu 
.pd_lcdc_dwn_rst_n            ( pd_lcdc_dwn_rst_n                 ),// i from pmu 
.pd_otg_dwn_rst_n             ( pd_otg_dwn_rst_n                  ),// i from pmu 
.pd_ca5_dwn_clkrst_n          ( pd_ca5_dwn_clkrst_n               ),// i from pmu modify 4 --> 1 core 
.pd_cpub_dwn_clkrst_n         ( pd_cpub_dwn_clkrst_n              ),// i from pmu 
.pd_cpul_dwn_clkrst_n         ( pd_cpul_dwn_clkrst_n              ),// i from pmu 
.pd_npu_dwn_clkrst_n          ( pd_npu_dwn_clkrst_n               ),// i from pmu 
.pd_ddr_dwn_clkrst_n          ( pd_ddr_dwn_clkrst_n               ),// i from pmu 
.pd_isp_dwn_clkrst_n          ( pd_isp_dwn_clkrst_n               ),// i from pmu 
.pd_lcdc_dwn_clkrst_n         ( pd_lcdc_dwn_clkrst_n              ),// i from pmu 
.pd_otg_dwn_clkrst_n          ( pd_otg_dwn_clkrst_n               ),// i from pmu 
.chiprstn                     ( chiprstn                          ),// o connect pd_peri 's "chiprstn" signals  
.chiprstn_pd_cpub             ( chiprstn_pd_cpub                  ),// o connect pd_cpub 's "chiprstn" signals  
.chiprstn_pd_cpul             ( chiprstn_pd_cpul                  ),// o connect pd_cpul 's "chiprstn" signals  
.chiprstn_pd_ddr              ( chiprstn_pd_ddr                   ),// o connect pd_ddr  's "chiprstn" signals  
.chiprstn_pd_isp              ( chiprstn_pd_isp                   ),// o connect pd_isp  's "chiprstn" signals   
.chiprstn_pd_lcdc             ( chiprstn_pd_lcdc                  ),// o connect pd_lcdc 's "chiprstn" signals  
.chiprstn_pd_otg              ( chiprstn_pd_otg                   ),// o connect pd_otg  's "chiprstn" signals  
.chiprstn_pd_npu              ( chiprstn_pd_npu                   ),// o connect pd_npu  's "chiprstn" signals  
.clk_otgphy0_ref              ( clk_otgphy0_ref                   ),// i 
.clk_otgphy0_utmi             ( clk_otgphy0_utmi                  ),// i 
.clk_otgphy1_ref              ( clk_otgphy1_ref                   ),// i 
.clk_otgphy1_utmi             ( clk_otgphy1_utmi                  ),// i 
.prstn_ddrphy                 ( prstn_ddrphy                      ),// o
.resetn_ddrphy                ( resetn_ddrphy                     ),// o connect to io_wrapper's phy 
.resetn_saradc_phy            ( resetn_saradc_phy                 ),// o connect to io_wrapper's phy 
.resetn_efuse_phy             ( resetn_efuse_phy                  ),// o connect to io_wrapper's phy 
.resetn_otgphy0_por           ( resetn_otgphy0_por                ),// o connect to io_wrapper's phy
.resetn_otgphy0_utmi          ( resetn_otgphy0_utmi               ),// o connect to io_wrapper's phy
.resetn_otgphy1_por           ( resetn_otgphy1_por                ),// o connect to io_wrapper's phy
.resetn_otgphy1_utmi          ( resetn_otgphy1_utmi               ),// o connect to io_wrapper's phy
.cru_sdio_con0                ( cru_sdio_con0                     ),// o connect peripheral sdio delay line
.cru_sdio_con1                ( cru_sdio_con1                     ),// o connect peripheral sdio delay line
.cru_emmc_con0                ( cru_emmc_con0                     ),// o connect peripheral sdio delay line
.cru_emmc_con1                ( cru_emmc_con1                     ),// o connect peripheral sdio delay line
.cru_wfi_ckg_con              ( cru_wfi_ckg_con                   ),// o modify 16 to 4 
.cru_wfe_ckg_con              ( cru_wfe_ckg_con                   ),// o modify 16 to 4
.cru_wfil2_ckg_con            ( cru_wfil2_ckg_con                 ),// o modify 16 to 4
.clk_cpub_2wrap_occ           ( clk_cpub_2wrap_occ                ),// o
.aclk_cpub_div_con            ( aclk_cpub_div_con                 ),// o
.pclk_cpub_div_con            ( pclk_cpub_div_con                 ),// o
.phclk_cpub_div_con           ( phclk_cpub_div_con                ),// o new add
.pd_cpub_ckg_con              ( pd_cpub_ckg_con                   ),// o new modify width                     
.pd_cpub_srst_con             ( pd_cpub_srst_con                  ),// o new modify width                                         
.cpub_unrst_test              ( cpub_unrst_test                   ),// o
.standbywfi                   ( standbywfi                        ),// i modify 4 to 1
.standbywfe                   ( standbywfe                        ),// i modify 4 to 1
.fclk_cpul_2wrap              ( fclk_cpul_2wrap                   ),// o
.pd_cpul_ckg_con              ( pd_cpul_ckg_con                   ),// o  
.pd_cpul_srst_con             ( pd_cpul_srst_con                  ),// o  
.pd_ddr_ckg_con               ( pd_ddr_ckg_con                    ),// o modify width 
.pd_ddr_srst_con              ( pd_ddr_srst_con                   ),// o modify width 
.pclk_ddr_2wrap               ( pclk_ddr_2wrap                    ),// i new add 
.pclk_ddrphy                  ( pclk_ddrphy                       ),// i new add 
.clk_ddrphy1x_2wrap_occ       ( clk_ddrphy1x_2wrap_occ            ),// o 
.clk24_ddr_mon_2wrap          ( clk24_ddr_mon_2wrap               ),// o
.otgphy0_pllck480             ( otgphy0_pllck480                  ),// i 
.pd_otg_ckg_con               ( pd_otg_ckg_con                    ),// o  
.pd_otg_srst_con              ( pd_otg_srst_con                   ),// o  
.pd_crypto_ckg_con            ( pd_crypto_ckg_con                 ),// o  
.pd_crypto_srst_con           ( pd_crypto_srst_con                ),// o  
.pd_gmac_ckg_con              ( pd_gmac_ckg_con                   ),// o add new    
.pd_gmac_sel_con              ( pd_gmac_sel_con                   ),// o add new    
.pd_gmac_srst_con             ( pd_gmac_srst_con                  ),// o add new    
.pclk_gmac_div_con            ( pclk_gmac_div_con                 ),// o add new pclk divider
.pd_gmac_speed_con            ( pd_gmac_speed_con                 ),// o add new [0::10M] [1::100M] [default = 1]
.clk_rmii_gmac_2wrapper       ( clk_rmii_gmac_2wrapper            ),// o add new gmac  
.hclk_otg_2wrap               ( hclk_otg_2wrap                    ),// o otg 
.clk_efuse_2wrap              ( clk_efuse_2wrap                   ),// o
.aclk_isp_2wrap               ( aclk_isp_2wrap                    ),// o from top cru
.pclk_isp_2wrap               ( pclk_isp_2wrap                    ),// o del from top cru 
.clk_isp_2wrap                ( clk_isp_2wrap                     ),// o from top cru
.pd_isp_ckg_con               ( pd_isp_ckg_con                    ),// o from top cru
.pd_isp_srst_con              ( pd_isp_srst_con                   ),// o from top cru
.cam_refclk_iout              ( cam_refclk_iout                   ),// o
.aclk_lcdc_2wrap              ( aclk_lcdc_2wrap                   ),// o
.mclk_lcdc_2wrap              ( mclk_lcdc_2wrap                   ),// o
.dclk_lcdc_2wrap              ( dclk_lcdc_2wrap                   ),// o pixel clock
.pd_lcdc_ckg_con              ( pd_lcdc_ckg_con                   ),// o
.pd_lcdc_srst_con             ( pd_lcdc_srst_con                  ),// o
.pclk_lcdc_div_con            ( pclk_lcdc_div_con                 ),// o
.xclk_npu_2wrap_occ           ( xclk_npu_2wrap_occ                ),// o 
.pd_npu_ckg_con               ( pd_npu_ckg_con                    ),// o  
.pd_npu_srst_con              ( pd_npu_srst_con                   ),// o  
.pclk_npu_div_con             ( pclk_npu_div_con                  ),// o add new  
.aclk_peri_2wrap              ( aclk_peri_2wrap                   ),// o
.pclk_peri_2wrap              ( pclk_peri_2wrap                   ),// o
.pd_peri_ckg_con              ( pd_peri_ckg_con                   ),// o
.pd_misc_ckg_con              ( pd_misc_ckg_con                   ),// o add new
.pd_peri_srst_con             ( pd_peri_srst_con                  ),// o modify witdh 63->47
.pd_misc_srst_con             ( pd_misc_srst_con                  ),// o add new
.pd_core_srst_con             ( pd_core_srst_con                  ),// o add new
.scfg_ao_peri_ckg_con         ( scfg_ao_peri_ckg_con              ),// i from ao_scfg
.scfg_ao_peri_rst_src         ( scfg_ao_peri_rst_src              ),// i from ao_scfg
.pclk_ao_2wrap                ( pclk_ao_2wrap                     ),// o connect to cru_ao
.pd_ao_srst_con               ( pd_ao_srst_con_tmp                ),// o
.clk_saradc_2wrap             ( clk_saradc_2wrap                  ),// o
.clk_gpio_2wrap               ( clk_gpio_2wrap                    ),// o
.clk_timerx6_ns_2wrap         ( clk_timerx6_ns_2wrap              ),// o
.clk_timerx2_s_2wrap          ( clk_timerx2_s_2wrap               ),// o
.clk_2x_hqspi_2wrap           ( clk_2x_hqspi_2wrap                ),// o add new
.clk_spi1_2wrap               ( clk_spi1_2wrap                    ),// o
.clk_spi0_2wrap               ( clk_spi0_2wrap                    ),// o 
.clk_2x_emmc_2wrap            ( clk_2x_emmc_2wrap                 ),// o
.clk_2x_sdio_2wrap            ( clk_2x_sdio_2wrap                 ),// o
.clk_i2c0_2wrap               ( clk_i2c0_2wrap                    ),// o  
.clk_i2c1_2wrap               ( clk_i2c1_2wrap                    ),// o  
.clk_i2c2_2wrap               ( clk_i2c2_2wrap                    ),// o  
.clk_i2c3_2wrap               ( clk_i2c3_2wrap                    ),// o  
.clk_i2c4_2wrap               ( clk_i2c4_2wrap                    ),// o add new  
.clk_i2c5_2wrap               ( clk_i2c5_2wrap                    ),// o add new   
.sclk_i2s0_to_ao              ( sclk_i2s0_to_ao                   ),// o to ao
.sclk_i2s0_from_ao            ( sclk_i2s0_from_ao                 ),// i from pd_ao
.mclk_i2s0_from_ao            ( mclk_i2s0_from_ao                 ),// i from pd_ao
.sclk_i2s1_2wrap              ( sclk_i2s1_2wrap                   ),// o to i2s1
.sclk_i2s1_masked_pin         ( sclk_i2s1_masked_pin              ),// i from sclk
.mclk_i2s1_masked_pin         ( mclk_i2s1_masked_pin              ),// i from io
.mclk_i2s1_iout               ( mclk_i2s1_iout                    ),// o to io
.mclk_i2s1_iout_oen           ( mclk_i2s1_iout_oen                ),// o to io
.clk_can0_2wrap               ( clk_can0_2wrap                    ),// o modify 
.clk_can1_2wrap               ( clk_can1_2wrap                    ),// o add new
.mclk_pwm0_2wrap              ( mclk_pwm0_2wrap                   ),// o  
.mclk_pwm1_2wrap              ( mclk_pwm1_2wrap                   ),// o  
.mclk_pwm2_2wrap              ( mclk_pwm2_2wrap                   ),// o  
.mclk_pwm3_2wrap              ( mclk_pwm3_2wrap                   ),// o  
.mclk_pwm4_2wrap              ( mclk_pwm4_2wrap                   ),// o add new  
.mclk_pwm5_2wrap              ( mclk_pwm5_2wrap                   ),// o add new   
.mclk_pwm6_2wrap              ( mclk_pwm6_2wrap                   ),// o add new   
.clk_uart0_2wrap              ( clk_uart0_2wrap                   ),// o  
.clk_uart1_2wrap              ( clk_uart1_2wrap                   ),// o  
.clk_uart2_2wrap              ( clk_uart2_2wrap                   ),// o  
.clk_uart3_2wrap              ( clk_uart3_2wrap                   ),// o  
.clk_uart4_2wrap              ( clk_uart4_2wrap                   ),// o add new  
.clk_uart5_2wrap              ( clk_uart5_2wrap                   ),// o add new   
.clk_assi0_2wrap              ( clk_assi0_2wrap                   ),// o add new 
.clk_assi1_2wrap              ( clk_assi1_2wrap                   ),// o add new 
.clk_assi2_2wrap              ( clk_assi2_2wrap                   ),// o add new 
.clk_assi3_2wrap              ( clk_assi3_2wrap                   ),// o add new 
.apll_clk_out                 ( apll_clk_out                      ),// i	// PLL, clock out
.apll_lkdt                    ( apll_lkdt                         ),// i	// PLL, lock out 
.apll_n                       ( apll_n                            ),// o	// Input 4-bit divider control pins.
.apll_m                       ( apll_m                            ),// o	// Feed Back 8-bit divider control pins.
.apll_pdrst                   ( apll_pdrst                        ),// o	// PDRST =0 should be used in normal PLL operation.
.apll_od                      ( apll_od                           ),// o // Output divider control pin
.apll_bp                      ( apll_bp                           ) // o // PLL bypass mode selection
);

////////////////////////////////////////////////////////////////////////////////////////////////////
//  cru_cpub_wrapper
////////////////////////////////////////////////////////////////////////////////////////////////////
cru_cpub_wrapper U_cru_cpub_wrapper( 
.npor                         ( npor                         ),// i
.soc_test_mode                ( soc_test_mode                ),// i
.soc_scan_mode                ( soc_scan_mode                ),// i
.soc_mbist_mode               ( soc_mbist_mode               ),// i
.scan_clk_func                ( scan_clk_func                ),// i
.mbist_clk_cpub               ( mbist_clk_cpub               ),// i
.pd_cpub_ckg_con              ( pd_cpub_ckg_con              ),// i                       
.pd_cpub_srst_con             ( pd_cpub_srst_con             ),// i  
.aclk_cpub_div_con            ( aclk_cpub_div_con            ),// i
.pclk_cpub_div_con            ( pclk_cpub_div_con            ),// i
.phclk_cpub_div_con           ( phclk_cpub_div_con           ),// i new add periphclk divider
.chiprstn                     ( chiprstn_pd_cpub             ),// i
.clk_cpub_2wrap_occ           ( clk_cpub_2wrap_occ           ),// i core clk source
.pd_ca5_dwn_clk_en            ( pd_ca5_dwn_clk_en            ),// i
.cpub_unrst_test              ( cpub_unrst_test              ),// i
.standbywfi                   ( standbywfi                   ),// i
.standbywfe                   ( standbywfe                   ),// i
.nFIQ                         ( nFIQ                         ),// i    
.nIRQ                         ( nIRQ                         ),// i 
.wfi_ckg_con                  ( wfi_ckg_con                  ),// i
.wfe_ckg_con                  ( wfe_ckg_con                  ),// i
.io_ca5_swclktck              ( io_ca5_swclktck              ),// i
.clk_cpub_g                   ( clk_cpub_g                   ),// o //TO CA5
.clk_swclktck_daplite         ( clk_swclktck_daplite         ),// o //TO DAPLITE
.pclken_dbg                   ( pclken_dbg                   ),// o //TO CA5
.pclkdbg_g                    ( pclkdbg_g                    ),// o add new
.pclksys_daplite              ( pclksys_daplite              ),// o //TO DAPLITE
.pclkdbg_daplite              ( pclkdbg_daplite              ),// o //TO DAPLITE
.nporrst_daplite              ( nporrst_daplite              ),// o 
.prstn_daplite                ( prstn_daplite                ),// o 
.ntrst_daplite                ( ntrst_daplite                ),// o 
.aclken_cpub                  ( aclken_cpub                  ),// o //TO CA5
.l2clk_cpub_g                 ( l2clk_cpub_g                 ),// o add new equal with aclk
.l2clk_sram_g                 ( l2clk_sram_g                 ),// o add new equal with aclk
.periphclk_cpub_g             ( periphclk_cpub_g             ),// o add new 
.periphclken_cpub             ( periphclken_cpub             ),// o add new 
.nperiphreset_cpub            ( nperiphreset_cpub            ),// o add new 
.nsocdbgreset_ca5             ( nsocdbgreset_ca5             ),// o 
.ndbgreset_ca5                ( ndbgreset_ca5                ),// o 
.ncpureset_ca5                ( ncpureset_ca5                ),// o 
.nscureset_ca5                ( nscureset_ca5                ),// o add new 
.netmreset_ca5                ( netmreset_ca5                ),// o add new
.nwdreset_ca5                 ( nwdreset_ca5                 ),// o add new
.nmbistreset_ca5              ( nmbistreset_ca5              ),// o 
.aclk_cpub_sgn                ( aclk_cpub_sgn                ),// o //TO NOC
.pclk_dbg_sgn                 ( pclk_dbg_sgn                 ),// o //TO NOC (sgn&ocp)
.syscpubreset_ni_sgn          ( syscpubreset_ni_sgn          ),// o //TO NOC 
.syscpub_clock_gate_disable_i ( syscpub_clock_gate_disable_i ) // o 
);

endmodule

