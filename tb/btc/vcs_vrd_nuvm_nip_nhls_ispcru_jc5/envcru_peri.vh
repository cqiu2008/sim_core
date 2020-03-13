// Ports Declaration
// source clk                                        
  reg           aclk_peri_2wrap               ;// i
  reg           pclk_peri_2wrap               ;// i
//reg           aclk_crypto_2wrap             ;// i
// source ctrl                                      
  reg   [ 3:0]  pd_misc_ckg_con               ;// i
  reg   [ 1:0]  pd_misc_srst_con              ;// i
  reg   [46:0]  pd_peri_ckg_con               ;// i
  reg   [46:0]  pd_peri_srst_con              ;// i
  reg   [27:0]  pd_core_srst_con              ;// i
  reg   [15:0]  scfg_ao_peri_rst_src          ;// i from ao_scfg
  reg   [15:0]  scfg_ao_peri_ckg_con          ;// i from ao_scfg
// APB BUS 
// tdm/pdm/i2s                                       
  reg           sclk_i2s1_2wrap               ;// i 
  wire          sclk_i2s1                     ;// o
  wire          sclkn_i2s1                    ;// o
  wire          pclk_i2s1                     ;// o
  wire          prstn_i2s1                    ;// o
  wire          srstn_i2s1                    ;// o
// ipcc
  wire          pclk_ipcc                     ;// o
  wire          prstn_ipcc                    ;// o
// pwm x 6                               
  reg           mclk_pwm0_2wrap               ;// i
  reg           mclk_pwm1_2wrap               ;// i
  reg           mclk_pwm2_2wrap               ;// i
  reg           mclk_pwm3_2wrap               ;// i
  reg           mclk_pwm4_2wrap               ;// i
  reg           mclk_pwm5_2wrap               ;// i
  wire          pclk_pwm0                     ;// o
  wire          pclk_pwm1                     ;// o
  wire          pclk_pwm2                     ;// o
  wire          pclk_pwm3                     ;// o
  wire          pclk_pwm4                     ;// o
  wire          pclk_pwm5                     ;// o
  wire          mclk_pwm0                     ;// o
  wire          mclk_pwm1                     ;// o
  wire          mclk_pwm2                     ;// o
  wire          mclk_pwm3                     ;// o
  wire          mclk_pwm4                     ;// o
  wire          mclk_pwm5                     ;// o
  wire          prstn_pwm0                    ;// o
  wire          prstn_pwm1                    ;// o
  wire          prstn_pwm2                    ;// o
  wire          prstn_pwm3                    ;// o
  wire          prstn_pwm4                    ;// o
  wire          prstn_pwm5                    ;// o
  wire          mrstn_pwm0                    ;// o
  wire          mrstn_pwm1                    ;// o
  wire          mrstn_pwm2                    ;// o
  wire          mrstn_pwm3                    ;// o
  wire          mrstn_pwm4                    ;// o
  wire          mrstn_pwm5                    ;// o
// wdt and wdt_ns                           
  wire          pclk_wdt_s                    ;// o
  wire          prstn_wdt_s                   ;// o
  wire          pclk_wdt_ns                   ;// o
  wire          prstn_wdt_ns                  ;// o
// nstimerx6                                       
  reg           clk_timerx6_ns_2wrap          ;// i
  wire          clk_timerx6_ns                ;// o
  wire          pclk_timerx6_ns               ;// o
  wire          prstn_timerx6_ns              ;// o
// timerx2                                        
  reg           clk_timerx2_s_2wrap           ;// i 
  wire          clk_timerx2_s                 ;// o
  wire          pclk_timerx2_s                ;// o
  wire          prstn_timerx2_s               ;// o
