//`include "uvm_macros.svh"
import uvm_pkg::*;

class localbus_input_driver extends uvm_driver #(localbus_seq_item);
	virtual dut_intf vif;
	localbus_config localbus_cfg[2];
	uvm_analysis_port #(localbus_seq_item) ap;
	bit [15:0]ar;
	bit [15:0]dw;
	`uvm_component_utils(localbus_input_driver)
	extern function new(string name,uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	extern task drive_vif_initial();
	extern task WriteFpgaRegSpi(localbus_seq_item req);//rpea total localbus
	extern task WriteFpgaRegSub(localbus_seq_item req);//sub module localbus
	extern task WriteFpgaRegBoard(localbus_seq_item req);//board localbus motorola 
	extern task ReadFpgaRegBoard(localbus_seq_item req);//board localbus motorola 
endclass

function localbus_input_driver::new(string name,uvm_component parent);
	string i_str ;
	super.new(name,parent);
	for(int i=0;i<2;i++)
	begin
		i_str = $psprintf("[%0d]",i);
		localbus_cfg[i]=localbus_config::type_id::create({"localbus_cfg",i_str});
	end
endfunction

function void localbus_input_driver::build_phase(uvm_phase phase);
	string i_str;
	super.build_phase(phase);
	if(!uvm_config_db#(virtual dut_intf)::get(this,"","dut_intf",vif))
		`uvm_fatal("localbus_input_driver","Error in Getting interface");
	for(int i=0;i<2;i++)
	begin
		i_str = $psprintf("[%0d]",i);
		uvm_config_db#(localbus_config)::get(this,"",{"localbus_cfg",i_str},localbus_cfg[i]);
	end
	ap = new("ap",this);
	ar = 16'h0;
	dw = 16'h0;
endfunction

task localbus_input_driver::drive_vif_initial();
	//==== spi localbus initial
	vif.S_arm_wr_en 	= 1'b1;
	vif.S_arm_rd_en 	= 1'b1;
	vif.S_arm_spi_cs	= 1'b1;
	vif.S_arm_spi_clk 	= 1'b1;
	vif.S_arm_spi_sdi	= 1'b1;


endtask


task localbus_input_driver::main_phase(uvm_phase phase);
	localbus_seq_item req;
	drive_vif_initial();
	super.main_phase(phase);
	while(1)begin
		seq_item_port.get_next_item(req);
		//WriteFpgaRegSpi(req);
		case(localbus_cfg[0].vif_mode)//0:sub module,1:board module,2:spi module 
		8'h0:
		begin
			WriteFpgaRegSub(req);
		end
		8'h1:
		begin
			if(req.localbus_rd_wr == READ)
			begin
				ReadFpgaRegBoard(req);
			end
			else
			begin
				WriteFpgaRegBoard(req);
			end
		end
		8'h2:
		begin
			WriteFpgaRegSpi(req);
		end
		default:
		begin
			WriteFpgaRegSpi(req);
		end
		endcase
		ap.write(req);
		seq_item_port.item_done();
	end
endtask
//====WriteFpgaRegSub
task localbus_input_driver::WriteFpgaRegSub(localbus_seq_item req);
	//(1) initial signal
	vif.S_sub_cs_n	<= 1'b1		;
	vif.S_sub_rd_n	<= 1'b1		;
	vif.S_sub_wr_n	<= 1'b1		;
	vif.S_sub_addr	<= 16'h0	;
	vif.S_sub_din	<= 16'h0	;
	//(2) active low the S_arm_wr_en  
	////(1)first step load the cpu address and cpu input data
	repeat(1) @(posedge vif.S_sub_lb_clk);        
	vif.S_sub_addr	<= req.localbus_addr	;
	vif.S_sub_din	<= req.localbus_data	;
	vif.S_sub_cs_n	<= 1'b1		;
	vif.S_sub_rd_n	<= 1'b1		;
	vif.S_sub_wr_n	<= 1'b1		;
	////(2)second step active the cs_n
	repeat(2) @(posedge vif.S_sub_lb_clk);        
	vif.S_sub_cs_n	<= 1'b0;
	////(3)third step active the wr_n
	repeat(2) @(posedge vif.S_sub_lb_clk);        
	vif.S_sub_wr_n	<= 1'b0;
	repeat(2) @(posedge vif.S_sub_lb_clk);        
	////(4)four step set ctrl signal default value 
	vif.S_sub_cs_n	<= 1'b1		;
	vif.S_sub_rd_n	<= 1'b1		;
	vif.S_sub_wr_n	<= 1'b1		;
	////(5)five step set the default value
	repeat(2) @(posedge vif.S_sub_lb_clk);        
	vif.S_sub_addr	<= 16'h0	;
	vif.S_sub_din	<= 16'h0	;
