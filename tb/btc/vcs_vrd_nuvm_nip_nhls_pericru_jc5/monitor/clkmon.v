
////////////////////////////////////////////////////////////////////////////////////////////////////
//  clkmon
////////////////////////////////////////////////////////////////////////////////////////////////////
module clkmon(
  input  wire              clk   ,
  output realtime        freq_clk 
);

////////////////////////////////////////////////////////////////////////////////////////////////////
// use to display the value of the clk 
// for example: clk is 30M , so the freq_clk is 30    number
// for example: clk is 30K , so the freq_clk is 0.03  number
////////////////////////////////////////////////////////////////////////////////////////////////////
realtime t_clk    = 0.0;
//realtime freq_clk = 0.0;
realtime prev_freq_clk = 0.0;
realtime curr_freq_clk = 0.0;

realtime t1 = 0;
realtime t2 = 0;
real t = 0;
real prev_t = 0;

always @( posedge clk ) begin
  t      <= $realtime;
  prev_t <= t;
end

always @( * ) begin
  t_clk = t - prev_t;
  curr_freq_clk = 1000/t_clk;
end

always @( curr_freq_clk ) begin
  if((( curr_freq_clk - prev_freq_clk ) > 0.01) ||
     (( prev_freq_clk - curr_freq_clk ) > 0.01) ) begin
     freq_clk       <= curr_freq_clk;
     prev_freq_clk  <= curr_freq_clk;
  end
end

endmodule