// uart x 5 
  reg           clk_uart1_2wrap               ;// i
  reg           clk_uart2_2wrap               ;// i
  reg           clk_uart3_2wrap               ;// i
  reg           clk_uart4_2wrap               ;// i
  reg           clk_uart5_2wrap               ;// i
  wire          pclk_uart1                    ;// o 
  wire          pclk_uart2                    ;// o 
  wire          pclk_uart3                    ;// o 
  wire          pclk_uart4                    ;// o 
  wire          pclk_uart5                    ;// o 
  wire          sclk_uart1                    ;// o 
  wire          sclk_uart2                    ;// o 
  wire          sclk_uart3                    ;// o 
  wire          sclk_uart4                    ;// o 
  wire          sclk_uart5                    ;// o 
  wire          prstn_uart1                   ;// o 
  wire          prstn_uart2                   ;// o 
  wire          prstn_uart3                   ;// o 
  wire          prstn_uart4                   ;// o 
  wire          prstn_uart5                   ;// o 
  wire          s_rst_n_uart1                 ;// o 
  wire          s_rst_n_uart2                 ;// o 
  wire          s_rst_n_uart3                 ;// o 
  wire          s_rst_n_uart4                 ;// o 
  wire          s_rst_n_uart5                 ;// o 
// i2c x 5 
  reg           clk_i2c1_2wrap                ;// i
  reg           clk_i2c2_2wrap                ;// i
  reg           clk_i2c3_2wrap                ;// i
  reg           clk_i2c4_2wrap                ;// i
  reg           clk_i2c5_2wrap                ;// i
  wire          pclk_i2c1                     ;// o
  wire          pclk_i2c2                     ;// o
  wire          pclk_i2c3                     ;// o
  wire          pclk_i2c4                     ;// o
  wire          pclk_i2c5                     ;// o
  wire          clk_i2c1                      ;// o
  wire          clk_i2c2                      ;// o
  wire          clk_i2c3                      ;// o
  wire          clk_i2c4                      ;// o
  wire          clk_i2c5                      ;// o
  wire          prstn_i2c1                    ;// o
  wire          prstn_i2c2                    ;// o
  wire          prstn_i2c3                    ;// o
  wire          prstn_i2c4                    ;// o
  wire          prstn_i2c5                    ;// o
  wire          i2c1_ic_rstn                  ;// o
  wire          i2c2_ic_rstn                  ;// o
  wire          i2c3_ic_rstn                  ;// o
  wire          i2c4_ic_rstn                  ;// o
  wire          i2c5_ic_rstn                  ;// o
// assi x 4 
  reg           clk_assi0_2wrap               ;// i
  reg           clk_assi1_2wrap               ;// i
  reg           clk_assi2_2wrap               ;// i
  reg           clk_assi3_2wrap               ;// i
  wire          pclk_assi0                    ;// o 
  wire          pclk_assi1                    ;// o 
  wire          pclk_assi2                    ;// o 
  wire          pclk_assi3                    ;// o 
  wire          clk_assi0                     ;// o 
  wire          clk_assi1                     ;// o 
  wire          clk_assi2                     ;// o 
  wire          clk_assi3                     ;// o 
  wire          prstn_assi0                   ;// o 
  wire          prstn_assi1                   ;// o 
  wire          prstn_assi2                   ;// o 
  wire          prstn_assi3                   ;// o 
  wire          rstn_assi0                    ;// o 
  wire          rstn_assi1                    ;// o 
  wire          rstn_assi2                    ;// o 
  wire          rstn_assi3                    ;// o 
// gpio x4 
  reg           clk_gpio_2wrap                ;// i 
  wire          pclk_gpio1                    ;// o
  wire          pclk_gpio2                    ;// o
  wire          pclk_gpio3                    ;// o
  wire          pclk_gpio4                    ;// o
  wire          gpio1_dbclk                   ;// o
  wire          gpio2_dbclk                   ;// o
  wire          gpio3_dbclk                   ;// o
  wire          gpio4_dbclk                   ;// o
  wire          prstn_gpio1                   ;// o
  wire          prstn_gpio2                   ;// o
  wire          prstn_gpio3                   ;// o
  wire          prstn_gpio4                   ;// o
  wire          gpio1_dbclk_res_n             ;// o
  wire          gpio2_dbclk_res_n             ;// o
  wire          gpio3_dbclk_res_n             ;// o
  wire          gpio4_dbclk_res_n             ;// o
// spi x 2
  reg           clk_spi0_2wrap                ;// i 
  reg           clk_spi1_2wrap                ;// i 
  wire          pclk_spi0                     ;// o
  wire          pclk_spi1                     ;// o
  wire          spi0_ssi_clk                  ;// o
  wire          spi1_ssi_clk                  ;// o
  wire          prstn_spi0                    ;// o
  wire          prstn_spi1                    ;// o
  wire          spi0_ssi_rst_n                ;// o
  wire          spi1_ssi_rst_n                ;// o
