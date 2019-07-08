//`include "uvm_macros.svh"
//import uvm_pkg::*;
`include "utb/scoreboard/eth_scoreboard.sv"

class eth_output_monitor extends uvm_monitor;
    virtual dut_intf vif;
	eth_private_config eth_private_cfg[16];
	eth_public_config eth_public_cfg;
	bit [1:0] sync_mon_state;// sync state information 
	bit [1:0] sync_mon_state_next;
	eth_seq_item port_queue[$];// just store the sequence item
	//eth_scoreboard out_scb; // just for monitor the scoreboard result 
	bit		   scb_result;
    uvm_analysis_port #(eth_seq_item) ap;
	uvm_blocking_get_port #(eth_seq_item) port;// just receive the sequence item
    extern function new (string name,uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern task receive10g_one_pkt64b(ref eth_seq_item get_pkt);
    extern task get10g_one_word64b(ref logic [7:0] xgmii64b_rxc,ref logic [63:0] xgmii64b_rxd);
    extern task receive10g_one_pkt32b(ref eth_seq_item get_pkt);
    extern task get10g_one_word32b(ref logic xgmii_rxcrc_err,ref logic [3:0] xgmii_rxc,ref logic [31:0] xgmii_rxd,ref logic [1:0] port_num);
    extern task receive1g_one_pkt8b(ref eth_seq_item get_pkt);
    extern task get1g_one_word8b(ref logic gmii_valid ,ref logic [7:0] gmii_data);

    extern task receive2g5_one_pkt16b(ref eth_seq_item get_pkt);
    extern task get2g5_one_word16b(ref logic egmii_rxmod,ref logic egmii_rxen,ref logic [15:0] egmii_rxd);

    `uvm_component_utils(eth_output_monitor)
endclass

function eth_output_monitor::new(string name,uvm_component parent);
    super.new(name,parent);
	//out_scb				= null	; // just for monitor the scoreboard result 
	sync_mon_state 		= 2'b00;
	sync_mon_state_next = 2'b00;
	scb_result			= 1'b0 ;
	for(int i=0;i<16;i++)
	begin
		eth_private_cfg[i]=eth_private_config::type_id::create({"eth_private_cfg",$psprintf("[%0d]",i)});
	end
	eth_public_cfg=eth_public_config::type_id::create("eth_public_cfg");
endfunction

