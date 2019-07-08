//typedef struct {
//	bit [7:0] dat[512];
//} sub_head_mem_s;

class eth_private_config extends uvm_object;

	rand bit [3:0] 	set_err				;//err==b0:preamble,b1:sfd,b2:pload,b3,crc
	rand bit [15:0]	pck_freq			;//the type of pck's frequence 
	rand bit [3:0]  pload_set_type		;//(b3=1,fix_length,b3=0,random_length)(b2-b0:random,fix,increase)
	rand bit [15:0] pload_set_length	;//pload pck length
	rand bit [7:0]  pload_set_fix_value	;//pload pattern 
	rand bit [7:0]  pload_set_inc_value	;//pload pattern  increase orginal value 
	rand bit [15:0]	random_length_low	;//the type of pck's frequence 
	rand bit [15:0]	random_length_high	;//the type of pck's frequence 
	rand bit [7:0]  sfd					;//sfd
	rand bit [47:0] dmac				;//destination mac value 
	rand bit [47:0] smac				;//source mac value 
	rand int	 	vlan_word_size		;//vlan layer number 0:no vlan 1:1 layer vlan 
	rand bit [0:7][31:0]vlan_word_mem	;//vlan type ,vlan cfi,vlan pri,vlan id
	rand bit [15:0] eth_type			;//eth_type
	rand bit [15:0] sub_head_size		;//sub head pck length
	rand bit [0:511][7:0]sub_head_mem	;//sub head data
	rand bit [7:0]	preamble_type		;//(b0=1,hc pkt)
	rand bit [1:0]	port_num			;//for 10g xgmii port number 


`uvm_object_utils_begin(eth_private_config)

    `uvm_field_int ( set_err			,UVM_ALL_ON  )	
    `uvm_field_int ( pck_freq			,UVM_ALL_ON  )	
    `uvm_field_int ( pload_set_type		,UVM_ALL_ON  )	
    `uvm_field_int ( pload_set_length	,UVM_ALL_ON  )	
    `uvm_field_int ( pload_set_fix_value,UVM_ALL_ON  )	
    `uvm_field_int ( pload_set_inc_value,UVM_ALL_ON  )	
    `uvm_field_int ( random_length_low	,UVM_ALL_ON  )	
    `uvm_field_int ( random_length_high ,UVM_ALL_ON  )	

    `uvm_field_int ( sfd		 		,UVM_ALL_ON  )
    `uvm_field_int ( dmac		 		,UVM_ALL_ON  )
    `uvm_field_int ( smac		 		,UVM_ALL_ON  )
    `uvm_field_int ( vlan_word_size		,UVM_ALL_ON  )
    `uvm_field_sarray_int (vlan_word_mem,UVM_ALL_ON  )
    `uvm_field_int ( eth_type	 		,UVM_ALL_ON  )
    `uvm_field_int ( sub_head_size		,UVM_ALL_ON  )
    `uvm_field_sarray_int ( sub_head_mem,UVM_ALL_ON  )
	`uvm_field_int ( preamble_type	 	,UVM_ALL_ON  )
	`uvm_field_int ( port_num			,UVM_ALL_ON  )
`uvm_object_utils_end


extern function new(string name ="eth_private_config");

endclass




function eth_private_config :: new(string name ="eth_private_config");
	super.new(name);
endfunction
