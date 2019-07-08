////////////////FPGA Device Data Sheet Begin ///////////////////////////
////xczu9eg-ffvb1156-2L-e-es2 for vivado board 
////xczu9eg-ffvb1156-2L-e-es1 for vivado board 
////xczu9eg-ffvb1156-2L-e-EVAL for vivado hls 
////////////////FPGA Device Data Sheet End//////////////////////////////

////////////////Just For Simulation Node Description Begin//////////////
//// 	Node0: Platform
//// 		windows or linux, Folder split : runsimlin, runsimwin
//// 		discreption: windows do not have makefile 
//// 		So no platform
//// 	Node1: Simulator Type(2 Type,omit vcs)
//// 		questasim , vivadosim , vcs and so on 
//// 	Node2: Wave Type(2 Type)
//// 		without Verdi, with Verdi
//// 	Node3: UVM Type (2 Type)
//// 		with UVM , without UVM
//// 	Node4: IP Type (4 Type, but have subType)
//// 		without IP, 
//// 		with Xilinx IP, (vvd2016.2,vvd2014.2 and so on)
//// 		with Altera IP, 
//// 		with Lattice IP 
//// 	Node5: Other Type (2 Type) 
//// 		without HLS Type, with HLS Type
////		(If with HLS type,Must be without UVM,with xilinx ip)
////////////////Just For Simulation Node Description End //////////////

////////////////Just For Simulation Name Rule Description Begin//////////////
////	(1)Word abbreviation
////		(name rule: omit the "a,e,i,o,u",or hold the first word)
////	qst 		==== questasim 
////	vvd 		==== vivado
////	vrd 		==== verdi 
////	xip 		==== xilinx	ipcore
////	aip 		==== altera ipcore 
////	lip			==== lattice ipcore
////	(2)Prefix is "N" and then word abbreviation
////		(name rule: "nxx" means "no xx" ) 
////	nvrd		==== no verdi
////	nuvm		==== no uvm 
////	nip			==== no ip
////	nhls		==== no hls 
////////////////Just For Simulation Name Rule Description End   //////////////

////////////////Just For Simulation Makefile Type Description Begin//////////////
////	Makefile.qst.nvrd.nuvm.nip.nhls	====	questa,NoVerdi,NoUVM,NoIp,NoHLS
////	Makefile.qst.nvrd.nuvm.lip.nhls	==== 	questa,NoVerdi,NoUVM,latticeIp,NoHLS
////	Makefile.qst.nvrd.nuvm.aip.nhls	==== 	questa,NoVerdi,NoUVM,alteraIp,NoHLS
////	Makefile.qst.nvrd.nuvm.xip.nhls	==== 	questa,NoVerdi,NoUVM,xilinxIp,NoHLS
////	Makefile.qst.nvrd.nuvm.xip.hls 	==== 	questa,NoVerdi,NoUVM,xilinxip,HLS
////	////////
////	Makefile.qst.nvrd.uvm.nip.nhls	====	questa,NoVerdi,UVM,NoIp,NoHLS
////	Makefile.qst.nvrd.uvm.lip.nhls	==== 	questa,NoVerdi,UVM,latticeIp,NoHLS
////	Makefile.qst.nvrd.uvm.aip.nhls	==== 	questa,NoVerdi,UVM,alteraIp,NoHLS
////	Makefile.qst.nvrd.uvm.xip.nhls	==== 	questa,NoVerdi,UVM,xilinxIp,NoHLS
////	////////
////	Makefile.qst.vrd.nuvm.nip.nhls	====	questa,Verdi,NoUVM,NoIp,NoHLS
////	Makefile.qst.vrd.nuvm.lip.nhls	==== 	questa,Verdi,NoUVM,latticeIp,NoHLS
////	Makefile.qst.vrd.nuvm.aip.nhls	==== 	questa,Verdi,NoUVM,alteraIp,NoHLS
////	Makefile.qst.vrd.nuvm.xip.nhls	==== 	questa,Verdi,NoUVM,xilinxIp,NoHLS
////	Makefile.qst.vrd.nuvm.xip.hls 	====	questa,Verdi,NoUVM,xilinxip,HLS
////	////////
////	Makefile.qst.vrd.uvm.nip.nhls	====	questa,Verdi,UVM,NoIp,NoHLS
////	Makefile.qst.vrd.uvm.lip.nhls	==== 	questa,Verdi,UVM,latticeIp,NoHLS
////	Makefile.qst.vrd.uvm.aip.nhls	==== 	questa,Verdi,UVM,alteraIp,NoHLS
////	Makefile.qst.vrd.uvm.xip.nhls	==== 	questa,Verdi,UVM,xilinxIp,NoHLS
////	////////
////	Makefile.vvd.nvrd.nuvm.nip.nhls	====	vivado,NoVerdi,NoUVM,NoIp,NoHLS
////	Makefile.vvd.nvrd.nuvm.xip.nhls	==== 	vivado,NoVerdi,NoUVM,xilinxIp,NoHLS
////	Makefile.vvd.nvrd.nuvm.xip.hls 	====	vivado,NoVerdi,NoUVM,xilinxIp,HLS
////////////////Just For Simulation Makefile Type Description End  //////////////

////////
////	2.Just For Vivado Compiler
////None