// AHB/AXI BUS 
// sdio                                        
  reg           clk_2x_sdio_2wrap             ;// i 
  wire          clk_2x_sdio                   ;// o
  wire          hclk_sdio                     ;// o
  wire          hrstn_sdio                    ;// o
// emmc/sd card reuser                                         
  reg           clk_2x_emmc_2wrap             ;// i 
  wire          clk_2x_emmc                   ;// o
  wire          hclk_emmc                     ;// o
  wire          hrstn_emmc                    ;// o
//dmac x2 
  wire          hclk_dmac0                    ;// o
  wire          hclk_dmac1                    ;// o
  wire          hs_clk_dma0                   ;// o 
  wire          hs_clk_dma1                   ;// o 
  wire          hrstn_dmac0                   ;// o
  wire          hrstn_dmac1                   ;// o
  wire          hsrstn_dmac0                  ;// o
  wire          hsrstn_dmac1                  ;// o
// ahb rom (btrom ) 
  wire          hclk_rom                      ;// o connect to ahb rom 
  wire          hrstn_rom                     ;// o
// axi ram (syssram)
  wire          aclk_ram                      ;// o connect to axi_ram
  wire          arstn_ram                     ;// o
// hsem 
  wire          aclk_hsem                     ;// o connect to axi_ram
  wire          arstn_hsem                    ;// o
// hqspi 
  reg           clk_2x_hqspi_2wrap            ;// i 
  wire          pclk_hqspi                    ;// o
  wire          clk_2x_hqspi                  ;// o
  wire          prstn_hqspi                   ;// o
  wire          rstn_hqspi                    ;// o
// IO_WRAPPER
// cfg and scfg                    
  wire          pclk_cfgtop                   ;// o
  wire          prstn_cfgtop                  ;// o
  wire          pclk_scfgtop                  ;// o
  wire          prstn_scfgtop                 ;// o
// efuse                                      
  reg           clk_efuse_2wrap               ;// i 
  wire          clk_efuse                     ;// o
  wire          pclk_efuse_ns                 ;// o
  wire          prstn_efuse_ns                ;// o
  wire          pclk_efuse_s                  ;// o
  wire          prstn_efuse_s                 ;// o
// saradc 
  reg           clk_saradc_2wrap              ;// i 
  wire          clk_saradc                    ;// o
// ddrphy                              
  wire          pclk_ddrphy                   ;// o
  wire          prstn_ddrphy                  ;// o
// top cru top                          
  wire          pclk_crutop                   ;// o
  wire          prstn_crutop                  ;// o
// noc                                
  wire          aclk_sgn                      ;// o
  wire          pclk_sgn                      ;// o
  wire          sysperi_reset_ni_sgn          ;// o 
  wire          sysperi_clock_gate_disable_i  ;//

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Initial some signals	
////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin
//initialize some regs that will be used
// source clk               
  aclk_peri_2wrap           =  1'b0    ;// i
  pclk_peri_2wrap           =  1'b0    ;// i
// source ctrl              
  pd_misc_ckg_con           = 0        ;// i
  pd_misc_srst_con          = 0        ;// i
  pd_core_srst_con          = 0        ;// i 
  pd_peri_srst_con          = 0        ;// i
  pd_peri_ckg_con           = 0        ;// i 
  scfg_ao_peri_rst_src      = 16'b0    ;// i from ao_scfg
  scfg_ao_peri_ckg_con      = 16'b0    ;// i from ao_scfg
// APB BUS 
// tdm/pdm/i2s             
  sclk_i2s1_2wrap           =  1'b0    ;// i 
// pwm x 6                 
  mclk_pwm0_2wrap           =  1'b0    ;// i
  mclk_pwm1_2wrap           =  1'b0    ;// i
  mclk_pwm2_2wrap           =  1'b0    ;// i
  mclk_pwm3_2wrap           =  1'b0    ;// i
  mclk_pwm4_2wrap           =  1'b0    ;// i
  mclk_pwm5_2wrap           =  1'b0    ;// i
// nstimerx6              
  clk_timerx6_ns_2wrap      =  1'b0    ;// i
// timerx2               
  clk_timerx2_s_2wrap       =  1'b0    ;// i 
