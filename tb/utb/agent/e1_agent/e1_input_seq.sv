//`include "uvm_mocras.svh"
//import uvm_pkg::*;

class e1_input_seq extends uvm_sequence #(e1_seq_item);
    e1_seq_item m_trans	;
	//bit [15:0] e1_tlm_num 	;
	bit [1:0] sync_ctrl_seq	;
	bit first_head_en		;
	int unsigned pck_num    ;
	bit [0:3]smf_crc		;
	bit [0:3]smf_crc_now	;
	bit [7:0]a_inc[33]		;

    extern function new(string name ="e1_input_seq");

    virtual task body();
		//if(!uvm_config_db#(bit[1:0])::get(this,"","sync_ctrl_seq",sync_ctrl_seq))
		//	$display("Cann't get the monitor interface by cqiu \n");
		//uvm_config_db#(bit[1:0])::get(this,"","sync_ctrl_seq",sync_ctrl_seq);
		
        if(starting_phase != null)
            starting_phase.raise_objection(this);
		    //repeat(6) begin
			a_inc[0] = p_sequencer.e1_cfg.e1_cfg_pck_increase_value ;
			for (int i=0;i<32;i++)
			begin
				a_inc[i+1] = a_inc[i] + 8'h1;
			end

		    repeat(p_sequencer.e1_cfg.e1_cfg_pck_num) begin
			 	case({first_head_en,p_sequencer.out_mon.sync_ctrl_mon})
			 	3'b100:
				begin
            	`uvm_do_with(m_trans,{	
										m_trans.smf  == '{ 8{{32{8'h55}}} }; 
									 } )
				end
			 	3'b101:
				begin
            	`uvm_do_with( m_trans,{	
										m_trans.smf[0:6]== '{ 7{{32{8'hff}}} } ; 
										m_trans.smf[7][0:247]  == {31{8'hff}} ; 
										m_trans.smf[7][248:255]== 8'hf3 ; 
									  } )
				first_head_en = 1'b0;
				end
			 	default:
				begin