endtask

//====WriteFpgaRegBoard
task localbus_input_driver::WriteFpgaRegBoard(localbus_seq_item req);
	//`uvm_info($sformatf("WriteFpgaRegBoard=%0x",req.localbus_addr),"",UVM_LOW)
	//(1) initial signal
	ar					<= req.localbus_addr	;
	dw					<= req.localbus_data	;
	vif.S_brd_lae		<= 1'b0					; // idle state ready for write data
	vif.S_brd_cs_n		<= 1'b1					;
	vif.S_brd_rd_n		<= 1'b1					;
	vif.S_brd_wr_n		<= 1'b1					;
	vif.S_brd_haddr[9:0]<= 10'h0				; 
	vif.S_brd_data[15:0]<= 16'h0				;
	vif.S_brd_data_en	<= 1'b0					; 
	//(2) active low the S_arm_wr_en  
	////(1)first step write the 26 address  
	repeat(1) @(posedge vif.I_cpu_clk);        
	vif.S_brd_lae		<= 1'b1					; // busy state for address 
	vif.S_brd_haddr[9:0]<= {1'b0,ar[0],ar[1],ar[2],ar[3],ar[4],ar[5],ar[6],ar[7],ar[8]};
	vif.S_brd_data[15:0]<= {ar[9],ar[10],ar[11],ar[12],ar[13],ar[14],ar[15],9'h0}; 
	vif.S_brd_data_en	<= 1'b1					; 
	////(2)second step lock the address lae active 
	repeat(2) @(posedge vif.I_cpu_clk);        
	vif.S_brd_lae		<= 1'b0					; 
	////(3)third step write the 16 wrdata  
	repeat(1) @(posedge vif.I_cpu_clk);        
	vif.S_brd_cs_n		<= 1'b0					;
	vif.S_brd_rd_n		<= 1'b1					;
	vif.S_brd_wr_n		<= 1'b1					;
	vif.S_brd_haddr[9:0]<={1'b0,ar[0],ar[1],ar[2],ar[3],ar[4],ar[5],ar[6],ar[7],ar[8]};
	vif.S_brd_data[15:0]<= {dw[0],dw[1],dw[2],dw[3],dw[4],dw[5],dw[6],dw[7],dw[8],
							dw[9],dw[10],dw[11],dw[12],dw[13],dw[14],dw[15]};
	repeat(1) @(posedge vif.I_cpu_clk);        
	vif.S_brd_wr_n		<= 1'b0					;
	repeat(6) @(posedge vif.I_cpu_clk);        
	vif.S_brd_wr_n		<= 1'b1					;
	repeat(2) @(posedge vif.I_cpu_clk);        
	vif.S_brd_cs_n		<= 1'b1					;
	repeat(2) @(posedge vif.I_cpu_clk);        
	vif.S_brd_data_en	<= 1'b0					; 
	repeat(3) @(posedge vif.I_cpu_clk);        

endtask

//====ReadFpgaRegBoard
task localbus_input_driver::ReadFpgaRegBoard(localbus_seq_item req);
	//`uvm_info($sformatf("ReadFpgaRegBoard=%0x",req.localbus_addr),"",UVM_LOW)
	//(1) initial signal
	ar					<= req.localbus_addr	;
	vif.S_brd_lae		<= 1'b0					; // idle state ready for write data
	vif.S_brd_cs_n		<= 1'b1					;
	vif.S_brd_rd_n		<= 1'b1					;
	vif.S_brd_wr_n		<= 1'b1					;
	vif.S_brd_haddr[9:0]<= 10'h0				; 
	vif.S_brd_data[15:0]<= 16'h0				;
	vif.S_brd_data_en	<= 1'b0					; 
	////(1)first step write the 26 address  
	repeat(1) @(posedge vif.I_cpu_clk);        
	vif.S_brd_lae		<= 1'b0					; // busy state for address 
	vif.S_brd_haddr[9:0]<= {1'b0,ar[0],ar[1],ar[2],ar[3],ar[4],ar[5],ar[6],ar[7],ar[8]};
	vif.S_brd_data[15:0]<= {ar[9],ar[10],ar[11],ar[12],ar[13],ar[14],ar[15],9'h0}; 
	vif.S_brd_data_en	<= 1'b1					; 
	////(2)second step lock the address lae active 
	repeat(2) @(posedge vif.I_cpu_clk);        
	vif.S_brd_lae		<= 1'b0					; 
	repeat(2) @(posedge vif.I_cpu_clk);        
	vif.S_brd_lae		<= 1'b1					; 
	repeat(2) @(posedge vif.I_cpu_clk);        
	vif.S_brd_lae		<= 1'b0					; 
	////(3) release the data bus 
	repeat(2) @(posedge vif.I_cpu_clk);        
	vif.S_brd_data_en	<= 1'b0					; 
	////(4)third step read the data 
	repeat(10) @(posedge vif.I_cpu_clk);        
	vif.S_brd_cs_n		<= 1'b0					;
	vif.S_brd_rd_n		<= 1'b0					;
	vif.S_brd_wr_n		<= 1'b1					;
	repeat(20) @(posedge vif.I_cpu_clk);        
	vif.S_brd_cs_n		<= 1'b1					;
	vif.S_brd_rd_n		<= 1'b1					;
	//repeat(3) @(posedge vif.I_cpu_clk);        
endtask





//====WriteFpgaRegSpi
task localbus_input_driver::WriteFpgaRegSpi(localbus_seq_item req);
	//(1) initial signal
	vif.S_arm_wr_en 	= 1'b1;
	vif.S_arm_rd_en 	= 1'b1;
	vif.S_arm_spi_cs	= 1'b1;
	vif.S_arm_spi_clk 	= 1'b1;
	vif.S_arm_spi_sdi	= 1'b1;
	//(2) active low the S_arm_wr_en  
	repeat (10) @(posedge vif.I_25m_clk);
	vif.S_arm_wr_en 	= 1'b0;
	//(3) transform the localbus_addr 
	repeat (5) @(posedge vif.I_25m_clk);
	vif.S_arm_spi_cs	= 1'b0;
	`uvm_info($sformatf("req.localbus_addr=%0x",req.localbus_addr),"",UVM_LOW)
	for(int i=0;i<16;i++)
	begin
		vif.S_arm_spi_clk = 1'b1; 
		repeat (1) @(posedge vif.I_25m_clk);
		vif.S_arm_spi_sdi = req.localbus_addr[15-i];
		vif.S_arm_spi_clk = 1'b0; 
		repeat (1) @(posedge vif.I_25m_clk);
	end
	repeat (1) @(posedge vif.I_25m_clk);
	vif.S_arm_spi_clk = 1'b1; 
	repeat (5) @(posedge vif.I_25m_clk);
	vif.S_arm_spi_cs	= 1'b1;
	//(4) transform the localbus_data
	repeat (10) @(posedge vif.I_25m_clk);
	vif.S_arm_spi_cs	= 1'b0;
	for(int i=0;i<16;i++)
	begin
		vif.S_arm_spi_clk = 1'b1; 
		repeat (1) @(posedge vif.I_25m_clk);
		vif.S_arm_spi_sdi = req.localbus_data[15-i];
		vif.S_arm_spi_clk = 1'b0; 
		repeat (1) @(posedge vif.I_25m_clk);
	end
	repeat (1) @(posedge vif.I_25m_clk);
	vif.S_arm_spi_clk = 1'b1; 
	repeat (5) @(posedge vif.I_25m_clk);
	vif.S_arm_spi_cs	= 1'b0;
	//(5) inactive all signal 
	repeat (10) @(posedge vif.I_25m_clk);
	vif.S_arm_wr_en 	= 1'b1;
	vif.S_arm_rd_en 	= 1'b1;
	vif.S_arm_spi_cs	= 1'b1;
	vif.S_arm_spi_clk 	= 1'b1;
	vif.S_arm_spi_sdi	= 1'b1;
endtask


	
