module sva_check_result(
	input 	sva_clk			,
	input 	sva_sync_state	,
	input 	sva_chk_edge	,
	input	sva_chk_result	
);

property chk_result;
	@(posedge sva_clk) disable iff(~sva_sync_state) //// if not synchronize ,then disable sva 
	( $rose (sva_chk_edge) | $fell(sva_chk_edge) ) |-> ##[1:2] sva_chk_result;
endproperty
assert_chk_result:assert property(chk_result);

endmodule

