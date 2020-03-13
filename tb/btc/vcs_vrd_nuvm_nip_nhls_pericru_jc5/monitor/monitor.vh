
`timescale 1ns/10ps
module monitor();

`define CKM(x,y) realtime freq_``x; clkmon U_CLKMON_``x (.clk(``y ), .freq_clk(freq_``x ))

`CKM (xin_osc,tb_dut_top.xin_osc);

// `CKM (pclk_crutop , test.pclk_crutop );
// `CKM (apll_clk_out, test.apll_clk_out);
// `CKM (dpll_clk_out, test.dpll_clk_out);
// `CKM (npll_clk_out, test.npll_clk_out);
// `CKM (usbphy_np5  , test.U_CRU.U_CLK_GEN.clk_usbphy_np5);
// `CKM (xin_osc_func_div  , test.U_CRU.U_CLK_GEN.xin_osc_func_div);
// `CKM (apll_clk_mux  , test.U_CRU.U_CLK_GEN.apll_clk_mux);
// `CKM (dpll_clk_mux  , test.U_CRU.U_CLK_GEN.dpll_clk_mux);
// `CKM (npll_clk_mux  , test.U_CRU.U_CLK_GEN.npll_clk_mux);
// `CKM (fclk_cpul_2wrap  , test.U_CRU.U_CLK_GEN.fclk_cpul_2wrap);
// 
// `CKM(pd_cpul_fclk_core0     , test.U_CRU_CPUL_WRAPPER.fclk_core0);
// `CKM(pd_cpul_hclk_core0     , test.U_CRU_CPUL_WRAPPER.hclk_core0);
// `CKM(pd_cpul_fclk_core1     , test.U_CRU_CPUL_WRAPPER.fclk_core1);
// `CKM(pd_cpul_hclk_core1     , test.U_CRU_CPUL_WRAPPER.hclk_core1);
// `CKM(pd_cpul_swclktck       , test.U_CRU_CPUL_WRAPPER.swclktck);
// `CKM(pd_cpul_clk_sgn        , test.U_CRU_CPUL_WRAPPER.clk_sgn);
// `CKM(pd_cpul_clk_dap        , test.U_CRU_CPUL_WRAPPER.clk_dap);
// `CKM(pd_cpul_hclk_busmatrix , test.U_CRU_CPUL_WRAPPER.hclk_busmatrix);
// 
// `CKM(pd_ddr_aclk_ddrc     , test.U_CRU_DDR_WRAPPER.aclk_ddrc);
// `CKM(pd_ddr_aclk_sgn      , test.U_CRU_DDR_WRAPPER.aclk_sgn);
// `CKM(pd_ddr_clk_core_ddrc , test.U_CRU_DDR_WRAPPER.clk_core_ddrc);
// `CKM(pd_ddr_pclk_ddrc     , test.U_CRU_DDR_WRAPPER.pclk_ddrc);
// `CKM(pd_ddr_pclk_sgn      , test.U_CRU_DDR_WRAPPER.pclk_sgn);
// 
// `CKM(pd_cypto_aclk_pka     ,test.U_CRU_CRYPTO_WRAPPER.aclk_pka     );
// `CKM(pd_cypto_aclk_sgn     ,test.U_CRU_CRYPTO_WRAPPER.aclk_sgn     );
// `CKM(pd_cypto_aclk_spacc   ,test.U_CRU_CRYPTO_WRAPPER.aclk_spacc     );
// `CKM(pd_cypto_clk_skp_spacc,test.U_CRU_CRYPTO_WRAPPER.clk_skp_spacc     );
// 
// `CKM(pd_otg_clk_2x_sdmmc     , test.U_CRU_OTG_WRAPPER.clk_2x_sdmmc);
// `CKM(pd_otg_clk_utmi_otgphy0 , test.U_CRU_OTG_WRAPPER.clk_utmi_otgphy0);
// `CKM(pd_otg_clk_utmi_otgphy1 , test.U_CRU_OTG_WRAPPER.clk_utmi_otgphy1);
// `CKM(pd_otg_hclk_otg0 , test.U_CRU_OTG_WRAPPER.hclk_otg0);
// `CKM(pd_otg_hclk_otg1 , test.U_CRU_OTG_WRAPPER.hclk_otg1);
// `CKM(pd_otg_hclk_sdmmc , test.U_CRU_OTG_WRAPPER.hclk_sdmmc);
// `CKM(pd_otg_hclk_sgn , test.U_CRU_OTG_WRAPPER.hclk_sgn);
// 
// `CKM(pd_dsp_clk_dsp , test.U_CRU_DSP_WRAPPER.clk_dsp);
// `CKM(pd_dsp_clk_sgn , test.U_CRU_DSP_WRAPPER.clk_sgn);
// 
// `CKM(pd_cpub_aclk_cpub_sgn , test.U_CRU_CPUB_WRAPPER.aclk_cpub_sgn);
// `CKM(pd_cpub_aclken_cpub , test.U_CRU_CPUB_WRAPPER.aclken_cpub);
// `CKM(pd_cpub_clk_cpub , test.U_CRU_CPUB_WRAPPER.clk_cpub);
// `CKM(pd_cpub_clk_swclktck_daplite , test.U_CRU_CPUB_WRAPPER.clk_swclktck_daplite);
// `CKM(pd_cpub_pclk_dbg_sgn , test.U_CRU_CPUB_WRAPPER.pclk_dbg_sgn);
// `CKM(pd_cpub_pclkdbg_daplite , test.U_CRU_CPUB_WRAPPER.pclkdbg_daplite);
// `CKM(pd_cpub_pclken_dbg , test.U_CRU_CPUB_WRAPPER.pclken_dbg);
// `CKM(pd_cpub_pclksys_daplite , test.U_CRU_CPUB_WRAPPER.pclksys_daplite);
// 
// `CKM(pd_vpu_aclk_vpu_2wrap , test.U_CRU_VPU_WRAPPER.aclk_vpu_2wrap);
// `CKM(pd_vpu_clk_sgn  , test.U_CRU_VPU_WRAPPER.clk_sgn);
// `CKM(pd_vpu_clk_vpu  , test.U_CRU_VPU_WRAPPER.clk_vpu);
// 
// `CKM(pd_isp_aclk_isp , test.U_CRU_ISP_WRAPPER.aclk_isp);
// `CKM(pd_isp_pclk_isp , test.U_CRU_ISP_WRAPPER.pclk_isp);
// `CKM(pd_isp_clk_isp  , test.U_CRU_ISP_WRAPPER.clk_isp );
// `CKM(pd_isp_sclk_isp , test.U_CRU_ISP_WRAPPER.sclk_isp);
// `CKM(pd_isp_aclk_sgn , test.U_CRU_ISP_WRAPPER.aclk_sgn);
// `CKM(pd_isp_pclk_sgn , test.U_CRU_ISP_WRAPPER.pclk_sgn);
// 
// 
// `CKM(pd_lcdc_aclk_lcdc_2wrap          , test.U_CRU_LCDC_WRAPPER.aclk_lcdc_2wrap            );
// `CKM(pd_lcdc_mclk_lcdc_2wrap          , test.U_CRU_LCDC_WRAPPER.mclk_lcdc_2wrap            );
// `CKM(pd_lcdc_dclk_lcdc_2wrap          , test.U_CRU_LCDC_WRAPPER.dclk_lcdc_2wrap            );
// `CKM(pd_lcdc_dsiphy_lanebyteclk_2wrap , test.U_CRU_LCDC_WRAPPER.dsiphy_lanebyteclk_2wrap   );
// `CKM(pd_lcdc_aclk_lcdc                , test.U_CRU_LCDC_WRAPPER.aclk_lcdc                  );
// `CKM(pd_lcdc_pclk_lcdc                , test.U_CRU_LCDC_WRAPPER.pclk_lcdc                  );
// `CKM(pd_lcdc_mclk_lcdc                , test.U_CRU_LCDC_WRAPPER.mclk_lcdc                  );
// `CKM(pd_lcdc_dclk_lcdc                , test.U_CRU_LCDC_WRAPPER.dclk_lcdc                  );
// `CKM(pd_lcdc_aclk_sgn                 , test.U_CRU_LCDC_WRAPPER.aclk_sgn                   );
// `CKM(pd_lcdc_pclk_sgn                 , test.U_CRU_LCDC_WRAPPER.pclk_sgn                   );
// `CKM(pd_lcdc_dsiphy_lanebyteclk       , test.U_CRU_LCDC_WRAPPER.dsiphy_lanebyteclk         );
// 
// `CKM(pd_npu_clk_sgn , test.U_CRU_NPU_WRAPPERP.clk_sgn);
// `CKM(pd_npu_clks_sgn , test.U_CRU_NPU_WRAPPERP.clks_sgn);
// `CKM(pd_npu_maclk_npu , test.U_CRU_NPU_WRAPPERP.maclk_npu);
// `CKM(pd_npu_saclk_npu , test.U_CRU_NPU_WRAPPERP.saclk_npu);
// `CKM(pd_npu_xclk_npu , test.U_CRU_NPU_WRAPPERP.xclk_npu);
// `CKM(pd_npu_xclk_npu_2wrap_occ , test.U_CRU_NPU_WRAPPERP.xclk_npu_2wrap_occ);
// 
// `CKM(peri_wrap_aclk_peri_2wrap , test.U_CRU_PERI_WRAPPER.aclk_peri_2wrap);
// `CKM(peri_wrap_pclk_peri_2wrap , test.U_CRU_PERI_WRAPPER.pclk_peri_2wrap);
// `CKM(peri_wrap_aclk_dmac0 , test.U_CRU_PERI_WRAPPER.aclk_dmac0);
// `CKM(peri_wrap_aclk_sgn , test.U_CRU_PERI_WRAPPER.aclk_sgn);
// `CKM(peri_wrap_clk_2x_emmc , test.U_CRU_PERI_WRAPPER.clk_2x_emmc);
// `CKM(peri_wrap_clk_2x_sdio , test.U_CRU_PERI_WRAPPER.clk_2x_sdio);
// `CKM(peri_wrap_clk_can , test.U_CRU_PERI_WRAPPER.clk_can);
// `CKM(peri_wrap_clk_efuse , test.U_CRU_PERI_WRAPPER.clk_efuse);
// `CKM(peri_wrap_clk_i2c0 , test.U_CRU_PERI_WRAPPER.clk_i2c0);
// `CKM(peri_wrap_clk_i2c1 , test.U_CRU_PERI_WRAPPER.clk_i2c1);
// `CKM(peri_wrap_clk_i2c2 , test.U_CRU_PERI_WRAPPER.clk_i2c2);
// `CKM(peri_wrap_clk_i2c3 , test.U_CRU_PERI_WRAPPER.clk_i2c3);
// //`CKM(peri_wrap_sclk_i2s0 , test.U_CRU_PERI_WRAPPER.sclk_i2s0);
// `CKM(peri_wrap_sclk_i2s1 , test.U_CRU_PERI_WRAPPER.sclk_i2s1);
// `CKM(peri_wrap_clk_sci , test.U_CRU_PERI_WRAPPER.clk_sci);
// `CKM(peri_wrap_clk_timerx2_s , test.U_CRU_PERI_WRAPPER.clk_timerx2_s);
// `CKM(peri_wrap_clk_timerx6_ns , test.U_CRU_PERI_WRAPPER.clk_timerx6_ns);
// `CKM(peri_wrap_gpio1_dbclk , test.U_CRU_PERI_WRAPPER.gpio1_dbclk);
// `CKM(peri_wrap_gpio2_dbclk , test.U_CRU_PERI_WRAPPER.gpio2_dbclk);
// `CKM(peri_wrap_gpio3_dbclk , test.U_CRU_PERI_WRAPPER.gpio3_dbclk);
// `CKM(peri_wrap_gpio4_dbclk , test.U_CRU_PERI_WRAPPER.gpio4_dbclk);
// `CKM(peri_wrap_gpio5_dbclk , test.U_CRU_PERI_WRAPPER.gpio5_dbclk);
// `CKM(peri_wrap_hclk_emmc , test.U_CRU_PERI_WRAPPER.hclk_emmc);
// `CKM(peri_wrap_hclk_sdio , test.U_CRU_PERI_WRAPPER.hclk_sdio);
// `CKM(peri_wrap_mclk_pwm0 , test.U_CRU_PERI_WRAPPER.mclk_pwm0);
// `CKM(peri_wrap_mclk_pwm1 , test.U_CRU_PERI_WRAPPER.mclk_pwm1);
// `CKM(peri_wrap_mclk_pwm2 , test.U_CRU_PERI_WRAPPER.mclk_pwm2);
// `CKM(peri_wrap_mclk_pwm3 , test.U_CRU_PERI_WRAPPER.mclk_pwm3);
// `CKM(peri_wrap_pclk_can , test.U_CRU_PERI_WRAPPER.pclk_can);
// `CKM(peri_wrap_pclk_cfgtop , test.U_CRU_PERI_WRAPPER.pclk_cfgtop);
// `CKM(peri_wrap_pclk_crutop , test.U_CRU_PERI_WRAPPER.pclk_crutop);
// `CKM(peri_wrap_pclk_efuse_ns , test.U_CRU_PERI_WRAPPER.pclk_efuse_ns);
// `CKM(peri_wrap_pclk_efuse_s , test.U_CRU_PERI_WRAPPER.pclk_efuse_s);
// `CKM(peri_wrap_pclk_gpio1 , test.U_CRU_PERI_WRAPPER.pclk_gpio1);
// `CKM(peri_wrap_pclk_gpio2 , test.U_CRU_PERI_WRAPPER.pclk_gpio2);
// `CKM(peri_wrap_pclk_gpio3 , test.U_CRU_PERI_WRAPPER.pclk_gpio3);
// `CKM(peri_wrap_pclk_gpio4 , test.U_CRU_PERI_WRAPPER.pclk_gpio4);
// `CKM(peri_wrap_pclk_gpio5 , test.U_CRU_PERI_WRAPPER.pclk_gpio5);
// `CKM(peri_wrap_pclk_i2c0 , test.U_CRU_PERI_WRAPPER.pclk_i2c0);
// `CKM(peri_wrap_pclk_i2c1 , test.U_CRU_PERI_WRAPPER.pclk_i2c1);
// `CKM(peri_wrap_pclk_i2c2 , test.U_CRU_PERI_WRAPPER.pclk_i2c2);
// `CKM(peri_wrap_pclk_i2c3 , test.U_CRU_PERI_WRAPPER.pclk_i2c3);
// //`CKM(peri_wrap_pclk_i2s0 , test.U_CRU_PERI_WRAPPER.pclk_i2s0);
// `CKM(peri_wrap_pclk_i2s1 , test.U_CRU_PERI_WRAPPER.pclk_i2s1);
// `CKM(peri_wrap_pclk_pwm0 , test.U_CRU_PERI_WRAPPER.pclk_pwm0);
// `CKM(peri_wrap_pclk_pwm1 , test.U_CRU_PERI_WRAPPER.pclk_pwm1);
// `CKM(peri_wrap_pclk_pwm2 , test.U_CRU_PERI_WRAPPER.pclk_pwm2);
// `CKM(peri_wrap_pclk_pwm3 , test.U_CRU_PERI_WRAPPER.pclk_pwm3);
// `CKM(peri_wrap_pclk_scfgtop , test.U_CRU_PERI_WRAPPER.pclk_scfgtop);
// `CKM(peri_wrap_pclk_sci , test.U_CRU_PERI_WRAPPER.pclk_sci);
// `CKM(peri_wrap_pclk_sgn , test.U_CRU_PERI_WRAPPER.pclk_sgn);
// `CKM(peri_wrap_pclk_spi0 , test.U_CRU_PERI_WRAPPER.pclk_spi0);
// `CKM(peri_wrap_pclk_spi1 , test.U_CRU_PERI_WRAPPER.pclk_spi1);
// `CKM(peri_wrap_pclk_timerx2_s , test.U_CRU_PERI_WRAPPER.pclk_timerx2_s);
// `CKM(peri_wrap_pclk_timerx6_ns , test.U_CRU_PERI_WRAPPER.pclk_timerx6_ns);
// //`CKM(peri_wrap_pclk_uart0 , test.U_CRU_PERI_WRAPPER.pclk_uart0);
// `CKM(peri_wrap_pclk_uart1 , test.U_CRU_PERI_WRAPPER.pclk_uart1);
// `CKM(peri_wrap_pclk_uart2 , test.U_CRU_PERI_WRAPPER.pclk_uart2);
// `CKM(peri_wrap_pclk_uart3 , test.U_CRU_PERI_WRAPPER.pclk_uart3);
// `CKM(peri_wrap_pclk_wdt_ns , test.U_CRU_PERI_WRAPPER.pclk_wdt_ns);
// `CKM(peri_wrap_pclk_wdt_s , test.U_CRU_PERI_WRAPPER.pclk_wdt_s);
// //`CKM(peri_wrap_sclk_uart0 , test.U_CRU_PERI_WRAPPER.sclk_uart0);
// `CKM(peri_wrap_sclk_uart1 , test.U_CRU_PERI_WRAPPER.sclk_uart1);
// `CKM(peri_wrap_sclk_uart2 , test.U_CRU_PERI_WRAPPER.sclk_uart2);
// `CKM(peri_wrap_sclk_uart3 , test.U_CRU_PERI_WRAPPER.sclk_uart3);
// `CKM(peri_wrap_spi0_ssi_clk , test.U_CRU_PERI_WRAPPER.spi0_ssi_clk);
// `CKM(peri_wrap_spi1_ssi_clk , test.U_CRU_PERI_WRAPPER.spi1_ssi_clk);
// 
// 
// `CKM(cruao_clk_pvtm , test.U_CRU_AO.clk_pvtm);
// `CKM(cruao_clk_rtc32k , test.U_CRU_AO.clk_rtc32k);
// `CKM(cruao_clk_rtc32k_from_io , test.U_CRU_AO.clk_rtc32k_from_io);
// `CKM(cruao_clk_rtc32k_from_pvtm , test.U_CRU_AO.clk_rtc32k_from_pvtm);
// `CKM(cruao_clk_timer0 , test.U_CRU_AO.clk_timer0);
// `CKM(cruao_clk_timer1 , test.U_CRU_AO.clk_timer1);
// `CKM(cruao_dbclk_gpio0 , test.U_CRU_AO.dbclk_gpio0);
// `CKM(cruao_dbclk_res_n_gpio0 , test.U_CRU_AO.dbclk_res_n_gpio0);
// `CKM(cruao_hclk_vad , test.U_CRU_AO.hclk_vad);
// `CKM(cruao_mclk_i2s0_from_ao , test.U_CRU_AO.mclk_i2s0_from_ao);
// `CKM(cruao_mclk_i2s0_iout , test.U_CRU_AO.mclk_i2s0_iout);
// `CKM(cruao_mclk_i2s0_iout_oen , test.U_CRU_AO.mclk_i2s0_iout_oen);
// `CKM(cruao_mclk_i2s0_masked_pin , test.U_CRU_AO.mclk_i2s0_masked_pin);
// `CKM(cruao_pclk_ao_2wrap , test.U_CRU_AO.pclk_ao_2wrap);
// `CKM(cruao_pclk_cfg_ao , test.U_CRU_AO.pclk_cfg_ao);
// //`CKM(cruao_pclk_cru_ao , test.U_CRU_AO.pclk_cru_ao);
// `CKM(cruao_pclk_gpio0 , test.U_CRU_AO.pclk_gpio0);
// `CKM(cruao_pclk_i2s0 , test.U_CRU_AO.pclk_i2s0);
// `CKM(cruao_pclk_pmu , test.U_CRU_AO.pclk_pmu);
// `CKM(cruao_pclk_scfg_ao , test.U_CRU_AO.pclk_scfg_ao);
// `CKM(cruao_pclk_sgn , test.U_CRU_AO.pclk_sgn);
// `CKM(cruao_pclk_sram , test.U_CRU_AO.pclk_sram);
// `CKM(cruao_pclk_timerx2 , test.U_CRU_AO.pclk_timerx2);
// `CKM(cruao_scan_clk_apb , test.U_CRU_AO.scan_clk_apb);
// `CKM(cruao_scan_clk_func , test.U_CRU_AO.scan_clk_func);
// `CKM(cruao_sclk_i2s0 , test.U_CRU_AO.sclk_i2s0);
// `CKM(cruao_sclk_i2s0_from_ao , test.U_CRU_AO.sclk_i2s0_from_ao);
// `CKM(cruao_sclk_i2s0_masked_pin , test.U_CRU_AO.sclk_i2s0_masked_pin);
// `CKM(cruao_sclk_i2s0_to_ao , test.U_CRU_AO.sclk_i2s0_to_ao);
// `CKM(cruao_sclkn_i2s0 , test.U_CRU_AO.sclkn_i2s0);

endmodule