// uart x 5 
  clk_uart1_2wrap           =  1'b0    ;// i
  clk_uart2_2wrap           =  1'b0    ;// i
  clk_uart3_2wrap           =  1'b0    ;// i
  clk_uart4_2wrap           =  1'b0    ;// i
  clk_uart5_2wrap           =  1'b0    ;// i
// i2c x 5 
  clk_i2c1_2wrap            =  1'b0    ;// i
  clk_i2c2_2wrap            =  1'b0    ;// i
  clk_i2c3_2wrap            =  1'b0    ;// i
  clk_i2c4_2wrap            =  1'b0    ;// i
  clk_i2c5_2wrap            =  1'b0    ;// i
// assi x 4 
  clk_assi0_2wrap           =  1'b0    ;// i
  clk_assi1_2wrap           =  1'b0    ;// i
  clk_assi2_2wrap           =  1'b0    ;// i
  clk_assi3_2wrap           =  1'b0    ;// i
// gpio x4 
  clk_gpio_2wrap            =  1'b0    ;// i 
// spi x 2
  clk_spi0_2wrap            =  1'b0    ;// i 
  clk_spi1_2wrap            =  1'b0    ;// i 
// AHB/AXI BUS 
// sdio                     
  clk_2x_sdio_2wrap         =  1'b0    ;// i 
// emmc/sd card reuser     
  clk_2x_emmc_2wrap         =  1'b0    ;// i 
// hqspi 
  clk_2x_hqspi_2wrap        =  1'b0    ;// i 
// IO_WRAPPER
// efuse                             
  clk_efuse_2wrap           =  1'b0    ;// i 
// saradc 
  clk_saradc_2wrap          =  1'b0    ;// i 
