class localbus_config extends uvm_object;
	string 			mem_path		;
	string 			oam_table_path 	;
	rand bit [7:0] 	vif_mode		;//0:sub module,1:whole module,2:spi module 
	//rand bit [7:0]	lb_en;//preamble_value

`uvm_object_utils_begin(localbus_config)
	`uvm_field_string 	( mem_path		,UVM_ALL_ON  )
	`uvm_field_string 	( oam_table_path,UVM_ALL_ON  )
	`uvm_field_int		( vif_mode		,UVM_ALL_ON  )
`uvm_object_utils_end

extern function new(string name ="localbus_config");
endclass

function localbus_config :: new(string name ="localbus_config");
	super.new(name);
endfunction
