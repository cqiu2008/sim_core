//`include "uvm_mocras.svh"
//import uvm_pkg::*;

class eth_input_seq extends uvm_sequence #(eth_seq_item);
    eth_seq_item m_trans	;
	eth_private_config	eth_private_cfg[16]	;
	eth_public_config   eth_public_cfg		;
	int		pck_num			;
	bit [1:0] sync_seq_state 	;
	bit [1:0] sync_seq_state_next;

    extern function new(string name ="eth_input_seq");
    extern virtual task body();

    `uvm_object_utils_begin(eth_input_seq)
		`uvm_field_object(eth_private_cfg[0],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[1],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[2],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[3],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[4],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[5],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[6],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[7],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[8],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[9],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[10],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[11],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[12],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[13],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[14],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_private_cfg[15],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(eth_public_cfg,UVM_ALL_ON | UVM_REFERENCE)
	`uvm_object_utils_end

	`uvm_declare_p_sequencer(eth_input_sequencer)

endclass

function eth_input_seq::new(string name = "eth_input_seq");
	string i_str ;
    super.new(name);
	sync_seq_state 		= 2'b00;
	sync_seq_state_next 	= 2'b00;
	for(int i=0;i<16;i++)
	begin
		i_str = $psprintf("[%0d]",i);
		eth_private_cfg[i] = eth_private_config::type_id::create({"eth_private_cfg",i_str});
	end
		eth_public_cfg = eth_public_config::type_id::create("eth_public_cfg");
	pck_num = 0;
endfunction

task eth_input_seq::body();
	//int	i_pck=0;
   	if(starting_phase != null)
    	starting_phase.raise_objection(this);
	for(int i=0;i<16;i++)
	begin
		this.eth_private_cfg[i] = p_sequencer.eth_private_cfg[i];
	end
		this.eth_public_cfg	= p_sequencer.eth_public_cfg;

	$display("eth_public_cfg.pck_num=%d\n",eth_public_cfg.pck_num);
	repeat(eth_public_cfg.pck_num) 
	begin
		`uvm_info($sformatf("sync_seq_state=%d",sync_seq_state),"",UVM_LOW)
		//==(1) calculate the "sync_seq_state_next" value
		if( p_sequencer.out_mon.sync_mon_state == 2'b00) 
		begin //comming to connect packet state
			sync_seq_state_next = 2'b00;
		end 
		if( p_sequencer.out_mon.sync_mon_state == 2'b01) 
		begin //comming to header packet state
			sync_seq_state_next = 2'b01;
		end
		if(sync_seq_state == 2'b01) 
		begin //comming to normal packet state
			sync_seq_state_next = 2'b10;
		end
		//==(2) update the sync_seq_state value 
		sync_seq_state = sync_seq_state_next;
		p_sequencer.sync_sqr_state = sync_seq_state;
		//`uvm_info($sformatf("sync_seq_state=%d",sync_seq_state),"",UVM_LOW)
		//==(3) sending the packet according to the syn_seq_state  
		case(sync_seq_state)
		2'b00: // connect state , send the connect pkt
		begin
			`uvm_do_with(m_trans,{
				m_trans.set_err				== eth_private_cfg[0].set_err				;
				m_trans.dmac	   			== eth_private_cfg[0].dmac					;
				m_trans.smac	   			== eth_private_cfg[0].smac					;
				m_trans.vlan_word_size		== eth_private_cfg[0].vlan_word_size		;
				m_trans.vlan_word_mem		== eth_private_cfg[0].vlan_word_mem			;
				m_trans.eth_type		 	== eth_private_cfg[0].eth_type				;
				m_trans.pload_set_type		== eth_private_cfg[0].pload_set_type		;
				m_trans.pload_set_length	== eth_private_cfg[0].pload_set_length		;
				m_trans.pload_set_fix_value == eth_private_cfg[0].pload_set_fix_value	;
				m_trans.pload_set_inc_value == eth_private_cfg[0].pload_set_inc_value	;
				m_trans.random_length_low	== eth_private_cfg[0].random_length_low		;
				m_trans.random_length_high	== eth_private_cfg[0].random_length_high	;
				m_trans.sub_head_size		== eth_private_cfg[0].sub_head_size			;
				m_trans.sub_head_mem		== eth_private_cfg[0].sub_head_mem			;
				m_trans.port_info			== 4'd0										;//4'd1,oam pkt from tx port return to rx port; 
				m_trans.port_num			== 2'd0										;//for 10g xgmii port number 
				m_trans.preamble_type		== eth_private_cfg[0].preamble_type			;
			})//向sequencer发送1个数据
			$display("sending connect packet num = %0d",pck_num);
			this.pck_num = this.pck_num + 1;
		end
		2'b01: // header state ,sending the header packet (only one time) 
		begin
			`uvm_do_with(m_trans,{
				m_trans.set_err				== eth_private_cfg[0].set_err				;
				m_trans.dmac	   			== ~eth_private_cfg[0].dmac					;// reverse the dmac value
				m_trans.smac	   			== eth_private_cfg[0].smac					;
				m_trans.vlan_word_size		== eth_private_cfg[0].vlan_word_size		;
				m_trans.vlan_word_mem		== eth_private_cfg[0].vlan_word_mem			;
				m_trans.eth_type		 	== eth_private_cfg[0].eth_type				;
				m_trans.pload_set_type		== eth_private_cfg[0].pload_set_type		;
				m_trans.pload_set_length	== eth_private_cfg[0].pload_set_length		;
				m_trans.pload_set_fix_value == eth_private_cfg[0].pload_set_fix_value	;
				m_trans.pload_set_inc_value == eth_private_cfg[0].pload_set_inc_value	;
				m_trans.random_length_low	== eth_private_cfg[0].random_length_low		;
				m_trans.random_length_high	== eth_private_cfg[0].random_length_high	;
				m_trans.sub_head_size		== eth_private_cfg[0].sub_head_size			;
				m_trans.sub_head_mem		== eth_private_cfg[0].sub_head_mem			;
				m_trans.port_info			== 4'd0										;//4'd1,oam pkt from tx port return to rx port; 
				m_trans.port_num			== 2'd0										;//for 10g xgmii port number 
				m_trans.preamble_type		== eth_private_cfg[0].preamble_type			;
			})//向sequencer发送1个数据
			$display("sending header packet num = %0d",pck_num);
			this.pck_num = this.pck_num + 1;
		end
		default: // normal state , sending the normal packet 
		begin
			for(int i=0;i<eth_public_cfg.stream_num;i++)
			begin
				for(int j=0;j<eth_private_cfg[i].pck_freq;j++)
				begin
				`uvm_do_with(m_trans,{
					m_trans.set_err				== eth_private_cfg[i].set_err				;
					m_trans.dmac	   			== eth_private_cfg[i].dmac					;
					m_trans.smac	   			== eth_private_cfg[i].smac					;
					m_trans.vlan_word_size		== eth_private_cfg[i].vlan_word_size		;
					m_trans.vlan_word_mem		== eth_private_cfg[i].vlan_word_mem			;// whole assgin
					m_trans.eth_type		 	== eth_private_cfg[i].eth_type				;
					m_trans.pload_set_type		== eth_private_cfg[i].pload_set_type		;
					m_trans.pload_set_length	== eth_private_cfg[i].pload_set_length		;
					m_trans.pload_set_fix_value == eth_private_cfg[i].pload_set_fix_value	;
					m_trans.pload_set_inc_value == eth_private_cfg[i].pload_set_inc_value	;
					m_trans.random_length_low	== eth_private_cfg[i].random_length_low		;
					m_trans.random_length_high	== eth_private_cfg[i].random_length_high	;
					m_trans.sub_head_size		== eth_private_cfg[i].sub_head_size			;
					m_trans.sub_head_mem		== eth_private_cfg[i].sub_head_mem			;
					m_trans.port_info			== 4'd0										;//4'd1,oam pkt from tx port return to rx port; 
					m_trans.port_num			== eth_private_cfg[i].port_num				;//for 10g xgmii port number 
					m_trans.preamble_type		== eth_private_cfg[i].preamble_type			;
									})//向sequencer发送1个数据
				$display("sending package num = %0d",pck_num);
				$display("m_pload_set_length= %0d",m_trans.pload_set_length);
				$display("m_pload_set_type= %0d",m_trans.pload_set_type);
				$display("eth_private_cfg[%0d].port_num= %0d",i,eth_private_cfg[i].port_num);
				this.pck_num = this.pck_num + 1;
				end
			end
		end
		endcase
	end
    #100;
    if(starting_phase != null)
	begin
		// starting_phase.drop_objection(this);
		$display("Ending uvm simulation by cqiu\n");
		$stop;
	end
endtask


/*
//====ipv4 sub type
	rand bit [3:0]	ipv4_version			;
	rand bit [3:0]	ipv4_hander_length		;
	rand bit [7:0]	ipv4_service_type		;
	rand bit [15:0]	ipv4_total_length		;
	rand bit [15:0]	ipv4_identifier			;	
	rand bit [2:0]	ipv4_flags				;
	rand bit [12:0]	ipv4_fragment_offset	;
	rand bit [7:0]	ipv4_time_to_live		;
	rand bit [7:0]	ipv4_protocol			;
	rand bit [15:0]	ipv4_hander_checksum	;
	rand bit [31:0]	ipv4_src_address		;
	rand bit [31:0]	ipv4_dst_address		;
//====udp sub type
	rand bit [15:0]	udp_src_port_num		;
	rand bit [15:0]	udp_dst_port_num		;
	rand bit [15:0]	udp_length				;
	rand bit [15:0]	udp_checksum			;
//====ptp sub type
	rand bit [3:0]	ptp_transport_specific	;
	rand bit [3:0]	ptp_message_type		;
	rand bit [3:0]	ptp_reserved1			;
	rand bit [3:0]	ptp_version				;
	rand bit [15:0]	ptp_message_length		;
	rand bit [7:0]	ptp_domain_number		;
	rand bit [7:0]	ptp_reserved2			;
	rand bit [15:0] ptp_flgs				;
	rand bit [63:0] ptp_correction_field	;
	rand bit [31:0] ptp_reserved3			;
	rand bit [79:0] ptp_src_port_id			;
	rand bit [15:0] ptp_sequence_id			;
	rand bit [7:0]  ptp_control_field		;
	rand bit [7:0]  ptp_log_message_interval;
*/
/*
			 	3'b100: //// syn pck
				begin
            	`uvm_do_with(m_trans,{	
										m_trans.dmac				== 48'hf0f1f2_f3f4f5;//sync dmac                      
										m_trans.smac				== 48'h010101_010101;
										m_trans.vlan_word_size		== 16'h2			;//vlan_layer_num,0:no vlan,1:1 layer vlan
										m_trans.vlan_word_mem[0]	== 32'h8100_0002	; 
										m_trans.vlan_word_mem[1]	== 32'h8100_0001	; 
										m_trans.eth_type			== eth_private_cfg[0].eth_type_value;
										m_trans.sub_head_size		== 16'h5			;
										m_trans.sub_head_mem[0]		== 8'h38			;
										m_trans.sub_head_mem[1]		== 8'h27			;
										m_trans.sub_head_mem[2]		== 8'h16			;
										m_trans.sub_head_mem[3]		== 8'h05			;
										m_trans.sub_head_mem[4]		== 8'hf4			;
										m_trans.pload_size			== 16'd65			;
										m_trans.pload_set_type		== 4'b1010			;//(b3=1,fix_length,b3=0,random_length)(b2-b0:random,fix,increase)
										m_trans.pload_set_length	== 16'h40			;
										m_trans.pload_set_fix_value == 8'hd9			;
										m_trans.pload_set_inc_value == 8'h01			;
										m_trans.set_err				== 4'b0000			;//err==b0:preamble,b1:sfd,b2:pload,b3,crc
										} )
				end
*/

/*
    eth_private_cfg.preamble_value			= 8'h55	;//preamble_value
    eth_private_cfg.sfd_value				= 8'hd5	;//sfd_value		
    eth_private_cfg.dmac_value				= 48'h0101_5678_9abc;//destination mac 
    eth_private_cfg.smac_value				= 48'h0202_def0_1234;//source mac value
    eth_private_cfg.ctrl_vlan_num			= 4'b0011;//vlan==b0:vlan1,b1:vlan2,b2:vlan3,b3:vlan4
    eth_private_cfg.vlan2_type_value		= 16'h88a8;//vlan_type
    eth_private_cfg.vlan2_cfi_value			= 1'b0;//vlan_cfi
    eth_private_cfg.vlan2_prio_value		= 3'h0;//vlan_priority
    eth_private_cfg.vlan2_id_value			= 12'h01;//vlan_id
    eth_private_cfg.vlan1_type_value		= 16'h8100;//vlan_type
    eth_private_cfg.vlan1_cfi_value			= 1'b0;//vlan_cfi
    eth_private_cfg.vlan1_prio_value		= 3'h3;//vlan_priority
    eth_private_cfg.vlan1_id_value			= 12'h02;//vlan_id
    eth_private_cfg.eth_type_value			= 16'h0800;//eth_type_value
    eth_private_cfg.ctrl_sub_type			= 3'b000;//subtype==b0:ipv4,b1:udp,b2:ptp,
    eth_private_cfg.ctrl_err				= 4'b0000;//err==b0:preamble,b1:sfd,b2:pload,b3,crc
    eth_private_cfg.pload_fix_value			= 8'h37;//eth_type_value
	eth_private_cfg.pck_num					= 300;//the number of sending packages
	*/
/*
		3'b100: 
		begin
        `uvm_do_with( m_trans,{	
								m_trans.dmac				== 48'he0e0111111111;//sync dmac                      
								m_trans.smac				== 48'h010101_010101;
								m_trans.vlan_word_size		== 16'h1			;//vlan_layer_num,0:no vlan,1:1 layer vlan
								m_trans.vlan_word_mem[0]	== 32'h8100_0002	; 
								m_trans.eth_type			== 16'h88f7			;//1588 pdu 
								m_trans.sub_head_size		== 16'd34			;//PDU length
								m_trans.sub_head_mem[0]		== 8'h30			;//transportSpecific(4b),messageType(4b=0x0,0x8,0x1,0x9)
								m_trans.sub_head_mem[1]		== 8'h02			;//reserved(4b),versionPTP(4b=0x2) 
								m_trans.sub_head_mem[2]		== 8'h01			;//messageLength (1B-H)
								m_trans.sub_head_mem[3]		== 8'h00			;//messageLength (1B-L)
								m_trans.sub_head_mem[4]		== 8'hf4			;//domainNumber (1B)
								m_trans.sub_head_mem[5]		== 8'h00			;//reserved	(1B)
								m_trans.sub_head_mem[6]		== 8'h01			;//flagField(1B-H)
								m_trans.sub_head_mem[7]		== 8'h00			;//flagField(1B-L)
								m_trans.sub_head_mem[8]		== 8'h07			;//correctionField(1B-H7)
								m_trans.sub_head_mem[9]		== 8'h06			;//correctionField(1B-H6)
								m_trans.sub_head_mem[10]	== 8'h05			;//correctionField(1B-H5)
								m_trans.sub_head_mem[11]	== 8'h04			;//correctionField(1B-H4)
								m_trans.sub_head_mem[12]	== 8'h03			;//correctionField(1B-H3)
								m_trans.sub_head_mem[13]	== 8'h02			;//correctionField(1B-H2)
								m_trans.sub_head_mem[14]	== 8'h01			;//correctionField(1B-H1)
								m_trans.sub_head_mem[15]	== 8'h00			;//correctionField(1B-H0)
								m_trans.sub_head_mem[16]	== 8'h00			;//reserved (1B-H3)
								m_trans.sub_head_mem[17]	== 8'h00			;//reserved (1B-H2)
								m_trans.sub_head_mem[18]	== 8'h00			;//reserved (1B-H1)
								m_trans.sub_head_mem[19]	== 8'h00			;//reserved (1B-H0)
								m_trans.sub_head_mem[20]	== 8'h09			;//sourcePortIdentity (1B-H9)
								m_trans.sub_head_mem[21]	== 8'h08			;//sourcePortIdentity (1B-H8)
								m_trans.sub_head_mem[22]	== 8'h07			;//sourcePortIdentity (1B-H7)
								m_trans.sub_head_mem[23]	== 8'h06			;//sourcePortIdentity (1B-H6)
								m_trans.sub_head_mem[24]	== 8'h05			;//sourcePortIdentity (1B-H5)
								m_trans.sub_head_mem[25]	== 8'h04			;//sourcePortIdentity (1B-H4)
								m_trans.sub_head_mem[26]	== 8'h03			;//sourcePortIdentity (1B-H3)
								m_trans.sub_head_mem[27]	== 8'h02			;//sourcePortIdentity (1B-H2)
								m_trans.sub_head_mem[28]	== 8'h01			;//sourcePortIdentity (1B-H1)
								m_trans.sub_head_mem[29]	== 8'h00			;//sourcePortIdentity (1B-H0)
								m_trans.sub_head_mem[30]	== 8'h01			;//sequenceID (1B-H1)
								m_trans.sub_head_mem[31]	== 8'h00			;//sequenceID (1B-H0)
								m_trans.sub_head_mem[32]	== 8'h33			;//controlField(1B)
								m_trans.sub_head_mem[33]	== 8'h44			;//logMessageInterval(1B)
								m_trans.pload_set_type		== 4'b1001			;//(b3=1,fix_length,b3=0,random_length)(b2-b0:random,fix,increase)
								m_trans.pload_set_length	== 16'd10			;
								m_trans.pload_set_fix_value == 8'hf2			;
								m_trans.pload_set_inc_value == 8'h01			;
								m_trans.set_err				== 4'b0000			;//err==b0:preamble,b1:sfd,b2:pload,b3,crc
								} )
		//first_head_en = 1'b0;
		end
*/
