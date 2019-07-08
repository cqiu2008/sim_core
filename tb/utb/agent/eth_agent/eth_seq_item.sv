//`include "uvm_macros.svh"
//import uvm_pkg::*;

//vlan_type 
//bit [15:0] a_vlan_type[4] = '{16'h8100,16'h88a8,16'h9100,16'h9200};
//int a_vlan_type[4] = '{16'h8100,16'h88a8,16'h9100,16'h9200};

class eth_seq_item extends uvm_sequence_item;

    rand bit [7:0]  preamble[] 				;
	rand bit [7:0]  sfd		 				;	
    rand bit [47:0] dmac					;
    rand bit [47:0] smac					;
	rand bit [31:0] vlan_word[] 			;//b31-16:type,b15:cfi,b14-12:priority,b11-0:id 
    rand bit [15:0] eth_type				;
	rand bit [7:0] 	pload[]					;//声明成员变量，pload存放的是载荷
	rand bit [31:0] eth_crc					;

	rand bit [7:0] 	preamble_size			;
	rand bit [15:0] vlan_word_size 			;
	rand bit [0:7][31:0]vlan_word_mem		;
	rand bit [15:0] sub_head_size			;
	rand bit [0:511][7:0]sub_head_mem		;
	rand bit [15:0] pload_size				;
	rand bit [3:0]  pload_set_type			;//(b3=1,fix_length,b3=0,random_length)(b2-b0:random,fix,increase)
	rand bit [15:0] pload_set_length		;
	rand bit [7:0]  pload_set_fix_value		;
	rand bit [7:0]  pload_set_inc_value		;//pload 
	rand bit [15:0] random_length_low		;
	rand bit [15:0] random_length_high		;
	rand bit [ 7:0] preamble_type			;//(b0=1,hc,pkt)
	rand bit [3:0] 	set_err					;//err==b0:preamble,b1:sfd,b2:pload,b3,crc
	rand bit [3:0]  port_info				;//==4'd1,oam pkt from tx port return to rx port; 
	rand bit [1:0]  port_num				;//for 10g xgmii port number

constraint cons_preamble_size {
	if (set_err[0])
		preamble_size inside {[0:3]};	
	else
       	preamble_size inside {[3:3]};// sub 555555 total 3 
}
constraint cons_sfd_type {
	if (set_err[1])
		sfd == 8'h5d;
	else
		sfd == 8'hd5; 
}
constraint cons_pload_size {
	if (set_err[2])
		pload_size inside {[1:45]}; 
	else if(pload_set_type[3])// b3=1, fix length,else random length
		pload_size == pload_set_length ; 
	else
        pload_size inside {[random_length_low:random_length_high]}; 
}
	
    extern function new (string name = "eth_seq_item");

	extern function void post_randomize();

	extern function	void crc32_calculate();	

    `uvm_object_utils_begin(eth_seq_item)
        `uvm_field_array_int(preamble,UVM_ALL_ON+UVM_NOCOMPARE)
        `uvm_field_int(sfd,UVM_ALL_ON+UVM_NOCOMPARE)
        `uvm_field_int(dmac,UVM_ALL_ON)
        `uvm_field_int(smac,UVM_ALL_ON)
        `uvm_field_array_int(vlan_word,UVM_ALL_ON)//b31-16:type,b15:cfi,b14-12:priority,b11-0:id 
        `uvm_field_int(eth_type,UVM_ALL_ON)
        `uvm_field_array_int(pload,UVM_ALL_ON)
        `uvm_field_int(eth_crc,UVM_ALL_ON)
		//==== UVM_NOPACK
		`uvm_field_int(preamble_size,UVM_ALL_ON|UVM_NOPACK|UVM_NOCOMPARE)
		`uvm_field_int(vlan_word_size,UVM_ALL_ON|UVM_NOPACK)
		`uvm_field_sarray_int(vlan_word_mem,UVM_ALL_ON|UVM_NOPACK)
		`uvm_field_int(sub_head_size,UVM_ALL_ON|UVM_NOPACK)
		`uvm_field_sarray_int(sub_head_mem,UVM_ALL_ON|UVM_NOPACK)
		`uvm_field_int(pload_size,UVM_ALL_ON|UVM_NOPACK)
		`uvm_field_int(pload_set_type,UVM_ALL_ON|UVM_NOPACK)
		`uvm_field_int(pload_set_length,UVM_ALL_ON|UVM_NOPACK)
		`uvm_field_int(pload_set_fix_value,UVM_ALL_ON|UVM_NOPACK)
		`uvm_field_int(pload_set_inc_value,UVM_ALL_ON|UVM_NOPACK)
		`uvm_field_int(random_length_low,UVM_ALL_ON|UVM_NOPACK)
		`uvm_field_int(random_length_high,UVM_ALL_ON|UVM_NOPACK)
		`uvm_field_int(set_err,UVM_ALL_ON|UVM_NOPACK)
		`uvm_field_int(preamble_type,UVM_ALL_ON|UVM_NOPACK)
		`uvm_field_int(port_info,UVM_ALL_ON|UVM_NOPACK)
		`uvm_field_int(port_num,UVM_ALL_ON|UVM_NOPACK)


    `uvm_object_utils_end//上面是为了加入factory实现，其是factory实现要使用的uvm_object_utils要使用的宏
