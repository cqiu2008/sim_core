//typedef struct {
//	bit [7:0] dat[512];
//} sub_head_mem_s;

class eth_public_config extends uvm_object;

	rand bit [7:0]	stream_num			;//the new stream num
	rand int		pck_num				;//the number of sending packages
	rand bit [15:0] pck_speed			;//the speed(M) of sending packages
	rand bit [15:0]	burst_num			;//the new burst num 
	rand bit [31:0]	burst_begin_num		;//the new burst num 
	rand bit [31:0]	burst_end_num		;//the new burst num 
	rand bit [ 7:0] vif_mode			;//0:10g32b,1:10g64b,2:1g8b,3:2g5,4:100m,5:10m
	rand bit [15:0] port_mode			;//bit0:=1,oam tx,=0,oam rx;bit1
	rand bit [ 3:0] port_num			;//=4'b0,port0;4'b1,port1;4'b2,port2
	rand bit [ 7:0] refm_chk			;//bit0:check 1588,bit1:check oam,active high
	string			oam_table_path		;//
	string			localbus_mem_path	;//


`uvm_object_utils_begin(eth_public_config)

    `uvm_field_int 		( stream_num		,UVM_ALL_ON  )	
    `uvm_field_int 		( pck_num			,UVM_ALL_ON  )	
    `uvm_field_int 		( pck_speed			,UVM_ALL_ON  )	
    `uvm_field_int 		( burst_num			,UVM_ALL_ON  )	
    `uvm_field_int 		( burst_begin_num	,UVM_ALL_ON  )	
    `uvm_field_int 		( burst_end_num		,UVM_ALL_ON  )	
    `uvm_field_int 		( vif_mode			,UVM_ALL_ON  )	
    `uvm_field_int 		( port_mode			,UVM_ALL_ON  )	
    `uvm_field_int 		( refm_chk			,UVM_ALL_ON  )	
	`uvm_field_string	( oam_table_path	,UVM_ALL_ON	 )
	`uvm_field_string 	( localbus_mem_path	,UVM_ALL_ON	 )

`uvm_object_utils_end

extern function new(string name ="eth_public_config");

endclass


function eth_public_config :: new(string name ="eth_public_config");
	super.new(name);
endfunction