function void eth_output_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual dut_intf)::get(this,"","dut_intf",vif))
        uvm_report_fatal("eth_output_monitor","Error in Geting Interface");
	for(int i=0;i<16;i++)
	begin
		if(!uvm_config_db#(eth_private_config)::get(this,"",{"eth_private_cfg",$psprintf("[%0d]",i)},eth_private_cfg[i]))
			uvm_report_fatal("eth_output_monitor","Error in Geting eth_private_cfg");
	end
	if(!uvm_config_db#(eth_public_config)::get(this,"","eth_public_cfg",eth_public_cfg))
		uvm_report_fatal("eth_output_monitor","Error in Geting eth_public_cfg");
    ap = new("ap",this);
	port = new("port",this);
	vif.S_eth_sync_state=0; // assert 
endfunction

task eth_output_monitor::main_phase(uvm_phase phase);
    logic 			xgmii_rxcrc_err	;
	logic [3:0]	 	xgmii_rxc		;
    logic [31:0] 	xgmii_rxd		;
    eth_seq_item 	tr				;
	eth_seq_item 	get_port_seq	;
    super.main_phase(phase);
	fork
		while(1) //// ==== wait after finding the header package
		begin
			port.get(get_port_seq);
			//get_port_seq.print();
			port_queue.push_back(get_port_seq); ////=== just store the seq_item to the port_queue
		end
    	while(1) 
		begin
        	tr = new();
			case(eth_public_cfg.vif_mode)//0:10g32b,1:10g64b,2:1g8b,3:2g5,4:100m,5:10m
			8'h00:
			begin
        		receive10g_one_pkt32b(tr);
			end
			8'h01:
			begin
        		receive10g_one_pkt64b(tr);
			end
			8'h02:
			begin
        		receive1g_one_pkt8b(tr);
			end
			8'h03:
			begin
        		receive2g5_one_pkt16b(tr);
			end
			default:
			begin
        		receive10g_one_pkt32b(tr);
			end
			endcase
        	//tr.print();
			if(sync_mon_state == 2'b11) //==== finding the first header package
        		ap.write(tr);
    	end
	join
endtask
//***********************************************************************************************//
//****monitor for 10g 64b interface
//***********************************************************************************************//
task eth_output_monitor::get10g_one_word64b(ref logic [7:0] xgmii64b_rxc,ref logic [63:0] xgmii64b_rxd);
    //@vif.mon_cb;
	@(posedge vif.S_xgmii64b_rxclk);
    xgmii64b_rxd	= vif.S_xgmii64b_rxd;
    xgmii64b_rxc	= vif.S_xgmii64b_rxc;
endtask

task eth_output_monitor::receive10g_one_pkt64b(ref eth_seq_item get_pkt);
	eth_seq_item seq_item;
    byte unsigned data_q[$];//一个字节队列
    byte unsigned data_array[];
    logic [63:0] xgmii64b_rxd   = 64'b0; 
    logic [ 7:0] xgmii64b_rxc	= 8'b0; 

    int data_size;
	int preamble_flg=0;
	int preamble_cnt=0;
	int sfd_flg = 0;
	int del_cnt = 0;
	int d5_location = 0; //the starting location of "d5" charactor 

	//==(1) check the first valid frame header 8'h8,32'hfb55_5555;
    while(   !( ((xgmii64b_rxc == 8'h1f) && (xgmii64b_rxd ==64'h5555_55fb_0707_0707)) ||
   				((xgmii64b_rxc == 8'h01) && (xgmii64b_rxd ==64'hd555_5555_5555_55fb)) )
		 ) begin//检查一个合法的data，当读到的valid为1时，不再执行该指令
        get10g_one_word64b(xgmii64b_rxc,xgmii64b_rxd);
    end
	if(xgmii64b_rxc == 8'h1f)
	begin
		d5_location = 11;
	end
	else
	begin
		d5_location = 7;
	end
	//==(2) push back the xgmii_rxd to the queue
    while(xgmii64b_rxc != 8'hff ) begin//检查一个合法的data，当读到的valid为1时，不再执行该指令
        data_q.push_back(xgmii64b_rxd[7:0]);//在队列的尾部插入data
        data_q.push_back(xgmii64b_rxd[15:8]);//在队列的尾部插入data
        data_q.push_back(xgmii64b_rxd[23:16]);//在队列的尾部插入data
        data_q.push_back(xgmii64b_rxd[31:24]);//在队列的尾部插入data
        data_q.push_back(xgmii64b_rxd[39:32]);//在队列的尾部插入data
        data_q.push_back(xgmii64b_rxd[47:40]);//在队列的尾部插入data
        data_q.push_back(xgmii64b_rxd[55:48]);//在队列的尾部插入data
        data_q.push_back(xgmii64b_rxd[63:56]);//在队列的尾部插入data
	//	`uvm_info($sformatf("S_xgmii64b_rxd=%0x",xgmii64b_rxd),"",UVM_LOW)
	//	`uvm_info($sformatf("S_xgmii64b_rxc=%0x",xgmii64b_rxc),"",UVM_LOW)
        get10g_one_word64b(xgmii64b_rxc,xgmii64b_rxd);
    end
	//==(3) calculate the the tail of the packet 
	case (xgmii64b_rxc)
	8'hfe:del_cnt=7;
	8'hfc:del_cnt=6;
	8'hf8:del_cnt=5;
	8'hf0:del_cnt=4;
	8'he0:del_cnt=3;
	8'hc0:del_cnt=2;
	8'h80:del_cnt=1;
	default:del_cnt=0;
	endcase

	//==(4) store in the data_array memory 
    data_size = data_q.size()-del_cnt-d5_location;//返回队列的长度
    data_array = new[data_size];
    for(int i=0;i<data_size;i++) 
	begin
        data_array[i]=data_q[i+d5_location];
	    //$display("monitor:data_array[%0d] = %h\n",i,data_array[i]);
    end

		$display("eth_private_cfg[0].dmac[47:32]=%h\n",eth_private_cfg[0].dmac[47:32]);
	//==(5)calcualte the sync mon state
	if(sync_mon_state == 2'b00) 
	begin // connect pkt state
		if( 
			({data_array[1],data_array[2]} == eth_private_cfg[0].dmac[47:32])
		  )
		begin
			sync_mon_state_next = 2'b01;
			$display("@%0t = 10G64B finding the connect eth pck\n",$time);
		end
	end
	else if(sync_mon_state == 2'b01)
	begin // header pkt state
		if({data_array[1],data_array[2]} == ~eth_private_cfg[0].dmac[47:32])
		begin
			sync_mon_state_next = 2'b10;
			$display("@%0t = 10G64B finding the header eth pck\n",$time);
		end
	end
	//==(6) update the syn_mon_state
	sync_mon_state = sync_mon_state_next;
	//==(7) normal state , transform the data to the transaction 
	if( sync_mon_state == 2'b10)
	begin
		seq_item = port_queue.pop_front();//==== must be after valid == 1
		//$display("@%0t seq_item pop_frone",$time);
		//seq_item.print();
   		get_pkt.set_err				= seq_item.set_err				;
   		//get_pkt.dmac				= seq_item.dmac					;
   		//get_pkt.smac				= seq_item.smac					;	
   		get_pkt.vlan_word_size		= seq_item.vlan_word_size		;
   		get_pkt.vlan_word_mem		= seq_item.vlan_word_mem		;
   		//get_pkt.eth_type			= seq_item.eth_type				;
   		get_pkt.pload_set_type		= seq_item.pload_set_type		;
   		get_pkt.pload_set_length	= seq_item.pload_set_length 	;
   		get_pkt.pload_set_fix_value	= seq_item.pload_set_fix_value	;
   		get_pkt.pload_set_inc_value	= seq_item.pload_set_inc_value	;
		get_pkt.random_length_low  	= seq_item.random_length_low	;
		get_pkt.random_length_high 	= seq_item.random_length_high	;
   		get_pkt.sub_head_size		= seq_item.sub_head_size		;
   		get_pkt.sub_head_mem		= seq_item.sub_head_mem			;
   		get_pkt.preamble_size		= seq_item.preamble_size		;
   		get_pkt.pload_size			= seq_item.pload_size			;
		get_pkt.vlan_word			= new[seq_item.vlan_word_size]	;
		get_pkt.pload				= new[seq_item.sub_head_size+seq_item.pload_size] ;
   		//get_pkt.port_info			= seq_item.port_info			;//==4'd1,oam pkt from tx port return to rx port;
		

    	data_size = get_pkt.unpack_bytes(data_array)/8;
		sync_mon_state = 2'b11;
		vif.S_eth_sync_state=1; //assert normal 
		//get_pkt.print();
	/*
	if(data_size > 4096)
	begin
		get_pkt.eth_crc = {	data_array[data_size-4],data_array[data_size-3],
							data_array[data_size-2],data_array[data_size-1] };

		for(int i=4096,j=0;i<data_size-4;i++,j++)
		begin
			get_pkt.pload[get_pkt.pload_size-1-j]=data_array[data_size-5-j];
		end
	*/
	end
	//==(8) if new compare fail ,last compare ok then restart the mon_state
	if({scb_result,vif.S_eth_chk_result} == 2'b10)
	begin
		sync_mon_state		= 2'b00; 
		sync_mon_state_next	= 2'b00;
		`uvm_info($sformatf("intf [receive10g_one_pkt64b] packets err restart sync_mon_state=%0d",sync_mon_state),"",UVM_LOW)
	end
	scb_result = vif.S_eth_chk_result	; 
	
endtask


//***********************************************************************************************//
//****monitor for 10g 32b interface
//***********************************************************************************************//
task eth_output_monitor::receive10g_one_pkt32b(ref eth_seq_item get_pkt);
	eth_seq_item seq_item;
    byte unsigned data_q[$];//一个字节队列
    byte unsigned data_array[];
    logic [31:0] xgmii_rxd = 32'h0707_0707;
    logic [3:0]	 xgmii_rxc = 4'b1111; 
	logic		 xgmii_rxcrc_err = 1'b0;	
	logic [1:0]	port_num = 2'b00;
    int data_size;
	int preamble_flg=0;
	int preamble_cnt=0;
	int sfd_flg = 0;
	int del_cnt =0;

	//==(1) check the first valid frame header 8'h8,32'hfb55_5555;
    while(xgmii_rxc != 4'b1000) 
	begin//检查一个合法的data，当读到xgmii_rxc=4'b1000为止
        get10g_one_word32b(xgmii_rxcrc_err,xgmii_rxc,xgmii_rxd,port_num);
    end
	//==(2) push back the xgmii_rxd to the queue
    while(xgmii_rxc != 4'b1111) 
	begin//检查一个合法的data，当读到的valid为1时，不再执行该指令
        data_q.push_back(xgmii_rxd[31:24]);//在队列的尾部插入data
        data_q.push_back(xgmii_rxd[23:16]);//在队列的尾部插入data
        data_q.push_back(xgmii_rxd[15:8]);//在队列的尾部插入data
        data_q.push_back(xgmii_rxd[7:0]);//在队列的尾部插入data
        get10g_one_word32b(xgmii_rxcrc_err,xgmii_rxc,xgmii_rxd,port_num);
    end
	//==(3) calculate the the tail of the packet 
	if(xgmii_rxc == 4'b0111)
	begin
		del_cnt = 3;
	end
	if(xgmii_rxc == 4'b0011)
	begin
		del_cnt = 2;
	end
	if(xgmii_rxc == 4'b0001)
	begin
		del_cnt = 1;
	end
    data_size = data_q.size()-del_cnt;//返回队列的长度
	//==(4) store in the data_array memory 
    data_array = new[data_size];
    for(int i=0;i<data_size;i++) 
	begin
        data_array[i]=data_q[i];
		//$display("monitor:data_q = %h\n",data_q[i]);
    end
	//==(5)calcualte the sync mon state
	if(sync_mon_state == 2'b00) 
	begin // connect pkt state
		if( ({data_array[0],data_array[1],data_array[2],data_array[3]} == 32'hfb55_5555) &&
			({data_array[8],data_array[9]} == eth_private_cfg[0].dmac[47:32])
		  )
		begin
			sync_mon_state_next = 2'b01;
			$display("@%0t = 10G32B finding the connect eth pck\n",$time);
		end
	end
	else if(sync_mon_state == 2'b01)
	begin // header pkt state
		if({data_array[8],data_array[9]} == ~eth_private_cfg[0].dmac[47:32])
		begin
			sync_mon_state_next = 2'b10;
			$display("@%0t = 10G32B finding the header eth pck\n",$time);
		end
	end
	//==(6) update the syn_mon_state
	sync_mon_state = sync_mon_state_next;


	if( sync_mon_state == 2'b10)
	begin
		//==(7) normal state , transform the data to the transaction 
		seq_item = port_queue.pop_front();//==== must be after valid == 1
		$display("@%0t seq_item pop_frone",$time);
		if(seq_item.preamble_type[0])//(b0=1,hc packet)
		begin /// cover the " fb 55 55" 
			for(int i=0;i<(data_size-3);i++)
			begin
				data_array[i] = data_array[i+3];//begin with sfd
			end
		end
		else
		begin /// cover the "fb 55 55 55 55 55 55"
			for(int i=0;i<(data_size-7);i++)
			begin
				data_array[i] = data_array[i+7];//begin with sfd
			end
		end
		//seq_item.print();
   		get_pkt.set_err				= seq_item.set_err				;
   		//get_pkt.dmac				= seq_item.dmac					;
   		//get_pkt.smac				= seq_item.smac					;	
   		get_pkt.vlan_word_size		= seq_item.vlan_word_size		;
   		get_pkt.vlan_word_mem		= seq_item.vlan_word_mem		;
   		//get_pkt.eth_type			= seq_item.eth_type				;
   		get_pkt.pload_set_type		= seq_item.pload_set_type		;
   		get_pkt.pload_set_length	= seq_item.pload_set_length 	;
   		get_pkt.pload_set_fix_value	= seq_item.pload_set_fix_value	;
   		get_pkt.pload_set_inc_value	= seq_item.pload_set_inc_value	;
		get_pkt.random_length_low  	= seq_item.random_length_low	;
		get_pkt.random_length_high 	= seq_item.random_length_high	;
   		get_pkt.sub_head_size		= seq_item.sub_head_size		;
   		get_pkt.sub_head_mem		= seq_item.sub_head_mem			;
   		get_pkt.preamble_size		= seq_item.preamble_size		;
   		get_pkt.pload_size			= seq_item.pload_size			;
		get_pkt.vlan_word			= new[seq_item.vlan_word_size]	;
		get_pkt.pload				= new[seq_item.sub_head_size+seq_item.pload_size] ;
   		//get_pkt.port_info			= seq_item.port_info			;//==4'd1,oam pkt from tx port return to rx port;
   		get_pkt.preamble_type		= seq_item.preamble_type		;
   		get_pkt.port_num			= port_num						; 
		

    	data_size = get_pkt.unpack_bytes(data_array)/8;
		`uvm_info($sformatf("10g32bit unpack_bytes 20150505 data_size =%0d",data_size),"",UVM_LOW)
		

		sync_mon_state = 2'b11;
		vif.S_eth_sync_state=1; //assert normal 
	/*
	if(data_size > 4096)
	begin
		get_pkt.eth_crc = {	data_array[data_size-4],data_array[data_size-3],
							data_array[data_size-2],data_array[data_size-1] };

		for(int i=4096,j=0;i<data_size-4;i++,j++)
		begin
			get_pkt.pload[get_pkt.pload_size-1-j]=data_array[data_size-5-j];
		end
	*/
	end
	//==(8) if new compare fail ,last compare ok then restart the mon_state
	if({scb_result,vif.S_eth_chk_result} == 2'b10)
	begin
		sync_mon_state		= 2'b00; 
		sync_mon_state_next	= 2'b00;
		`uvm_info($sformatf("intf [receive10g_one_pkt32b] packets err restart sync_mon_state=%0d",sync_mon_state),"",UVM_LOW)
	end
	scb_result = vif.S_eth_chk_result	; 
	
endtask
task eth_output_monitor::get10g_one_word32b(ref logic xgmii_rxcrc_err,ref logic [3:0] xgmii_rxc,ref logic [31:0] xgmii_rxd,ref logic [1:0] port_num);
    //@vif.mon_cb;
	@(posedge vif.I_312m5_clk);
    xgmii_rxd		= vif.S_xgmii_rxd;
    xgmii_rxc 		= vif.S_xgmii_rxc;
	xgmii_rxcrc_err = vif.S_xgmii_rxcrc_err;
	port_num		= vif.S_xgmii_rxport_num;

endtask

//***********************************************************************************************//
//****monitor for 1g 8b interface
//***********************************************************************************************//
task eth_output_monitor::receive1g_one_pkt8b(ref eth_seq_item get_pkt);
	eth_seq_item seq_item;
    byte unsigned data_q[$];//一个字节队列
    byte unsigned data_array[];
    int data_size;
	logic [7:0] gmii_data=8'h0;
	logic		gmii_en=1'b0;
	int preamble_flg;
	int preamble_cnt;
	int sfd_flg; 
	bit [3:0]port_info=4'b0000;////==4'd1,oam pkt from tx port return to rx port; 
	gmii_data=8'h00;
	gmii_en = 1'b0;
	preamble_flg=0;
	preamble_cnt=0;
	sfd_flg=0;

	//==(1) check the first valid frame header 8'h8,32'hfb55_5555;
    while( (!gmii_en) | (gmii_en == 1'bx) | (gmii_en ==1'bz)) //including gmii_en == 1'bx,1'bz,1'b0,and so on 
	begin//检查一个合法的data，当读到gmii_data
        get1g_one_word8b(gmii_en,gmii_data);
    end
	//==(2) push back the gmii_data to the queue
    while(gmii_en) 
	begin
        data_q.push_back(gmii_data);//在队列的尾部插入data
        get1g_one_word8b(gmii_en,gmii_data);
		port_info=vif.S_gmii_port_info;//==4'd1,oam pkt from tx port return to rx port; 
    end
	//==(3) check the preamble and sfd word
	preamble_cnt = 0;
	while(data_q[preamble_cnt] == 8'h55)
	begin
		preamble_cnt++;	
	end
	if(preamble_cnt <3 ) //==== less than 4 byte,55
	begin
		`uvm_info($sformatf("Error preamble length less than 4byte =%0d",preamble_cnt),"",UVM_LOW)
		//vif.S_eth_chk_result = 	
	end
	if(data_q[preamble_cnt] != 8'hd5)
	begin
		`uvm_info($sformatf("Error sfd value = %0d  is wrong",data_q[preamble_cnt]),"",UVM_LOW)
	end
	//==(4) calculate and store the the data_size of the packet 
    data_size = data_q.size();//返回队列的长度
    data_array = new[data_size];
    for(int i=0;i<(data_size-preamble_cnt);i++) 
	begin
        data_array[i]=data_q[i+preamble_cnt];
		//$display("@%0t = finding data_q = %h \n",$time,data_array[i]);
	end
	//==(5)calcualte the sync mon state
	if(sync_mon_state == 2'b00) 
	begin // connect pkt state
		if( ({data_array[1],data_array[2]} == eth_private_cfg[0].dmac[47:32]) )
		begin
			sync_mon_state_next = 2'b01;
			$display("@%0t = finding the connect 1g 8b eth pck \n",$time);
		end
	end
	else if(sync_mon_state == 2'b01)
	begin // header pkt state
		if({data_array[1],data_array[2]} == ~eth_private_cfg[0].dmac[47:32])
		begin
			sync_mon_state_next = 2'b10;
			$display("@%0t = finding the header 1g 8b eth pck\n",$time);
		end
	end
	//==(6) update the syn_mon_state
	sync_mon_state = sync_mon_state_next;
	//==(7) normal state , transform the data to the transaction 
	//for(int i=0;i<(data_size-7);i++)
	//begin
	//	data_array[i] = data_array[i+7];//begin with sfd
		//$display("data_array[%0d]=%h\n",i,data_array[i]);
	//end
	`uvm_info($sformatf("eth 1G monitor port_info=%0x",port_info),"",UVM_LOW)
	if( sync_mon_state == 2'b10)
	begin
		seq_item = port_queue.pop_front();//==== must be after valid == 1
		$display("@%0t seq_item pop_frone",$time);
		//seq_item.print();
   		get_pkt.set_err				= seq_item.set_err				;
   		//get_pkt.dmac				= seq_item.dmac					;
   		//get_pkt.smac				= seq_item.smac					;	
   		get_pkt.vlan_word_size		= seq_item.vlan_word_size		;
   		get_pkt.vlan_word_mem		= seq_item.vlan_word_mem		;
   		//get_pkt.eth_type			= seq_item.eth_type				;
   		get_pkt.pload_set_type		= seq_item.pload_set_type		;
   		get_pkt.pload_set_length	= seq_item.pload_set_length 	;
   		get_pkt.pload_set_fix_value	= seq_item.pload_set_fix_value	;
   		get_pkt.pload_set_inc_value	= seq_item.pload_set_inc_value	;
		get_pkt.random_length_low  	= seq_item.random_length_low	;
		get_pkt.random_length_high 	= seq_item.random_length_high	;
   		get_pkt.sub_head_size		= seq_item.sub_head_size		;
   		get_pkt.sub_head_mem		= seq_item.sub_head_mem			;
   		get_pkt.preamble_size		= seq_item.preamble_size		;
   		get_pkt.pload_size			= seq_item.pload_size			;
		get_pkt.vlan_word			= new[seq_item.vlan_word_size]	;
		get_pkt.pload				= new[seq_item.sub_head_size+seq_item.pload_size] ;
		//get_pkt.preamble			= new[seq_item.preamble_size]	;
		get_pkt.port_info			= port_info						;//==4'd1,oam pkt from tx port return to rx port; 

    	data_size = get_pkt.unpack_bytes(data_array)/8;

		sync_mon_state = 2'b11;
		vif.S_eth_sync_state=1; //assert normal 
	end
	//==(8) if new compare fail ,last compare ok then restart the mon_state
	if({scb_result,vif.S_eth_chk_result} == 2'b10)
	begin
		sync_mon_state		= 2'b00; 
		sync_mon_state_next	= 2'b00;
		`uvm_info($sformatf("intf [receive1g_one_pkt8b] packets err restart sync_mon_state=%0d",sync_mon_state),"",UVM_LOW)
	end
	scb_result = vif.S_eth_chk_result	; 
	
endtask
task eth_output_monitor::get1g_one_word8b(ref logic gmii_valid ,ref logic [7:0] gmii_data );
    //@vif.mon_cb;
	@(posedge vif.I_125m_clk);
    gmii_data  = vif.S_gmii_rxd;
    gmii_valid = vif.S_gmii_rxen;
	$display("@%0t get1g_one_word8b=%d",$time,{gmii_valid,gmii_data});
endtask

//***********************************************************************************************//
//****monitor for 2g5 16interface
//***********************************************************************************************//
task eth_output_monitor::receive2g5_one_pkt16b(ref eth_seq_item get_pkt);
	eth_seq_item seq_item;
    byte unsigned data_q[$];//一个字节队列
    byte unsigned data_array[];
    logic [15:0] egmii_rxd		= 16'h00; 
    logic 		 egmii_rxen 	= 1'h0; 
	logic		 egmii_rxmod 	= 1'b0;	
    int data_size;
	int preamble_flg=0;
	int preamble_cnt=0;
	int sfd_flg = 0;
	int del_cnt =0;
	//==(1) check the first valid frame header 8'h8,32'hfb55_5555;
    while(!egmii_rxen) 
	begin//检查一个合法的data，当读到gmii_data
		get2g5_one_word16b(egmii_rxmod,egmii_rxen,egmii_rxd);
    end
	//==(2) push back the gmii_data to the queue
    while(egmii_rxen) 
	begin
        data_q.push_back(egmii_rxd[15:8]);//在队列的尾部插入data
        data_q.push_back(egmii_rxd[7:0]);//在队列的尾部插入data
		get2g5_one_word16b(egmii_rxmod,egmii_rxen,egmii_rxd);
    end
	if(egmii_rxmod)
	begin
	    data_size = data_q.size()-1;//返回队列的长度
	end
	else
	begin
	    data_size = data_q.size();//返回队列的长度
	end
	//==(3) check the preamble and sfd word
	preamble_cnt = 0;
	while(data_q[preamble_cnt] == 8'h55)
	begin
		preamble_cnt++;	
		//`uvm_info($sformatf("preamble_cnt=%0d",preamble_cnt),"",UVM_LOW)
	end
	if(preamble_cnt <3 ) //==== less than 4 byte,55
	begin
		`uvm_info($sformatf("Error preamble length less than 4byte =%0d",preamble_cnt),"",UVM_LOW)
	end
	if(data_q[preamble_cnt] != 8'hd5)
	begin
		`uvm_info($sformatf("Error sfd value = %0d  is wrong",data_q[preamble_cnt]),"",UVM_LOW)
	end
	//==(4) calculate and store the the data_size of the packet 
    data_array = new[data_size];
    for(int i=0;i<(data_size-preamble_cnt);i++) 
	begin
        data_array[i]=data_q[i+preamble_cnt];
		//$display("@%0t = finding data_q = %h \n",$time,data_array[i]);
	end
	//==(5)calcualte the sync mon state
	if(sync_mon_state == 2'b00) 
	begin // connect pkt state
		if( ({data_array[1],data_array[2]} == eth_private_cfg[0].dmac[47:32]) )
		begin
			sync_mon_state_next = 2'b01;
			$display("@%0t = finding the connect 2.5g 16eth pck \n",$time);
		end
	end
	else if(sync_mon_state == 2'b01)
	begin // header pkt state
		if({data_array[1],data_array[2]} == ~eth_private_cfg[0].dmac[47:32])
		begin
			sync_mon_state_next = 2'b10;
			$display("@%0t = finding the header 2.5g 16b eth pck\n",$time);
		end
	end
	//==(6) update the syn_mon_state
	sync_mon_state = sync_mon_state_next;
	//==(7) normal state , transform the data to the transaction 
	//for(int i=0;i<(data_size-7);i++)
	//begin
	//	data_array[i] = data_array[i+7];//begin with sfd
		//$display("data_array[%0d]=%h\n",i,data_array[i]);
	//end
	if( sync_mon_state == 2'b10)
	begin
		seq_item = port_queue.pop_front();//==== must be after valid == 1
		$display("@%0t seq_item pop_frone",$time);
		//seq_item.print();
   		get_pkt.set_err				= seq_item.set_err				;
   		//get_pkt.dmac				= seq_item.dmac					;
   		//get_pkt.smac				= seq_item.smac					;	
   		get_pkt.vlan_word_size		= seq_item.vlan_word_size		;
   		get_pkt.vlan_word_mem		= seq_item.vlan_word_mem		;
   		//get_pkt.eth_type			= seq_item.eth_type				;
   		get_pkt.pload_set_type		= seq_item.pload_set_type		;
   		get_pkt.pload_set_length	= seq_item.pload_set_length 	;
   		get_pkt.pload_set_fix_value	= seq_item.pload_set_fix_value	;
   		get_pkt.pload_set_inc_value	= seq_item.pload_set_inc_value	;
		get_pkt.random_length_low  	= seq_item.random_length_low	;
		get_pkt.random_length_high 	= seq_item.random_length_high	;
   		get_pkt.sub_head_size		= seq_item.sub_head_size		;
   		get_pkt.sub_head_mem		= seq_item.sub_head_mem			;
   		get_pkt.preamble_size		= seq_item.preamble_size		;
   		get_pkt.pload_size			= seq_item.pload_size			;
		get_pkt.vlan_word			= new[seq_item.vlan_word_size]	;
		get_pkt.pload				= new[seq_item.sub_head_size+seq_item.pload_size] ;
		//get_pkt.preamble			= new[seq_item.preamble_size]	;

    	data_size = get_pkt.unpack_bytes(data_array)/8;

		sync_mon_state = 2'b11;
		vif.S_eth_sync_state=1; //assert normal 
	end
	//==(8) if new compare fail ,last compare ok then restart the mon_state
	if({scb_result,vif.S_eth_chk_result} == 2'b10)
	begin
		sync_mon_state		= 2'b00; 
		sync_mon_state_next	= 2'b00;
		`uvm_info($sformatf("intf [receive2g5_one_pkt16b] packets err restart sync_mon_state=%0d",sync_mon_state),"",UVM_LOW)
	end
	scb_result = vif.S_eth_chk_result	; 
	
endtask
task eth_output_monitor::get2g5_one_word16b(ref logic egmii_rxmod,ref logic egmii_rxen,ref logic [15:0] egmii_rxd);
    //@vif.mon_cb;
	@(posedge vif.I_156m25_clk);
    egmii_rxd		= vif.S_egmii_rxd;
    egmii_rxen		= vif.S_egmii_rxen;
	egmii_rxmod		= vif.S_egmii_rxmod;
endtask
