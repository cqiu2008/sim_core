
class e1_config extends uvm_object;

	rand bit [0:15] e1_cfg_pck_ch_en;
	rand bit [7:0]	e1_cfg_pck_mod; 
	rand bit [7:0]  e1_cfg_pck_pload_type;
	rand bit [7:0]  e1_cfg_pck_fix_value;
	rand bit [7:0]  e1_cfg_pck_increase_value;
	rand bit [15:0] e1_cfg_pck_num;

`uvm_object_utils_begin(e1_config)
	`uvm_field_int(e1_cfg_pck_ch_en,UVM_ALL_ON);
	`uvm_field_int(e1_cfg_pck_mod,UVM_ALL_ON);
	`uvm_field_int(e1_cfg_pck_pload_type,UVM_ALL_ON);
	`uvm_field_int(e1_cfg_pck_fix_value,UVM_ALL_ON);
	`uvm_field_int(e1_cfg_pck_increase_value,UVM_ALL_ON);
	`uvm_field_int(e1_cfg_pck_num,UVM_ALL_ON);
`uvm_object_utils_end

	extern function new(string name = "e1_config");

endclass

function e1_config::new (string name ="e1_config");
	super.new(name);
endfunction
