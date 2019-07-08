module axi_top(

////Clock and reset
input 	ACLK		,
input 	ARESETn		, 

////Write address access
input 	[3:0]AWID		,////WriteAddressId,it is the identifcation tag for the write address group
input	[3:0]AWLEN		,////Burst length,give the exact number of transfers in a burst.
input 	[2:0]AWSIZE		,////Burst size,it indicates the size of each transfer in the burst
input	[1:0]AWLOCK		,////Lock type,axi4 does not support it.
input	[1:0]AWBURST	,////The burst type and the size information,determine how the address for each transfer
						 ////within the burst is calculated. 
						 ////FIXED,the address is the same for every transfer in the burst.repeated accesses same location.
						 ////INCR,(increment,if each transfer 4 bytes,so AWBURST is 4)
						 ////WRAP,similar to the incremention, difference, the address wraps around to a lower address if 
						 ////an upper address limit is reached.
input 	[3:0]AWCACHE	,////bufferable,cacheable,write-through,write-back,allocate attributes
						 ////000 Non-bufferable
						 ////001 bufferable
						 ////... ...
input	[2:0]AWPROT		,////Protection type.
						 ////[0]=0, Unprivileged access =1,Privileged access.......
input 		AWVALID		,////
input		AWREADY		,////
input 	[31:0]AWADDR	,

////Write data access
input 			WID		,////WriteIdTag,This is the ID tag of the write data transfer.Supported only in AXI3
output			WREADY	,////
input			WVALID	,////
input	[31:0]	WDATA	,////
input	[ 3:0]	WSTRB	,////
input 			WLAST	,////

////Write response access
input	[ 3:0]	BID		,////
input	[ 1:0]	BRESP	,////
input			BVALID	,////
input			BREADY	,////

////Read address access
input 			ARVALID ,////
input	[31:0]	ARADDR	,////
input			ARREADY	,////
input	[ 3:0]	ARID	,////
input	[ 3:0]	ARLEN	,////
input	[ 2:0]	ARSIZE	,////
input	[ 1:0]	ARBURST	,////
input	[ 1:0]	ARLOCK	,////
input	[ 3:0]	ARCACHE	,////
input	[ 2:0]	ARPROT	,////

////Read data access
input	[ 3:0]	RID		,////
input	[31:0]	RDATA	,////
input	[ 1:0]	RRESP	,////
input			RLAST	,////
input			RVALID	,////
input			RREADY	,////

////Low power mode
input			CSYSREQ	,////
input			CSYSACK	,////
input			CACTIVE	 ////	
);
