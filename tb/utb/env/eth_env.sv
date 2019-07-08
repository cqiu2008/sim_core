//`include "uvm_macros.svh"//env是整个UVM验证平台的大容器
`include "utb/scoreboard/eth_scoreboard.sv"
`include "utb/refm/eth_refm.sv"
//import uvm_pkg::*;

class eth_env extends uvm_env;
    eth_agent input_agt;//用于向DUT发送数据在实例化中，配置为ACTIVE模式
    eth_agent output_agt;//用于向DUT接收数据，配置为PASSIVE模式 
    eth_refm  my_eth_model;//实例化model和scoreboard
    eth_scoreboard my_eth_scb;
//定义了三个fifo，用于连接scoreboard的两个接口和reference model的一个接口
    uvm_tlm_analysis_fifo #(eth_seq_item) agt_scb_fifo;//o_agt<==>scb
    uvm_tlm_analysis_fifo #(eth_seq_item) agt_mdl_fifo;//i_agt<==>ref
    uvm_tlm_analysis_fifo #(eth_seq_item) mdl_scb_fifo;//ref  <==>scb

    uvm_tlm_analysis_fifo #(eth_seq_item) mdl_mon_fifo;//(just send the refm item ctrl item to the monitor)
													   // why refm -> monitor,because 
													   // when the pkt tlm lose condition,
													   // the refm wil lose the pkt tlm,
													   // the monitor should lose it at the same time 

    extern function new(string name,uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    `uvm_component_utils(eth_env)

endclass

function eth_env::new(string name,uvm_component parent);
    super.new(name,parent);
endfunction

function void eth_env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    input_agt = new("input_agt",this);
    output_agt = new("output_agt",this);
    input_agt.is_active = UVM_ACTIVE;//配置input_agent为ACTIVE模式
    output_agt.is_active = UVM_PASSIVE;//配置output_agent为PASSIVE模式
    my_eth_model = new("my_eth_model",this);
    my_eth_scb = new ("my_eth_scb",this);
    agt_scb_fifo = new ("agt_scb_fifo",this);
    agt_mdl_fifo = new ("agt_mdl_fifo",this);
    mdl_scb_fifo = new ("mdl_scb_fifo",this);
   // uvm_tlm_analysis_fifo #(eth_seq_item) mdl_mon_fifo;//(just send the refm item ctrl signal to the monitor)
	mdl_mon_fifo = new ("mdl_mon_fifo",this);
endfunction

function void eth_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    input_agt.ap.connect(agt_mdl_fifo.analysis_export);//i_agt=>fifo
    my_eth_model.port.connect(agt_mdl_fifo.blocking_get_export);//fifo=>reference_model
    my_eth_model.ap.connect(mdl_scb_fifo.analysis_export);//reference_model=>fifo
    my_eth_scb.exp_port.connect(mdl_scb_fifo.blocking_get_export);//fifo=>scoreboard
    output_agt.ap.connect(agt_scb_fifo.analysis_export);//o_agt=>fifo
    my_eth_scb.act_port.connect(agt_scb_fifo.blocking_get_export);//fifo=>scoreboard
//====
    my_eth_model.ap.connect(mdl_mon_fifo.analysis_export);//i_agt=>mdl_mon_fifo
    output_agt.mon.port.connect(mdl_mon_fifo.blocking_get_export);//mdl_mon_fifo=>output_agt
	////=== pointer for sequencer 
	input_agt.sqr.out_mon = output_agt.mon	;
	////=== pointer for driver 
	input_agt.drv.out_mon = output_agt.mon	;
	////=== pointer for monitor 
	//output_agt.mon.out_scb = my_eth_scb			;

	input_agt.drv.sqr	= input_agt.sqr; 
endfunction
