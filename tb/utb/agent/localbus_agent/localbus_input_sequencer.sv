
class localbus_input_sequencer extends uvm_sequencer #(localbus_seq_item);

	virtual dut_intf vif;
	localbus_config localbus_cfg[2]	;

	extern function new (string name,uvm_component parent);
	extern function void build_phase(uvm_phase phase);

	`uvm_component_utils_begin(localbus_input_sequencer)
		`uvm_field_object(localbus_cfg[0],UVM_ALL_ON | UVM_REFERENCE)
		`uvm_field_object(localbus_cfg[1],UVM_ALL_ON | UVM_REFERENCE)
	`uvm_component_utils_end

endclass

function localbus_input_sequencer::new(string name,uvm_component parent);
	string i_str ;
	super.new(name,parent);
	for(int i=0;i<2;i++)
	begin
		i_str = $psprintf("[%0d]",i);
		localbus_cfg[i] = localbus_config::type_id::create({"localbus_cfg",i_str});
	end

endfunction

function void localbus_input_sequencer::build_phase(uvm_phase phase);
	string i_str ;
	super.build_phase(phase);
	if(!uvm_config_db#(virtual dut_intf)::get(this,"","dut_intf",vif))
		`uvm_fatal("localbus_input_sequencer","Error in Getting interface");
	for(int i=0;i<2;i++)
	begin
		i_str = $psprintf("[%0d]",i);
		uvm_config_db#(localbus_config)::get(this,"",{"localbus_cfg",i_str},localbus_cfg[i]);
	end

endfunction