end

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Model Instance 
////////////////////////////////////////////////////////////////////////////////////////////////////
cru_peri_wrapper U_cru_peri_wrapper(
.npor                          (npor                           ),// i                    
.soc_test_mode                 (soc_test_mode                  ),// i
.soc_scan_mode                 (soc_scan_mode                  ),// i
.soc_mbist_mode                (soc_mbist_mode                 ),// i
.scan_clk_ahb                  (scan_clk_ahb                   ),// i
.scan_clk_apb                  (scan_clk_apb                   ),// i
.scan_clk_func                 (scan_clk_func                  ),// i
.chiprstn_top                  (chiprstn_top                   ),// i
.aclk_peri_2wrap               (aclk_peri_2wrap                ),// i
.pclk_peri_2wrap               (pclk_peri_2wrap                ),// i
.pd_misc_ckg_con               (pd_misc_ckg_con                ),// i
.pd_misc_srst_con              (pd_misc_srst_con               ),// i
.pd_core_srst_con              (pd_core_srst_con               ),// i
.pd_peri_srst_con              (pd_peri_srst_con               ),// i
.pd_peri_ckg_con               (pd_peri_ckg_con                ),// i
.scfg_ao_peri_rst_src          (scfg_ao_peri_rst_src           ),// i from ao_scfg
.scfg_ao_peri_ckg_con          (scfg_ao_peri_ckg_con           ),// i from ao_scfg
.sclk_i2s1_2wrap               (sclk_i2s1_2wrap                ),// i 
.sclk_i2s1                     (sclk_i2s1                      ),// o
.sclkn_i2s1                    (sclkn_i2s1                     ),// o
.pclk_i2s1                     (pclk_i2s1                      ),// o
.prstn_i2s1                    (prstn_i2s1                     ),// o
.srstn_i2s1                    (srstn_i2s1                     ),// o
.pclk_ipcc                     (pclk_ipcc                      ),// o
.prstn_ipcc                    (prstn_ipcc                     ),// o
.mclk_pwm0_2wrap               (mclk_pwm0_2wrap                ),// i
.mclk_pwm1_2wrap               (mclk_pwm1_2wrap                ),// i
.mclk_pwm2_2wrap               (mclk_pwm2_2wrap                ),// i
.mclk_pwm3_2wrap               (mclk_pwm3_2wrap                ),// i
.mclk_pwm4_2wrap               (mclk_pwm4_2wrap                ),// i
.mclk_pwm5_2wrap               (mclk_pwm5_2wrap                ),// i
.pclk_pwm0                     (pclk_pwm0                      ),// o
.pclk_pwm1                     (pclk_pwm1                      ),// o
.pclk_pwm2                     (pclk_pwm2                      ),// o
.pclk_pwm3                     (pclk_pwm3                      ),// o
.pclk_pwm4                     (pclk_pwm4                      ),// o
.pclk_pwm5                     (pclk_pwm5                      ),// o
.mclk_pwm0                     (mclk_pwm0                      ),// o
.mclk_pwm1                     (mclk_pwm1                      ),// o
.mclk_pwm2                     (mclk_pwm2                      ),// o
.mclk_pwm3                     (mclk_pwm3                      ),// o
.mclk_pwm4                     (mclk_pwm4                      ),// o
.mclk_pwm5                     (mclk_pwm5                      ),// o
.prstn_pwm0                    (prstn_pwm0                     ),// o
.prstn_pwm1                    (prstn_pwm1                     ),// o
.prstn_pwm2                    (prstn_pwm2                     ),// o
.prstn_pwm3                    (prstn_pwm3                     ),// o
.prstn_pwm4                    (prstn_pwm4                     ),// o
.prstn_pwm5                    (prstn_pwm5                     ),// o
.mrstn_pwm0                    (mrstn_pwm0                     ),// o
.mrstn_pwm1                    (mrstn_pwm1                     ),// o
.mrstn_pwm2                    (mrstn_pwm2                     ),// o
.mrstn_pwm3                    (mrstn_pwm3                     ),// o
.mrstn_pwm4                    (mrstn_pwm4                     ),// o
.mrstn_pwm5                    (mrstn_pwm5                     ),// o
.pclk_wdt_s                    (pclk_wdt_s                     ),// o
.prstn_wdt_s                   (prstn_wdt_s                    ),// o
.pclk_wdt_ns                   (pclk_wdt_ns                    ),// o
.prstn_wdt_ns                  (prstn_wdt_ns                   ),// o
.clk_timerx6_ns_2wrap          (clk_timerx6_ns_2wrap           ),// i
.clk_timerx6_ns                (clk_timerx6_ns                 ),// o
.pclk_timerx6_ns               (pclk_timerx6_ns                ),// o
.prstn_timerx6_ns              (prstn_timerx6_ns               ),// o
.clk_timerx2_s_2wrap           (clk_timerx2_s_2wrap            ),// i 
.clk_timerx2_s                 (clk_timerx2_s                  ),// o
.pclk_timerx2_s                (pclk_timerx2_s                 ),// o
.prstn_timerx2_s               (prstn_timerx2_s                ),// o
.clk_uart1_2wrap               (clk_uart1_2wrap                ),// i
.clk_uart2_2wrap               (clk_uart2_2wrap                ),// i
.clk_uart3_2wrap               (clk_uart3_2wrap                ),// i
.clk_uart4_2wrap               (clk_uart4_2wrap                ),// i
.clk_uart5_2wrap               (clk_uart5_2wrap                ),// i
.pclk_uart1                    (pclk_uart1                     ),// o 
.pclk_uart2                    (pclk_uart2                     ),// o 
.pclk_uart3                    (pclk_uart3                     ),// o 
.pclk_uart4                    (pclk_uart4                     ),// o 
.pclk_uart5                    (pclk_uart5                     ),// o 
.sclk_uart1                    (sclk_uart1                     ),// o 
.sclk_uart2                    (sclk_uart2                     ),// o 
.sclk_uart3                    (sclk_uart3                     ),// o 
.sclk_uart4                    (sclk_uart4                     ),// o 
.sclk_uart5                    (sclk_uart5                     ),// o 
.prstn_uart1                   (prstn_uart1                    ),// o 
.prstn_uart2                   (prstn_uart2                    ),// o 
.prstn_uart3                   (prstn_uart3                    ),// o 
.prstn_uart4                   (prstn_uart4                    ),// o 
.prstn_uart5                   (prstn_uart5                    ),// o 
.s_rst_n_uart1                 (s_rst_n_uart1                  ),// o 
.s_rst_n_uart2                 (s_rst_n_uart2                  ),// o 
.s_rst_n_uart3                 (s_rst_n_uart3                  ),// o 
.s_rst_n_uart4                 (s_rst_n_uart4                  ),// o 
.s_rst_n_uart5                 (s_rst_n_uart5                  ),// o 
.clk_i2c1_2wrap                (clk_i2c1_2wrap                 ),// i
.clk_i2c2_2wrap                (clk_i2c2_2wrap                 ),// i
.clk_i2c3_2wrap                (clk_i2c3_2wrap                 ),// i
.clk_i2c4_2wrap                (clk_i2c4_2wrap                 ),// i
.clk_i2c5_2wrap                (clk_i2c5_2wrap                 ),// i
.pclk_i2c1                     (pclk_i2c1                      ),// o
.pclk_i2c2                     (pclk_i2c2                      ),// o
.pclk_i2c3                     (pclk_i2c3                      ),// o
.pclk_i2c4                     (pclk_i2c4                      ),// o
.pclk_i2c5                     (pclk_i2c5                      ),// o
.clk_i2c1                      (clk_i2c1                       ),// o
.clk_i2c2                      (clk_i2c2                       ),// o
.clk_i2c3                      (clk_i2c3                       ),// o
.clk_i2c4                      (clk_i2c4                       ),// o
.clk_i2c5                      (clk_i2c5                       ),// o
.prstn_i2c1                    (prstn_i2c1                     ),// o
.prstn_i2c2                    (prstn_i2c2                     ),// o
.prstn_i2c3                    (prstn_i2c3                     ),// o
.prstn_i2c4                    (prstn_i2c4                     ),// o
.prstn_i2c5                    (prstn_i2c5                     ),// o
.i2c1_ic_rstn                  (i2c1_ic_rstn                   ),// o
.i2c2_ic_rstn                  (i2c2_ic_rstn                   ),// o
.i2c3_ic_rstn                  (i2c3_ic_rstn                   ),// o
.i2c4_ic_rstn                  (i2c4_ic_rstn                   ),// o
.i2c5_ic_rstn                  (i2c5_ic_rstn                   ),// o
.clk_assi0_2wrap               (clk_assi0_2wrap                ),// i
.clk_assi1_2wrap               (clk_assi1_2wrap                ),// i
.clk_assi2_2wrap               (clk_assi2_2wrap                ),// i
.clk_assi3_2wrap               (clk_assi3_2wrap                ),// i
.pclk_assi0                    (pclk_assi0                     ),// o 
.pclk_assi1                    (pclk_assi1                     ),// o 
.pclk_assi2                    (pclk_assi2                     ),// o 
.pclk_assi3                    (pclk_assi3                     ),// o 
.clk_assi0                     (clk_assi0                      ),// o 
.clk_assi1                     (clk_assi1                      ),// o 
.clk_assi2                     (clk_assi2                      ),// o 
.clk_assi3                     (clk_assi3                      ),// o 
.prstn_assi0                   (prstn_assi0                    ),// o 
.prstn_assi1                   (prstn_assi1                    ),// o 
.prstn_assi2                   (prstn_assi2                    ),// o 
.prstn_assi3                   (prstn_assi3                    ),// o 
.rstn_assi0                    (rstn_assi0                     ),// o 
.rstn_assi1                    (rstn_assi1                     ),// o 
.rstn_assi2                    (rstn_assi2                     ),// o 
.rstn_assi3                    (rstn_assi3                     ),// o 
.clk_gpio_2wrap                (clk_gpio_2wrap                 ),// i 
.pclk_gpio1                    (pclk_gpio1                     ),// o
.pclk_gpio2                    (pclk_gpio2                     ),// o
.pclk_gpio3                    (pclk_gpio3                     ),// o
.pclk_gpio4                    (pclk_gpio4                     ),// o
.gpio1_dbclk                   (gpio1_dbclk                    ),// o
.gpio2_dbclk                   (gpio2_dbclk                    ),// o
.gpio3_dbclk                   (gpio3_dbclk                    ),// o
.gpio4_dbclk                   (gpio4_dbclk                    ),// o
.prstn_gpio1                   (prstn_gpio1                    ),// o
.prstn_gpio2                   (prstn_gpio2                    ),// o
.prstn_gpio3                   (prstn_gpio3                    ),// o
.prstn_gpio4                   (prstn_gpio4                    ),// o
.gpio1_dbclk_res_n             (gpio1_dbclk_res_n              ),// o
.gpio2_dbclk_res_n             (gpio2_dbclk_res_n              ),// o
.gpio3_dbclk_res_n             (gpio3_dbclk_res_n              ),// o
.gpio4_dbclk_res_n             (gpio4_dbclk_res_n              ),// o
.clk_spi0_2wrap                (clk_spi0_2wrap                 ),// i 
.clk_spi1_2wrap                (clk_spi1_2wrap                 ),// i 
.pclk_spi0                     (pclk_spi0                      ),// o
.pclk_spi1                     (pclk_spi1                      ),// o
.spi0_ssi_clk                  (spi0_ssi_clk                   ),// o
.spi1_ssi_clk                  (spi1_ssi_clk                   ),// o
.prstn_spi0                    (prstn_spi0                     ),// o
.prstn_spi1                    (prstn_spi1                     ),// o
.spi0_ssi_rst_n                (spi0_ssi_rst_n                 ),// o
.spi1_ssi_rst_n                (spi1_ssi_rst_n                 ),// o
.clk_2x_sdio_2wrap             (clk_2x_sdio_2wrap              ),// i 
.clk_2x_sdio                   (clk_2x_sdio                    ),// o
.hclk_sdio                     (hclk_sdio                      ),// o
.hrstn_sdio                    (hrstn_sdio                     ),// o
.clk_2x_emmc_2wrap             (clk_2x_emmc_2wrap              ),// i 
.clk_2x_emmc                   (clk_2x_emmc                    ),// o
.hclk_emmc                     (hclk_emmc                      ),// o
.hrstn_emmc                    (hrstn_emmc                     ),// o
.hclk_dmac0                    (hclk_dmac0                     ),// o
.hclk_dmac1                    (hclk_dmac1                     ),// o
.hs_clk_dma0                   (hs_clk_dma0                    ),// o 
.hs_clk_dma1                   (hs_clk_dma1                    ),// o 
.hrstn_dmac0                   (hrstn_dmac0                    ),// o
.hrstn_dmac1                   (hrstn_dmac1                    ),// o
.hsrstn_dmac0                  (hsrstn_dmac0                   ),// o
.hsrstn_dmac1                  (hsrstn_dmac1                   ),// o
.hclk_rom                      (hclk_rom                       ),// o connect to ahb rom 
.hrstn_rom                     (hrstn_rom                      ),// o
.aclk_ram                      (aclk_ram                       ),// o connect to axi_ram
.arstn_ram                     (arstn_ram                      ),// o
.aclk_hsem                     (aclk_hsem                      ),// o connect to axi_ram
.arstn_hsem                    (arstn_hsem                     ),// o
.clk_2x_hqspi_2wrap            (clk_2x_hqspi_2wrap             ),// i 
.pclk_hqspi                    (pclk_hqspi                     ),// o
.clk_2x_hqspi                  (clk_2x_hqspi                   ),// o
.prstn_hqspi                   (prstn_hqspi                    ),// o
.rstn_hqspi                    (rstn_hqspi                     ),// o
.pclk_cfgtop                   (pclk_cfgtop                    ),// o
.prstn_cfgtop                  (prstn_cfgtop                   ),// o
.pclk_scfgtop                  (pclk_scfgtop                   ),// o
.prstn_scfgtop                 (prstn_scfgtop                  ),// o
.clk_efuse_2wrap               (clk_efuse_2wrap                ),// i 
.clk_efuse                     (clk_efuse                      ),// o
.pclk_efuse_ns                 (pclk_efuse_ns                  ),// o
.prstn_efuse_ns                (prstn_efuse_ns                 ),// o
.pclk_efuse_s                  (pclk_efuse_s                   ),// o
.prstn_efuse_s                 (prstn_efuse_s                  ),// o
.clk_saradc_2wrap              (clk_saradc_2wrap               ),// i 
.clk_saradc                    (clk_saradc                     ),// o
.pclk_ddrphy                   (pclk_ddrphy                    ),// o
.prstn_ddrphy                  (prstn_ddrphy                   ),// o
.pclk_crutop                   (pclk_crutop                    ),// o
.prstn_crutop                  (prstn_crutop                   ),// o
.aclk_sgn                      (aclk_sgn                       ),// o
.pclk_sgn                      (pclk_sgn                       ),// o
.sysperi_reset_ni_sgn          (sysperi_reset_ni_sgn           ),// o 
.sysperi_clock_gate_disable_i  (sysperi_clock_gate_disable_i   )
);
