typedef enum {
	NOP,
	READ,
	WRITE
	}localbus_ctrl_e;

class localbus_seq_item extends uvm_sequence_item;
	
	rand bit [15:0] localbus_addr 	;
	rand bit [15:0] localbus_data	;
	rand localbus_ctrl_e	localbus_rd_wr	;

	constraint cons_localbus_ctrl_e{
		localbus_rd_wr inside { READ,WRITE };
	};
	
	extern function new (string name ="localbus_seq_item");

	`uvm_object_utils_begin(localbus_seq_item)
		`uvm_field_int(localbus_addr,UVM_ALL_ON)
		`uvm_field_int(localbus_data,UVM_ALL_ON)
		`uvm_field_enum(localbus_ctrl_e,localbus_rd_wr,UVM_ALL_ON)
	`uvm_object_utils_end

endclass

function localbus_seq_item::new(string name = "localbus_seq_item");
	super.new(name);
endfunction


