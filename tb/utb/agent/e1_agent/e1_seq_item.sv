class e1_seq_item extends uvm_sequence_item;

	rand bit [0:7][0:255]smf;
	rand bit [0:3]smf_crc ;

	extern function new (string name = "e1_seq_item");
	extern function crc4_calculate();
	//上面是为了加入factory实现，
	//其实是factory实现要使用的uvm_object_utils要使用的宏
	`uvm_object_utils_begin(e1_seq_item)
		`uvm_field_sarray_int(smf,UVM_ALL_ON)
		//`uvm_field_int(smf_crc,UVM_ALL_ON);
	`uvm_object_utils_end//上面是为了加入factory实现
endclass

function e1_seq_item::new(string name = "e1_seq_item");
	super.new(name);
endfunction

function e1_seq_item::crc4_calculate();
	int i;
	bit[7:0]a_d[256];
	//bit[0:3]crc_pre[256] ;
	bit[0:3]crc_pre;
	a_d = {>>{smf[0],smf[1],smf[2],smf[3],smf[4],smf[5],smf[6],smf[7]}}; 

	crc_pre = 4'b0000; 

	//a_d[0] = 8'h80;
    for(i=0;i<256;i=i+1)
	begin
	//$display("crc_pre[%0d]=%h\n",i,crc_pre);
	smf_crc[0] = crc_pre[0]^crc_pre[2]^a_d[i][1]^a_d[i][3]^a_d[i][4]^a_d[i][7];
	smf_crc[1] = crc_pre[1]^crc_pre[2]^crc_pre[3]^a_d[i][0]^a_d[i][1]^a_d[i][2]^a_d[i][4]^a_d[i][6]^a_d[i][7];		
	smf_crc[2] = crc_pre[0]^crc_pre[2]^crc_pre[3]^a_d[i][0]^a_d[i][1]^a_d[i][3]^a_d[i][5]^a_d[i][6];
	smf_crc[3] = crc_pre[1]^crc_pre[3]^a_d[i][0]^a_d[i][2]^a_d[i][4]^a_d[i][5];
	crc_pre = smf_crc;
	//$display("ad[%d]=%h\n",i,a_d[i]);
	//$display("smf_crc=%h\n",smf_crc);
	end
	
endfunction














