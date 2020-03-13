verdiWindowResize -win $_Verdi_1 "65" "24" "1855" "1056"
debImport "-L" \
          "/home/cqiu/work/prj/simPrj/sim_hqspi_jc5/tb/btc/vcs_vrd_nuvm_nip_nhls_jc5_hqspi" \
          "-f" \
          "/home/cqiu/work/prj/simPrj/sim_hqspi_jc5/runsim/run_vcs_vrd_nuvm_nip_nhls_jc5_hqspi/flist.f"
debLoadSimResult \
           /home/cqiu/work/prj/simPrj/sim_hqspi_jc5/runsim/run_vcs_vrd_nuvm_nip_nhls_jc5_hqspi/tb_dut_top.fsdb
wvCreateWindow
srcHBSelect "tb_dut_top" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb_dut_top" -delim "."
srcHBSelect "tb_dut_top.U_hqspi_mst_DW_apb_ssi_top" -win $_nTrace1
srcHBSelect "tb_dut_top.U_hqspi_mst_DW_apb_ssi_top" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb_dut_top.U_hqspi_mst_DW_apb_ssi_top" -delim "."
srcDeselectAll -win $_nTrace1
srcHBSelect "tb_dut_top.U_hqspi_mst_DW_apb_ssi_top.U_hqspi_mst_DW_apb_ssi" -win \
           $_nTrace1
srcHBSelect "tb_dut_top.uut" -win $_nTrace1
srcHBSelect "tb_dut_top.uut" -win $_nTrace1
srcHBSelect "tb_dut_top.U_hqspi_mst_DW_apb_ssi_top.U_hqspi_mst_DW_apb_ssi" -win \
           $_nTrace1
srcHBSelect "tb_dut_top.uut" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb_dut_top.uut" -delim "."
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {39 45 1 1 1 1} -backward
srcAddSelectedToWave -win $_nTrace1
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 25723541.786982 -snap {("G1" 2)}
wvZoom -win $_nWave2 0.000000 16369526.591716
wvZoom -win $_nWave2 1627266.548762 4901171.867105
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 0)}
verdiDockWidgetSetCurTab -dock widgetDock_MTB_SOURCE_TAB_1
srcHBSelect "tb_dut_top.U_hqspi_mst_DW_apb_ssi_top.U_hqspi_mst_DW_apb_ssi" -win \
           $_nTrace1
srcSetScope -win $_nTrace1 \
           "tb_dut_top.U_hqspi_mst_DW_apb_ssi_top.U_hqspi_mst_DW_apb_ssi" \
           -delim "."
srcDeselectAll -win $_nTrace1
srcSelect -signal "ss_in_n" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
verdiDockWidgetSetCurTab -dock widgetDock_MTB_SOURCE_TAB_1
srcHBSelect "tb_dut_top.U_hqspi_mst_DW_apb_ssi_top" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb_dut_top.U_hqspi_mst_DW_apb_ssi_top" -delim "."
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {27 37 1 11 1 7} -backward
srcAddSelectedToWave -win $_nTrace1
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
wvSelectSignal -win $_nWave2 {( "G1" 11 )} 
wvZoom -win $_nWave2 247964.426478 22068833.956548
wvZoom -win $_nWave2 1978139.880342 5438490.788069
wvSetCursor -win $_nWave2 3157525.751850 -snap {("G1" 11)}
wvZoom -win $_nWave2 2240225.629565 3751313.777437
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 2457500.434259 3258645.393130
wvZoomOut -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 12 )} 
wvSelectSignal -win $_nWave2 {( "G1" 11 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 2867056.042162 3640706.085286
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 8701502.970228 10459382.358153
wvZoom -win $_nWave2 9130051.081367 9379690.757759
wvSetCursor -win $_nWave2 9192682.574142 -snap {("G1" 11)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 1890762.046044 9075657.821009
wvZoom -win $_nWave2 2562486.029738 3217204.342960
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 2330642.232155 2826523.558145
wvZoomOut -win $_nWave2
verdiDockWidgetSetCurTab -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pslverr" -win $_nTrace1
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvSetCursor -win $_nWave2 2528701.341648 -snap {("G1" 7)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 2967072.170660 4037471.624633
wvSetCursor -win $_nWave2 3667582.109177 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 11 )} 
wvZoom -win $_nWave2 625276175.112426 900988504.295858
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcHBSelect "tb_dut_top.uut" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb_dut_top.uut" -delim "."
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {39 45 1 1 1 1} -backward
srcAddSelectedToWave -win $_nTrace1
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 3805814829.621302 4076603724.355030
wvZoom -win $_nWave2 3857729386.954566 3916053148.897215
wvZoom -win $_nWave2 3871602849.853967 3879609425.457929
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 3869902044.740438 3877444333.711744
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 3870513461.064852 3876333073.383540
wvSetCursor -win $_nWave2 3871229721.041685 -snap {("G1" 18)}
wvSetCursor -win $_nWave2 3872200804.280661 -snap {("G1" 18)}
wvSetCursor -win $_nWave2 3871856448.522159 -snap {("G1" 18)}
wvSetCursor -win $_nWave2 3872517611.578483 -snap {("G1" 18)}
wvSetCursor -win $_nWave2 3873247645.786508 -snap {("G1" 18)}
wvSetCursor -win $_nWave2 3873970792.879363 -snap {("G1" 18)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 3514125416.284763 3573189315.983068
wvSelectSignal -win $_nWave2 {( "G1" 14 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 3197521944.469527 3338436526.471638
wvZoom -win $_nWave2 3257056270.829655 3309253033.157064
wvSetPosition -win $_nWave2 {("G1" 13)}
wvSelectSignal -win $_nWave2 {( "G1" 13 )} 
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 13)}
wvSetPosition -win $_nWave2 {("G1" 12)}
wvSelectSignal -win $_nWave2 {( "G1" 14 )} 
wvSetPosition -win $_nWave2 {("G1" 14)}
wvSetPosition -win $_nWave2 {("G1" 13)}
wvSetPosition -win $_nWave2 {("G1" 12)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 12)}
wvSetPosition -win $_nWave2 {("G1" 13)}
wvSelectSignal -win $_nWave2 {( "G1" 15 )} 
wvSetPosition -win $_nWave2 {("G1" 15)}
wvSetPosition -win $_nWave2 {("G1" 14)}
wvSelectSignal -win $_nWave2 {( "G1" 14 )} 
wvSetPosition -win $_nWave2 {("G1" 13)}
wvSetPosition -win $_nWave2 {("G1" 12)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 12)}
wvSetPosition -win $_nWave2 {("G1" 13)}
wvZoom -win $_nWave2 3288621413.490901 3297269397.781833
wvZoom -win $_nWave2 3293124505.901846 3294649416.741312
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
debExit
