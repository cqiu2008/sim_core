debImport "-L" \
          "/home/cqiu/work/prj/simPrj/sim_sync_pulse/tb/btc/vcs_vrd_nuvm_nip_nhls_sync_pluse" \
          "-f" \
          "/home/cqiu/work/prj/simPrj/sim_sync_pulse/runsim/run_vcs_vrd_nuvm_nip_nhls_sync_pluse/flist.f"
debLoadSimResult \
           /home/cqiu/work/prj/simPrj/sim_sync_pulse/runsim/run_vcs_vrd_nuvm_nip_nhls_sync_pluse/tb_dut_top.fsdb
wvCreateWindow
wvSetCursor -win $_nWave2 0.000000
srcHBSelect "tb_dut_top.U_sync_pulse" -win $_nTrace1
srcHBSelect "tb_dut_top.U_sync_pulse" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb_dut_top.U_sync_pulse" -delim "."
verdiWindowResize -win $_Verdi_1 "1900" "302" "902" "700"
verdiWindowResize -win $_Verdi_1 "1900" "302" "932" "700"
verdiWindowResize -win $_Verdi_1 "1900" "302" "1153" "700"
verdiWindowResize -win $_Verdi_1 "1900" "302" "1234" "700"
verdiWindowResize -win $_Verdi_1 "1900" "302" "1272" "700"
verdiWindowResize -win $_Verdi_1 "1900" "302" "1276" "700"
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb_dut_top"
wvGetSignalSetScope -win $_nWave2 "/tb_dut_top/U_sync_pulse"
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_dut_top/U_sync_pulse/clka} \
{/tb_dut_top/U_sync_pulse/clkb} \
{/tb_dut_top/U_sync_pulse/level_b_out} \
{/tb_dut_top/U_sync_pulse/pose_b_out} \
{/tb_dut_top/U_sync_pulse/pulse_a_in} \
{/tb_dut_top/U_sync_pulse/rstn} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 )} 
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_dut_top/U_sync_pulse/clka} \
{/tb_dut_top/U_sync_pulse/clkb} \
{/tb_dut_top/U_sync_pulse/level_b_out} \
{/tb_dut_top/U_sync_pulse/pose_b_out} \
{/tb_dut_top/U_sync_pulse/pulse_a_in} \
{/tb_dut_top/U_sync_pulse/rstn} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 )} 
wvSetPosition -win $_nWave2 {("G1" 6)}
wvGetSignalClose -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 10723869.230769 23592512.307692
wvZoom -win $_nWave2 11618582.580783 13160535.375503
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 10510826.150991 41459369.817799
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetCursor -win $_nWave2 13623993.265403 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 12937265.225459 -snap {("G1" 5)}
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvZoom -win $_nWave2 11792718.492219 23696004.517914
wvZoom -win $_nWave2 12796397.935205 15138316.635527
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 11334430.935892 14078217.342186
wvZoom -win $_nWave2 12450616.234308 12844325.230478
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 12162905.814030 14194351.048703
wvZoomOut -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvZoom -win $_nWave2 12427354.306114 14296524.329733
wvSetCursor -win $_nWave2 12524130.860587 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 12795105.213124 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 13154560.986897 -snap {("G1" 4)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 19554394.093247 24509353.682486
wvSetCursor -win $_nWave2 21313551.343857 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 21628733.684593 -snap {("G1" 4)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 32720324.861484 39874231.013995
wvZoom -win $_nWave2 35567071.540512 35948048.791237
wvZoom -win $_nWave2 35676968.824373 35708529.069995
wvSetCursor -win $_nWave2 35685839.307607 -snap {("G1" 3)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 41716460.679667 44011208.006330
wvZoom -win $_nWave2 42653369.351492 42721261.284234
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
wvZoom -win $_nWave2 50914692.729375 56262488.046858
wvZoom -win $_nWave2 52504791.632941 53303796.554636
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 51088803.620815 55324948.057731
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 89034231.005464 94849529.877442
wvZoom -win $_nWave2 90247185.355976 91348307.035877
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 211617686.153846 226631103.076923
wvZoom -win $_nWave2 218213817.553436 219390904.974920
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 218788431.235511 -snap {("G1" 4)}
wvZoom -win $_nWave2 218607340.862975 219108821.894613
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
wvZoom -win $_nWave2 215907233.846154 301698187.692308
wvZoom -win $_nWave2 261594724.060028 263244550.095531
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 261287212.106591 261746039.465578
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 260669559.892531 260772728.174434
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
wvSetCursor -win $_nWave2 89365576.923077 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 484582509.349112 869398031.479290
wvZoom -win $_nWave2 736192658.434216 772055643.484810
wvZoom -win $_nWave2 758474394.708238 760702568.335641
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 672254622.895180 692927855.130500
wvZoom -win $_nWave2 676505479.819226 678829689.360475
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 878347262.849642 1253301398.545581
wvZoom -win $_nWave2 1187296158.681905 1196725478.662424
wvZoom -win $_nWave2 1189541899.090562 1190448564.473304
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 1189863792.125664 1189933535.616644
wvSetCursor -win $_nWave2 1189891132.398831 -snap {("G1" 3)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 1191430544.572210 1193649130.415460
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
verdiDockWidgetSetCurTab -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
debReload
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
verdiDockWidgetSetCurTab -dock widgetDock_MTB_SOURCE_TAB_1
debReload
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
wvZoom -win $_nWave2 3891561885.221894 5241695600.502958
wvZoom -win $_nWave2 4079302372.257124 4171175376.551398
wvZoom -win $_nWave2 4104852852.741206 4120346229.205034
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 4288618965.886975 4376628678.344220
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 4364911408.933617 4395115925.634919
wvZoom -win $_nWave2 4377377474.257945 4382292410.407566
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 4655304026.410145 4833986675.541929
wvZoom -win $_nWave2 4734072413.157443 4749403172.994194
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
wvZoom -win $_nWave2 10821883582.751749 11913361111.484221
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 6274150794.541420 -snap {("G1" 3)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoom -win $_nWave2 7460015.384615 26856055.384615
wvZoom -win $_nWave2 12050794.082840 15809494.142011
wvSetCursor -win $_nWave2 12601254.594454 -snap {("G1" 5)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 9252184.761038 22062902.122475
wvZoom -win $_nWave2 11734735.018949 13307648.541137
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
wvSetCursor -win $_nWave2 166358343.076923 -snap {("G1" 5)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoom -win $_nWave2 8171405.000000 52742705.000000
wvZoom -win $_nWave2 11863702.041420 13973586.065089
wvZoom -win $_nWave2 12491049.214138 12840615.797941
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 12626532.120875 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 12554136.674525 -snap {("G1" 3)}
wvZoom -win $_nWave2 12510699.406715 12742364.835034
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 12528519.824273 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 12582666.477637 -snap {("G1" 5)}
wvSetCursor -win $_nWave2 12531946.827650 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 12577868.672909 -snap {("G1" 4)}
wvGetSignalOpen -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_dut_top/U_sync_pulse/clka} \
{/tb_dut_top/U_sync_pulse/rstn} \
{/tb_dut_top/U_sync_pulse/sig_fromclka} \
{/tb_dut_top/U_sync_pulse/sig_fromclka2b2a_ff1} \
{/tb_dut_top/U_sync_pulse/sig_fromclka2b2a_ff2} \
{/tb_dut_top/U_sync_pulse/sig_fromclka2b_ff1} \
{/tb_dut_top/U_sync_pulse/sig_fromclka2b_ff2} \
{/tb_dut_top/U_sync_pulse/sig_fromclka2b_ff3} \
{/tb_dut_top/U_sync_pulse/pulse_a_in} \
{/tb_dut_top/U_sync_pulse/clkb} \
{/tb_dut_top/U_sync_pulse/pose_b_out} \
{/tb_dut_top/U_sync_pulse/level_b_out} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 3 4 5 6 7 8 )} 
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_dut_top/U_sync_pulse/clka} \
{/tb_dut_top/U_sync_pulse/rstn} \
{/tb_dut_top/U_sync_pulse/sig_fromclka} \
{/tb_dut_top/U_sync_pulse/sig_fromclka2b2a_ff1} \
{/tb_dut_top/U_sync_pulse/sig_fromclka2b2a_ff2} \
{/tb_dut_top/U_sync_pulse/sig_fromclka2b_ff1} \
{/tb_dut_top/U_sync_pulse/sig_fromclka2b_ff2} \
{/tb_dut_top/U_sync_pulse/sig_fromclka2b_ff3} \
{/tb_dut_top/U_sync_pulse/pulse_a_in} \
{/tb_dut_top/U_sync_pulse/clkb} \
{/tb_dut_top/U_sync_pulse/pose_b_out} \
{/tb_dut_top/U_sync_pulse/level_b_out} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 3 4 5 6 7 8 )} 
wvSetPosition -win $_nWave2 {("G1" 8)}
wvGetSignalClose -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvScrollDown -win $_nWave2 4
wvSelectSignal -win $_nWave2 {( "G1" 8 )} 
wvScrollUp -win $_nWave2 4
wvSelectSignal -win $_nWave2 {( "G1" 3 4 5 6 7 8 )} 
wvChangeDisplayAttr -win $_nWave2 -c ID_CYAN6 -lw 1 -ls solid
wvChangeDisplayAttr -win $_nWave2 -c ID_PURPLE5 -lw 1 -ls solid
wvScrollDown -win $_nWave2 2
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 9)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 9)}
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSetCursor -win $_nWave2 12570329.265478 -snap {("G1" 4)}
wvZoomOut -win $_nWave2
wvScrollDown -win $_nWave2 1
wvZoomOut -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSelectSignal -win $_nWave2 {( "G1" 7 )} 
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSelectSignal -win $_nWave2 {( "G1" 5 6 )} 
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 9)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 9)}
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvZoom -win $_nWave2 12431878.329025 12834893.926219
wvSetCursor -win $_nWave2 12578537.851076 -snap {("G1" 5)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G1" 5 6 )} 
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 9)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 9)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetCursor -win $_nWave2 12642924.958320 -snap {("G1" 9)}
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G1" 9 )} 
wvScrollUp -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSelectSignal -win $_nWave2 {( "G1" 5 6 )} 
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 9)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G1" 11)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G1" 9)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetCursor -win $_nWave2 12646502.019834 -snap {("G1" 5)}
wvSelectSignal -win $_nWave2 {( "G1" 8 )} 
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvZoom -win $_nWave2 4273396.154866 33881926.656434
wvZoomOut -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G1" 11 )} 
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSetPosition -win $_nWave2 {("G1" 11)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G1" 9)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetCursor -win $_nWave2 16381050.898797 -snap {("G1" 8)}
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 23126189.504184 -snap {("G1" 8)}
wvSetCursor -win $_nWave2 34689284.256276 -snap {("G1" 8)}
wvZoom -win $_nWave2 32937300.202928 37492458.741631
wvZoom -win $_nWave2 34594946.653395 35086849.868373
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 32791786.643450 43968759.102128
wvZoom -win $_nWave2 34709728.662986 36412728.904471
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 40196614.056400 42695691.333846
wvZoom -win $_nWave2 40799202.216494 41372215.497565
wvSetCursor -win $_nWave2 41059431.620763 -snap {("G1" 8)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 41763831.083146 43201450.202520
wvZoom -win $_nWave2 42352914.657203 42520920.441863
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 42395164.632634 -snap {("G1" 8)}
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 53634652.214709 59297143.039716
wvZoom -win $_nWave2 57010367.898839 57387308.856125
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
wvSaveSignal -win $_nWave2 \
           "/home/cqiu/work/prj/simPrj/sim_core/tb/btc/vcs_vrd_nuvm_nip_nhls_sync_pluse/rc/cm.rc"
debExit
