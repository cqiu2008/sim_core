////////////////////////////////////////////////////////////////////////////////////////////////////
//  TASKS 
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
//  pclkaodly
task pclkaodly(bit [31:0]num);
  begin
    repeat(num)begin
      @(posedge U_cru_wrapper.pclk_ao_2wrap);
    end
    #1;
  end
endtask

//  pclk_cru
task pclkdly(bit [31:0]num);
  begin
    repeat(num)begin
      @(posedge pclk_cru);
    end
    #1;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  wregcruao 
task wregcruao(
  logic     [31: 0] ipaddr  ,// Address bus
  logic     [31: 0] ipwdata  // Write data Bus
);
  begin
  //Setup Time
    paddr   <= ipaddr       ;
    pwdata  <= ipwdata      ;
    psel    <= 1'b1         ;
    penable <= 1'b0         ;
    pwrite  <= 1'b1         ;
    pclkaodly(1)            ;
  //Write Time
    psel    <= 1'b1         ;
    penable <= 1'b1         ;
    pwrite  <= 1'b1         ;
    pclkaodly(1)            ;
  //Release Time
    psel    <= 1'b0         ;
    penable <= 1'b0         ;
    pwrite  <= 1'b0         ;
    pclkaodly(1)            ;
  end
endtask

//  wregcru
task wregcru(
  logic     [31: 0] ipaddr  ,// Address bus
  logic     [31: 0] ipwdata  // Write data Bus
);
  begin
  //Setup Time
    paddr_cru   <= ipaddr   ;
    pwdata_cru  <= ipwdata  ;
    psel_cru    <= 1'b1     ;
    penable_cru <= 1'b0     ;
    pwrite_cru  <= 1'b1     ;
    pclkdly(1)              ;
  //Write Time
    psel_cru    <= 1'b1     ;
    penable_cru <= 1'b1     ;
    pwrite_cru  <= 1'b1     ;
    pclkdly(1)              ;
  //Release Time
    psel_cru    <= 1'b0     ;
    penable_cru <= 1'b0     ;
    pwrite_cru  <= 1'b0     ;
    pclkdly(1)              ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  rregcruao
task rregcruao(
  logic     [31: 0] ipaddr    // Address bus
);
  begin
  //Setup Time
    paddr   <= ipaddr         ;
    psel    <= 1'b1           ;
    penable <= 1'b0           ;
    pwrite  <= 1'b0           ;
    pclkaodly(1)              ;
  //Read Time
    psel    <= 1'b1           ;
    penable <= 1'b1           ;
    pwrite  <= 1'b0           ;
    pclkaodly(1)              ;
  //Get Data Time
    //oprdata = prdata        ;
    psel    <= 1'b0           ;
    penable <= 1'b0           ;
    pwrite  <= 1'b0           ;
    pclkaodly(1)              ;
  end
endtask

//  rregcru
task rregcru(
  logic     [31: 0] ipaddr     // Address bus
);
  begin
  //Setup Time
    paddr_cru   <= ipaddr     ;
    psel_cru    <= 1'b1       ;
    penable_cru <= 1'b0       ;
    pwrite_cru  <= 1'b0       ;
    pclkdly(1)                ;
  //Read Time
    psel_cru    <= 1'b1       ;
    penable_cru <= 1'b1       ;
    pwrite_cru  <= 1'b0       ;
    pclkdly(1)                ;
  //Get Data Time
    //oprdata_cru = prdata    ;
    psel_cru    <= 1'b0       ;
    penable_cru <= 1'b0       ;
    pwrite_cru  <= 1'b0       ;
    pclkdly(1)                ;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//  reset
////////////////////////////////////////////////////////////////////////////////////////////////////
task reset;
  begin
    npor        = 1'b1          ;
    npor_to_cru = 1'b1          ;
    rstn_pd     = 1'b1          ;
    wdt_rstn    = 1'b1          ;
    pclkdly(100)                ;
    npor        = 1'b0          ;
    npor_to_cru = 1'b0          ;
    rstn_pd     = 1'b0          ;
    wdt_rstn    = 1'b0          ;
    pclkdly(100)                ;
    npor = 1'b1                 ;
    npor_to_cru = 1'b1          ;
    rstn_pd     = 1'b1          ;
    wdt_rstn    = 1'b1          ;
  end
endtask
