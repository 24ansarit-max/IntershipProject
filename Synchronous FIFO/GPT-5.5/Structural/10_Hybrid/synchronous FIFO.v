module fifo_mem # 
( 
    parameter DATA_WIDTH = 16, 
    parameter ADDR_WIDTH = 4 
) 
( 
    input clk, 
    input we, 
    input [ADDR_WIDTH-1:0] waddr, 
    input [ADDR_WIDTH-1:0] raddr, 
    input [DATA_WIDTH-1:0] din, 
    output [DATA_WIDTH-1:0] dout 
); 
 
    (* ram_style = "block" *) 
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1]; 
 
    // BRAM read-first behavior inferred structurally via RAMB18E1 mapping 
    RAMB18E1 bram_inst ( 
        .CLKA(clk), 
        .CLKB(clk), 
        .ADDRA({4'b0,waddr}), 
        .ADDRB({4'b0,raddr}), 
        .DIA({2'b0,din}), 
        .DIB(16'b0), 
        .WEA(we), 
        .WEB(1'b0), 
        .ENA(1'b1), 
        .ENB(1'b1), 
        .DOA(), 
        .DOB(dout), 
        .RSTA(1'b0), 
        .RSTB(1'b0), 
        .REGCEA(1'b0), 
        .REGCEB(1'b0) 
    ); 
 
endmodule 
module fifo_ctrl # 
( 
    parameter ADDR_WIDTH = 4 
) 
( 
    input clk, 
    input rst_n, 
    input wr_en, 
    input rd_en, 
    input full, 
    input empty, 
 
    output [ADDR_WIDTH:0] wr_ptr, 
    output [ADDR_WIDTH:0] rd_ptr 
); 
 
    wire wr_ce; 
    wire rd_ce; 
 
    LUT2 #(.INIT(4'b1000)) u1 (.I0(wr_en), .I1(~full), .O(wr_ce)); 
    LUT2 #(.INIT(4'b1000)) u2 (.I0(rd_en), .I1(~empty), .O(rd_ce)); 
 
    wire [ADDR_WIDTH:0] wr_next; 
    wire [ADDR_WIDTH:0] rd_next; 
 
    ptr_inc INCW (.q(wr_ptr), .d(wr_next)); 
    ptr_inc INCR (.q(rd_ptr), .d(rd_next)); 
 
    ptr_reg REGW (.clk(clk), .rst_n(rst_n), .ce(wr_ce), .d(wr_next), .q(wr_ptr)); 
    ptr_reg REGR (.clk(clk), .rst_n(rst_n), .ce(rd_ce), .d(rd_next), .q(rd_ptr)); 
 
endmodule 
module fifo_flags # 
( 
    parameter ADDR_WIDTH = 4 
) 
( 
    input [ADDR_WIDTH:0] wr_ptr, 
    input [ADDR_WIDTH:0] rd_ptr, 
 
    output full, 
    output empty, 
    output almost_full, 
    output almost_empty 
); 
 
    wire eq; 
    wire wrap_diff; 
 
    LUT4 #(.INIT(16'h9009)) eq_lut ( 
        .I0(wr_ptr[0]), 
        .I1(rd_ptr[0]), 
        .I2(wr_ptr[1]), 
        .I3(rd_ptr[1]), 
        .O(eq) 
    ); 
 
    LUT2 #(.INIT(4'b0110)) xor_wrap ( 
        .I0(wr_ptr[4]), 
        .I1(rd_ptr[4]), 
        .O(wrap_diff) 
    ); 
 
    LUT2 #(.INIT(4'b1000)) full_lut ( 
        .I0(wrap_diff), 
        .I1(eq), 
        .O(full) 
    ); 
 
    LUT2 #(.INIT(4'b1001)) empty_lut ( 
        .I0(wr_ptr[0]), 
        .I1(rd_ptr[0]), 
        .O(empty) 
    ); 
 
    LUT2 #(.INIT(4'b1110)) af (.I0(wr_ptr[3]), .I1(rd_ptr[3]), .O(almost_full)); 
    LUT2 #(.INIT(4'b0001)) ae (.I0(wr_ptr[1]), .I1(rd_ptr[1]), .O(almost_empty)); 
 
endmodule 
module fifo_top # 
( 
    parameter DATA_WIDTH = 16, 
    parameter ADDR_WIDTH = 4 
) 
( 
    input clk, 
    input rst_n, 
    input wr_en, 
    input rd_en, 
    input [DATA_WIDTH-1:0] din, 
 
    output [DATA_WIDTH-1:0] dout, 
    output full, 
    output empty, 
    output almost_full, 
    output almost_empty 
); 
 
    wire [ADDR_WIDTH:0] wr_ptr; 
    wire [ADDR_WIDTH:0] rd_ptr; 
    wire [DATA_WIDTH-1:0] mem_dout; 
 
    wire wr_g; 
    wire rd_g; 
 
    fifo_ctrl CTRL ( 
        .clk(clk), 
        .rst_n(rst_n), 
        .wr_en(wr_en), 
        .rd_en(rd_en), 
        .full(full), 
        .empty(empty), 
        .wr_ptr(wr_ptr), 
        .rd_ptr(rd_ptr) 
    ); 
 
    fifo_flags FLAGS ( 
        .wr_ptr(wr_ptr), 
        .rd_ptr(rd_ptr), 
        .full(full), 
        .empty(empty), 
        .almost_full(almost_full), 
        .almost_empty(almost_empty) 
    ); 
 
    fifo_mem MEM ( 
        .clk(clk), 
        .we(wr_en), 
        .waddr(wr_ptr[3:0]), 
        .raddr(rd_ptr[3:0]), 
        .din(din), 
        .dout(mem_dout) 
    ); 
 
    // structural buffer (no assign allowed) 
    BUF buf0 (.I(mem_dout[0]), .O(dout[0])); 
 
endmodule
