`include "uvm_macros.svh"
import uvm_pkg::*;
import eth_pkg::*;
//`include "hello_pkg.sv"

class eth_scoreboard extends uvm_scoreboard;
	virtual dut_intf vif;
    eth_seq_item expect_queue [$];
    bit result;
    uvm_blocking_get_port #(eth_seq_item) exp_port;//用于从reference model获取数据
    uvm_blocking_get_port #(eth_seq_item) act_port;//用于从monitor的ap获取数据
    `uvm_component_utils(eth_scoreboard)

    extern function new (string name,uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
endclass

function eth_scoreboard::new(string name,uvm_component parent);
    super.new(name,parent)	;
	result	= 1'b0			;
endfunction

function void eth_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    exp_port = new("exp_port",this);
    act_port = new("act_port",this);
	if(!uvm_config_db#(virtual dut_intf)::get(this,"","dut_intf",vif))
        `uvm_fatal("eth_scoreboard","Error in Geting interface");

endfunction

task eth_scoreboard::main_phase(uvm_phase phase);
    eth_seq_item get_export,get_actual,tmp_tran;
	int chk_result_num=0;

    super.main_phase(phase);
		vif.S_eth_chk_edge = 1'b0;
    fork 
        while(1) begin//从reference model获取数据
            exp_port.get(get_export);
            expect_queue.push_back(get_export);
        end
        while(1) begin//从monitor获取数据
            act_port.get(get_actual);
            if(expect_queue.size()>0) begin
                tmp_tran = expect_queue.pop_front(); 
                result = get_actual.compare(tmp_tran);
				vif.S_eth_chk_result = result;
                    $display("ETH Package check result times=%0d",chk_result_num++);
                if(result) begin
                    $display("ETH Compare SUCCESSFULLY");
                end
                else begin
                    $display("ETH Compare FAILED");
					$display("@%0t\n",$time);
                    $display("the expect pkt is");
                    tmp_tran.print();
                    $display("the actual pkt is");
                    get_actual.print();
                end
				vif.S_eth_chk_edge = ~vif.S_eth_chk_edge; 
				//assert (~vif.eth_result);
            end
            else begin
                $display("@%0t ERROR::Received from DUT,while Expect Queue is empty",$time);
                get_actual.print();
            end
        end
    join 
endtask

