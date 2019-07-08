function void initial_signal_drive_tc();
begin
/*
//// board level localbus		;
logic			S_brd_lae		;// idle state ready for write data 
logic			S_brd_cs_n		; 
logic			S_brd_rd_n		; 
logic			S_brd_wr_n		; 
logic [9:0]		S_brd_haddr		; 
logic [15:0]	S_brd_data		; 
logic 			S_brd_data_en	; 

$init_signal_driver("/tb_dut_top/dut_if/S_brd_lae","/tb_dut_top/U0_dut_top/U0_rtuio_fpga_top/I_8313_cpld_lale", , , 1);
$init_signal_driver("/tb_dut_top/dut_if/S_brd_cs_n","/tb_dut_top/U0_dut_top/U0_rtuio_fpga_top/I_cpld_fpga_cs", , , 1);
$init_signal_driver("/tb_dut_top/dut_if/S_brd_wr_n","/tb_dut_top/U0_dut_top/U0_rtuio_fpga_top/I_cpld_fpga_lwe1", , , 1);
$init_signal_driver("/tb_dut_top/dut_if/S_brd_rd_n","/tb_dut_top/U0_dut_top/U0_rtuio_fpga_top/I_cpld_fpga_loe", , , 1);
$init_signal_driver("/tb_dut_top/dut_if/S_brd_haddr","/tb_dut_top/U0_dut_top/U0_rtuio_fpga_top/I_cpu_rla", , , 1);

$init_signal_driver("/tb_dut_top/U0_dut_top/U0_rtuio_fpga_top/U0_transceiver_top/U0_mdio_interface/U0_mdio_core/S_mdio_state","/tb_dut_top/dut_if/S_mdio_state",, , 1);
*/

//====10G ten_gig_eth_pcs_pma xgmii
/*
$init_signal_driver("/tb_dut_top/dut_if/S_xgmii64b_txd","/tb_dut_top/U0_dut_top/U0_rtuio_fpga_top/U0_transceiver_top/U0_ten_gig_eth_pcs_pma_sfp_example_design/xgmii_txd", , , 1);
$init_signal_driver("/tb_dut_top/dut_if/S_xgmii64b_txc","/tb_dut_top/U0_dut_top/U0_rtuio_fpga_top/U0_transceiver_top/U0_ten_gig_eth_pcs_pma_sfp_example_design/xgmii_txc", , , 1);

$init_signal_driver("/tb_dut_top/U0_dut_top/U0_rtuio_fpga_top/U0_transceiver_top/U0_ten_gig_eth_pcs_pma_sfp_example_design/xgmii_rxd","/tb_dut_top/dut_if/S_xgmii64b_rxd", , , 1);
$init_signal_driver("/tb_dut_top/U0_dut_top/U0_rtuio_fpga_top/U0_transceiver_top/U0_ten_gig_eth_pcs_pma_sfp_example_design/xgmii_rxc","/tb_dut_top/dut_if/S_xgmii64b_rxc", , , 1);
$init_signal_driver("/tb_dut_top/U0_dut_top/U0_rtuio_fpga_top/U0_transceiver_top/U0_ten_gig_eth_pcs_pma_sfp_example_design/xgmii_rx_clk","/tb_dut_top/dut_if/S_xgmii64b_rxclk", , , 1);
*/

/*
//=============================================================================
//============================================================OAM Setting======
//=============================================================================
//========oam module localbus connection
$init_signal_driver("/tb_dut_top/U0_dut_top/U_oam_top_4ports/I_125m_clk", "/tb_dut_top/dut_if/S_sub_lb_clk", , , 1);
$init_signal_driver("/tb_dut_top/dut_if/S_sub_cs_n","/tb_dut_top/U0_dut_top/U_oam_top_4ports/I_cs_n", , , 1);
$init_signal_driver("/tb_dut_top/dut_if/S_sub_rd_n","/tb_dut_top/U0_dut_top/U_oam_top_4ports/I_125m_rden", , , 1);
$init_signal_driver("/tb_dut_top/dut_if/S_sub_wr_n","/tb_dut_top/U0_dut_top/U_oam_top_4ports/I_125m_wren", , , 1);
$init_signal_driver("/tb_dut_top/dut_if/S_sub_addr[10:0]","/tb_dut_top/U0_dut_top/U_oam_top_4ports/I_125m_address", , , 1);
$init_signal_driver("/tb_dut_top/dut_if/S_sub_din","/tb_dut_top/U0_dut_top/U_oam_top_4ports/I_125m_data_in", , , 1);
//==== oam system_timestamp
$init_signal_driver("/tb_dut_top/dut_if/S_sub_oam_system_timestamp","/tb_dut_top/U0_dut_top/U_oam_top_4ports/I_system_timestamp", , , 1);
$signal_force("/tb_dut_top/dut_if/S_sub_oam_system_timestamp","64'h1234_5678_9abc_def0",0,3,,1);


//========rpea oam P0 gmii port
//==== Example port 0 (RX) [S_p0_fp_rxd1 --> 1588 -- pla_1588 -- gmii_transform_top -- sw_pause_parse_top -- bpdu -- oam -- pla_replace]
$init_signal_driver("/tb_dut_top/dut_if/S_gmii_txd","/tb_dut_top/U0_dut_top/U_oam_top_4ports/I_gmii_data_tx2", , , 1);
$init_signal_driver("/tb_dut_top/dut_if/S_gmii_txen","/tb_dut_top/U0_dut_top/U_oam_top_4ports/I_gmii_en_tx2", , , 1);
$init_signal_driver("/tb_dut_top/U0_dut_top/S_tx_gmii_d_p1", "/tb_dut_top/dut_if/S_gmii_rxd", , , 1);
$init_signal_driver("/tb_dut_top/U0_dut_top/S_tx_gmii_dv_p1","/tb_dut_top/dut_if/S_gmii_rxen", , , 1);
$init_signal_driver("/tb_dut_top/U0_dut_top/S_tx_port_info_p1","/tb_dut_top/dut_if/S_gmii_port_info", , , 1);

*/
//==============================================================================================================================================//
//============================================================Example Setting===================================================================//
//==============================================================================================================================================//
//========Example traffic gmii port
/*
//==== Example port 0 (RX) [S_p0_fp_rxd1 --> 1588 -- pla_1588 -- gmii_transform_top -- sw_pause_parse_top -- bpdu -- oam -- pla_replace]
$init_signal_driver("/tb_dut_top/dut_if/S_gmii_txd", "/tb_dut_top/U0_dut_top/U0_rpea_fpga/S_p0_fp_rxd1", , , 1);
$init_signal_driver("/tb_dut_top/dut_if/S_gmii_txen", "/tb_dut_top/U0_dut_top/U0_rpea_fpga/S_p0_fp_rx_en1", , , 1);
$init_signal_driver("/tb_dut_top/U0_dut_top/U0_rpea_fpga/S_p0_sys_rxd", "/tb_dut_top/dut_if/S_gmii_rxd", , , 1);
$init_signal_driver("/tb_dut_top/U0_dut_top/U0_rpea_fpga/S_p0_sys_rx_en", "/tb_dut_top/dut_if/S_gmii_rxen", , , 1);
*/
end
endfunction


//====For example
//$signal_force("/tb_mw8120_top/U_fpga_test_dut/U_rcmua_fpga_b_top/inst_rcu_1588_top/I_set_10_0", "0", 0, 3, , 1);
//$init_signal_driver("/tb_dut_top/U0_dut_top/U0_rpea_fpga/S_p2_sys_rxd", "/tb_dut_top/dut_if/S_gmii_rxd", , , 1);

