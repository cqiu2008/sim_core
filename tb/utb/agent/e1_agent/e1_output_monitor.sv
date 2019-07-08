
class e1_output_monitor extends uvm_monitor;
	//====virtual interface
	virtual dut_intf vintf;
	bit [15:0] ch_num;
	bit [1:0] sync_ctrl_mon;

	//====主要用于把dut发出的数据通知给reference model
	//====从而reference model能和DUT接收到同样的激励
	//====drv2refm_port的类型是uvm_analysis#(e1_seq_item)
	//====这个是一个参数化的类，是UVM中的一种用于传递
	//====transaction级别信息的通信接口
	//====它是TLM(Transaction Level Modeling)
	//====通信在UVM中的具体体现
	uvm_analysis_port #(e1_seq_item) tx_mon2scb_port;

	extern function new(string name,uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	extern task get_one_pkg(ref e1_seq_item get_pkg);
	extern task get_one_byte(ref logic [0:7] data_byte);

	//====register
	`uvm_component_utils (e1_output_monitor)

endclass

function e1_output_monitor::new(string name,uvm_component parent);
	super.new(name,parent);
	ch_num = 16'h0;
	sync_ctrl_mon = 2'b00;
endfunction 

function void e1_output_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(virtual dut_intf)::get(this,"","dut_intf",vintf))
		uvm_report_fatal("e1_output_monitor","Error in Geting Interface");
	//==== get the ch_num from the testcase
	uvm_config_db#(bit[15:0])::get(this,"","ch_num",ch_num);
	tx_mon2scb_port = new("tx_mon2scb_port",this);
	vintf.e1_sync_state[ch_num]=0; // assert 

endfunction


task e1_output_monitor::main_phase(uvm_phase phase);
	e1_seq_item tr; 
	super.main_phase(phase);
	while(1)
	begin
		tr = new();
		get_one_pkg(tr);
		$display("monitor::get_one_pkg\n");
		//tr.print();
		tx_mon2scb_port.write(tr);
	end
endtask 
	

task e1_output_monitor::get_one_pkg(ref e1_seq_item get_pkg);
	//byte unsigned q_data[$];//一个字节队列
	//byte unsigned a_data[] ;//一个字节数组
	bit [0:7] q_data[$];//一个字节队列
	bit [0:7] a_data[] ;//一个字节数组

//	rand bit [0:255]smf[];
//	bit [0:255]a_data[];
	

	logic [0:7] data_byte;
	int tmp;
	int j;
	bit [3:0]fsm_syn_cnt = 4'd0;

	//====(1) checking the e1_synchronization (01010101) 
	//==== for whether the e1_dut receive the real pck
			fsm_syn_cnt = 4'd0;
	while(sync_ctrl_mon == 2'b00)
	begin
		@(negedge vintf.dut_e1_clk[ch_num]);

		if( (~vintf.dut_e1_bit[ch_num]) && (fsm_syn_cnt == 4'd0))     //==== 0
			fsm_syn_cnt = 4'd1;
		else if( (vintf.dut_e1_bit[ch_num]) && (fsm_syn_cnt == 4'd1)) //==== 1
			fsm_syn_cnt = 4'd2;
		else if((~vintf.dut_e1_bit[ch_num]) && (fsm_syn_cnt == 4'd2)) //==== 0 
			fsm_syn_cnt = 4'd3;
		else if( (vintf.dut_e1_bit[ch_num]) && (fsm_syn_cnt == 4'd3)) //==== 1
			fsm_syn_cnt = 4'd4;
		else if( (~vintf.dut_e1_bit[ch_num]) && (fsm_syn_cnt == 4'd4))//==== 0
			fsm_syn_cnt = 4'd5;
		else if( (vintf.dut_e1_bit[ch_num]) && (fsm_syn_cnt == 4'd5)) //==== 1
			fsm_syn_cnt = 4'd6;
		else if((~vintf.dut_e1_bit[ch_num]) && (fsm_syn_cnt == 4'd6)) //==== 0 
			fsm_syn_cnt = 4'd7;
		else if( (vintf.dut_e1_bit[ch_num]) && (fsm_syn_cnt == 4'd7)) //==== 1
			fsm_syn_cnt = 4'd8;
		else
			fsm_syn_cnt = 4'd0;

		if (fsm_syn_cnt == 4'd8)
		begin
			//e1_seq_item :: syn_done = 2'b01;
			sync_ctrl_mon = 2'b01;
			$display("@%0t = finding the synchronsizaton e1 bit\n",$time);
		end
	end
		
	//====(2) checking the e1_header (11110011) 
	//==== for whether the e1_dut receive the real pck
			fsm_syn_cnt = 4'd0;
	//while(e1_seq_item :: syn_done == 2'b01)
	while(sync_ctrl_mon == 2'b01)
	begin
		@(negedge vintf.dut_e1_clk[ch_num]);
		//$display("@%0t fsm_syn_cnt = %h header bit\n",$time,fsm_syn_cnt);

		if( (~vintf.dut_e1_bit[ch_num]) && (fsm_syn_cnt == 4'd0))     //==== 0
			fsm_syn_cnt = 4'd1;
		else if( (~vintf.dut_e1_bit[ch_num]) && (fsm_syn_cnt == 4'd1))//==== 0 
			fsm_syn_cnt = 4'd2;
		else if((vintf.dut_e1_bit[ch_num]) && (fsm_syn_cnt == 4'd2))  //==== 1 
			fsm_syn_cnt = 4'd3;
		else if( (vintf.dut_e1_bit[ch_num]) && (fsm_syn_cnt == 4'd3)) //==== 1
			fsm_syn_cnt = 4'd4;
		else
			fsm_syn_cnt = 4'd0;

		if (fsm_syn_cnt == 4'd4)
		begin
			//e1_seq_item :: syn_done = 2'b11;
			sync_ctrl_mon = 2'b11;
			$display("@%0t = finding the header e1 bit\n",$time);
			vintf.e1_sync_state[ch_num]=1; // assert 
		end
	end


	for(int i=0;i<256;i++)
	begin
		get_one_byte(data_byte);
		//$display("receive from dut data_byte = %h",data_byte);
	 	//==== push_back 属于队列的固有内建函数
		q_data.push_back(data_byte);//在队列尾部插入data_byte
	end

	a_data = new[256]; //动态分配数组空间
	//j=0;
/*
	for(int i=0;i<8;i++)
	begin
		a_data[i] = {
					q_data[j],q_data[j+1],q_data[j+2],q_data[j+3],
					q_data[j+4],q_data[j+5],q_data[j+6],q_data[j+7],
					q_data[j+8],q_data[j+9],q_data[j+10],q_data[j+11],
					q_data[j+12],q_data[j+13],q_data[j+14],q_data[j+15],
					q_data[j+16],q_data[j+17],q_data[j+18],q_data[j+19],
					q_data[j+20],q_data[j+21],q_data[j+22],q_data[j+23],
					q_data[j+24],q_data[j+25],q_data[j+26],q_data[j+27],
					q_data[j+28],q_data[j+29],q_data[j+30],q_data[j+31] };
		j=j+32;
	//	$display ("a_data[%d]=%h\n",i,a_data[i]);
	end
*/
	for(int i=0;i<256;i++)
	begin
		a_data[i] = q_data[i]; 
		//$display ("a_data[%d]=%h\n",i,a_data[i]);
	end

	//tmp = get_pkg.unpack_bytes(a_data);
	j=0;
	for(int i=0;i<8;i++)
	begin
		get_pkg.smf[i] = {
					a_data[j],a_data[j+1],a_data[j+2],a_data[j+3],
					a_data[j+4],a_data[j+5],a_data[j+6],a_data[j+7],
					a_data[j+8],a_data[j+9],a_data[j+10],a_data[j+11],
					a_data[j+12],a_data[j+13],a_data[j+14],a_data[j+15],
					a_data[j+16],a_data[j+17],a_data[j+18],a_data[j+19],
					a_data[j+20],a_data[j+21],a_data[j+22],a_data[j+23],
					a_data[j+24],a_data[j+25],a_data[j+26],a_data[j+27],
					a_data[j+28],a_data[j+29],a_data[j+30],a_data[j+31] };
		j=j+32;
	end
	//$display("Just here \n ");
	//get_pkg.print();

endtask

task e1_output_monitor::get_one_byte(ref logic [0:7] data_byte);
	for(int i=0;i<8;i++)
	begin
		@(negedge vintf.dut_e1_clk[ch_num]);
		data_byte[i] = vintf.dut_e1_bit[ch_num];
		//$display("@%0t = vintf.dut_e1_bit[ch_num]_real = %d\n",$time,vintf.dut_e1_bit[ch_num]);
	end
endtask 