endclass

function eth_seq_item::new(string name = "eth_seq_item");
    super.new(name);
endfunction


function void eth_seq_item::crc32_calculate();
begin
	int i;
	bit [7:0]a_d[]		;
	int crc_length		;
	bit [31:0]crc_pre	;

	crc_length=6+6+((vlan_word.size)<<2)+2+(pload.size);
//====initial 
		a_d = new[crc_length];
		a_d = {>>{dmac,smac,vlan_word,eth_type,pload}};
//====crc32 calculate body
	crc_pre = 32'hffff_ffff			;
	for(i=0;i<crc_length;i++)
	begin
 		eth_crc[0] =  crc_pre[24] ^ crc_pre[30] ^ a_d[i][1]   ^ a_d[i][7] ;
      	eth_crc[1] =  crc_pre[24] ^ crc_pre[25] ^ crc_pre[30] ^ crc_pre[31] ^ a_d[i][0]   ^ a_d[i][1]   ^ a_d[i][7]   ^ a_d[i][6] ;
      	eth_crc[2] =  crc_pre[24] ^ crc_pre[25] ^ crc_pre[26] ^ crc_pre[30] ^ crc_pre[31] ^ a_d[i][0]   ^ a_d[i][5]   ^ a_d[i][6]   ^ a_d[i][1]    ^ a_d[i][7] ;
      	eth_crc[3] =  crc_pre[25] ^ crc_pre[26] ^ crc_pre[27] ^ crc_pre[31] ^ a_d[i][0]   ^ a_d[i][4]   ^ a_d[i][5]   ^ a_d[i][6]    ;              
      	eth_crc[4] =  crc_pre[24] ^ crc_pre[26] ^ crc_pre[27] ^ crc_pre[28] ^ crc_pre[30] ^ a_d[i][1]   ^ a_d[i][3]   ^ a_d[i][4]   ^ a_d[i][5]    ^ a_d[i][7]    ;
      	eth_crc[5] =  crc_pre[24] ^ crc_pre[25] ^ crc_pre[27] ^ crc_pre[28] ^ crc_pre[29] ^ crc_pre[30] ^ crc_pre[31] ^ a_d[i][0]   ^ a_d[i][1]    ^ a_d[i][2]    ^ a_d[i][3]   ^ a_d[i][4]  ^ a_d[i][6] ^ a_d[i][7] ;
      	eth_crc[6] =  crc_pre[31] ^ crc_pre[30] ^ crc_pre[29] ^ crc_pre[28] ^ crc_pre[26] ^ crc_pre[25] ^ a_d[i][6]   ^ a_d[i][5]   ^ a_d[i][3]    ^ a_d[i][2]    ^ a_d[i][1]   ^ a_d[i][0];
      	eth_crc[7] =  crc_pre[24] ^ crc_pre[26] ^ crc_pre[27] ^ crc_pre[29] ^ crc_pre[31] ^ a_d[i][0]   ^ a_d[i][2]   ^ a_d[i][4]   ^ a_d[i][5]    ^ a_d[i][7]    ; 
      	eth_crc[8] =  crc_pre[0]  ^ crc_pre[24] ^ crc_pre[25] ^ crc_pre[27] ^ crc_pre[28] ^ a_d[i][3]   ^ a_d[i][4]   ^ a_d[i][6]   ^ a_d[i][7]    ;
      	eth_crc[9] =  crc_pre[1]  ^ crc_pre[25] ^ crc_pre[26] ^ crc_pre[28] ^ crc_pre[29] ^ a_d[i][2]   ^ a_d[i][3]   ^ a_d[i][5]   ^ a_d[i][6];
      	eth_crc[10]=  crc_pre[2]  ^ crc_pre[24] ^ crc_pre[26] ^ crc_pre[27] ^ crc_pre[29] ^ a_d[i][4]   ^ a_d[i][2]   ^ a_d[i][7]   ^ a_d[i][5]    ;
      	eth_crc[11]=  crc_pre[24] ^ crc_pre[25] ^ crc_pre[3]  ^ crc_pre[28] ^ crc_pre[27] ^ a_d[i][7]   ^ a_d[i][3]   ^ a_d[i][4]   ^ a_d[i][6]    ;
      	eth_crc[12]=  crc_pre[24] ^ crc_pre[28] ^ crc_pre[25] ^ crc_pre[26] ^ crc_pre[29] ^ crc_pre[30] ^ crc_pre[4]  ^ a_d[i][1]   ^ a_d[i][7]    ^ a_d[i][2]    ^ a_d[i][3]    ^ a_d[i][5]    ^ a_d[i][6]  ;
      	eth_crc[13]=  crc_pre[29] ^ crc_pre[26] ^ crc_pre[25] ^ crc_pre[31] ^ crc_pre[5]  ^ crc_pre[30] ^ crc_pre[27] ^ a_d[i][2]   ^ a_d[i][4]    ^ a_d[i][5]    ^ a_d[i][0]    ^ a_d[i][1]    ^ a_d[i][6]    ;
      	eth_crc[14]=  crc_pre[6]  ^ crc_pre[31] ^ crc_pre[30] ^ crc_pre[28] ^ crc_pre[27] ^ crc_pre[26] ^ a_d[i][0]   ^ a_d[i][1]   ^ a_d[i][3]    ^ a_d[i][4]    ^ a_d[i][5]    ;
      	eth_crc[15]=  crc_pre[7]  ^ crc_pre[31] ^ crc_pre[29] ^ crc_pre[28] ^ crc_pre[27] ^ a_d[i][0]   ^ a_d[i][2]   ^ a_d[i][3]   ^ a_d[i][4]    ;
      	eth_crc[16]=  crc_pre[8]  ^ crc_pre[29] ^ crc_pre[28] ^ crc_pre[24] ^ a_d[i][2]   ^ a_d[i][3]   ^ a_d[i][7] 	;
      	eth_crc[17]=  crc_pre[9]  ^ crc_pre[30] ^ crc_pre[29] ^ crc_pre[25] ^ a_d[i][1]   ^ a_d[i][2]   ^ a_d[i][6]    	; 
      	eth_crc[18]=  crc_pre[10] ^ crc_pre[31] ^ crc_pre[30] ^ crc_pre[26] ^ a_d[i][0]   ^ a_d[i][1]   ^ a_d[i][5]    	;
      	eth_crc[19]=  crc_pre[11] ^ crc_pre[31] ^ crc_pre[27] ^ a_d[i][0]   ^ a_d[i][4]    ;
      	eth_crc[20]=  crc_pre[12] ^ crc_pre[28] ^ a_d[i][3]    	;                
      	eth_crc[21]=  crc_pre[13] ^ crc_pre[29] ^ a_d[i][2]    	;                
      	eth_crc[22]=  crc_pre[14] ^ crc_pre[24] ^ a_d[i][7]		;
      	eth_crc[23]=  crc_pre[24] ^ crc_pre[30] ^ crc_pre[15]  ^ crc_pre[25] ^ a_d[i][7]    ^ a_d[i][1]    ^ a_d[i][6]   ;
      	eth_crc[24]=  crc_pre[16] ^ crc_pre[26] ^ crc_pre[25]  ^ crc_pre[31] ^ a_d[i][5]    ^ a_d[i][6]    ^ a_d[i][0]   ;
      	eth_crc[25]=  crc_pre[17] ^ crc_pre[27] ^ crc_pre[26]  ^ a_d[i][4]    ^ a_d[i][5]    ;               
      	eth_crc[26]=  crc_pre[24] ^ crc_pre[30] ^ crc_pre[18]  ^ crc_pre[28] ^ crc_pre[27]^ a_d[i][7]    ^ a_d[i][1]    ^ a_d[i][3]   ^ a_d[i][4] ;
      	eth_crc[27]=  crc_pre[19] ^ crc_pre[29] ^ crc_pre[28]  ^ crc_pre[25] ^ crc_pre[31]^ a_d[i][2]    ^ a_d[i][3]    ^ a_d[i][6]   ^ a_d[i][0] ;
      	eth_crc[28]=  crc_pre[20] ^ crc_pre[30] ^ crc_pre[26]  ^ crc_pre[29] ^ a_d[i][1]    ^ a_d[i][5]    ^ a_d[i][2] ;
      	eth_crc[29]=  crc_pre[21] ^ crc_pre[31] ^ crc_pre[30]  ^ crc_pre[27] ^ a_d[i][0]    ^ a_d[i][1]    ^ a_d[i][4]    ;
      	eth_crc[30]=  crc_pre[22] ^ crc_pre[31] ^ crc_pre[28]  ^ a_d[i][0]    ^ a_d[i][3]    ;
      	eth_crc[31]=  crc_pre[23] ^ crc_pre[29] ^ a_d[i][2]    ;    
		crc_pre = eth_crc;
		//$display("ad[%0d]=%h\n",i,a_d[i]);
	end
		eth_crc =	~{
						crc_pre[24],crc_pre[25],crc_pre[26],crc_pre[27],
						crc_pre[28],crc_pre[29],crc_pre[30],crc_pre[31],
						crc_pre[16],crc_pre[17],crc_pre[18],crc_pre[19],
						crc_pre[20],crc_pre[21],crc_pre[22],crc_pre[23],
						crc_pre[8],crc_pre[9],crc_pre[10],crc_pre[11],
						crc_pre[12],crc_pre[13],crc_pre[14],crc_pre[15],
						crc_pre[0],crc_pre[1],crc_pre[2],crc_pre[3],
						crc_pre[4],crc_pre[5],crc_pre[6],crc_pre[7]
						};

		$display("eth_crc=%h\n",eth_crc);
