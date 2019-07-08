
class e1_refm extends uvm_component;
	
	//====���ڽ���uvm_analysis_port���͵���Ϣ
	uvm_blocking_get_port #(e1_seq_item) port;

	//====����������Ϣ��scoreboard��ʹ�����ַ�ʽ����ʵ��
	//====transaction�����ͨ��
	uvm_analysis_port #(e1_seq_item) ap;

	extern function new(string name,uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);

	//====factory
	`uvm_component_utils(e1_refm)
endclass
	
function e1_refm::new(string name,uvm_component parent);
	super.new(name,parent);
endfunction

function void e1_refm::build_phase(uvm_phase phase);
	super.build_phase(phase);
	port = new ("port",this);
	ap = new("ap",this);
endfunction

task e1_refm::main_phase(uvm_phase phase);
	e1_seq_item tr;
	bit first_head_done = 1'b0;
	super.main_phase(phase);
	while(1) 
	begin
		port.get(tr);//���յ�һ��transaction
		if(~first_head_done) /// if we cann't find the first header
		begin
			first_head_done = (tr.smf[7][224:255]== 32'hffff_fff3);
		end
		else
		begin
			ap.write(tr);//ֱ�ӷ������transaction
			//tr.print();
		end
	end
endtask 


