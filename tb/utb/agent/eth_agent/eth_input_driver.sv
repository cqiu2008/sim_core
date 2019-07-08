//`include "uvm_macros.svh"
import uvm_pkg::*;

class eth_input_driver extends uvm_driver #(eth_seq_item);
    virtual dut_intf vif;
	eth_private_config eth_private_cfg[16];
	eth_public_config eth_public_cfg;
	eth_output_monitor out_mon; //// this pointer point to the instance of eth_output_monitor
								  	   //// in order to detect the "sync_mon_state" signal
	eth_input_sequencer sqr; 	//// this pointer point to the instance of eth_input_sequencer
	int	eth_burst_ifg_sum; //// the last pck ifg clk times ,such as below 
						   //// NO1 pkt 12 clk,
						   //// NO2 pkt 12 clk
						   //// NO3 pkt 38 clk (the last pck ,now 38 is eth_burst_ifg_last)
	int eth_burst_ifg_cnt; //// the current number of the pck. such NO2 ,so 2 is the eth_burst_ifg_number  
	int eth_pck_num;//// record the driver sending packages
	int eth_burst_real_num;//// actural burst_num 

    uvm_analysis_port #(eth_seq_item) ap;

    `uvm_component_utils(eth_input_driver)

    extern function new(string name ,uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern task drive_vif_initial();
    extern task drive10g_one_pkt64b(eth_seq_item req);
    extern task drive10g_one_word64b(bit [63:0] data,bit[7:0]data_ctrl);
    extern task drive10g_one_pkt32b(eth_seq_item req);
    extern task drive10g_one_word32b(bit [31:0] data,bit[3:0]data_ctrl,bit data_crc_err,bit[1:0] port_num);
    extern task drive1g_one_pkt8b(eth_seq_item req);
    extern task drive1g_one_word8b(bit [7:0] data,bit data_ctrl,bit data_crc_err);
    extern task drive2g5_one_pkt16b(eth_seq_item req);
	extern task drive2g5_one_word16b(bit [15:0] data,bit data_ctrl,bit data_mod);

endclass

function eth_input_driver::new(string name,uvm_component parent);
	string i_str ;
    super.new(name,parent);
	out_mon = null;
	sqr = null;
	for(int i=0;i<16;i++)
	begin
		i_str = $psprintf("[%0d]",i);
		eth_private_cfg[i] = eth_private_config::type_id::create({"eth_private_cfg",i_str});
	end
		eth_public_cfg = eth_public_config::type_id::create("eth_public_cfg");

endfunction

function void eth_input_driver::build_phase(uvm_phase phase);
	string i_str;
    super.build_phase(phase);
    if(!uvm_config_db#(virtual dut_intf)::get(this,"","dut_intf",vif))
        `uvm_fatal("eth_input_driver","Error in Geting interface");

	for(int i=0;i<16;i++)
	begin
		i_str = $psprintf("[%0d]",i);
		uvm_config_db#(eth_private_config)::get(this,"",{"eth_private_cfg",i_str},eth_private_cfg[i]); // by cqiu 
	end
		uvm_config_db#(eth_public_config)::get(this,"","eth_public_cfg",eth_public_cfg ); // by cqiu 

	eth_burst_ifg_sum 	= 0;//// the last pck ifg clk times ,such as below 
							//// NO1 pck 3 clk,
							//// NO2 pck 3 clk
							//// NO3 pck 38 clk (the last pck ,now 38 is eth_burst_ifg_last)
	eth_burst_ifg_cnt	= 0;//// the current number of the pck. such NO2 ,so 2 is the eth_burst_ifg_number  
	eth_pck_num			= 0;//// record the driver sending packages
	eth_burst_real_num  = 1;//// actural burst number if 1 means no burst 
    ap = new ("ap",this);
endfunction

task eth_input_driver::drive_vif_initial();
	//====10g 32b interface
    vif.S_xgmii_txd			<= 32'h0707_0707;//== idle
    vif.S_xgmii_txc			<= 4'b1111;//== ctrl 
    vif.S_xgmii_txcrc_err	<= 1'b0; 
	//====10g 64b interface
    vif.S_xgmii64b_txd			<= 64'h0707_0707_0707_0707;//== idle
    vif.S_xgmii64b_txc			<= 4'hff;//== ctrl 
	//====1g 8b interface
    vif.S_gmii_txd			<= 8'h0; 
    vif.S_gmii_txen			<= 1'b0; 
    vif.S_gmii_txerr		<= 1'b0; 
	//====2g5 16b interface
    vif.S_egmii_txd			<= 16'h0; 
    vif.S_egmii_txen		<= 1'b0; 
    vif.S_egmii_txmod		<= 1'b0; 