end
endfunction

function void eth_seq_item::post_randomize();
//==== preamble process 
	preamble=new[preamble_size];
	for(int i =0; i<preamble_size;i++)
	begin
		preamble[i] = 8'h55;
	end
//==== vlan process 
	vlan_word=new[vlan_word_size];
	for(int i=0;i<vlan_word_size;i++)
	begin
		vlan_word[i] = vlan_word_mem[i]; 
	end	
//==== pload process
	pload = new [sub_head_size+pload_size];
	for(int i=0;i<sub_head_size;i++)
	begin
		pload[i] = sub_head_mem[i]; 
	end	
	for(int i=sub_head_size;i<(pload_size+sub_head_size);i++)
	begin
		case (pload_set_type[2:0])
		3'b001: // increase  
			pload[i] = pload_set_inc_value+(i%256)-sub_head_size;
		3'b010: // fix
			pload[i] = pload_set_fix_value; 
		3'b100: // random 
			pload[i] = $random % 256; 
		default:
			pload[i] = $random % 256; 
		endcase
	end
//==== crc process
	crc32_calculate();

endfunction

/*
//====can working but cann't display the vlan_number
		for(vlan_num = 0; vlan_num < 4 ; vlan_num=vlan_num+1)
		begin
			if(ctrl_vlan_num[3-vlan_num])
			begin
				`uvm_field_int(vlan_type[3-vlan_num],UVM_ALL_ON)	
				`uvm_field_int(vlan_cfi[3-vlan_num]	,UVM_ALL_ON)	
				`uvm_field_int(vlan_prio[3-vlan_num],UVM_ALL_ON)	
				`uvm_field_int(vlan_id[3-vlan_num]	,UVM_ALL_ON)	
			end
		end
*/
/*
		if(ctrl_sub_type[0])//subtype==b0:ipv4,b1:udp,b2:ptp,
		begin
			`uvm_field_int(ipv4_version				,UVM_ALL_ON)
			`uvm_field_int(ipv4_hander_length		,UVM_ALL_ON)
			`uvm_field_int(ipv4_service_type		,UVM_ALL_ON)
			`uvm_field_int(ipv4_total_length		,UVM_ALL_ON)
			`uvm_field_int(ipv4_identifier			,UVM_ALL_ON)	
			`uvm_field_int(ipv4_flags				,UVM_ALL_ON)
			`uvm_field_int(ipv4_fragment_offset		,UVM_ALL_ON)
			`uvm_field_int(ipv4_time_to_live		,UVM_ALL_ON)
			`uvm_field_int(ipv4_protocol			,UVM_ALL_ON)
			`uvm_field_int(ipv4_hander_checksum		,UVM_ALL_ON)
			`uvm_field_int(ipv4_src_address			,UVM_ALL_ON)
			`uvm_field_int(ipv4_dst_address			,UVM_ALL_ON)
		end
		if(ctrl_sub_type[1])//subtype==b0:ipv4,b1:udp,b2:ptp,
		begin
			`uvm_field_int(udp_src_port_num			,UVM_ALL_ON)
			`uvm_field_int(udp_dst_port_num			,UVM_ALL_ON)
			`uvm_field_int(udp_length				,UVM_ALL_ON)
			`uvm_field_int(udp_checksum				,UVM_ALL_ON)
		end
		if(ctrl_sub_type[2])//subtype==b0:ipv4,b1:udp,b2:ptp,
		begin
			`uvm_field_int(ptp_transport_specific	,UVM_ALL_ON)
			`uvm_field_int(ptp_message_type			,UVM_ALL_ON)
			`uvm_field_int(ptp_reserved1			,UVM_ALL_ON)
			`uvm_field_int(ptp_version				,UVM_ALL_ON)
			`uvm_field_int(ptp_message_length		,UVM_ALL_ON)
			`uvm_field_int(ptp_domain_number		,UVM_ALL_ON)
			`uvm_field_int(ptp_reserved2			,UVM_ALL_ON)
			`uvm_field_int(ptp_flgs					,UVM_ALL_ON)
			`uvm_field_int(ptp_correction_field		,UVM_ALL_ON)
			`uvm_field_int(ptp_reserved3			,UVM_ALL_ON)
			`uvm_field_int(ptp_src_port_id			,UVM_ALL_ON)
			`uvm_field_int(ptp_sequence_id			,UVM_ALL_ON)
			`uvm_field_int(ptp_control_field		,UVM_ALL_ON)
			`uvm_field_int(ptp_log_message_interval	,UVM_ALL_ON)
		end
*/