/*
	e1_cfg.e1_cfg_pck_ch_en 		= 16'b0000_0000_0000_0001;
	e1_cfg.e1_cfg_pck_mod			= 8'h00; ////( 00::unframe,01::frame_no_crc::02::frame_crc) 
	e1_cfg.e1_cfg_pck_pload_type	= 8'h00; ////( 00::random,01::fix,02:increase)  
	e1_cfg.e1_cfg_pck_fix_value		= 8'h00; ////( fix::value) 
	e1_cfg.e1_cfg_pck_increase_value= 8'h00; ////( increase::beging::value) 
	e1_cfg.e1_cfg_pck_num			= 16'h00;////( the sending pck num (2048bit == 1 pck) ) 
*/
					case ({p_sequencer.e1_cfg.e1_cfg_pck_mod,p_sequencer.e1_cfg.e1_cfg_pck_pload_type})
					16'h00_00: // mod::unframe,pload_type::random
					begin
						`uvm_do(m_trans)	
					end
					16'h00_01: // mod::unframe,pload_type::fix
					begin
            			`uvm_do_with(	m_trans,
										{	
										m_trans.smf 	==  '{ 8{{32{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}} } ; 
									   	} )
					end
					16'h00_02: // mod::unframe,pload_type::increase
					begin
            			`uvm_do_with(	m_trans,
										{	
											m_trans.smf 	==  '{ 8{{1{ a_inc[0], a_inc[1], a_inc[2], a_inc[3],
																		 a_inc[4], a_inc[5], a_inc[6], a_inc[7],
																		 a_inc[8], a_inc[9], a_inc[10],a_inc[11],
																		 a_inc[12],a_inc[13],a_inc[14],a_inc[15],
																		 a_inc[16],a_inc[17],a_inc[18],a_inc[19],
																		 a_inc[20],a_inc[21],a_inc[22],a_inc[23],
																		 a_inc[24],a_inc[25],a_inc[26],a_inc[27],
																		 a_inc[28],a_inc[29],a_inc[30],a_inc[31]
																	    }}} } ; 
									   	} 
									)
					end
					16'h01_00: // mod::frame_no_crc,pload_type::random
					begin
						`uvm_do_with( m_trans, {
								m_trans.smf[0][0]  == 1'b0; 
								m_trans.smf[2][0]  == 1'b0; 
								m_trans.smf[4][0]  == 1'b0; 
								m_trans.smf[6][0]  == 1'b0; 
								m_trans.smf[0][1:7]=={7'b0011011}; //// smf_crc4[0],7'b001101
								m_trans.smf[2][1:7]=={7'b0011011}; //// smf_crc4[1],7'b001101
								m_trans.smf[4][1:7]=={7'b0011011}; //// smf_crc4[2],7'b001101
								m_trans.smf[6][1:7]=={7'b0011011}; //// smf_crc4[3],7'b001101
								m_trans.smf[1][0:7]=={2'b01,1'b0,5'b00000}; ////2'b01,smf_alarm,smf_sa4_8
								m_trans.smf[3][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
								m_trans.smf[5][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
								m_trans.smf[7][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
									} )
					end
					16'h01_01: // mod::frame_no_crc,pload_type::fix
					begin
						`uvm_do_with( m_trans, {
								m_trans.smf[0][0]  == 1'b0; 
								m_trans.smf[2][0]  == 1'b0; 
								m_trans.smf[4][0]  == 1'b0; 
								m_trans.smf[6][0]  == 1'b0; 
								m_trans.smf[0][1:7]=={7'b0011011}; //// smf_crc4[0],7'b001101
								m_trans.smf[2][1:7]=={7'b0011011}; //// smf_crc4[1],7'b001101
								m_trans.smf[4][1:7]=={7'b0011011}; //// smf_crc4[2],7'b001101
								m_trans.smf[6][1:7]=={7'b0011011}; //// smf_crc4[3],7'b001101
								m_trans.smf[1][0:7]=={2'b01,1'b0,5'b00000}; ////2'b01,smf_alarm,smf_sa4_8
								m_trans.smf[3][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
								m_trans.smf[5][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
								m_trans.smf[7][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
									
							    m_trans.smf[0][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[1][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[2][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[3][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[4][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[5][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[6][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[7][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
									} )
					end
					16'h01_02: // mod::frame_no_crc,pload_type::increase
					begin
						`uvm_do_with( m_trans, {
								m_trans.smf[0][0]  == 1'b0; 
								m_trans.smf[2][0]  == 1'b0; 
								m_trans.smf[4][0]  == 1'b0; 
								m_trans.smf[6][0]  == 1'b0; 
								m_trans.smf[0][1:7]=={7'b0011011}; //// smf_crc4[0],7'b001101
								m_trans.smf[2][1:7]=={7'b0011011}; //// smf_crc4[1],7'b001101
								m_trans.smf[4][1:7]=={7'b0011011}; //// smf_crc4[2],7'b001101
								m_trans.smf[6][1:7]=={7'b0011011}; //// smf_crc4[3],7'b001101
								m_trans.smf[1][0:7]=={2'b01,1'b0,5'b00000}; ////2'b01,smf_alarm,smf_sa4_8
								m_trans.smf[3][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
								m_trans.smf[5][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
								m_trans.smf[7][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
							    m_trans.smf[0][8:255] ==  { a_inc[0],{6{a_inc[1],a_inc[2],a_inc[3],a_inc[4],a_inc[5]}}  }; 
							    m_trans.smf[1][8:255] ==  { a_inc[0],{6{a_inc[1],a_inc[2],a_inc[3],a_inc[4],a_inc[5]}}  }; 
							    m_trans.smf[2][8:255] ==  { a_inc[0],{6{a_inc[1],a_inc[2],a_inc[3],a_inc[4],a_inc[5]}}  }; 
							    m_trans.smf[3][8:255] ==  { a_inc[0],{6{a_inc[1],a_inc[2],a_inc[3],a_inc[4],a_inc[5]}}  }; 
							    m_trans.smf[4][8:255] ==  { a_inc[0],{6{a_inc[1],a_inc[2],a_inc[3],a_inc[4],a_inc[5]}}  }; 
							    m_trans.smf[5][8:255] ==  { a_inc[0],{6{a_inc[1],a_inc[2],a_inc[3],a_inc[4],a_inc[5]}}  }; 
							    m_trans.smf[6][8:255] ==  { a_inc[0],{6{a_inc[1],a_inc[2],a_inc[3],a_inc[4],a_inc[5]}}  }; 
							    m_trans.smf[7][8:255] ==  { a_inc[0],{6{a_inc[1],a_inc[2],a_inc[3],a_inc[4],a_inc[5]}}  }; 
									} )
					end
					16'h02_00: // mod::frame_crc,pload_type::random
					begin
								$display("smf_crc4 now = %b\n",smf_crc_now);
						`uvm_do_with( m_trans, {
								m_trans.smf[0][0]  == smf_crc_now[0]; 
								m_trans.smf[2][0]  == smf_crc_now[1]; 
								m_trans.smf[4][0]  == smf_crc_now[2]; 
								m_trans.smf[6][0]  == smf_crc_now[3]; 
								m_trans.smf[0][1:7]=={7'b0011011}; //// smf_crc4[0],7'b001101
								m_trans.smf[2][1:7]=={7'b0011011}; //// smf_crc4[1],7'b001101
								m_trans.smf[4][1:7]=={7'b0011011}; //// smf_crc4[2],7'b001101
								m_trans.smf[6][1:7]=={7'b0011011}; //// smf_crc4[3],7'b001101
								m_trans.smf[1][0:7]=={2'b01,1'b0,5'b00000}; ////2'b01,smf_alarm,smf_sa4_8
								m_trans.smf[3][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
								m_trans.smf[5][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
								m_trans.smf[7][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
									} )
								//==== calculate the crc4 
								m_trans.crc4_calculate();
								this.smf_crc = m_trans.smf_crc; // update the result of crc4
							//	$display("Package crc4  by sequcence = %b\n",this.smf_crc);
					end
					16'h02_01: // mod::frame_crc,pload_type::fix
					begin
								$display("smf_crc4 now = %b\n",smf_crc_now);
						`uvm_do_with( m_trans, {

								m_trans.smf[0][0]  == smf_crc_now[0]; 
								m_trans.smf[2][0]  == smf_crc_now[1]; 
								m_trans.smf[4][0]  == smf_crc_now[2]; 
								m_trans.smf[6][0]  == smf_crc_now[3]; 

								m_trans.smf[0][1:7]=={7'b0011011}; //// smf_crc4[0],7'b001101
								m_trans.smf[2][1:7]=={7'b0011011}; //// smf_crc4[1],7'b001101
								m_trans.smf[4][1:7]=={7'b0011011}; //// smf_crc4[2],7'b001101
								m_trans.smf[6][1:7]=={7'b0011011}; //// smf_crc4[3],7'b001101
								m_trans.smf[1][0:7]=={2'b01,1'b0,5'b00000}; ////2'b01,smf_alarm,smf_sa4_8
								m_trans.smf[3][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
								m_trans.smf[5][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
								m_trans.smf[7][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
							    m_trans.smf[0][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[1][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[2][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[3][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[4][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[5][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[6][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[7][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
									} )
								//==== calculate the crc4 
								m_trans.crc4_calculate();
								this.smf_crc = m_trans.smf_crc; // update the result of crc4
								//$display("Package crc4  by sequcence = %b\n",this.smf_crc);
								//m_trans.print();
					end
					16'h02_02: // mod::frame_crc,pload_type::increase
					begin
								$display("smf_crc4 now = %b\n",smf_crc_now);
						`uvm_do_with( m_trans, {
								m_trans.smf[0][0]  == smf_crc_now[0]; 
								m_trans.smf[2][0]  == smf_crc_now[1]; 
								m_trans.smf[4][0]  == smf_crc_now[2]; 
								m_trans.smf[6][0]  == smf_crc_now[3]; 
								m_trans.smf[0][1:7]=={7'b0011011}; //// smf_crc4[0],7'b001101
								m_trans.smf[2][1:7]=={7'b0011011}; //// smf_crc4[1],7'b001101
								m_trans.smf[4][1:7]=={7'b0011011}; //// smf_crc4[2],7'b001101
								m_trans.smf[6][1:7]=={7'b0011011}; //// smf_crc4[3],7'b001101
								m_trans.smf[1][0:7]=={2'b01,1'b0,5'b00000}; ////2'b01,smf_alarm,smf_sa4_8
								m_trans.smf[3][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
								m_trans.smf[5][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
								m_trans.smf[7][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
							    m_trans.smf[0][8:255] ==  { a_inc[0],{6{a_inc[1],a_inc[2],a_inc[3],a_inc[4],a_inc[5]}}  }; 
							    m_trans.smf[1][8:255] ==  { a_inc[0],{6{a_inc[1],a_inc[2],a_inc[3],a_inc[4],a_inc[5]}}  }; 
							    m_trans.smf[2][8:255] ==  { a_inc[0],{6{a_inc[1],a_inc[2],a_inc[3],a_inc[4],a_inc[5]}}  }; 
							    m_trans.smf[3][8:255] ==  { a_inc[0],{6{a_inc[1],a_inc[2],a_inc[3],a_inc[4],a_inc[5]}}  }; 
							    m_trans.smf[4][8:255] ==  { a_inc[0],{6{a_inc[1],a_inc[2],a_inc[3],a_inc[4],a_inc[5]}}  }; 
							    m_trans.smf[5][8:255] ==  { a_inc[0],{6{a_inc[1],a_inc[2],a_inc[3],a_inc[4],a_inc[5]}}  }; 
							    m_trans.smf[6][8:255] ==  { a_inc[0],{6{a_inc[1],a_inc[2],a_inc[3],a_inc[4],a_inc[5]}}  }; 
							    m_trans.smf[7][8:255] ==  { a_inc[0],{6{a_inc[1],a_inc[2],a_inc[3],a_inc[4],a_inc[5]}}  }; 
									} )
								//==== calculate the crc4 
								m_trans.crc4_calculate();
								this.smf_crc = m_trans.smf_crc; // update the result of crc4
								//$display("Package crc4  by sequcence = %b\n",this.smf_crc);
					end
					default:
					begin
						`uvm_do_with( 	m_trans, {
								m_trans.smf[0][0]  == smf_crc_now[0]; 
								m_trans.smf[2][0]  == smf_crc_now[1]; 
								m_trans.smf[4][0]  == smf_crc_now[2]; 
								m_trans.smf[6][0]  == smf_crc_now[3]; 
								m_trans.smf[0][1:7]=={7'b0011011}; //// smf_crc4[0],7'b001101
								m_trans.smf[2][1:7]=={7'b0011011}; //// smf_crc4[1],7'b001101
								m_trans.smf[4][1:7]=={7'b0011011}; //// smf_crc4[2],7'b001101
								m_trans.smf[6][1:7]=={7'b0011011}; //// smf_crc4[3],7'b001101
								m_trans.smf[1][0:7]=={2'b01,1'b0,5'b00000}; ////2'b01,smf_alarm,smf_sa4_8
								m_trans.smf[3][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
								m_trans.smf[5][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
								m_trans.smf[7][0:7]=={2'b01,1'b0,5'b00000}; ////smf_alarm,smf_sa4_8
									} )
								//m_trans.crc4_calculate();
								//this.smf_crc = m_trans.smf_crc;
								//$display("Package crc4  by sequcence = %b\n",this.smf_crc);
					end
					endcase
				end //// end default branch :: 
				endcase

			smf_crc_now = this.smf_crc; //// update the smf_crc result
			$display("Package num by sequcence = %d\n",pck_num);
			pck_num = pck_num + 1;
			m_trans.print();
        end //// end repeat branch 
        #100;
        if(starting_phase != null)
		begin
			$display("Ending uvm simulation by cqiu\n");
            //starting_phase.drop_objection(this);
			$stop;
		end
    endtask
   
    //====
    `uvm_object_utils(e1_input_seq)
	`uvm_declare_p_sequencer(e1_input_sequencer)
endclass

function e1_input_seq::new(string name = "e1_input_seq");
    super.new(name);
	//e1_tlm_num 	  = 16'h5;
	first_head_en = 1'b1;
	pck_num = 0;
	smf_crc = 4'b0000;
	smf_crc_now = 4'b0000;
//	uvm_config_db#(bit[1:0])::get(this,"","sync_ctrl_seq",sync_ctrl_seq);
		//$display("Cann't get the monitor interface by cqiu \n");
	//uvm_config_db#(bit[15:0])::get(this,"","ch_num",ch_num);

endfunction


/*
			m_trans.smf[0]	== 256'h55555555_55555555_55555555_55555555_55555555_55555555_55555555_55555555; 
			m_trans.smf[1]	== 256'h55555555_55555555_55555555_55555555_55555555_55555555_55555555_55555555; 
			m_trans.smf[2]	== 256'h55555555_55555555_55555555_55555555_55555555_55555555_55555555_55555555; 
			m_trans.smf[3]	== 256'h55555555_55555555_55555555_55555555_55555555_55555555_55555555_55555555; 
			m_trans.smf[4]	== 256'h55555555_55555555_55555555_55555555_55555555_55555555_55555555_55555555; 
			m_trans.smf[5]	== 256'h55555555_55555555_55555555_55555555_55555555_55555555_55555555_55555555; 
			m_trans.smf[6]	== 256'h55555555_55555555_55555555_55555555_55555555_55555555_55555555_55555555; 
			m_trans.smf[7]	== 256'h55555555_55555555_55555555_55555555_55555555_55555555_55555555_55555555; 
*/

/*
										m_trans.smf[0]	== {32{8'h55}} ; 
										m_trans.smf[1]	== {32{8'h55}} ; 
										m_trans.smf[2]	== {32{8'h55}} ; 
										m_trans.smf[3]	== {32{8'h55}} ; 
										m_trans.smf[4]	== {32{8'h55}} ; 
										m_trans.smf[5]	== {32{8'h55}} ; 
										m_trans.smf[6]	== {32{8'h55}} ; 
										m_trans.smf[7]	== {32{8'h55}} ; 
*/

//										m_trans.smf  	== '{{32{8'h55}},{32{8'h55}},{32{8'h55}},{32{8'h55}},
//															 {32{8'h55}},{32{8'h55}},{32{8'h55}},{32{8'h55}} };

/*
										m_trans.smf[0]	== {32{8'hff}} ; 
										m_trans.smf[1]	== {32{8'hff}} ; 
										m_trans.smf[2]	== {32{8'hff}} ; 
										m_trans.smf[3]	== {32{8'hff}} ; 
										m_trans.smf[4]	== {32{8'hff}} ; 
										m_trans.smf[5]	== {32{8'hff}} ; 
										m_trans.smf[6]	== {32{8'hff}} ; 
										m_trans.smf[7][0:247]  == {31{8'hff}} ; 
										m_trans.smf[7][248:255]== 8'hf3 ; 
*/

/*
										m_trans.smf[0]	== {32{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}} ; 
										m_trans.smf[1]	== {32{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}} ; 
										m_trans.smf[2]	== {32{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}} ; 
										m_trans.smf[3]	== {32{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}} ; 
										m_trans.smf[4]	== {32{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}} ; 
										m_trans.smf[5]	== {32{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}} ; 
										m_trans.smf[6]	== {32{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}} ; 
										m_trans.smf[7]	== {32{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}} ; 
*/

/*
							    m_trans.smf[0][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[1][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[2][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[3][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[4][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[5][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[6][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
							    m_trans.smf[7][8:255] ==  {31{p_sequencer.e1_cfg.e1_cfg_pck_fix_value}}  ; 
*/

/*
							    m_trans.smf[0][8:255] ==  { 
																a_inc[0], a_inc[1], a_inc[2], a_inc[3], a_inc[4],a_inc[5],
																a_inc[6], a_inc[7], a_inc[8], a_inc[9], a_inc[10],
																a_inc[11],a_inc[12],a_inc[13],a_inc[14],a_inc[15],
																a_inc[16],a_inc[17],a_inc[18],a_inc[19],a_inc[20],
																a_inc[21],a_inc[22],a_inc[23],a_inc[24],a_inc[25],
																a_inc[26],a_inc[27],a_inc[28],a_inc[29],a_inc[30] };
*/
