`include "uvm_macros.svh"
import uvm_pkg::*;

class e1_input_driver extends uvm_driver #(e1_seq_item);
	//====virtual interface
	virtual dut_intf vintf;

	bit [15:0] ch_num;

	//====��Ҫ���ڰ�driver����������֪ͨ��reference model
	//====�Ӷ�reference model�ܺ�DUT���յ�ͬ���ļ���
	//====drv2refm_port��������uvm_analysis#(e1_seq_item)
	//====�����һ�����������࣬��UVM�е�һ�����ڴ���
	//====transaction������Ϣ��ͨ�Žӿ�
	//====����TLM(Transaction Level Modeling)
	//====ͨ����UVM�еľ�������
	uvm_analysis_port #(e1_seq_item) drv2refm_port;

	//====factory 
	`uvm_component_utils(e1_input_driver)

	extern function new(string name,uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	extern task	drive_one_pkg(e1_seq_item req);
	extern task drive_one_bit(ref bit [0:7] data_byte);

endclass

function e1_input_driver::new(string name,uvm_component parent);
	super.new(name,parent);
	//this.ch_num = 16'h0;
endfunction

function void e1_input_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(virtual dut_intf)::get(this,"","dut_intf",vintf))
		`uvm_fatal("e1_input_driver","Error in Getting interface");
	//==== get the ch_num from the testcase
	uvm_config_db#(bit[15:0])::get(this,"","ch_num",ch_num);
	
	drv2refm_port = new ("drv2refm_port",this);
endfunction

task e1_input_driver::main_phase(uvm_phase phase);
	e1_seq_item req;
    super.main_phase(phase);//���ø����main_phase,

	$display("e1_input_driver::ch_num=%h\n",ch_num);
	vintf.sim_e1_bit[ch_num] <= 1'b1;

    while(1) begin

		//��req_item_port����õ�һ��e1_seq_item���͵�item��
		//seq_item_port,��������driver��sequencer��һ���˿ڣ�driver��Ҫ��������Ҫ�Ӹ�
		//�˿ڻ�ã�sequencer��������ݽ���driver��ҲҪͨ���ö˿��͸�driver��
		//������˿���������Ҫ��������˿ڵ�get_next_item�������������������ʱ��Ҫͨ������
		//item_done����֪����˿ڡ�
        seq_item_port.get_next_item(req);
        drive_one_pkg(req);//����drive_one_pkt�����item���ͳ�ȥ
        //$display("driver pkt is:");
        //req.print();
        drv2refm_port.write(req);//�����ͳ�ȥ��item����drv2refm_port����reference modelһ��
        //$display("driver_send_reference_model pkt is:");
        //req.print();
        seq_item_port.item_done();//��Ӧseq_item_port.get_item(req)
    end

endtask

task e1_input_driver::drive_one_pkg(e1_seq_item req);
	byte unsigned q_data[];// q_ means queue
	int data_size = 8 ;
	data_size=req.pack_bytes(q_data)/8;
	for(int i=0;i<data_size;i++)
	begin
	//	@(negedge vintf.sim_e1_clk[ch_num]);
	//	vintf.sim_e1_bit[ch_num] = {$random} % 2; 
	//	$display("vint.sim_e1_bit[ch_num]=%d",vintf.sim_e1_bit[ch_num]);
		drive_one_bit(q_data[i]);// drive one bit
		//drive_one_bit(8'h13);// drive one bit
	end
endtask 

task e1_input_driver::drive_one_bit(ref bit [0:7] data_byte);
	for(int i=0; i<8;i++)
	begin
		vintf.sim_e1_bit[ch_num] = data_byte[i];
		@(negedge vintf.sim_e1_clk[ch_num]);
		//$display("@%0t vint.sim_e1_bit[ch_num] = %d",$time,vintf.sim_e1_bit[ch_num]);
	end
endtask 