endtask

task eth_input_driver::main_phase(uvm_phase phase);
    eth_seq_item req;
	drive_vif_initial();
    super.main_phase(phase);//调用父类的main_phase,
    while(1) begin
        seq_item_port.get_next_item(req);
		//向req_item_port申请得到一个eth_seq_item类型的item。
		//seq_item_port,用于连接driver和sequencer的一个端口，driver想要发送数据要从该
		//端口获得，sequencer如果有数据交给driver，也要通过该端口送给driver。
		//从这个端口申请数据要调用这个端口的get_next_item方法，当数据驱动完毕时，要通过调用
		//item_done来告知这个端口。
		//req.print();
		case(eth_public_cfg.vif_mode)//0:10g32b,1:10g64b,2:1g8b,3:2g5,4:100m,5:10m
		8'h00:
		begin
        	drive10g_one_pkt32b(req);//调用drive10g_one_pkt32b将这个item发送出去
		end
		8'h01:
		begin
        	drive10g_one_pkt64b(req);//调用drive10g_one_pkt64b将这个item发送出去
		end
		8'h02:
		begin
        	drive1g_one_pkt8b(req);
		end
		8'h03:
		begin
        	drive2g5_one_pkt16b(req);
		end
		default:
		begin
        	drive10g_one_pkt32b(req);//调用drive10g_one_pkt32b将这个item发送出去
		end
		endcase
		//if(out_mon.sync_mon_state == 2'b11)
		//if(out_mon.sync_mon_state != 2'b00) 
		if(sqr.sync_sqr_state != 2'b00) 
		begin

        	ap.write(req);//将发送出去的item放入ap，给reference model一份
        	//$display("@%0t driver_send_reference_model pkt is:",$time);
        	//req.print();
		end
        //$display("driver pkt is:");
        //req.print();
        seq_item_port.item_done();//照应seq_item_port.get_item(req)
    end
endtask

//***********************************************************************************************//
//****driver for 10g 64b interface
//***********************************************************************************************//
task eth_input_driver::drive10g_one_pkt64b(eth_seq_item req);
    bit [7:0] data_q[];
    int data_size;
    int word_size;
	int ifg ;
	int pt;
	int pck_speed_value;
//==(0) judge whether the burst enable or not 
	eth_pck_num  = eth_pck_num + 1 ;
	if( (eth_pck_num >= eth_public_cfg.burst_begin_num) &&
		(eth_pck_num <= eth_public_cfg.burst_end_num) )
	begin
		eth_burst_real_num <=  eth_public_cfg.burst_num ;
	end
	else
	begin
		eth_burst_real_num <=  1; 
	end
//==(1) calculate the data_size (Byte)
    data_size=req.pack_bytes(data_q)/8;
	word_size=(data_size/8)+1;//add 1 word about 0xfb555555_555555
//==(2) calculate the original frame ifg
	if(eth_public_cfg.pck_speed > 10000)
		pck_speed_value = 10000;
	else
		pck_speed_value = eth_public_cfg.pck_speed;
	ifg=((word_size+1)*10000/(pck_speed_value)) - word_size;////====for 10G 
//==(3) update the total ifg sum and the times of ifg 
	eth_burst_ifg_cnt = eth_burst_ifg_cnt + 1;
	eth_burst_ifg_sum = eth_burst_ifg_sum + ifg - 1 ; 
	//`uvm_info($sformatf("eth_burst_ifg_cnt=%0d",ifg),"",UVM_LOW)
//==(4) judge whether is the last time of burst number 
	if(eth_burst_ifg_cnt >= eth_burst_real_num) 
	begin
		ifg = eth_burst_ifg_sum + 1;
		eth_burst_ifg_cnt = 0; 
		eth_burst_ifg_sum = 0; 
	end
	else
	begin
		ifg = 1 ;
	end
//==(5) because the 1 clock for ifg is in the last of this task so sub 1 clock 
	ifg = ifg -1 ;
	//`uvm_info($sformatf("eth_burst_ifg_cnt=%0d",ifg),"",UVM_LOW)
//==(6) use the real ifg for clock delay  
	repeat(ifg) @(posedge vif.I_156m25_clk);
	if(req.set_err[0])//====preamble err
	begin
    	drive10g_one_word64b(64'h555555fc_07070707,8'h1f);
	end
	else
	begin
    	drive10g_one_word64b(64'h555555fb_07070707,8'h1f);
	end
	pt = 0;
    for(pt=0;pt<data_size;pt=pt+8)
	begin
		if(data_size-pt == 1) 
		begin
			if(req.set_err[3]) //== indicate crc err
        		drive10g_one_word64b({48'h07070707_0707,8'hfd,8'hfe},8'hff);
			else
        		drive10g_one_word64b({48'h07070707_0707,8'hfd,data_q[pt]},8'hfe);
		end
		else if(data_size-pt == 2) 
		begin
			if(req.set_err[3]) //== indicate crc err
        		drive10g_one_word64b({40'hfdfefefe_07,8'hfe,data_q[pt+1],data_q[pt]},8'hfc);
			else
        		drive10g_one_word64b({40'h07070707_07,8'hfd,data_q[pt+1],data_q[pt]},8'hfc);
		end
		else if(data_size-pt == 3) 
		begin
			if(req.set_err[3]) //== indicate crc err
        		drive10g_one_word64b({32'hfd0707fe,8'hfe,data_q[pt+2],data_q[pt+1],data_q[pt]},8'hf8);
			else
        		drive10g_one_word64b({32'h07070707,8'hfd,data_q[pt+2],data_q[pt+1],data_q[pt]},8'hf8);
		end
		else if(data_size-pt == 4) 
		begin
			if(req.set_err[3]) //== indicate crc err
        		drive10g_one_word64b({24'hfd07fe,8'hfe,data_q[pt+3],data_q[pt+2],data_q[pt+1],data_q[pt]},8'hf0);
			else
        		drive10g_one_word64b({24'h070707,8'hfd,data_q[pt+3],data_q[pt+2],data_q[pt+1],data_q[pt]},8'hf0);
		end
		else if(data_size-pt == 5) 
		begin
			if(req.set_err[3]) //== indicate crc err
        		drive10g_one_word64b({24'hfdfefe,data_q[pt+4],data_q[pt+3],data_q[pt+2],data_q[pt+1],data_q[pt]},8'he0);
			else
        		drive10g_one_word64b({24'h0707fd,data_q[pt+4],data_q[pt+3],data_q[pt+2],data_q[pt+1],data_q[pt]},8'he0);
		end
		else if(data_size-pt == 6) 
		begin
			if(req.set_err[3]) //== indicate crc err
        		drive10g_one_word64b({16'hfdfe,data_q[pt+5],data_q[pt+4],data_q[pt+3],data_q[pt+2],data_q[pt+1],data_q[pt]},8'hc0);
			else
        		drive10g_one_word64b({16'h07fd,data_q[pt+5],data_q[pt+4],data_q[pt+3],data_q[pt+2],data_q[pt+1],data_q[pt]},8'hc0);
		end
		else if(data_size-pt == 7) 
		begin
			if(req.set_err[3]) //== indicate crc err
        		drive10g_one_word64b({16'hfd,32'hfe,data_q[pt+2],data_q[pt+1],data_q[pt]},8'hf8);
			else
        		drive10g_one_word64b({16'hfd,data_q[pt+6],data_q[pt+5],data_q[pt+4],data_q[pt+3],data_q[pt+2],data_q[pt+1],data_q[pt]},8'h80);
		end
		else
		begin
			if(req.set_err[3]) //== indicate crc err
        		drive10g_one_word64b(64'hfefefe_fefefefe,8'hff);
			else
        		drive10g_one_word64b({data_q[pt+7],data_q[pt+6],data_q[pt+5],data_q[pt+4],data_q[pt+3],data_q[pt+2],data_q[pt+1],data_q[pt]},8'h00);
		end
	end
//==(7) 1 clock to recover the xgmii64b_txd for ifg in the last step  
    @(posedge vif.I_156m25_clk); //== recover 
    vif.S_xgmii64b_txd 	<=64'h07070707_07070707;
	vif.S_xgmii64b_txc	<=8'hff;
endtask

task eth_input_driver::drive10g_one_word64b(bit [63:0] data,bit [7:0]data_ctrl);
    @(posedge vif.I_156m25_clk);
    vif.S_xgmii64b_txd	<= data;
    vif.S_xgmii64b_txc	<= data_ctrl; 
endtask
//***********************************************************************************************//
//****driver for 10g 32b interface
//***********************************************************************************************//
task eth_input_driver::drive10g_one_pkt32b(eth_seq_item req);
    byte unsigned data_q[];
    int data_size;
    int word_size;
	int ifg ;
	int pt;
	bit [1:0] port_num	;
	//==(0) judge whether the burst enable or not 
	port_num   = req.port_num		;
	`uvm_info($sformatf("10g32bit pack_bytes xgmii port_num =%0d",port_num),"",UVM_LOW)

	eth_pck_num  = eth_pck_num + 1	;
	if( (eth_pck_num >= eth_public_cfg.burst_begin_num) &&
		(eth_pck_num <= eth_public_cfg.burst_end_num) )
	begin
		eth_burst_real_num <=  eth_public_cfg.burst_num ;
	end
	else
	begin
		eth_burst_real_num <=  1; 
	end
	//==(1) calculate the data_size (Byte)
    data_size=req.pack_bytes(data_q)/8;
	word_size=(data_size/4)+1;// add the 1 word about 0xfb55_5555 
	`uvm_info($sformatf("10g32bit pack_bytes 20150505 data_size =%0d",data_size),"",UVM_LOW)

	//==(2) calculate the original frame ifg
	//eth_public_cfg.print();
	ifg=((word_size+3)*10000/(eth_public_cfg.pck_speed)) -word_size;////====for 10G 
	//****ifg=( (data_size+12)*1000/(eth_public_cfg.pck_speed)) -data_size;//====for 1G****// 
	//==(3) update the total ifg sum and the times of ifg 
	eth_burst_ifg_cnt = eth_burst_ifg_cnt + 1;
	eth_burst_ifg_sum = eth_burst_ifg_sum + ifg - 3 ; 
	//==(4) judge whether is the last time of burst number 
	if(eth_burst_ifg_cnt >= eth_burst_real_num) 
	begin
		ifg = eth_burst_ifg_sum + 3;
		eth_burst_ifg_cnt = 0; 
		eth_burst_ifg_sum = 0; 
	end
	else
	begin
		ifg = 3 ;
	end
	//==(5) because the 1 clock for ifg is in the last of this task so sub 1 clock 
	ifg = ifg -1 ;
	//==(6) use the real ifg for clock delay  
    repeat(ifg) @(posedge vif.I_312m5_clk); // vif.drv_cb;
	if(req.set_err[0])//====preamble err
	begin
    	drive10g_one_word32b(32'hfc555555,4'h8,1'b0,port_num);
		pt = 0;
	end
	else if(req.preamble_type[0])//(b0=1,hc packet)
	begin
    	drive10g_one_word32b(32'hfb5555d5,4'h8,1'b0,port_num);
		pt = 4;//// jump the "5555_55d5"
	end
	else
	begin
    	drive10g_one_word32b(32'hfb555555,4'h8,1'b0,port_num); /// by cqiu 
		pt = 0;
	end
    for(pt=pt;pt<data_size;pt=pt+4)
	begin
		//$display("driver::data_q[%0d]=%h",pt,data_q[pt]);
		if((data_size-pt == 4) && req.set_err[3]) 	   
		begin
    		@(posedge vif.I_312m5_clk);
    		vif.S_xgmii_txd 		<={data_q[pt],data_q[pt+1],data_q[pt+2],data_q[pt+3]};
			vif.S_xgmii_txc 		<=4'b0;
			vif.S_xgmii_txcrc_err 	<=1'b1;
			vif.S_xgmii_txport_num	<=port_num	;	
		end
		else if(data_size-pt == 3) 	   //==case 1 4'h1,32'hxxxx_xxfd
		begin
			if(req.set_err[3]) //== indicate crc err
        		drive10g_one_word32b({data_q[pt],data_q[pt+1],data_q[pt+2],8'hfd},4'h1,1'b1,port_num);
			else
        		drive10g_one_word32b({data_q[pt],data_q[pt+1],data_q[pt+2],8'hfd},4'h1,1'b0,port_num);
		end
		else if(data_size-pt == 2)//==case 2 4'h3,32'hxxxx_fd07
		begin
			if(req.set_err[3]) //== indicate crc err
        		drive10g_one_word32b({data_q[pt],data_q[pt+1],16'hfd07},4'h3,1'b1,port_num);
			else
        		drive10g_one_word32b({data_q[pt],data_q[pt+1],16'hfd07},4'h3,1'b0,port_num);
		end
		else if(data_size-pt == 1)//==case 3 4'h7,32'hxx_fd0707
		begin
			if(req.set_err[3]) //== indicate crc err
        		drive10g_one_word32b({data_q[pt],24'hfd0707},4'h7,1'b1,port_num);
			else
        		drive10g_one_word32b({data_q[pt],24'hfd0707},4'h7,1'b0,port_num);
		end
		else
		begin
        	drive10g_one_word32b({data_q[pt],data_q[pt+1],data_q[pt+2],data_q[pt+3]},4'h0,1'b0,port_num);
		end
    end
	if(data_size[1:0] == 2'b00) //==case 4 4'hf,32'hfd070707
	begin
    	@(posedge vif.I_312m5_clk);
    	vif.S_xgmii_txd 		<=32'hfd070707;
		vif.S_xgmii_txc 		<=4'b1111;
		vif.S_xgmii_txcrc_err 	<=1'b0;
	end
   // @vif.drv_cb;
	//==(7) 1 clock to recover the xgmii_txd for ifg in the last step  
    @(posedge vif.I_312m5_clk); //== recover 
    vif.S_xgmii_txd 		<=32'h07070707;
	vif.S_xgmii_txc 		<=4'b1111;
	vif.S_xgmii_txcrc_err 	<=1'b0;
endtask
task eth_input_driver::drive10g_one_word32b(bit [31:0] data,bit [3:0]data_ctrl,bit data_crc_err,bit[1:0] port_num);
	vif.S_xgmii_txcrc_err 	<= data_crc_err;
    @(posedge vif.I_312m5_clk);
    vif.S_xgmii_txd			<= data;
    vif.S_xgmii_txc			<= data_ctrl; 
	vif.S_xgmii_txport_num	<= port_num;
endtask

//***********************************************************************************************//
//****driver for 1g 8b interface
//***********************************************************************************************//
task eth_input_driver::drive1g_one_pkt8b(eth_seq_item req);
    bit [7:0] data_q[];
    int data_size;
	int pck_speed_value;
	int ifg ;
	int pt;
	//==(0) judge whether the burst enable or not 
	eth_pck_num  = eth_pck_num + 1 ;
	if( (eth_pck_num >= eth_public_cfg.burst_begin_num) &&
		(eth_pck_num <= eth_public_cfg.burst_end_num) )
	begin
		eth_burst_real_num <=  eth_public_cfg.burst_num ;
	end
	else
	begin
		eth_burst_real_num <=  1; 
	end
	//==(1) calculate the data_size (Byte)
    data_size=req.pack_bytes(data_q)/8;
	//==(2) calculate the original frame ifg
	if(eth_public_cfg.pck_speed > 1000)
		pck_speed_value = 1000;
	else
		pck_speed_value = eth_public_cfg.pck_speed; 
	ifg=((data_size+12)*1000/(pck_speed_value)) -data_size;////====for 1G 
	//==(3) update the total ifg sum and the times of ifg 
	eth_burst_ifg_cnt = eth_burst_ifg_cnt + 1;
	eth_burst_ifg_sum = eth_burst_ifg_sum + ifg - 12; 
	//==(4) judge whether is the last time of burst number 
	if(eth_burst_ifg_cnt >= eth_burst_real_num) 
	begin
		ifg = eth_burst_ifg_sum + 12;
		eth_burst_ifg_cnt = 0; 
		eth_burst_ifg_sum = 0; 
	end
	else
	begin
		ifg = 12 ;
	end
	//==(5) because the 1 clock for ifg is in the last of this task so sub 1 clock 
	ifg = ifg -1 ;
	//==(6) use the real ifg for clock delay  
    repeat(ifg) @(posedge vif.I_125m_clk); // vif.drv_cb;
	drive1g_one_word8b(8'h55,1'b1,1'b0);
	drive1g_one_word8b(8'h55,1'b1,1'b0);
	drive1g_one_word8b(8'h55,1'b1,1'b0);
	drive1g_one_word8b(8'h55,1'b1,1'b0);
	for(int i=0;i<data_size;i++)
	begin
		drive1g_one_word8b(data_q[i],1'b1,1'b0);
	end
   // @vif.drv_cb;
	//==(7) 1 clock to recover the xgmii_txd for ifg in the last step  
    @(posedge vif.I_125m_clk); //== recover 
    vif.S_gmii_txd 		<=8'h0;
	vif.S_gmii_txen		<=1'b0;
	vif.S_gmii_txerr	<=1'b0;
endtask
task eth_input_driver::drive1g_one_word8b(bit [7:0] data,bit data_ctrl,bit data_crc_err);
    @(posedge vif.I_125m_clk);
    vif.S_gmii_txd		<= data;
    vif.S_gmii_txen		<= data_ctrl; 
	vif.S_gmii_txerr	<= data_crc_err;
endtask

//***********************************************************************************************//
//****driver for 2g5 16b interface
//***********************************************************************************************//
task eth_input_driver::drive2g5_one_pkt16b(eth_seq_item req);
    bit [7:0] data_q[];
    int data_size;
    int word_size;
	int ifg ;
	int pt;
	//==(0) judge whether the burst enable or not 
	eth_pck_num  = eth_pck_num + 1 ;
	if( (eth_pck_num >= eth_public_cfg.burst_begin_num) &&
		(eth_pck_num <= eth_public_cfg.burst_end_num) )
	begin
		eth_burst_real_num <=  eth_public_cfg.burst_num ;
	end
	else
	begin
		eth_burst_real_num <=  1; 
	end
	//==(1) calculate the data_size (Byte)
    data_size=req.pack_bytes(data_q)/8;
	word_size=data_size/2	;
	//==(2) calculate the original frame ifg
	//eth_public_cfg.print();
	ifg=((word_size+6)*2500/(eth_public_cfg.pck_speed)) -word_size;////====for 2.5G 
	//****ifg=( (data_size+12)*1000/(eth_public_cfg.pck_speed)) -data_size;//====for 1G****// 
	//==(3) update the total ifg sum and the times of ifg 
	eth_burst_ifg_cnt = eth_burst_ifg_cnt + 1;
	eth_burst_ifg_sum = eth_burst_ifg_sum + ifg - 6 ; 
	//==(4) judge whether is the last time of burst number 
	if(eth_burst_ifg_cnt >= eth_burst_real_num) 
	begin
		ifg = eth_burst_ifg_sum + 6;
		eth_burst_ifg_cnt = 0; 
		eth_burst_ifg_sum = 0; 
	end
	else
	begin
		ifg = 6 ;
	end
	//==(5) because the 1 clock for ifg is in the last of this task so sub 1 clock 
	ifg = ifg -1 ;
	//==(6) use the real ifg for clock delay  
    repeat(ifg) @(posedge vif.I_156m25_clk); // vif.drv_cb;
	if(req.set_err[0])//====preamble err
	begin
    	drive2g5_one_word16b(16'hd55d,1'b1,1'b0);
	end
	else
	begin
    	drive2g5_one_word16b(16'h5555,1'b1,1'b0);
	end
	pt = 0;
    for(pt=0;pt<data_size;pt=pt+2)
	begin
		//$display("driver::data_q[%0d]=%h",pt,data_q[pt]);
		if(data_size-pt == 1) 
		begin
        	drive2g5_one_word16b({data_q[pt],8'h0},1'h1,1'b1);
		end
		else
		begin
        	drive2g5_one_word16b({data_q[pt],data_q[pt+1]},1'h1,1'b0);
		end
	end
   // @vif.drv_cb;
	//==(7) 1 clock to recover the xgmii_txd for ifg in the last step  
    @(posedge vif.I_156m25_clk); //== recover 
    vif.S_egmii_txd 	<=8'h0;
	vif.S_egmii_txen	<=1'b0;
	vif.S_egmii_txmod	<=1'b0;
endtask

task eth_input_driver::drive2g5_one_word16b(bit [15:0] data,bit data_ctrl,bit data_mod);
    @(posedge vif.I_156m25_clk);
    vif.S_egmii_txd		<= data;
    vif.S_egmii_txen	<= data_ctrl; 
	vif.S_egmii_txmod	<= data_mod;
endtask
