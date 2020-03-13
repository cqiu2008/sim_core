////////////////////////////////////////////////////////////////////////////////////////////////////
//  TASKS 
////////////////////////////////////////////////////////////////////////////////////////////////////
task pclkdly;
  input [31:0]num;
  begin
    repeat(num)begin
      @(posedge aclk_peri_2wrap);
    end
    #1;
  end
endtask

task reset;
  chiprstn_top              =  1'b0     ;// i
  pclkdly(300)                          ;
  chiprstn_top              =  1'b1     ;// i
  pclkdly(300)                          ;
endtask
