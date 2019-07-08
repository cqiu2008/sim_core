typedef bit[15:0] bit16;
class localbus_input_seq extends uvm_sequence #(localbus_seq_item);
	localbus_seq_item m_trans;
	//virtual dut_intf vif;
	localbus_config localbus_cfg[2];
	extern function new(string name="localbus_input_seq");
	extern virtual task body();
	`uvm_object_utils_begin(localbus_input_seq)
		`uvm_field_object(localbus_cfg[0],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(localbus_cfg[1],UVM_ALL_ON | UVM_REFERENCE)
	`uvm_object_utils_end
	`uvm_declare_p_sequencer(localbus_input_sequencer)
endclass

function localbus_input_seq::new(string name = "localbus_input_seq");
	super.new(name);
endfunction

task localbus_input_seq::body();
	int pt=0;
	bit [31:0]localbus_cfg_mem[0:1023];	
	bit [75:0]oam_table_mem[0:511];
	
	if(starting_phase != null)
		starting_phase.raise_objection(this);
	for(int i=0;i<2;i++)
	begin
		this.localbus_cfg[i] = p_sequencer.localbus_cfg[i];
	end

//$readmemh("../../../tb/testcase/tc4_rpea/config_data/SIM_FPGA_CFG_TOP/DUT_FPGA_CFG/FPGA.dat",localbus_cfg_mem);	
	$readmemh(this.localbus_cfg[0].mem_path,localbus_cfg_mem);	
	$readmemh(this.localbus_cfg[0].oam_table_path,oam_table_mem);	

	while( (localbus_cfg_mem[pt] != 32'hffff_ffff) && (pt<10000))
	begin
		`uvm_do_with(m_trans,{ 
								m_trans.localbus_addr == localbus_cfg_mem[pt][31:16];
								m_trans.localbus_data == localbus_cfg_mem[pt][15:0];
								m_trans.localbus_rd_wr== WRITE;
							 })
		`uvm_info($sformatf("localbus_cfg_mem[%0d]=%0x",pt,localbus_cfg_mem[pt]),"",UVM_LOW)
		pt=pt+1;
	end
	
	`uvm_info($sformatf("p_sequencer.vif.S_mdio_state=%d",p_sequencer.vif.S_mdio_state[3:0]),"",UVM_LOW)

	`uvm_do_with(m_trans,{ 
								m_trans.localbus_addr == 16'h0001;
								m_trans.localbus_data == 0;
								m_trans.localbus_rd_wr== READ;
							 })
	`uvm_info($sformatf("Read localbus addr=%0x",m_trans.localbus_addr),"",UVM_LOW)


	
		
	#100;
	if(starting_phase != null)
	begin
		//`uvm_info("Finishing the configuration of localbus localbus",UVM_MEDIUM)
		`uvm_info($sformatf("Finishing the configuration of localbus time=%0d",$time),"",UVM_LOW)
	   //starting_phase.drop_objection(this);
	   //$stop;
	end

endtask

	
	
