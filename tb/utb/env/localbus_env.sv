`include "uvm_macros.svh"//env是整个UVM验证平台的大容器
//import uvm_pkg::*;
//`include "testbench/localbus_pkg.sv"
//`include "testbench/agent/localbus_agent.sv"
//	import localbus_pkg::*; 
//`include "intf/localbus_define.sv"
import localbus_pkg::*;
class localbus_env extends uvm_env;
    localbus_agent input_agt;//用于向DUT发送数据在实例化中，配置为ACTIVE模式
	//定义了三个fifo，用于连接scoreboard的两个接口和reference model的一个接口
    //uvm_tlm_analysis_fifo #(localbus_seq_item) mdl_scb_fifo;//ref  <==>scb
    extern function new(string name,uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    `uvm_component_utils(localbus_env)

endclass

function localbus_env::new(string name,uvm_component parent);
    super.new(name,parent);
endfunction

function void localbus_env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    input_agt = new("input_agt",this);
    input_agt.is_active = UVM_ACTIVE;//配置input_agent为ACTIVE模式
   //uvm_tlm_analysis_fifo #(localbus_seq_item) seq_mon_fifo;//(just send the sequence item cfg to the monitor)
	//seq_mon_fifo = new ("seq_mon_fifo",this);
endfunction

function void localbus_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
	/*
    input_agt.ap.connect(agt_mdl_fifo.analysis_export);//i_agt=>fifo
    my_localbus_model.port.connect(agt_mdl_fifo.blocking_get_export);//fifo=>reference_model
    my_localbus_model.ap.connect(mdl_scb_fifo.analysis_export);//reference_model=>fifo
    my_localbus_scb.exp_port.connect(mdl_scb_fifo.blocking_get_export);//fifo=>scoreboard
    output_agt.ap.connect(agt_scb_fifo.analysis_export);//o_agt=>fifo
    my_localbus_scb.act_port.connect(agt_scb_fifo.blocking_get_export);//fifo=>scoreboard
//====
    input_agt.ap.connect(seq_mon_fifo.analysis_export);//i_agt=>seq_mon_fifo
    output_agt.mon.port.connect(seq_mon_fifo.blocking_get_export);//seq_mon_fifo=>output_agt
	////=== pointer for sequencer 
	input_agt.sqr.out_mon = output_agt.mon;
	////=== pointer for driver 
	input_agt.drv.out_mon = output_agt.mon;
	*/
endfunction
