//`include "uvm_macros.svh"
//import uvm_pkg::*;

class eth_refm extends uvm_component;

    virtual dut_intf vif;
	eth_public_config eth_public_cfg;
	int pkt_chk_done;
	bit [31:0]oam_lm_mem[0:3][0:1023];//load the lm statistic data
	bit [31:0]lm_statistic_value;
    uvm_blocking_get_port #(eth_seq_item) port;//用于接收一个uvm_analysis_port发送的信息
    uvm_analysis_port #(eth_seq_item) ap;//用来发送信息给scoreboard，使用这种方式来实现transaction级别的通信

    extern function new(string name,uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
	extern task process_1588pkt(ref eth_seq_item tr);
	extern task process_oampkt(ref eth_seq_item tr);
	extern function void init_refm();

	extern function void process_oam_getable(bit oam_pkt_id_en,bit[11:0]oam_pkt_id,ref bit [63:0] oam_table_value);
	extern function void process_oam_getmac(ref bit[0:3][47:0]port_mac,ref bit[0:3][47:0]system_mac); 
	
	
	extern function void process_oam_lm_statistic( 	eth_seq_item tr,
													bit [2:0] tl_node_type,
													bit [3:0] vlan_num,
													bit [2:0] tl_min_mel,
													bit [2:0] tl_min_mel_ccm_vlan_pri,
													bit [2:0] tl_min_mel_lm_vlan_pri,
													bit [9:0] tl_min_mel_mep_num,
													bit [2:0] tl_max_mel,
													bit [2:0] tl_max_mel_ccm_vlan_pri,
													bit [2:0] tl_max_mel_lm_vlan_pri,
													bit [9:0] tl_max_mel_mep_num,
													ref bit [31:0]lm_statistic_value
												);
	
	
	extern function void process_oam_txdown(eth_seq_item tr,
											bit[2:0]tl_node_type,bit[2:0]tl_min_mel,bit[2:0]tl_max_mel,
											bit[3:0]port_num,
											bit[0:3][47:0]port_mac,bit[0:3][47:0]system_mac,
											ref bit[15:0]tst_cnt,
											ref bit [7:0] oam_process_info
											); 	
	extern function void process_oam_txup( 	eth_seq_item tr,
											bit[2:0]tl_node_type,bit[2:0]tl_min_mel,bit[2:0]tl_max_mel,
											bit tl_min_mel_lck_ind,bit tl_min_mel_hard_ind,
											bit tl_max_mel_lck_ind,bit tl_max_mel_hard_ind,
											bit [4:0]tl_min_mel_oam_id,
											bit tl_min_mel_lev_tst_ind,
											bit tl_max_mel_lev_tst_ind,
											bit[3:0]port_num,bit[3:0]vlan_num, 
											bit[0:3][47:0]port_mac,bit[0:3][47:0]system_mac,
											ref bit[15:0]tst_cnt,
											ref bit [7:0] oam_process_info
											);
	extern function void process_oam_rxdown( eth_seq_item tr,
											bit[2:0]tl_node_type,bit[2:0]tl_min_mel,bit[2:0]tl_max_mel,
											bit tl_min_mel_lck_ind,bit tl_min_mel_hard_ind,
											bit tl_max_mel_lck_ind,bit tl_max_mel_hard_ind,
											bit [4:0]tl_min_mel_oam_id,
											bit tl_min_mel_lev_tst_ind,
											bit tl_max_mel_lev_tst_ind,
											bit[3:0]port_num,bit[3:0]vlan_num, 
											bit[0:3][47:0]port_mac,bit[0:3][47:0]system_mac,
											ref bit[15:0]tst_cnt,
											ref bit [7:0] oam_process_info
											); 	
	extern function void process_oam_rxup( 	eth_seq_item tr,
											bit[2:0]tl_node_type,bit[2:0]tl_min_mel,
											bit[3:0]port_num,
											bit[0:3][47:0]port_mac,
											ref bit [7:0] oam_process_info
											); 
	extern function void process_modify_oam( 
											bit [7:0]oam_process_info,
											bit [31:0]lm_statistic_value,
											bit [4:0]tl_min_mel_oam_id,
											bit [4:0]tl_max_mel_oam_id,
											bit [63:0]sub_oam_system_timestamp,
											bit[3:0]port_num,bit[3:0]vlan_num, 
											bit[0:3][47:0]port_mac,bit[0:3][47:0]system_mac,
											ref eth_seq_item tr
											); 					
											

    `uvm_component_utils(eth_refm)
endclass
function void eth_refm::init_refm();
	bit [31:0]oam_lm_mem[0:3][0:1023];//load the lm statistic data
	for(int i=0;i<1024;i++)
	begin
		for(int j=0;j<4;j++)
		begin
			oam_lm_mem[j][i] = 32'h0;
		end
	end
	lm_statistic_value = 32'h0;
endfunction

function eth_refm::new(string name,uvm_component parent);
    super.new(name,parent);
	pkt_chk_done = 1'b0;
	eth_public_cfg = eth_public_config::type_id::create("eth_public_cfg");
endfunction

function void eth_refm::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual dut_intf)::get(this,"","dut_intf",vif))
        `uvm_fatal("eth_refm","Error in Geting interface");
	uvm_config_db#(eth_public_config)::get(this,"","eth_public_cfg",eth_public_cfg);
    port = new ("port",this);
    ap = new("ap",this);
endfunction

task eth_refm::process_1588pkt(ref eth_seq_item tr);
	bit [7:0] chk_1588 = 8'h00; // bit7-4:L3 (sync,folllow up,delay_req,delay_resp),bit3-0:L2 (sync,folllow up,delay_req,delay_resp)
	bit [63:0] cf= 64'h0;
	bit [31:0] reserved = 32'h0;
    //$display("reference_model_send_socreboard pkt is:");
    //tr.print();
	chk_1588 = 8'h00; 
	cf= 64'h0;
	reserved = 32'h0;
	//====(1)1588  Process
	//==(1.1) Check whether it is 1588 Packet
	//==(1.1.1)L2 1588 Check (eth_type == 16'h88f7,msgType=4'd0,1,8,9)
	if (tr.eth_type == 16'h88f7)
	begin
	case (tr.pload[0][3:0])
	4'b0000:
		chk_1588 = 8'h1;//(L2 sync)
	4'b1000:
		chk_1588 = 8'h2;//(L2 follow_up)
	4'b0001:
		chk_1588 = 8'h4;//(L2 delay_req)
	4'b1001:
		chk_1588 = 8'h8;//(L2 delay_resp)
	default:
		chk_1588 = 8'h0;// no 1588 pkt
	endcase
	//`uvm_info($sformatf("chk_1588=%0x",chk_1588),"",UVM_LOW)
	end
	//==(1.1.2)L3 1588 Check 
	if(	(tr.eth_type == 16'h0800) 	&& // eth_type == 16'h0800
		(tr.pload[0][7:4] == 4'h4) 	&& // L3 header version = 4'h4 
		(tr.pload[9] == 8'h11) 		   // L3 header protocol = 8'h11
		)
	begin
	case({tr.pload[22],tr.pload[23],tr.pload[24],tr.pload[25],tr.pload[28][3:0]})// dest_port,length,msgType
		{16'h013f,16'h0034,4'h0}:
			chk_1588 = 8'h10; // L3 sync
		{16'h0140,16'h0034,4'h8}:
			chk_1588 = 8'h20; // L3 follow_up 
		{16'h013f,16'h0034,4'h1}:
			chk_1588 = 8'h40; // L3 delay_req 
		{16'h0140,16'h003e,4'h9}:
			chk_1588 = 8'h80; // L3 delay_req 
		default:
			chk_1588 = 8'h00; // no 1588
		endcase
	end
	`uvm_info($sformatf("chk_1588=%0x",chk_1588),"",UVM_LOW)
	//==(1.2) Modify the packet for 1588 Packet 
	//==(1.2.1) load the cf and reserved value 
	if(|chk_1588)
	begin
		pkt_chk_done = 1'b1;
	end
	while( (vif.S_valid_negedge != 2'b10 ) && (|chk_1588) )// wait until become to negedge 
	begin
		@(posedge vif.I_125m_clk);
	end
	`uvm_info($sformatf("S_valid_negedge=%0x",vif.S_valid_negedge),"",UVM_LOW)
	cf	= vif.S_cf; 
	reserved = vif.S_reserved;
	`uvm_info($sformatf("cf=%0x",cf),"",UVM_LOW)
	`uvm_info($sformatf("reserved=%0x",reserved),"",UVM_LOW)
	//==(1.2.2) update cf and reserved , clear check sum 
	if(chk_1588[0] || chk_1588[2]) // for sync and delay_req packet L2 
	begin
		{	tr.pload[8],tr.pload[9],tr.pload[10],tr.pload[11],
			tr.pload[12],tr.pload[13],tr.pload[14],tr.pload[15] } = cf		;
		{	tr.pload[16],tr.pload[17],tr.pload[18],tr.pload[19] } = reserved;
	end
	if(chk_1588[4] || chk_1588[6]) // for sync and delay_req packet L3
	begin
		{	tr.pload[36],tr.pload[37],tr.pload[38],tr.pload[39], // base addr 28+8
			tr.pload[40],tr.pload[41],tr.pload[42],tr.pload[43] } = cf		;
		{	tr.pload[44],tr.pload[45],tr.pload[46],tr.pload[47] } = reserved;
		{	tr.pload[26],tr.pload[27]	} = 0	; // clear check sum
	end
	//==(1.3) Calcuate the new crc   
	if(|chk_1588)
	begin
		tr.crc32_calculate();
	end
	//====(2) sending the transaction
	ap.write(tr);//发送这个transaction

endtask


task eth_refm::main_phase(uvm_phase phase);
    eth_seq_item tr;
    super.main_phase(phase);
	init_refm();
    while(1) begin
        port.get(tr);//接收到一个transaction
		pkt_chk_done = 1'b0;
		if(eth_public_cfg.refm_chk[0])//chk_1588
		begin
			process_1588pkt(tr);
		end
		else if( (!pkt_chk_done) && eth_public_cfg.refm_chk[1])//chk_oam
		begin
			process_oampkt(tr);
		end
		else
		begin
			ap.write(tr);//发送这个transaction
		end

		/*
		for(int i=0;i<(tr.pload_size+tr.sub_head_size);i++)
		begin
			$display("refm pload[%0d]=%0x",i,tr.pload[i]);
		end
		*/
		//while(~vif.S_system_time_en);//wait
		//`uvm_info($sformatf("system_time_312m5=%0x",vif.S_system_time_312m5),"",UVM_LOW)
    end
endtask


function void eth_refm::process_oam_getable( bit oam_pkt_id_en, bit[11:0]oam_pkt_id, ref bit [63:0] oam_table_value);
	int pt = 0;
	bit [75:0] 	oam_table_mem[0:511];
	$readmemh(eth_public_cfg.oam_table_path,oam_table_mem);

	while ( (oam_table_mem[pt] != 76'hfff_ffff_ffff_ffff_ffff) && (pt<1000) && oam_pkt_id_en )
	begin
		if(oam_table_mem[pt][75:64] == oam_pkt_id[11:0])//address
		begin
			oam_table_value = oam_table_mem[pt][63:0];
			break;
		end
		pt = pt + 1;
	end
endfunction


function void eth_refm::process_oam_getmac( ref bit[0:3][47:0]port_mac, ref bit[0:3][47:0]system_mac); 
	//==(1.1.3) get the oam system mac and port mac 
	int pt =0;
	bit [31:0]	localbus_mem[0:1023];	
	$readmemh(eth_public_cfg.localbus_mem_path,localbus_mem);
	while( (localbus_mem[pt] != 32'hffff_ffff) && (pt<10000))
	begin
		case(localbus_mem[pt][23:16])
		8'h20://port mac h
			case(localbus_mem[pt][26:24])
			3'b000://port 0
				port_mac[0][47:32] = localbus_mem[pt][15:0];
			3'b001://port 1 
				port_mac[1][47:32] = localbus_mem[pt][15:0];
			3'b010://port 2 
				port_mac[2][47:32] = localbus_mem[pt][15:0];
			3'b011://port 3 
				port_mac[3][47:32] = localbus_mem[pt][15:0];
			default:
				port_mac[0][47:32] = 16'heeee; 
			endcase
		8'h21://port mac m
			case(localbus_mem[pt][26:24])
			3'b000://port 0
				port_mac[0][31:16] = localbus_mem[pt][15:0];
			3'b001://port 1 
				port_mac[1][31:16] = localbus_mem[pt][15:0];
			3'b010://port 2 
				port_mac[2][31:16] = localbus_mem[pt][15:0];
			3'b011://port 3 
				port_mac[3][31:16] = localbus_mem[pt][15:0];
			default:
				port_mac[0][31:16] = 16'heeee; 
			endcase
		8'h22://port mac l 
			case(localbus_mem[pt][26:24])
			3'b000://port 0
				port_mac[0][15:0] = localbus_mem[pt][15:0];
			3'b001://port 1 
				port_mac[1][15:0] = localbus_mem[pt][15:0];
			3'b010://port 2 
				port_mac[2][15:0] = localbus_mem[pt][15:0];
			3'b011://port 3 
				port_mac[3][15:0] = localbus_mem[pt][15:0];
			default:
				port_mac[0][15:0] = 16'heeee; 
			endcase
		8'h23://system mac l 
			case(localbus_mem[pt][26:24])
			3'b000://port 0
				system_mac[0][47:32] = localbus_mem[pt][15:0];
			3'b001://port 1 
				system_mac[1][47:32] = localbus_mem[pt][15:0];
			3'b010://port 2 
				system_mac[2][47:32] = localbus_mem[pt][15:0];
			3'b011://port 3 
				system_mac[3][47:32] = localbus_mem[pt][15:0];
			default:
				system_mac[0][47:32] = 16'heeee; 
			endcase
		8'h24://system mac m 
			case(localbus_mem[pt][26:24])
			3'b000://port 0
				system_mac[0][31:16] = localbus_mem[pt][15:0];
			3'b001://port 1 
				system_mac[1][31:16] = localbus_mem[pt][15:0];
			3'b010://port 2 
				system_mac[2][31:16] = localbus_mem[pt][15:0];
			3'b011://port 3 
				system_mac[3][31:16] = localbus_mem[pt][15:0];
			default:
				system_mac[0][31:16] = 16'heeee; 
			endcase
		8'h25://system mac l 
			case(localbus_mem[pt][26:24])
			3'b000://port 0
				system_mac[0][15:0] = localbus_mem[pt][15:0];
			3'b001://port 1 
				system_mac[1][15:0] = localbus_mem[pt][15:0];
			3'b010://port 2 
				system_mac[2][15:0] = localbus_mem[pt][15:0];
			3'b011://port 3 
				system_mac[3][15:0] = localbus_mem[pt][15:0];
			default:
				system_mac[0][15:0] = 16'heeee; 
			endcase
		default:
		begin
				system_mac = 192'h0;
				port_mac= 192'h0;
		end
		endcase
		pt=pt+1;
	end
endfunction



//==== oam tx down process
function void eth_refm::process_oam_txdown( eth_seq_item tr,
											bit[2:0]tl_node_type,bit[2:0]tl_min_mel,bit[2:0]tl_max_mel,
											bit[3:0]port_num,
											bit[0:3][47:0]port_mac,bit[0:3][47:0]system_mac,
											ref bit[15:0]tst_cnt,
											ref bit [7:0] oam_process_info
											); 	
	case(tl_node_type)
	3'b000://normal node 
	begin
		if	( 	(tr.eth_type[15:8] == 8'hff) 
			&&	(tr.pload[1]== 8'h1) //Opcode,CCM=1 
			)
		begin
			oam_process_info = 8'd1;//ch 16'h8902,add LM
			//`uvm_info($sformatf("now oam_process_info=%0x",oam_process_info),"",UVM_LOW)
		end
		else if	(tr.eth_type == 16'hfe02) 
		begin
			case(tr.pload[1])
			8'h1:// CCM
			begin
				oam_process_info = 8'd1;//ccm 16'h8902,add LM
			end
			8'h2a:
			begin
				oam_process_info = 8'd5;//lmr 16'h8902,add LM
			end
			8'h2b:
			begin
				oam_process_info = 8'd39;//lmm 16'h8902,add LM
			end

			8'h2d,8'h2f:// 1DM,DMM
			begin
				oam_process_info = 8'd3;//ch 1dm/dmm/dmr 16'h8902,add TxTimeStamp 
			end
			8'h2e: //DMR
			begin
				oam_process_info = 8'd40;//ch dmr 16'h8902,add TxTimeStamp 
			end
			default:
			begin
				oam_process_info = 8'd2;//ch 16'h8902
			end
			endcase
		end
		else 
		begin
				oam_process_info = 8'd4;//transmisstion
		end
	end
	3'b001://mep node 
	begin
		if	( 	(tr.eth_type == 16'hff02) 
			&&	(tr.pload[1]== 8'h1) //Opcode,CCM=1 
			)
		begin
			oam_process_info = 8'd1;//ch 16'h8902,add LM
		end
		else if	(tr.eth_type == 16'hfe02) 
		begin
			case(tr.pload[1])
			8'h1:// CCM
			begin
				oam_process_info = 8'd1;//ccm 16'h8902,add LM
			end
			8'h2a:
			begin
				oam_process_info = 8'd5;//lmr 16'h8902,add LM
			end
			8'h2b:
			begin
				oam_process_info = 8'd39;//lmm 16'h8902,add LM
			end

			8'h2d,8'h2f:// 1DM,DMM
			begin
				oam_process_info = 8'd3;//ch 1dm/dmm 16'h8902,add TxTimeStamp 
			end
			8'h2e:// DMR 
			begin
				oam_process_info = 8'd40;//ch dmr 16'h8902,add TxTimeStamp 
			end
			default:
			begin
				oam_process_info = 8'd2;//ch 16'h8902
			end
			endcase
		end
		else if(tr.eth_type == 16'h8902)
		begin
			if(tr.pload[1] == 8'h25)// TST pkt
			begin
				if(tr.pload[0][7:5] != tl_min_mel[2:0] )
				begin
					oam_process_info = 8'd4;//transmisstion
				end
				else
				begin
					oam_process_info = 8'd6;//lose it 
				end
			end
			else
			begin
					oam_process_info = 8'd4;//transmisstion
			end
		end
		else
		begin
				oam_process_info = 8'd4;//transmisstion
		end
	end // end mel node
	3'b010://mip node 
	begin
		if(tr.eth_type==16'h8902)
		begin
			if(tr.pload[0][7:5]>tl_min_mel[2:0])
			begin
				oam_process_info = 8'd4;//transmisstion
			end
			else if(tr.pload[0][7:5] == tl_min_mel[2:0])//mel > LEV1
			begin
				if( (tr.pload[1] == 8'h03) //LBM,dmac==port mac
					&&(tr.dmac[47:0] == port_mac[port_num][47:0])
					)
				begin
					oam_process_info = 8'd7;//fe01,sa->portmac,da->sysmac,sa(pkt)add behand of eth_type,return 
				end
				else if( tr.pload[1] == 8'h05)//LTM
				begin
					oam_process_info = 8'd8;//fe01,sa->portmac,sa(pkt)add behand of eth_type 
				end
				else
				begin
					oam_process_info = 8'd4;//transmisstion
				end
			end
			else
			begin
					oam_process_info = 8'd6;//lose it 
			end
		end
		else if(tr.eth_type==16'hfe01)
		begin
					oam_process_info = 8'd9;//16'h8902,sa-->portmac,return
		end
		else if(tr.eth_type[15:8]==8'hff)
		begin
					oam_process_info = 8'd10;//16'h8902,sa-->portmac
		end
		else
		begin
					oam_process_info = 8'd4;//transmisstion
		end
	end
	3'b100://mep1+mip2 (LEV2(lev max)>LEV1(lev min))
	begin
		if(tr.eth_type==16'h8902)//
		begin
			if(tr.pload[0][7:5]>tl_max_mel[2:0])
			begin
				oam_process_info = 8'd4;//transmisstion
			end
			else if(tr.pload[0][7:5] == tl_max_mel[2:0])//mel == LEV2
			begin
				if( (tr.pload[1] == 8'h03) //LBM,dmac==port mac
					&&(tr.dmac[47:0] == port_mac[port_num][47:0]) )
				begin
					oam_process_info = 8'd7;//fe01,sa->portmac,da->sysmac,sa(pkt)add behand of eth_type,return
				end
				else if(tr.pload[1] == 8'h05) //LTM
				begin
					oam_process_info = 8'd8;//fe01,sa->portmac,sa(pkt)add behand of eth_type,return 
				end
				else
				begin
					oam_process_info = 8'd4;//transmisstion
				end
			end
			else if(((tr.pload[0][7:5] > tl_min_mel[2:0])    //mel > LEV1
					&& (tl_max_mel[2:0] > tr.pload[0][7:5])) //LEV2 > mel
					|| (tr.pload[0][7:5] < tl_min_mel[2:0]) )//|| mel < LEV1
			begin
					oam_process_info = 8'd6;//lose it 
			end
			else if(tr.pload[0][7:5] == tl_min_mel[2:0])//mel == LEV1
			begin
				if(tr.pload[1] == 8'h25)// TST pkt
				begin
					oam_process_info = 8'd6;//lose it 
					tst_cnt=tst_cnt+16'h1;// tst add 1
					`uvm_info($sformatf("tst_cnt=%0x",tst_cnt),"",UVM_LOW)
				end
				else
				begin
					oam_process_info = 8'd4;//transmisstion
				end
			end
		end// end 16'h8902
		else if( (tr.eth_type[15:8] == 8'hff) 
				||(tr.eth_type == 16'hfe01) 
				||(tr.eth_type == 16'hfe02) ) 
		begin
			if(tr.pload[0][7:5] == tl_max_mel[2:0])//mel == LEV2
			begin
				if(tr.eth_type == 16'hfe01)
				begin
					oam_process_info = 8'd9;//16'h8902,sa-->portmac,return
				end
				else
				begin
					oam_process_info = 8'd10;//16'h8902,sa-->portmac
				end
			end
			else
			begin
				if( (tr.eth_type == 16'hff02) 
					&& (tr.pload[1] == 8'h01)) //CCM
				begin
					oam_process_info = 8'd1;//ch 16'h8902,add LM
				end
				else if(tr.eth_type == 16'hfe02)
				begin
				case(tr.pload[1])
				8'h01://ccm
				begin
					oam_process_info = 8'd1;//ccm 16'h8902,add LM
				end
				8'h2a://lmr
				begin
					oam_process_info = 8'd5;//lmr 16'h8902,add LM
				end
				8'h2b://lmm
				begin
					oam_process_info = 8'd39;//lmm 16'h8902,add LM
				end
				8'h2d,8'h2f://1dm,dmm
				begin
					oam_process_info = 8'd3;//ch 1dm/dmm 16'h8902,add TxTimeStamp 
				end
				8'h2e://dmr
				begin
					oam_process_info = 8'd40;//ch dmr 16'h8902,add TxTimeStamp 
				end
				default:
				begin
					oam_process_info = 8'd2;//ch 16'h8902
				end
				endcase
				end
			end
		end
		else // data pkt
		begin
					oam_process_info = 8'd4;//transmisstion
		end
	end
	3'b011://mep1+mep2 (LEV2(lev max)>LEV1(lev min))
	begin
		if(tr.eth_type==16'h8902)//
		begin
			if(tr.pload[1]==8'h25)// tst
			begin
				if( (tr.pload[0][7:5] == tl_min_mel[2:0])
					|| (tr.pload[0][7:5] == tl_max_mel[2:0]) )
				begin
					oam_process_info = 8'd6;//lose it 
					tst_cnt=tst_cnt+16'h1;// tst add 1
					`uvm_info($sformatf("tst_cnt=%0x",tst_cnt),"",UVM_LOW)
				end
				else
				begin
					oam_process_info = 8'd4;//transmisstion
				end
			end
			else
			begin
				oam_process_info = 8'd4;//transmisstion
			end
		end
		else if( (tr.eth_type==16'hff02)
				&& (tr.pload[1] == 8'h01) ) 
		begin
				oam_process_info = 8'd1;//ch 16'h8902,add LM
		end
		else if(tr.eth_type==16'hfe02)
		begin
			case(tr.pload[1])
			8'h01://ccm
			begin
				oam_process_info = 8'd1;//ccm 16'h8902,add LM
			end
			8'h2a://lmr
			begin
				oam_process_info = 8'd5;//lmr 16'h8902,add LM
			end
			8'h2b://lmm
			begin
				oam_process_info = 8'd39;//lmm 16'h8902,add LM
			end
			8'h2d,8'h2f://1dm,dmr,dmm
			begin
				oam_process_info = 8'd3;//ch 1dm/dmm 16'h8902,add TxTimeStamp 
			end
			8'h2e://dmr
			begin
				oam_process_info = 8'd40;//ch 1dm/dmm 16'h8902,add TxTimeStamp 
			end
			default:
			begin
				oam_process_info = 8'd2;//ch 16'h8902
			end
			endcase
		end
		else
		begin
				oam_process_info = 8'd4;//transmisstion
		end
	end
	default:
	begin
		oam_process_info = 8'h0;
	end
	endcase
endfunction

function void eth_refm::process_oam_lm_statistic( 	eth_seq_item tr,
													bit [2:0] tl_node_type,
													bit [3:0] vlan_num,
													bit [2:0] tl_min_mel,
													bit [2:0] tl_min_mel_ccm_vlan_pri,
													bit [2:0] tl_min_mel_lm_vlan_pri,
													bit [9:0] tl_min_mel_mep_num,
													bit [2:0] tl_max_mel,
													bit [2:0] tl_max_mel_ccm_vlan_pri,
													bit [2:0] tl_max_mel_lm_vlan_pri,
													bit [9:0] tl_max_mel_mep_num,
													ref bit [31:0]lm_statistic_value
												);
	bit vlan_flag=0;
	bit oam_flag=0;
	bit mep1_mep2_port_flag=0;
	bit ccm_min_vlan_match=0;
	bit ccm_max_vlan_match=0;
	bit lm_min_vlan_match=0;
	bit lm_max_vlan_match=0;
	bit above_min_level=0;
	bit above_max_level=0;
	bit [9:0]min_mep_num=10'd0;
	bit [9:0]max_mep_num=10'd0;
	bit [1:0]normal_frame_low=2'b00;//bit1=lm,bit0=ccm
	bit [1:0]normal_frame_high=2'b00;
	bit [1:0]high_level1_oam=2'b00;
	bit [1:0]high_level2_oam=2'b00;
	bit [1:0]low_lm_flag=2'b00;
	bit [1:0]high_lm_flag=2'b00;
	//==(1) calculate the control signal
	if(|vlan_num)
	begin
		vlan_flag=1;
	end
	if( (tr.eth_type == 16'h8902)
	  	||(tr.eth_type == 16'hfe01)
	  	||(tr.eth_type == 16'hfe02)
	  	||(tr.eth_type[15:8] == 8'hff) )
	begin
		oam_flag=1;
	end
	if(tl_node_type == 3'd3)
	begin
		mep1_mep2_port_flag=1;
	end
	if( ((vlan_num==1)&&(tr.vlan_word_mem[0][15:13]==tl_min_mel_ccm_vlan_pri))
	 || ((vlan_num==2)&&(tr.vlan_word_mem[1][15:13]==tl_min_mel_ccm_vlan_pri)) 
	 || ((vlan_num==3)&&(tr.vlan_word_mem[2][15:13]==tl_min_mel_ccm_vlan_pri)) )
	begin
		ccm_min_vlan_match=1'b1;
	end
	if( ((vlan_num==1)&&(tr.vlan_word_mem[0][15:13]==tl_max_mel_ccm_vlan_pri))
	 || ((vlan_num==2)&&(tr.vlan_word_mem[1][15:13]==tl_max_mel_ccm_vlan_pri)) 
	 || ((vlan_num==3)&&(tr.vlan_word_mem[2][15:13]==tl_max_mel_ccm_vlan_pri)) )
	begin
		ccm_max_vlan_match=1'b1;
	end
	if( ((vlan_num==1)&&(tr.vlan_word_mem[0][15:13]==tl_min_mel_lm_vlan_pri))
	 || ((vlan_num==2)&&(tr.vlan_word_mem[1][15:13]==tl_min_mel_lm_vlan_pri))
	 || ((vlan_num==3)&&(tr.vlan_word_mem[2][15:13]==tl_min_mel_lm_vlan_pri)) )
	begin
		lm_min_vlan_match=1'b1;
	end
	if( ((vlan_num==1)&&(tr.vlan_word_mem[0][15:13]==tl_max_mel_lm_vlan_pri))
	 || ((vlan_num==2)&&(tr.vlan_word_mem[1][15:13]==tl_max_mel_lm_vlan_pri)) 
	 || ((vlan_num==3)&&(tr.vlan_word_mem[2][15:13]==tl_max_mel_lm_vlan_pri)) )
	begin
		lm_max_vlan_match=1'b1;
	end
	if(tr.pload[0][7:5] > tl_min_mel[2:0])//mel > min_mel
	begin
		above_min_level = 1'b1;
	end
	if(tr.pload[0][7:5] > tl_max_mel[2:0])//mel > max_mel
	begin
		above_max_level = 1'b1;
	end
	min_mep_num = tl_min_mel_mep_num;
	max_mep_num = tl_max_mel_mep_num;

/*
	`uvm_info($sformatf("vlan_flag=%0x",vlan_flag),"",UVM_LOW)
	`uvm_info($sformatf("oam_flag=%0x",oam_flag),"",UVM_LOW)
	`uvm_info($sformatf("lm_min_vlan_match=%0x",lm_min_vlan_match),"",UVM_LOW)
	`uvm_info($sformatf("lm_max_vlan_match=%0x",lm_max_vlan_match),"",UVM_LOW)
	`uvm_info($sformatf("ccm_min_vlan_match=%0x",ccm_min_vlan_match),"",UVM_LOW)
	`uvm_info($sformatf("ccm_max_vlan_match=%0x",ccm_max_vlan_match),"",UVM_LOW)
	`uvm_info($sformatf("above_min_level=%0x",above_min_level),"",UVM_LOW)
	`uvm_info($sformatf("above_max_level=%0x",above_max_level),"",UVM_LOW)
	`uvm_info($sformatf("min_mep_num=%0x",min_mep_num),"",UVM_LOW)
	`uvm_info($sformatf("max_mep_num=%0x",max_mep_num),"",UVM_LOW)
*/

	//==(2) calculate the lm statistic memory

	normal_frame_low  = (vlan_flag && (!oam_flag))?{lm_min_vlan_match,ccm_min_vlan_match}:2'b00;
	normal_frame_high = (vlan_flag && (!oam_flag))?{lm_max_vlan_match,ccm_max_vlan_match}:2'b00;
	high_level1_oam   = (vlan_flag && oam_flag && above_min_level)?{lm_min_vlan_match,ccm_min_vlan_match}:2'b00;
	high_level2_oam   = (vlan_flag && oam_flag && above_max_level)?{lm_min_vlan_match,ccm_min_vlan_match}:2'b00;
	low_lm_flag = {(normal_frame_low[1]||high_level1_oam[1]),(normal_frame_low[0]||high_level1_oam[0])};
	high_lm_flag =  {(normal_frame_high[1]||high_level2_oam[1]),(normal_frame_high[0]||high_level2_oam[0])};
	if(low_lm_flag[0])//ccm low
	begin
		oam_lm_mem[0][min_mep_num]+=1;
		`uvm_info($sformatf("oam_lm_mem 0 0=%0x",oam_lm_mem[0][min_mep_num]),"",UVM_LOW)
	end
	if(low_lm_flag[1])//lm low
	begin
		oam_lm_mem[1][min_mep_num]+=1;
		`uvm_info($sformatf("oam_lm_mem 0 1=%0x",oam_lm_mem[1][min_mep_num]),"",UVM_LOW)
	end
	if(high_lm_flag[0])//ccm high
	begin
		oam_lm_mem[2][max_mep_num]+=1;
	end
	if(high_lm_flag[1])//lm high
	begin
		oam_lm_mem[3][max_mep_num]+=1;
	end
	//==(3) calculate the lm statistic value
	if(oam_flag && (tr.pload[1] == 8'h1))
	begin
		if(tr.pload[0][7:5] == tl_min_mel[2:0])
		begin
			lm_statistic_value = oam_lm_mem[0][min_mep_num];
		end
		else if(mep1_mep2_port_flag && (tr.pload[0][7:5] == tl_max_mel[2:0]))
		begin
			lm_statistic_value = oam_lm_mem[2][max_mep_num];
		end
	end
	else
	begin
		if(tr.pload[0][7:5] == tl_min_mel[2:0])
		begin
			lm_statistic_value = oam_lm_mem[1][min_mep_num];
		end
		else if(mep1_mep2_port_flag && (tr.pload[0][7:5] == tl_max_mel[2:0]))
		begin
			lm_statistic_value = oam_lm_mem[3][max_mep_num];
		end
	end
	
endfunction


task eth_refm::process_oampkt(ref eth_seq_item tr);
	bit [15:0] 	chk_oam = 16'h00; // bit7-4:L3 (sync,folllow up,delay_req,delay_resp),bit3-0:L2 (sync,folllow up,delay_req,delay_resp)
	bit [11:0] 	oam_pkt_id = 12'h0;
	bit			oam_pkt_id_en = 1'b0;
	bit		   	port_mode=1'b0;//bit0:=1,oam tx,=0,oam rx;bit1
	bit [3:0]	port_num=4'd0;
	int 		pt = 0;	
	bit [63:0]  oam_table_value=64'h0;
	bit [7:0]	oam_process_info=8'h0;
	//oam traffic
	bit [2:0]	tl_node_type=3'h0;//tl_ indicate table value
	bit [2:0]	tl_min_mel=3'h0;
	bit 		tl_min_mel_hard_ind=1'b0;
	bit			tl_min_mel_lck_ind=1'b0;
	bit [2:0]	tl_min_mel_ccm_vlan_pri=3'h0;
	bit [2:0]	tl_min_mel_lm_vlan_pri=3'h0;
	bit [9:0]	tl_min_mel_mep_num=10'h0;
	bit [4:0]	tl_min_mel_oam_id=5'h0;
	bit			tl_min_mel_lev_tst_ind=1'b0;
	bit	[2:0]	tl_max_mel=3'b0;
	bit			tl_max_mel_hard_ind=1'b0;
	bit			tl_max_mel_lck_ind=1'b0;
	bit [2:0]	tl_max_mel_ccm_vlan_pri=3'b0;
	bit [2:0]	tl_max_mel_lm_vlan_pri=3'b0;
	bit [9:0]	tl_max_mel_mep_num=10'd0;
	bit [4:0]	tl_max_mel_oam_id=5'd0;
	bit			tl_max_mel_lev_tst_ind=1'b0;
	bit			tl_resp_mep_type=1'b0;//up/down
	bit [2:0]	pkt_node_type=3'h0;//pkt_ indicate the packet value
	bit [2:0]	pkt_min_mel=3'h0;
	bit 		pkt_min_mel_hard_ind=1'b0;
	bit			pkt_min_mel_lck_ind=1'b0;
	bit [2:0]	pkt_min_mel_ccm_vlan_pri=3'h0;
	bit [2:0]	pkt_min_mel_lm_vlan_pri=3'h0;
	bit [9:0]	pkt_min_mel_mep_num=10'h0;
	bit [4:0]	pkt_min_mel_oam_id=5'h0;
	bit			pkt_min_mel_lev_tst_ind=1'b0;
	bit	[2:0]	pkt_max_mel=3'b0;
	bit			pkt_max_mel_hard_ind=1'b0;
	bit			pkt_max_mel_lck_ind=1'b0;
	bit [2:0]	pkt_max_mel_ccm_vlan_pri=3'b0;
	bit [2:0]	pkt_max_mel_lm_vlan_pri=3'b0;
	bit [9:0]	pkt_max_mel_mep_num=10'd0;
	bit [4:0]	pkt_max_mel_oam_id=5'd0;
	bit			pkt_max_mel_lev_tst_ind=1'b0;
	bit			pkt_resp_mep_type=1'b0;//up/down
	bit [0:3][47:0] port_mac=192'h0; ////
	bit [0:3][47:0] system_mac=192'h0;//// 
	bit [15:0]	tst_cnt=0;
	bit [3:0]	vlan_num=0;
	//bit [3:0]	port_info=4'b0000;//
	port_mode = eth_public_cfg.port_mode;
	port_num = eth_public_cfg.port_num;
	vlan_num = tr.vlan_word_size;

	//====(1)OAM Process
	//==(1.1) Check whether it is OAM Packet
	//==(1.1.1) oam vlan process
	case(tr.vlan_word_size)
	16'h1:
	begin
		if(tr.vlan_word_mem[0][31:16] == 16'h8100)
		begin
			oam_pkt_id = tr.vlan_word_mem[0][11:0];
			oam_pkt_id_en = 1'b1;
		end
	end
	16'h2:
	begin
		if( ( (tr.vlan_word_mem[0][31:16] == 16'h8100) 
			||(tr.vlan_word_mem[0][31:16] == 16'h9100) 
			||(tr.vlan_word_mem[0][31:16] == 16'h9200) 
			||(tr.vlan_word_mem[0][31:16] == 16'h88a8) )
			&& (tr.vlan_word_mem[1][31:16] == 16'h8100) )
		begin
			oam_pkt_id = tr.vlan_word_mem[1][11:0];
			oam_pkt_id_en = 1'b1;
		end
	end
	16'h3:
	begin
		if( ( (tr.vlan_word_mem[0][31:16] == 16'h8100) 
			||(tr.vlan_word_mem[0][31:16] == 16'h9100) 
			||(tr.vlan_word_mem[0][31:16] == 16'h9200) 
			||(tr.vlan_word_mem[0][31:16] == 16'h88a8) )
			&&( (tr.vlan_word_mem[1][31:16] == 16'h8100) 
			||(tr.vlan_word_mem[1][31:16] == 16'h9100) 
			||(tr.vlan_word_mem[1][31:16] == 16'h9200) 
			||(tr.vlan_word_mem[1][31:16] == 16'h88a8) )
			&& (tr.vlan_word_mem[2][31:16] == 16'h8100) )
		begin
			oam_pkt_id = tr.vlan_word_mem[2][11:0];
			oam_pkt_id_en = 1'b1;
		end
	end


	default:
	begin
			oam_pkt_id = 12'h0;
			oam_pkt_id_en = 1'b0;
	end
	endcase
	`uvm_info($sformatf("oam_pkt_id_en=%x",oam_pkt_id_en),"",UVM_LOW)
	`uvm_info($sformatf("oam_pkt_id=%x",oam_pkt_id),"",UVM_LOW)
	//==(1.1.2) search the oam table 
	process_oam_getable(oam_pkt_id_en,oam_pkt_id,oam_table_value);
	`uvm_info($sformatf("now oam_table_value=%0x",oam_table_value),"",UVM_LOW)
	tl_node_type=oam_table_value[2:0];
	tl_min_mel=oam_table_value[5:3];
	tl_min_mel_hard_ind=oam_table_value[6];
	tl_min_mel_lck_ind=oam_table_value[7];
	tl_min_mel_ccm_vlan_pri=oam_table_value[10:8];
	tl_min_mel_lm_vlan_pri=oam_table_value[13:11];
	tl_min_mel_mep_num=oam_table_value[23:14];
	tl_min_mel_oam_id=oam_table_value[28:24];
	tl_min_mel_lev_tst_ind=oam_table_value[29];
	tl_max_mel=oam_table_value[37:35];
	tl_max_mel_hard_ind=oam_table_value[38];
	tl_max_mel_lck_ind=oam_table_value[39];
	tl_max_mel_ccm_vlan_pri=oam_table_value[42:40];
	tl_max_mel_lm_vlan_pri=oam_table_value[45:43];
	tl_max_mel_mep_num=oam_table_value[55:46];
	tl_max_mel_oam_id=oam_table_value[60:56];
	tl_max_mel_lev_tst_ind=oam_table_value[61];
	tl_resp_mep_type=oam_table_value[62];
	//==(1.1.3) get the oam system mac and port mac 
	process_oam_getmac(port_mac,system_mac);
	`uvm_info($sformatf("system_mac=%0x",system_mac),"",UVM_LOW)
	`uvm_info($sformatf("port_mac=%0x",port_mac),"",UVM_LOW)
	//==(1.1.4) generate lm_statistic 
	process_oam_lm_statistic(tr,
							tl_node_type,
							vlan_num,
							tl_min_mel,
							tl_min_mel_ccm_vlan_pri,
							tl_min_mel_lm_vlan_pri,
							tl_min_mel_mep_num,
							tl_max_mel,
							tl_max_mel_ccm_vlan_pri,
							tl_max_mel_lm_vlan_pri,
							tl_max_mel_mep_num,
							lm_statistic_value
							);
	`uvm_info($sformatf("lm_statistic_value=%0x",lm_statistic_value),"",UVM_LOW)
	//lm_statistic_value = 32'h0;//
	//==(1.1.5) judge , generate the oam_process_info
	case ({port_mode,tl_resp_mep_type})
	2'b10://oam tx down process 
	begin
		process_oam_txdown(
						tr,
						tl_node_type,tl_min_mel,tl_max_mel,
						port_num,
						port_mac,system_mac,
						tst_cnt,
						oam_process_info
						); 	
	end
	2'b11://oam tx up process
	begin
		process_oam_txup(
						tr,
						tl_node_type,tl_min_mel,tl_max_mel,
						tl_min_mel_lck_ind,tl_min_mel_hard_ind,
						tl_max_mel_lck_ind,tl_max_mel_hard_ind,
						tl_min_mel_oam_id,
						tl_min_mel_lev_tst_ind,
						tl_max_mel_lev_tst_ind,
						port_num,vlan_num, 
						port_mac,system_mac,
						tst_cnt,
						oam_process_info
						);
	end
	2'b00://oam rx down process
	begin
		process_oam_rxdown( 
						tr,
						tl_node_type,tl_min_mel,tl_max_mel,
						tl_min_mel_lck_ind,tl_min_mel_hard_ind,
						tl_max_mel_lck_ind,tl_max_mel_hard_ind,
						tl_min_mel_oam_id,
						tl_min_mel_lev_tst_ind,
						tl_max_mel_lev_tst_ind,
						port_num,vlan_num, 
						port_mac,system_mac,
						tst_cnt,
						oam_process_info
						); 	
	end
	2'b01://oam rx up process
	begin
		process_oam_rxup(	
						tr,
						tl_node_type,tl_min_mel,
						port_num,
						port_mac,
						oam_process_info
						); 
	end
	default:
	begin
		oam_process_info = 8'd0;
	end
	endcase
	`uvm_info($sformatf("port_mode=%0x",port_mode),"",UVM_LOW)
	`uvm_info($sformatf("tl_resp_mep_type=%0x",tl_resp_mep_type),"",UVM_LOW)
	`uvm_info($sformatf("tl_node_type=%0x",tl_node_type),"",UVM_LOW)
	`uvm_info($sformatf("oam_process_info=%0d",oam_process_info),"",UVM_LOW)
	`uvm_info($sformatf("tl_min_mel_hard_ind=%0d",tl_min_mel_hard_ind),"",UVM_LOW)
	//==(1.1.4) modify the packet 
	process_modify_oam( 
						oam_process_info,
						lm_statistic_value,
						tl_min_mel_oam_id,
						tl_max_mel_oam_id,
						vif.S_sub_oam_system_timestamp,
						port_num,vlan_num, 
						port_mac,system_mac,
						tr
						); 
	//==(1.2) Calcuate the new crc   
	if(|oam_process_info)
	begin
		tr.crc32_calculate();
	end
	//==(1.3) pkt return to the oam pkt rx port process 
	//==(1.3.1) judge pkt return to the oam pkt rx port process
	if(tr.port_info == 4'd1)//==4'd1,oam pkt from tx port return to rx port; 
	begin
		if(tl_resp_mep_type) //oam rx up process
		begin
			process_oam_rxup(	
						tr,
						tl_node_type,tl_min_mel,
						port_num,
						port_mac,
						oam_process_info
						); 
		end
		else //oam rx down process
		begin
			process_oam_rxdown( 
						tr,
						tl_node_type,tl_min_mel,tl_max_mel,
						tl_min_mel_lck_ind,tl_min_mel_hard_ind,
						tl_max_mel_lck_ind,tl_max_mel_hard_ind,
						tl_min_mel_oam_id,
						tl_min_mel_lev_tst_ind,
						tl_max_mel_lev_tst_ind,
						port_num,vlan_num, 
						port_mac,system_mac,
						tst_cnt,
						oam_process_info
						); 	
		end
		//==(1.3.2) modify the packet (return to the oam pkt rx port process)
		`uvm_info($sformatf("retrun rx tl_resp_mep_type=%0x",tl_resp_mep_type),"",UVM_LOW)
		`uvm_info($sformatf("return rx oam_process_info=%0x",oam_process_info),"",UVM_LOW)
		process_modify_oam( 
						oam_process_info,
						lm_statistic_value,
						tl_min_mel_oam_id,
						tl_max_mel_oam_id,
						vif.S_sub_oam_system_timestamp,
						port_num,vlan_num, 
						port_mac,system_mac,
						tr
						); 
	end
	if((!port_mode) && (tr.smac == port_mac[port_num]))//rx
	begin
		oam_process_info = 8'd6;//lose it 
	end
	//====(2) sending the transaction
	if(oam_process_info != 8'd6)// lose it 
	begin
		ap.write(tr);//发送这个transaction
	end
endtask

//==== oam modify process
function void eth_refm::process_modify_oam( 
											bit [7:0]oam_process_info,
											bit [31:0]lm_statistic_value,
											bit [4:0]tl_min_mel_oam_id,
											bit [4:0]tl_max_mel_oam_id,
											bit [63:0]sub_oam_system_timestamp,
											bit[3:0]port_num,bit[3:0]vlan_num, 
											bit[0:3][47:0]port_mac,bit[0:3][47:0]system_mac,
											ref eth_seq_item tr
											); 	
	int			pload_buf_size=0;
	bit [7:0]	pload_buf[];//// for oam add sa behind the eth_type 

	case (oam_process_info)
	8'd1://ccm 16'h8902, add lm statistic
	begin
		tr.eth_type=16'h8902;
		{tr.pload[58],tr.pload[59],tr.pload[60],tr.pload[61]} = lm_statistic_value[31:0];
	end
	8'd2://16'h8902
	begin
		tr.eth_type=16'h8902;
	end
	8'd3://1ch 1dm/dmm 16'h8902,add TxTimeStamp 
	begin
		tr.eth_type=16'h8902;
		{tr.pload[4],tr.pload[5],tr.pload[6],tr.pload[7],
		tr.pload[8],tr.pload[9],tr.pload[10],tr.pload[11]} = sub_oam_system_timestamp;//vif.S_sub_oam_system_timestamp; 
	end
	8'd40://dmr 0x2e 16'h8902,add TxTimeStamp 
	begin
		tr.eth_type=16'h8902;
		{tr.pload[20],tr.pload[21],tr.pload[22],tr.pload[23],
		tr.pload[24],tr.pload[25],tr.pload[26],tr.pload[27]} = sub_oam_system_timestamp; 
	end

	8'd4://transmission
	begin
		tr = tr;
	end
	8'd5://lmr(0x2a) 16'h8902,add LM
	begin
		tr.eth_type=16'h8902;
		{tr.pload[12],tr.pload[13],tr.pload[14],tr.pload[15]} = lm_statistic_value[31:0];
	end
	8'd39://lmm(0x2b) 16'h8902,add LM
	begin
		tr.eth_type=16'h8902;
		{tr.pload[4],tr.pload[5],tr.pload[6],tr.pload[7]} = lm_statistic_value[31:0];
	end
	//8'd6: //lose it
	8'd19,8'd7://fe01,sa->portmac,da->sysmac,sa(pkt)add behand of eth_type,return
	begin
		//==update the eth_type
		tr.eth_type=16'hfe01;
		//==add pkt old smac;
		//(1) load the old tr.pload.size
		pload_buf_size=tr.pload.size;
		//(2) save the old tr.pload in the pload_buf  
		pload_buf=new [pload_buf_size];
		for(int i=0;i<pload_buf_size;i++)
		begin
			pload_buf[i]=tr.pload[i];
		end
		//(3) add the pkt old smac and the old tr.pload 
		tr.pload=new[pload_buf_size+6];
		{tr.pload[0],tr.pload[1],tr.pload[2],tr.pload[3],tr.pload[4],tr.pload[5]}=tr.smac;///add smac
		for(int i=0;i<pload_buf_size;i++)
		begin
			tr.pload[i+6]=pload_buf[i];
		end
		//(4)update the old pload_size (this is different from the pload.size)
		tr.pload_size=tr.pload_size+6;// add sa
		//==update the smac
		tr.smac=port_mac[port_num];
		//==update the dmac 
		tr.dmac=system_mac[port_num];
		//==update the port info
		tr.port_info=4'd1;//////==4'd1,oam pkt from tx port return to rx port; 
	end
	8'd8://fe01,sa->portmac,sa(pkt)add behand of eth_type,return
	begin
		//==update the eth_type
		tr.eth_type=16'hfe01;
		//==add pkt old smac;
		//(1) load the old tr.pload.size
		pload_buf_size=tr.pload.size;
		//(2) save the old tr.pload in the pload_buf  
		pload_buf=new [pload_buf_size];
		for(int i=0;i<pload_buf_size;i++)
		begin
			pload_buf[i]=tr.pload[i];
		end
		//(3) add the pkt old smac and the old tr.pload 
		tr.pload=new[pload_buf_size+6];
		{tr.pload[0],tr.pload[1],tr.pload[2],tr.pload[3],tr.pload[4],tr.pload[5]}=tr.smac;///add smac
		for(int i=0;i<pload_buf_size;i++)
		begin
			tr.pload[i+6]=pload_buf[i];
		end
		//(4)update the old pload_size (this is different from the pload.size)
		tr.pload_size=tr.pload_size+6;// add sa
		//==update the smac
		tr.smac=port_mac[port_num];
		//==update the port info
		tr.port_info=4'd1;//////==4'd1,oam pkt from tx port return to rx port; 
	end
	8'd9://16'h8902,sa-->portmac,return
	begin
		//==update the eth_type
		tr.eth_type=16'h8902;
		//==update the smac
		tr.smac=port_mac[port_num];
		//==update the port info
		tr.port_info=4'd1;//////==4'd1,oam pkt from tx port return to rx port; 
	end
	8'd10://16'h8902,sa-->portmac
	begin
		//==update the eth_type
		tr.eth_type=16'h8902;
		//==update the smac
		tr.smac=port_mac[port_num];
	end
	8'd11://16'h8902,sa-->portmac,add timestamp,return
	begin
		//==update the eth_type
		tr.eth_type=16'h8902;
		//==update the smac
		tr.smac=port_mac[port_num];
		//==add timestamp
		{tr.pload[4],tr.pload[5],tr.pload[6],tr.pload[7],
		tr.pload[8],tr.pload[9],tr.pload[10],tr.pload[11]} = sub_oam_system_timestamp; 
		//==update the port info
		tr.port_info=4'd1;//////==4'd1,oam pkt from tx port return to rx port; 
	end
	8'd12://ccm ff01,add lm,sa->portmac,return,add min_mel_oam_id
	begin
		//==update the eth_type
		tr.eth_type=16'hff01;
		//===add lm
		{tr.pload[70],tr.pload[71],tr.pload[72],tr.pload[73]} = lm_statistic_value[31:0];
		//==update the smac
		tr.smac=port_mac[port_num];
		//==update the port info
		tr.port_info=4'd1;//////==4'd1,oam pkt from tx port return to rx port; 
		//==add min_mel_oam_id;
		//(1) load the old tr.pload.size
		pload_buf_size=tr.pload.size;
		//(2) save the old tr.pload in the pload_buf  
		pload_buf=new [pload_buf_size];
		for(int i=0;i<pload_buf_size;i++)
		begin
			pload_buf[i]=tr.pload[i];
		end
		//(3) add oam id the old tr.pload 
		tr.pload=new[pload_buf_size+2];
		{tr.pload[0],tr.pload[1]}={tl_min_mel_oam_id[4:0],3'b000};///add min_mel_oam_id 
		for(int i=0;i<pload_buf_size;i++)
		begin
			tr.pload[i+2]=pload_buf[i];
		end
		//(4)update the old pload_size (this is different from the pload.size)
		tr.pload_size=tr.pload_size+2;// add min_mel_oam_id 
	end
	8'd13://ccm fe01,add lm,sa->portmac,add old sa return
	begin
		//==update the eth_type
		tr.eth_type=16'hfe01;
		//==add lm
		{tr.pload[70],tr.pload[71],tr.pload[72],tr.pload[73]} = lm_statistic_value[31:0];
		//==add pkt old smac;
		//(1) load the old tr.pload.size
		pload_buf_size=tr.pload.size;
		//(2) save the old tr.pload in the pload_buf  
		pload_buf=new [pload_buf_size];
		for(int i=0;i<pload_buf_size;i++)
		begin
			pload_buf[i]=tr.pload[i];
		end
		//(3) add the pkt old smac and the old tr.pload 
		tr.pload=new[pload_buf_size+6];
		{tr.pload[0],tr.pload[1],tr.pload[2],tr.pload[3],tr.pload[4],tr.pload[5]}=tr.smac;///add smac
		for(int i=0;i<pload_buf_size;i++)
		begin
			tr.pload[i+6]=pload_buf[i];
		end
		//(4)update the old pload_size (this is different from the pload.size)
		tr.pload_size=tr.pload_size+6;// add sa
		//==update the smac
		tr.smac=port_mac[port_num];
		//==update the port info
		tr.port_info=4'd1;//////==4'd1,oam pkt from tx port return to rx port; 
	end
	8'd14://lmm,fe01,add lm,sa->portmac,da->sys mac add old sa return
	begin
		//==update the eth_type
		tr.eth_type=16'hfe01;
		//==add lm
		{tr.pload[17],tr.pload[18],tr.pload[19],tr.pload[20]} = lm_statistic_value[31:0];
		//==add pkt old smac;
		//(1) load the old tr.pload.size
		pload_buf_size=tr.pload.size;
		//(2) save the old tr.pload in the pload_buf  
		pload_buf=new [pload_buf_size];
		for(int i=0;i<pload_buf_size;i++)
		begin
			pload_buf[i]=tr.pload[i];
		end
		//(3) add the pkt old smac and the old tr.pload 
		tr.pload=new[pload_buf_size+6];
		{tr.pload[0],tr.pload[1],tr.pload[2],tr.pload[3],tr.pload[4],tr.pload[5]}=tr.smac;///add smac
		for(int i=0;i<pload_buf_size;i++)
		begin
			tr.pload[i+6]=pload_buf[i];
		end
		//(4)update the old pload_size (this is different from the pload.size)
		tr.pload_size=tr.pload_size+6;// add sa
		//==update the smac
		tr.smac=port_mac[port_num];
		//==update the dmac
		tr.dmac=system_mac[port_num];
		//==update the port info
		tr.port_info=4'd1;//////==4'd1,oam pkt from tx port return to rx port; 
	end
	8'd15://1dm,fe01,add timestamp,sa->portmac,add old sa return
	begin
		//==update the eth_type
		tr.eth_type=16'hfe01;
		//==add timestamp 
		{tr.pload[12],tr.pload[13],tr.pload[14],tr.pload[15],
		tr.pload[16],tr.pload[17],tr.pload[18],tr.pload[19]} = sub_oam_system_timestamp; 
		//==add pkt old smac;
		//(1) load the old tr.pload.size
		pload_buf_size=tr.pload.size;
		//(2) save the old tr.pload in the pload_buf  
		pload_buf=new [pload_buf_size];
		for(int i=0;i<pload_buf_size;i++)
		begin
			pload_buf[i]=tr.pload[i];
		end
		//(3) add the pkt old smac and the old tr.pload 
		tr.pload=new[pload_buf_size+6];
		{tr.pload[0],tr.pload[1],tr.pload[2],tr.pload[3],tr.pload[4],tr.pload[5]}=tr.smac;///add smac
		for(int i=0;i<pload_buf_size;i++)
		begin
			tr.pload[i+6]=pload_buf[i];
		end
		//(4)update the old pload_size (this is different from the pload.size)
		tr.pload_size=tr.pload_size+6;// add sa
		//==update the smac
		tr.smac=port_mac[port_num];
		//==update the port info
		tr.port_info=4'd1;//////==4'd1,oam pkt from tx port return to rx port; 
	end
	8'd16://1dm,fe01,add timestamp,sa->portmac,da->sys mac,add old sa return
	begin
		//==update the eth_type
		tr.eth_type=16'hfe01;
		//==add timestamp 
		{tr.pload[12],tr.pload[13],tr.pload[14],tr.pload[15],
		tr.pload[16],tr.pload[17],tr.pload[18],tr.pload[19]} = sub_oam_system_timestamp; 
		//==add pkt old smac;
		//(1) load the old tr.pload.size
		pload_buf_size=tr.pload.size;
		//(2) save the old tr.pload in the pload_buf  
		pload_buf=new [pload_buf_size];
		for(int i=0;i<pload_buf_size;i++)
		begin
			pload_buf[i]=tr.pload[i];
		end
		//(3) add the pkt old smac and the old tr.pload 
		tr.pload=new[pload_buf_size+6];
		{tr.pload[0],tr.pload[1],tr.pload[2],tr.pload[3],tr.pload[4],tr.pload[5]}=tr.smac;///add smac
		for(int i=0;i<pload_buf_size;i++)
		begin
			tr.pload[i+6]=pload_buf[i];
		end
		//(4)update the old pload_size (this is different from the pload.size)
		tr.pload_size=tr.pload_size+6;// add sa
		//==update the smac
		tr.smac=port_mac[port_num];
		//==update the dmac
		tr.dmac=system_mac[port_num];
		//==update the port info
		tr.port_info=4'd1;//////==4'd1,oam pkt from tx port return to rx port; 
	end
/*
oam_process_info = 8'd30;//8902->ff02,add oam_id,addRxPC1
*/
	8'd30://8902->ff02,add oam_id,addRxPC1
	begin
		//==update the eth_type
		tr.eth_type=16'hff02;
		//==add RXFC1
		{tr.pload[70],tr.pload[71],tr.pload[72],tr.pload[73]}=lm_statistic_value[31:0];
		//==add min_mel_oam_id;
		//(1) load the old tr.pload.size
		pload_buf_size=tr.pload.size;
		//(2) save the old tr.pload in the pload_buf  
		pload_buf=new [pload_buf_size];
		for(int i=0;i<pload_buf_size;i++)
		begin
			pload_buf[i]=tr.pload[i];
		end
		//(3) add oam id the old tr.pload 
		tr.pload=new[pload_buf_size+2];
		{tr.pload[0],tr.pload[1]}={tl_min_mel_oam_id[4:0],3'b000};///add min_mel_oam_id 
		for(int i=0;i<pload_buf_size;i++)
		begin
			tr.pload[i+2]=pload_buf[i];
		end
		//(4)update the old pload_size (this is different from the pload.size)
		tr.pload_size=tr.pload_size+2;// add min_mel_oam_id 
		
	end


//oam_process_info = 8'd31;//8902->fe02,addRxPC1
	8'd31://ccm 8902->fe02,addRxPC1
	begin
		//==update the eth_type
		tr.eth_type=16'hfe02;
		//==add RXFC1
		{tr.pload[70],tr.pload[71],tr.pload[72],tr.pload[73]}=lm_statistic_value[31:0];
	end
	8'd32://8902->fe02,addRxTimeStamp
	begin
		//==update the eth_type
		tr.eth_type=16'hfe02;
		//==add RXTimeStamp
		{tr.pload[12],tr.pload[13],tr.pload[14],tr.pload[15],
		tr.pload[16],tr.pload[17],tr.pload[18],tr.pload[19]} = sub_oam_system_timestamp; 
	end
	
	//oam_process_info = 8'd33;//8902->fe02
	8'd33://8902->fe02,
	begin
		//==update the eth_type
		tr.eth_type=16'hfe02;
	end

	8'd34://8902->fe02,da->system mac(cpu mac)
	begin
		//==update the eth_type
		tr.eth_type=16'hfe02;
		//==da --> system mac
		tr.dmac=system_mac[port_num];
	end

	8'd41://dmm,dmr  16'h8902,sa-->portmac,add timestamp,return
	begin
		//==update the eth_type
		tr.eth_type=16'h8902;
		//==update the smac
		tr.smac=port_mac[port_num];
		//==add timestamp
		{tr.pload[20],tr.pload[21],tr.pload[22],tr.pload[23],
		tr.pload[24],tr.pload[25],tr.pload[26],tr.pload[27]} = sub_oam_system_timestamp; 
		//==update the port info
		tr.port_info=4'd1;//////==4'd1,oam pkt from tx port return to rx port; 
	end





	
	8'd42://lmm,fe01,add lm,sa->portmac,add old sa return
	begin
		//==update the eth_type
		tr.eth_type=16'hfe01;
		//==add lm
		{tr.pload[17],tr.pload[18],tr.pload[19],tr.pload[20]} = lm_statistic_value[31:0];//reserved
		//==add pkt old smac;
		//(1) load the old tr.pload.size
		pload_buf_size=tr.pload.size;
		//(2) save the old tr.pload in the pload_buf  
		pload_buf=new [pload_buf_size];
		for(int i=0;i<pload_buf_size;i++)
		begin
			pload_buf[i]=tr.pload[i];
		end
		//(3) add the pkt old smac and the old tr.pload 
		tr.pload=new[pload_buf_size+6];
		{tr.pload[0],tr.pload[1],tr.pload[2],tr.pload[3],tr.pload[4],tr.pload[5]}=tr.smac;///add smac
		for(int i=0;i<pload_buf_size;i++)
		begin
			tr.pload[i+6]=pload_buf[i];
		end
		//(4)update the old pload_size (this is different from the pload.size)
		tr.pload_size=tr.pload_size+6;// add sa
		//==update the smac
		tr.smac=port_mac[port_num];
		//==update the port info
		tr.port_info=4'd1;//////==4'd1,oam pkt from tx port return to rx port; 
	end
	8'd43://lmm,fe01,add lm,sa->portmac,add old sa return
	begin
		//==update the eth_type
		tr.eth_type=16'hfe01;
		//==add lm
		{tr.pload[17],tr.pload[18],tr.pload[19],tr.pload[20]} = lm_statistic_value[31:0];
		//==add pkt old smac;
		//(1) load the old tr.pload.size
		pload_buf_size=tr.pload.size;
		//(2) save the old tr.pload in the pload_buf  
		pload_buf=new [pload_buf_size];
		for(int i=0;i<pload_buf_size;i++)
		begin
			pload_buf[i]=tr.pload[i];
		end
		//(3) add the pkt old smac and the old tr.pload 
		tr.pload=new[pload_buf_size+6];
		{tr.pload[0],tr.pload[1],tr.pload[2],tr.pload[3],tr.pload[4],tr.pload[5]}=tr.smac;///add smac
		for(int i=0;i<pload_buf_size;i++)
		begin
			tr.pload[i+6]=pload_buf[i];
		end
		//(4)update the old pload_size (this is different from the pload.size)
		tr.pload_size=tr.pload_size+6;// add sa
		//==update the smac
		tr.smac=port_mac[port_num];
		//==update the port info
		tr.port_info=4'd1;//////==4'd1,oam pkt from tx port return to rx port; 
	end
	8'd45://dmr0x2e ,fe01,add Rxtimestampb(),sa->portmac,da->sys mac,add old sa return
	begin
		//==update the eth_type
		tr.eth_type=16'hfe01;
		//==add timestamp 
		{tr.pload[28],tr.pload[29],tr.pload[30],tr.pload[31],
		tr.pload[32],tr.pload[33],tr.pload[34],tr.pload[35]} = sub_oam_system_timestamp; 
		//==add pkt old smac;
		//(1) load the old tr.pload.size
		pload_buf_size=tr.pload.size;
		//(2) save the old tr.pload in the pload_buf  
		pload_buf=new [pload_buf_size];
		for(int i=0;i<pload_buf_size;i++)
		begin
			pload_buf[i]=tr.pload[i];
		end
		//(3) add the pkt old smac and the old tr.pload 
		tr.pload=new[pload_buf_size+6];
		{tr.pload[0],tr.pload[1],tr.pload[2],tr.pload[3],tr.pload[4],tr.pload[5]}=tr.smac;///add smac
		for(int i=0;i<pload_buf_size;i++)
		begin
			tr.pload[i+6]=pload_buf[i];
		end
		//(4)update the old pload_size (this is different from the pload.size)
		tr.pload_size=tr.pload_size+6;// add sa
		//==update the smac
		tr.smac=port_mac[port_num];
		//==update the dmac
		tr.dmac=system_mac[port_num];
		//==update the port info
		tr.port_info=4'd1;//////==4'd1,oam pkt from tx port return to rx port; 
	end
	8'd46://dmr0x2e,8902,add Rxtimestampb(),sa->portmac,,add old sa return
	begin
		//==update the eth_type
		tr.eth_type=16'h8902;
		//==add timestamp 
		{tr.pload[20],tr.pload[21],tr.pload[22],tr.pload[23],
		tr.pload[24],tr.pload[25],tr.pload[26],tr.pload[27]} = sub_oam_system_timestamp; 
		//==update the smac
		tr.smac=port_mac[port_num];
		//==update the port info
		tr.port_info=4'd1;//////==4'd1,oam pkt from tx port return to rx port; 
	end

	8'd47://lmm,fe01,add lm,sa->portmac,add old sa return
	begin
		//==update the eth_type
		tr.eth_type=16'hfe01;
		//==add lm
		{tr.pload[17],tr.pload[18],tr.pload[19],tr.pload[20]} = lm_statistic_value[31:0];
		//==add pkt old smac;
		//(1) load the old tr.pload.size
		pload_buf_size=tr.pload.size;
		//(2) save the old tr.pload in the pload_buf  
		pload_buf=new [pload_buf_size];
		for(int i=0;i<pload_buf_size;i++)
		begin
			pload_buf[i]=tr.pload[i];
		end
		//(3) add the pkt old smac and the old tr.pload 
		tr.pload=new[pload_buf_size+6];
		{tr.pload[0],tr.pload[1],tr.pload[2],tr.pload[3],tr.pload[4],tr.pload[5]}=tr.smac;///add smac
		for(int i=0;i<pload_buf_size;i++)
		begin
			tr.pload[i+6]=pload_buf[i];
		end
		//(4)update the old pload_size (this is different from the pload.size)
		tr.pload_size=tr.pload_size+6;// add sa
		//==update the smac
		tr.smac=port_mac[port_num];
		//==update the port info
		tr.port_info=4'd1;//////==4'd1,oam pkt from tx port return to rx port; 
	end
	8'd48://1dm 0x2d,fe01,add Rxtimestampb(),sa->portmac,da->sys mac,add old sa return
	begin
		//==update the eth_type
		tr.eth_type=16'hfe01;
		//==add timestamp 
		{tr.pload[12],tr.pload[13],tr.pload[14],tr.pload[15],
		tr.pload[16],tr.pload[17],tr.pload[18],tr.pload[19]} = sub_oam_system_timestamp; 
		//==add pkt old smac;
		//(1) load the old tr.pload.size
		pload_buf_size=tr.pload.size;
		//(2) save the old tr.pload in the pload_buf  
		pload_buf=new [pload_buf_size];
		for(int i=0;i<pload_buf_size;i++)
		begin
			pload_buf[i]=tr.pload[i];
		end
		//(3) add the pkt old smac and the old tr.pload 
		tr.pload=new[pload_buf_size+6];
		{tr.pload[0],tr.pload[1],tr.pload[2],tr.pload[3],tr.pload[4],tr.pload[5]}=tr.smac;///add smac
		for(int i=0;i<pload_buf_size;i++)
		begin
			tr.pload[i+6]=pload_buf[i];
		end
		//(4)update the old pload_size (this is different from the pload.size)
		tr.pload_size=tr.pload_size+6;// add sa
		//==update the smac
		tr.smac=port_mac[port_num];
		//==update the dmac
		tr.dmac=system_mac[port_num];
		//==update the port info
		tr.port_info=4'd1;//////==4'd1,oam pkt from tx port return to rx port; 
	end

	8'd49://lmm 8902->fe02,addRxPC1
	begin
		//==update the eth_type
		tr.eth_type=16'hfe02;
		//==add RXFC1
		{tr.pload[17],tr.pload[18],tr.pload[19],tr.pload[20]}=lm_statistic_value[31:0];
	end
	8'd50://dmr 8902->fe02,add timestamp
	begin
		//==update the eth_type
		tr.eth_type=16'hfe02;
		//==add RXFC1
		{tr.pload[28],tr.pload[29],tr.pload[30],tr.pload[31],
		tr.pload[32],tr.pload[33],tr.pload[34],tr.pload[35]} = sub_oam_system_timestamp; 
	end

	8'd51://ccm,add lm_statistic
	begin
	//	if(tr.eth_type == 16'h)
		//==add RXFC1
		{tr.pload[58],tr.pload[59],tr.pload[60],tr.pload[61]}=lm_statistic_value[31:0];
	end

	8'd52://dmm,dmr  16'h8902,sa-->portmac,add timestamp,return
	begin
		//==update the eth_type
		tr.eth_type=16'h8902;
		//==update the smac
		tr.smac=port_mac[port_num];
		//==add timestamp
		{tr.pload[4],tr.pload[5],tr.pload[6],tr.pload[7],
		tr.pload[8],tr.pload[9],tr.pload[10],tr.pload[11]} = sub_oam_system_timestamp; 
		//==update the port info
		tr.port_info=4'd1;//////==4'd1,oam pkt from tx port return to rx port; 
	end


	default:
	begin
	end
	endcase
	
endfunction










//==== oam tx up process
function void eth_refm::process_oam_txup( 	eth_seq_item tr,
											bit[2:0]tl_node_type,bit[2:0]tl_min_mel,bit[2:0]tl_max_mel,
											bit tl_min_mel_lck_ind,bit tl_min_mel_hard_ind,
											bit tl_max_mel_lck_ind,bit tl_max_mel_hard_ind,
											bit [4:0]tl_min_mel_oam_id,
											bit tl_min_mel_lev_tst_ind,
											bit tl_max_mel_lev_tst_ind,
											bit[3:0]port_num,bit[3:0]vlan_num, 
											bit[0:3][47:0]port_mac,bit[0:3][47:0]system_mac,
											ref bit[15:0]tst_cnt,
											ref bit [7:0] oam_process_info
											); 	
	case(tl_node_type)
	3'b000://normal node 
	begin
		if(tr.eth_type == 16'hfe01) 
		begin
		case(tr.pload[1])
		8'h2d://1dm
		begin
			oam_process_info = 8'd11;//16'h8902,sa-->portmac,add timestamp,return
		end
		8'h2e://dmr
		begin
			oam_process_info = 8'd41;//dmr 16'h8902,sa-->portmac,add timestamp,return
		end
		8'h2f://dmm
		begin
			oam_process_info = 8'd52;//dmr 16'h8902,sa-->portmac,add timestamp,return
		end
		
		default:
		begin
			oam_process_info = 8'd9;//16'h8902,sa-->portmac,return
		end
		endcase
		end
		else if( (tr.eth_type[15:8] == 8'hff)
				&& ( tr.pload[1] == 8'h01) )// ccm
		begin
			oam_process_info = 8'd9;//16'h8902,sa-->portmac,return
		end
		else 
		begin
			oam_process_info = 8'd4;//transmisstion
		end
	end
	3'b001://mep node
	begin
		if(tr.eth_type[15:8] == 8'hff)
		begin
			if(tr.pload[1] == 8'h01)//ccm
			begin
				oam_process_info=8'd9;//16'h8902,sa-->portmac,return
			end
			else
			begin
				oam_process_info = 8'd4;//transmisstion
			end
		end
		else if(tr.eth_type == 16'hfe01) 
		begin
			case(tr.pload[1])
			8'h2d://1dm
			begin
				oam_process_info=8'd11;//16'h8902,sa-->portmac,add timestamp,return
			end
			8'h2f,8'h2e://dmm,dmr
			begin
				oam_process_info = 8'd41;//dmr 16'h8902,sa-->portmac,add timestamp,return
			end
			default:
			begin
				oam_process_info=8'd9;//16'h8902,sa-->portmac,return
			end
			endcase
		end
		else if(tr.eth_type == 16'h8902) 
		begin
			if(tr.pload[0][7:5] > tl_min_mel[2:0])
			begin
				if (tl_min_mel_lck_ind) // lck
				begin
					oam_process_info = 8'd6;//lose it 
				end
				else
				begin
					oam_process_info = 8'd4;//transmisstion
				end
			end
			else if (tr.pload[0][7:5] == tl_min_mel[2:0])
			begin
				case(tr.pload[1])
				8'h01://ccm
				begin
					if(tl_min_mel_hard_ind)//hard info
					begin
						oam_process_info = 8'd12;//ff01,add lm,sa->portmac,return,add min_mel oam_id
					end
					else 
					begin
						oam_process_info = 8'd13;//fe01,add lm,sa->portmac,add old sa return
					end
				end
				8'h2B://lmm
				begin
					if(tr.dmac[40])// group mac
					begin
						oam_process_info = 8'd42;//lmm,fe01,add lm,sa->portmac,add old sa return
					end
					else if(tr.dmac == port_mac[port_num])
					begin
						oam_process_info = 8'd14;//fe01,add lm,sa->portmac,da->sys mac add old sa return
					end
					else 
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				8'h2A://lmr
				begin
					if(tr.dmac == port_mac[port_num])
					begin
						oam_process_info = 8'd14;//fe01,add lm,sa->portmac,da->sys mac add old sa return
					end
					else
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				8'h2d://1DM
				begin
					if(tr.dmac[40])// group mac
					begin
						oam_process_info = 8'd15;//fe01,add timestamp,sa->portmac,add old sa return
					end
					else if(tr.dmac == port_mac[port_num])
					begin
						oam_process_info = 8'd16;//fe01,add timestamp,sa->portmac,da->sys mac ,add old sa ,return
					end
					else 
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				8'h2f://dmm
				begin
					if(tr.dmac[40])// group mac
					begin
						oam_process_info = 8'd15;//fe01,add timestamp,sa->portmac,add old sa return
					end
					else if(tr.dmac == port_mac[port_num])
					begin
						oam_process_info = 8'd17;//fe01,add lm,sa->portmac,da->sys mac ,add old sa ,return
					end
					else 
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				8'h2E://dmr
				begin
					if(tr.dmac == port_mac[port_num])
					begin
						oam_process_info = 8'd16;//fe01,add timestamp,sa->portmac,da->sys mac ,add old sa ,return
					end
					else
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				8'h25://tst
				begin
					if(tl_min_mel_lev_tst_ind)
					begin
						oam_process_info = 8'd6;//lose it 
						tst_cnt=tst_cnt+16'h1;// tst add 1
					end
					else
					begin
						oam_process_info = 8'd6;//lose it 
					end
				end
				default:
				begin
					if(tr.dmac[40])// group mac
					begin
						oam_process_info = 8'd18;//fe01,sa->portmac,add timestamp,add old sa return
					end
					else if(tr.dmac == port_mac[port_num])
					begin
						oam_process_info = 8'd19;//fe01,sa->portmac,da->sys mac ,add old sa ,return
					end
					else 
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				endcase
			end
			else
			begin
				oam_process_info = 8'd6;//lose it 
			end
		end
		else // data pkt
		begin
			if(vlan_num == 0) // no vlan
			begin
				oam_process_info = 8'd4;//transmisstion
			end
			else if(tl_min_mel_lck_ind)
			begin
				oam_process_info = 8'd6;//lose it 
			end
			else
			begin
				oam_process_info = 8'd4;//transmisstion
			end
		end
	end
	3'b100://mep1+mip2(LEV2 max >LEV1 min)
	begin
		if(tr.eth_type[15:8] == 8'hff)
		begin
			if(tr.pload[1] == 8'h01)//ccm
			begin
				oam_process_info = 8'd9;//16'h8902,sa-->portmac,return
			end
			else
			begin
				oam_process_info = 8'd4;//transmisstion
			end
		end
		else if(tr.eth_type == 16'hfe01)
		begin
			case(tr.pload[1])
			8'h2d,8'h2f://1dm,dmm
			begin
				oam_process_info = 8'd11;//16'h8902,sa-->portmac,add timestamp,return
			end
			8'h2e://dmm,dmr
			begin
				oam_process_info = 8'd41;//dmr 16'h8902,sa-->portmac,add timestamp,return
			end
			default:
			begin
				oam_process_info = 8'd9;//16'h8902,sa-->portmac,return
			end
			endcase
		end
		else if(tr.eth_type == 16'hfe02)
		begin
			oam_process_info = 8'd10;//16'h8902,sa-->portmac
		end
		else if(tr.eth_type == 16'h8902)
		begin
			if(tr.pload[0][7:5] > tl_max_mel[2:0])//mel > LEV2
			begin
				if (tl_min_mel_lck_ind) // lck
				begin
					oam_process_info = 8'd6;//lose it 
				end
				else
				begin
					oam_process_info = 8'd4;//transmisstion
				end
			end
			else if (tr.pload[0][7:5] == tl_max_mel[2:0])//mel == LEV2
			begin
				if (tl_min_mel_lck_ind) // lck
				begin
					oam_process_info = 8'd6;//lose it 
				end
				else
				begin
					if( (tr.pload[1] == 8'h03)
						&& (tr.dmac == port_mac[port_num]))
					begin
						oam_process_info = 8'd7;//fe01,sa->portmac,da->sysmac,sa(pkt)add behand of eth_type,return 
					end
					else if(tr.pload[1] == 8'h05)//LTM
					begin
						oam_process_info = 8'd8;//fe01,sa->portmac,sa(pkt)add behand of eth_type,return 
					end
					else
					begin
						oam_process_info = 8'd4;//transmisstion
					end
					//oam_process_info = 8'd4;//transmisstion
				end
			end
			else if( (tr.pload[0][7:5] < tl_max_mel[2:0])//mel < LEV2
					&&(tr.pload[0][7:5] > tl_min_mel[2:0]) )// mel > LEV1
			begin
				oam_process_info = 8'd6;//lose it 
			end
			else if(tr.pload[0][7:5] == tl_min_mel[2:0])// mel == LEV1
			begin
			case(tr.pload[1])
				8'h01://ccm
				begin
					if(tl_min_mel_hard_ind)//hard info
					begin
						oam_process_info = 8'd12;//ff01,add lm,sa->portmac,return,add min_mel_oam_id
					end
					else 
					begin
						oam_process_info = 8'd13;//fe01,add lm,sa->portmac,add old sa return
					end
				end
				8'h2B://lmm
				begin
					if(tr.dmac[40])// group mac
					begin
						oam_process_info = 8'd43;//lmm fe01,add lm,sa->portmac,add old sa return
					end
					else if(tr.dmac == port_mac[port_num])
					begin
						oam_process_info = 8'd14;//lmm,fe01,add lm,sa->portmac,da->sys mac add old sa return
					end
					else 
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				8'h2A://lmr
				begin
					if(tr.dmac == port_mac[port_num])
					begin
						oam_process_info = 8'd14;//fe01,add lm,sa->portmac,da->sys mac add old sa return
					end
					else
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				8'h2d://1DM
				begin
					if(tr.dmac[40])// group mac
					begin
						oam_process_info = 8'd15;//fe01,add timestamp,sa->portmac,add old sa return
					end
					else if(tr.dmac == port_mac[port_num])
					begin
						oam_process_info = 8'd16;//1dm,fe01,add timestamp,sa->portmac,da->sys mac ,add old sa ,return
					end
					else 
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				8'h2f://DMM
				begin
					if(tr.dmac[40])// group mac
					begin
						oam_process_info = 8'd15;//fe01,add timestamp,sa->portmac,add old sa return
					end
					else if(tr.dmac == port_mac[port_num])
					begin
						oam_process_info = 8'd16;//fe01,add timestamp,sa->portmac,da->sys mac ,add old sa ,return
					end
					else 
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				8'h2E://DMR
				begin
					if(tr.dmac == port_mac[port_num])
					begin
						oam_process_info = 8'd45;//dmr fe01,add timestamp,sa->portmac,da->sys mac ,add old sa ,return
					end
					else
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				8'h25://tst
				begin
					if(tl_min_mel_lev_tst_ind)
					begin
						oam_process_info = 8'd6;//lose it 
						tst_cnt=tst_cnt+16'h1;// tst add 1
					end
					else
					begin
						oam_process_info = 8'd6;//lose it 
					end
				end
				default:
				begin
					if(tr.dmac[40])// group mac
					begin
						oam_process_info = 8'd8;//fe01,sa->portmac,add old sa return
					end
					else if(tr.dmac == port_mac[port_num])
					begin
						oam_process_info = 8'd19;//fe01,sa->portmac,da->sys mac ,add old sa ,return
					end
					else 
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				endcase
			
			
			
			
			
			
			end
			else // mel < LEV1
			begin
				oam_process_info = 8'd6;//lose it
			end	
		end
		else //data pkt
		begin
			if(vlan_num == 0) // no vlan
			begin
				oam_process_info = 8'd4;//transmisstion
			end
			else if(tl_min_mel_lck_ind)
			begin
				oam_process_info = 8'd6;//lose it 
			end
			else
			begin
				oam_process_info = 8'd4;//transmisstion
			end	
		end
	end
	3'b011://mep1+mep2(LEV2 max >LEV1 min)
	begin
		if(tr.eth_type[15:8] == 8'hff)
		begin
			if(tr.pload[1] == 8'h01)//ccm
			begin
				oam_process_info = 8'd9;//16'h8902,sa-->portmac,return
			end
			else
			begin
				oam_process_info = 8'd4;//transmisstion
			end
		end
		else if(tr.eth_type == 16'hfe01)
		begin
			case(tr.pload[1])
			8'h2d,8'h2f://1dm,dmm
			begin
				oam_process_info = 8'd11;//16'h8902,add timestamp sa-->portmac,return
			end
			8'h2e://dmr
			begin
				oam_process_info = 8'd46;//dmr0x2e,16'h8902,add timestamp sa-->portmac,return
			end
			default:
			begin
				oam_process_info = 8'd9;//16'h8902,sa-->portmac,return
			end
			endcase
		end
		else if(tr.eth_type == 16'h8902)
		begin
			if (tr.pload[0][7:5] > tl_max_mel[2:0])//mel > LEV2
			begin
				if (tl_min_mel_lck_ind || tl_max_mel_lck_ind ) // lck
				begin
					oam_process_info = 8'd6;//lose it 
				end
				else
				begin
					oam_process_info = 8'd4;//transmisstion
				end
			end
			else if (tr.pload[0][7:5] == tl_max_mel[2:0])//mel == LEV2
			begin
				if (tl_min_mel_lck_ind) // lck
				begin
					oam_process_info = 8'd6;//lose it 
				end
				else
				begin
					case(tr.pload[1])
					8'h01://ccm
					begin
						if(tl_max_mel_hard_ind)//hard info
						begin
							oam_process_info = 8'd12;//ff01,add lm,sa->portmac,return,add min_mel_oam_id
						end
						else 
						begin
							oam_process_info = 8'd13;//fe01,add lm,sa->portmac,add old sa return
						end
					end
					8'h2B://lmm
					begin
						if(tr.dmac[40])// group mac
						begin
							oam_process_info = 8'd47;//lmm fe01,add lm,sa->portmac,add old sa return
						end
						else if(tr.dmac == port_mac[port_num])
						begin
							oam_process_info = 8'd14;//fe01,add lm,sa->portmac,da->sys mac add old sa return
						end
						else 
						begin
							oam_process_info = 8'd4;//transmisstion
						end
					end
					8'h2A://lmr
					begin
						if(tr.dmac == port_mac[port_num])
						begin
							oam_process_info = 8'd14;//fe01,add lm,sa->portmac,da->sys mac add old sa return
						end
						else
						begin
							oam_process_info = 8'd4;//transmisstion
						end
					end
					8'h2d://1DM
					begin
						if(tr.dmac[40])// group mac
						begin
							oam_process_info = 8'd15;//fe01,add timestamp,sa->portmac,add old sa,return
						end
						else if(tr.dmac == port_mac[port_num])
						begin
							oam_process_info = 8'd48;//fe01,add 1m,sa->portmac,da->sys mac ,add old sa ,return
						end
						else 
						begin
							oam_process_info = 8'd4;//transmisstion
						end
					end
					8'h2f://DMM
					begin
						if(tr.dmac[40])// group mac
						begin
							oam_process_info = 8'd15;//fe01,add timestamp,sa->portmac,add old sa return
						end
						else if(tr.dmac == port_mac[port_num])
						begin
							oam_process_info = 8'd48;//fe01,add 1m,sa->portmac,da->sys mac ,add old sa ,return
						end
						else 
						begin
							oam_process_info = 8'd4;//transmisstion
						end
					end
					8'h2E://DMR
					begin
						if(tr.dmac == port_mac[port_num])
						begin
							oam_process_info = 8'd16;//fe01,add timestamp,sa->portmac,da->sys mac ,add old sa ,return
						end
						else
						begin
							oam_process_info = 8'd4;//transmisstion
						end
					end
					8'h25://tst
					begin
						if(tl_max_mel_lev_tst_ind)
						begin
							oam_process_info = 8'd6;//lose it 
							tst_cnt=tst_cnt+16'h1;// tst add 1,by cqiu tst 2
						end
						else
						begin
							oam_process_info = 8'd6;//lose it 
						end
					end
					default:
					begin
						if(tr.dmac[40])// group mac
						begin
							oam_process_info = 8'd8;//fe01,sa->portmac,add old sa return
						end
						else if(tr.dmac == port_mac[port_num])
						begin
							oam_process_info = 8'd19;//fe01,sa->portmac,da->sys mac ,add old sa ,return
						end
						else 
						begin
							oam_process_info = 8'd4;//transmisstion
						end
					end
					endcase
				end
			end
			else if( (tr.pload[0][7:5] < tl_max_mel[2:0])//mel < LEV2
					&& (tr.pload[0][7:5] > tl_min_mel[2:0]) )//mel > LEV1
			begin
				oam_process_info = 8'd6;//lose it 
			end
			else if(tr.pload[0][7:5] == tl_min_mel[2:0])// mel == LEV1
			begin
				case(tr.pload[1])
				8'h01://ccm
				begin
					if(tl_min_mel_hard_ind)//hard info
					begin
						oam_process_info = 8'd12;//ff01,add lm,sa->portmac,return,add min_mel_oam_id
					end
					else 
					begin
						oam_process_info = 8'd13;//fe01,add lm,sa->portmac,add old sa return
					end
				end
				8'h2B://lmm
				begin
					if(tr.dmac[40])// group mac
					begin
						oam_process_info = 8'd42;//lmm fe01,add lm,sa->portmac,add old sa return
					end
					else if(tr.dmac == port_mac[port_num])
					begin
						oam_process_info = 8'd14;//fe01,add lm,sa->portmac,da->sys mac add old sa return
					end
					else 
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				8'h2A://lmr
				begin
					if(tr.dmac == port_mac[port_num])
					begin
						oam_process_info = 8'd14;//fe01,add lm,sa->portmac,da->sys mac add old sa return
					end
					else
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				8'h2d://1DM
				begin
					if(tr.dmac[40])// group mac
					begin
						oam_process_info = 8'd15;//fe01,add timestamp,sa->portmac,add old sa return
					end
					else if(tr.dmac == port_mac[port_num])
					begin
						oam_process_info = 8'd48;//fe01,add 1m,sa->portmac,da->sys mac ,add old sa ,return
					end
					else 
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				8'h2f://DMM
				begin
					if(tr.dmac[40])// group mac
					begin
						oam_process_info = 8'd15;//fe01,add timestamp,sa->portmac,add old sa return
					end
					else if(tr.dmac == port_mac[port_num])
					begin
						oam_process_info = 8'd48;//fe01,add lm,sa->portmac,da->sys mac ,add old sa ,return
					end
					else 
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				8'h2E://DMR
				begin
					if(tr.dmac == port_mac[port_num])
					begin
						oam_process_info = 8'd45;//fe01,add timestamp,sa->portmac,da->sys mac ,add old sa ,return
					end
					else
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				8'h25://tst
				begin
					if(tl_min_mel_lev_tst_ind)
					begin
						oam_process_info = 8'd6;//lose it 
						tst_cnt=tst_cnt+16'h1;// tst add 1
					end
					else
					begin
						oam_process_info = 8'd6;//lose it 
					end
				end
				default:
				begin
					if(tr.dmac[40])// group mac
					begin
						oam_process_info = 8'd8;//fe01,sa->portmac,add old sa return
					end
					else if(tr.dmac == port_mac[port_num])
					begin
						oam_process_info = 8'd19;//fe01,sa->portmac,da->sys mac ,add old sa ,return
					end
					else 
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				endcase
			end
			else // mel < LEV1
			begin
				oam_process_info = 8'd6;//lose it
			end	
		end
		else //data pkt
		begin
			if(vlan_num == 0) // no vlan
			begin
				oam_process_info = 8'd4;//transmisstion
			end
			else if(tl_min_mel_lck_ind || tl_max_mel_lck_ind)
			begin
				oam_process_info = 8'd6;//lose it 
			end
			else
			begin
				oam_process_info = 8'd4;//transmisstion
			end	
		end
	end
	default:
	begin
		oam_process_info = 8'd4;//transmisstion
	end
	endcase
endfunction

//==== oam rx up process
function void eth_refm::process_oam_rxup( 	eth_seq_item tr,
											bit[2:0]tl_node_type,bit[2:0]tl_min_mel,
											bit[3:0]port_num,
											bit[0:3][47:0]port_mac,
											ref bit [7:0] oam_process_info
											); 
	case(tl_node_type)
	3'b000://normal node 
	begin
		oam_process_info = 8'd4;//transmisstion
	end
	3'b001,3'b100,3'b011://mep node,mep1+mip2(LEV2>LEV1),mep1+mep2(LEV2>LEV1)
	begin
		if( (tr.eth_type == 16'h8902)
			&& (tr.smac == port_mac[port_num])
			&& (tr.pload[0][7:5] == tl_min_mel[2:0]) )
		begin
			case(tr.pload[1])
			8'h01://ccm
			begin
				oam_process_info = 8'd51;//ccm 16'h8902, add lm statistic
			end
			8'h2a://lmr(0x2a)
			begin
				oam_process_info = 8'd5;//lmr 16'h8902, add lm statistic
			end
			8'h2b://lmm(0x2b)
			begin
				oam_process_info = 8'd39;//lmm 16'h8902, add lm statistic
			end

			default:
			begin
				oam_process_info = 8'd4;//transmisstion
			end
			endcase
		end
		else
		begin
			oam_process_info = 8'd4;//transmisstion
		end
	end
	default:
	begin
		oam_process_info = 8'd4;//transmisstion
	end
	endcase
endfunction


//==== oam rx down process
function void eth_refm::process_oam_rxdown( eth_seq_item tr,
											bit[2:0]tl_node_type,bit[2:0]tl_min_mel,bit[2:0]tl_max_mel,
											bit tl_min_mel_lck_ind,bit tl_min_mel_hard_ind,
											bit tl_max_mel_lck_ind,bit tl_max_mel_hard_ind,
											bit [4:0]tl_min_mel_oam_id,
											bit tl_min_mel_lev_tst_ind,
											bit tl_max_mel_lev_tst_ind,
											bit[3:0]port_num,bit[3:0]vlan_num, 
											bit[0:3][47:0]port_mac,bit[0:3][47:0]system_mac,
											ref bit[15:0]tst_cnt,
											ref bit [7:0] oam_process_info
											); 	
	case(tl_node_type)
	3'b000://normal node 
	begin
		oam_process_info = 8'd4;//transmisstion
	end
	3'b001://mep node
	begin
		if(tr.eth_type == 16'h8902)//oam pkt
		begin
			if( (tr.pload[0][7:5] > tl_min_mel[2:0]) )//mel > LEV1
			begin
				if(tl_min_mel_lck_ind)
				begin
					oam_process_info = 8'd6;//lose it 
				end
				else
				begin
					oam_process_info = 8'd4;//transmisstion
				end
			end
			else if(tr.pload[0][7:5] == tl_min_mel[2:0])//mel == LEV1
			begin
				case(tr.pload[1])
				8'h01://ccm
				begin
					if(tl_min_mel_hard_ind)
					begin
						oam_process_info = 8'd30;//8902->ff02,add oam_id,addRxPC1
					end
					else
					begin
						oam_process_info = 8'd31;//8902->fe02,addRxPC1
					end
				end
				8'h2b,8'h2a://lmm/lmr
				begin
					oam_process_info = 8'd49;//8902->fe02,addRxPC1
				end
				8'h2d,8'h2f://1dm,dmm
				begin
					oam_process_info = 8'd32;//8902->fe02,addRxTimeStamp
				end
				8'h2e://dmr
				begin
					oam_process_info = 8'd50;//8902->fe02,addRxTimeStamp
				end
				
				8'h25://tst
				begin
					if(tl_min_mel_lev_tst_ind)
					begin
						oam_process_info = 8'd6;//lose it
						tst_cnt = tst_cnt + 1; //by cqiu
					end
					else
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				default:
				begin
					oam_process_info = 8'd33;//8902->fe02
				end
				endcase
			end
			else  // mel < LEV1
			begin
				oam_process_info = 8'd6;//lose it
			end
		end
		else //data pkt
		begin
			if(vlan_num != 0)
			begin
				if(tl_min_mel_lck_ind)
				begin
					oam_process_info = 8'd6;//lose it 
				end
				else
				begin
					oam_process_info = 8'd4;//transmisstion
				end
			end
			else
			begin
				oam_process_info = 8'd4;//transmisstion
			end
		end
	end
	3'b010://mip node
	begin
		if(tr.eth_type == 16'h8902)//oam pkt
		begin
			if( (tr.pload[0][7:5] > tl_min_mel[2:0]) )//mel > LEV1
			begin
				oam_process_info = 8'd4;//transmisstion
			end
			else if((tr.pload[0][7:5] == tl_min_mel[2:0]))//mel == LEV1
			begin
				if(tr.smac == port_mac[port_num])
				begin
					oam_process_info = 8'd4;//transmisstion
				end
				else
				begin
					case(tr.pload[1])
					8'h03://lbm
					begin
						if(tr.dmac != port_mac[port_num])
						begin
							oam_process_info = 8'd4;//transmisstion
						end
						else
						begin
							oam_process_info = 8'd34;//lbm,8902->fe02,da->system mac(cpu mac)
						end
					end
					8'h05://ltm
					begin
						oam_process_info = 8'd33;//8902->fe02
					end
					default:
					begin
						oam_process_info = 8'd4;//transmisstion
					end
					endcase
				end
			end 
			else //mel < LEV1
			begin
				oam_process_info = 8'd6;//lose it 
			end
		end
		else //data pkt
		begin
			oam_process_info = 8'd4;//transmisstion
		end
	end
	3'b100://mep1+mip2(LEV2>LEV1)
	begin
		if(tr.eth_type == 16'h8902)//oam pkt
		begin
			if (tr.pload[0][7:5] > tl_max_mel[2:0])//mel > LEV2
			begin
				if (tl_min_mel_lck_ind) // lck
				begin
					oam_process_info = 8'd6;//lose it 
				end
				else
				begin
					oam_process_info = 8'd4;//transmisstion
				end
			end
			else if (tr.pload[0][7:5] == tl_max_mel[2:0])//mel == LEV2
			begin
				if (tl_min_mel_lck_ind) // lck
				begin
					oam_process_info = 8'd6;//lose it 
				end
				else
				begin
					if(tr.smac == port_mac[port_num])
					begin
						oam_process_info = 8'd4;//transmisstion
					end
					else if( (tr.pload[1] == 8'h03)//lbm
							&& (tr.dmac == port_mac[port_num]) )
					begin
						oam_process_info = 8'd34;//8902->fe02,da->system mac(cpu mac)
					end
					else if(tr.pload[1] == 8'h05)
					begin
						oam_process_info = 8'd33;//8902->fe02
					end
					else 
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
			end
			else if( (tr.pload[0][7:5] < tl_max_mel[2:0])//mel < LEV2
					&& (tr.pload[0][7:5] > tl_min_mel[2:0]) )//mel > LEV1
			begin
				oam_process_info = 8'd6;//lose it 
			end
			else if(tr.pload[0][7:5] == tl_min_mel[2:0])// mel == LEV1
			begin
				case(tr.pload[1])
				8'h01://ccm
				begin
					if(tl_min_mel_hard_ind)//hard info
					begin
						oam_process_info = 8'd30;//8902->ff02,add oam_id,addRxPC1
					end
					else 
					begin
						oam_process_info = 8'd31;//8902->fe02,addRxPC1
					end
				end
				8'h2B,8'h2A://lmm/lmr
				begin
					oam_process_info = 8'd49;//8902->fe02,addRxPC1
				end
				8'h2d,8'h2f://1DM,DMM,
				begin
					oam_process_info = 8'd32;//8902->fe02,addRxTimeStamp
				end
				8'h2e://DMR
				begin
					oam_process_info = 8'd50;//8902->fe02,addRxTimeStamp
				end
				8'h25://tst
				begin
					if(tl_min_mel_lev_tst_ind)
					begin
						oam_process_info = 8'd6;//lose it 
						tst_cnt=tst_cnt+16'h1;// tst add 1 // by cqiu
					end
					else
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				default:
				begin
					oam_process_info = 8'd33;//8902->fe02
				end
				endcase
			end
			else // mel < LEV1
			begin
				oam_process_info = 8'd6;//lose it
			end	
		end
		else //data pkt
		begin
			if( (vlan_num != 0)
			  && tl_min_mel_lck_ind)
			begin
				oam_process_info = 8'd6;//lose it 
			end
			else
			begin
				oam_process_info = 8'd4;//transmisstion
			end
		end
	end
	3'b011://mep1+mep2(LEV2>LEV1)
	begin
		if(tr.eth_type == 16'h8902)//oam pkt
		begin
			if (tr.pload[0][7:5] > tl_max_mel[2:0])//mel > LEV2
			begin
				if (tl_min_mel_lck_ind || tl_max_mel_lck_ind) // lck
				begin
					oam_process_info = 8'd6;//lose it 
				end
				else
				begin
					oam_process_info = 8'd4;//transmisstion
				end
			end
			else if (tr.pload[0][7:5] == tl_max_mel[2:0])//mel == LEV2
			begin
				if (tl_min_mel_lck_ind) // lck
				begin
					oam_process_info = 8'd6;//lose it 
				end
				else
				begin
					case(tr.pload[1])
					8'h01://ccm
					begin
						if(tl_max_mel_hard_ind)//hard info
						begin
							oam_process_info = 8'd30;//8902->ff02,add oam_id,addRxPC1
						end
						else 
						begin
							oam_process_info = 8'd31;//8902->fe02,addRxPC1
						end
					end
					8'h2B,8'h2A://lmm/lmr
					begin
						oam_process_info = 8'd49;//8902->fe02,addRxPC1
					end
					8'h2d,8'h2f://1DM
					begin
						oam_process_info = 8'd32;//8902->fe02,addRxTimeStamp
					end
					8'h2e://DMM,DMR
					begin
						oam_process_info = 8'd50;//8902->fe02,addRxTimeStamp
					end
					8'h25://tst
					begin
						if(tl_max_mel_lev_tst_ind)
						begin
							oam_process_info = 8'd6;//lose it 
							tst_cnt=tst_cnt+16'h1;// tst add 1 // by cqiu
						end
						else
						begin
							oam_process_info = 8'd4;//transmisstion
						end
					end
					default:
					begin
						oam_process_info = 8'd33;//8902->fe02
					end
					endcase
				end
			end
			else if( (tr.pload[0][7:5] < tl_max_mel[2:0])//mel < LEV2
					&& (tr.pload[0][7:5] > tl_min_mel[2:0]) )//mel > LEV1
			begin
				oam_process_info = 8'd6;//lose it 
			end
			else if(tr.pload[0][7:5] == tl_min_mel[2:0])// mel == LEV1
			begin
				case(tr.pload[1])
				8'h01://ccm
				begin
					if(tl_min_mel_hard_ind)//hard info
					begin
						oam_process_info = 8'd30;//8902->ff02,add oam_id,addRxPC1
					end
					else 
					begin
						oam_process_info = 8'd31;//8902->fe02,addRxPC1
					end
				end
				8'h2B,8'h2A://lmm/lmr
				begin
					oam_process_info = 8'd49;//8902->fe02,addRxPC1
				end
				8'h2d,8'h2f://1DM,DMM
				begin
					oam_process_info = 8'd32;//8902->fe02,addRxTimeStamp
				end
				8'h2e://DMR
				begin
						oam_process_info = 8'd50;//8902->fe02,addRxTimeStamp
				end
				8'h25://tst
				begin
					if(tl_min_mel_lev_tst_ind)
					begin
						oam_process_info = 8'd6;//lose it 
						tst_cnt=tst_cnt+16'h1;// tst add 1 // by cqiu
					end
					else
					begin
						oam_process_info = 8'd4;//transmisstion
					end
				end
				default:
				begin
					oam_process_info = 8'd33;//8902->fe02
				end
				endcase
			end
			else // mel < LEV1
			begin
				oam_process_info = 8'd6;//lose it
			end	
		end
		else //data pkt
		begin
			if( (vlan_num != 0)
			  && tl_min_mel_lck_ind)
			begin
				oam_process_info = 8'd6;//lose it 
			end
			else
			begin
				oam_process_info = 8'd4;//transmisstion
			end
		end
	end
	default:
	begin
		oam_process_info = 8'd4;//transmisstion
	end
	endcase

		
endfunction
