module fifo_mem # 
( 
    parameter DW = 16, 
    parameter AW = 4 
) 
( 
    input clk, 
    input we, 
    input [AW-1:0] waddr, 
    input [AW-1:0] raddr, 
    input [DW-1:0] din, 
    output [DW-1:0] dout 
); 
 
    RAMB18E1 #( 
        .READ_WIDTH_A(18), 
        .WRITE_WIDTH_A(18), 
        .READ_WIDTH_B(18), 
        .WRITE_WIDTH_B(18), 
        .WRITE_MODE_A("READ_FIRST"), 
        .WRITE_MODE_B("READ_FIRST") 
    ) 
    bram ( 
        .CLKA(clk), 
        .CLKB(clk), 
 
        .ADDRA({4'b0, waddr}), 
        .ADDRB({4'b0, raddr}), 
 
        .DIA({2'b0, din}), 
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
module ptr_inc # 
( 
    parameter AW = 4 
) 
( 
    input  [AW:0] q, 
    output [AW:0] d 
); 
 
    LUT1 #(.INIT(2'b01)) u0 (.I0(q[0]), .O(d[0])); 
 
    genvar i; 
    generate 
        for (i = 1; i <= AW; i = i + 1) 
        begin : INC 
            LUT2 #(.INIT(4'b0110)) u_inc ( 
                .I0(q[i]), 
                .I1(q[i-1]), 
                .O(d[i]) 
            ); 
        end 
    endgenerate 
 
endmodule 
module ptr_reg # 
( 
    parameter AW = 4 
) 
( 
    input clk, 
    input rst_n, 
    input ce, 
    input [AW:0] d, 
    output [AW:0] q 
); 
 
    genvar i; 
    generate 
        for (i = 0; i <= AW; i = i + 1) 
        begin : FF 
            FDRE ff ( 
                .C(clk), 
                .CE(ce), 
                .D(d[i]), 
                .Q(q[i]), 
                .R(~rst_n) 
            ); 
        end 
    endgenerate 
 
endmodule 
module fifo_ctrl # 
( 
    parameter AW = 4 
) 
( 
    input clk, 
    input rst_n, 
    input wr_en, 
    input rd_en, 
    input full, 
    input empty, 
 
    output [AW:0] wr_ptr, 
    output [AW:0] rd_ptr 
); 
 
    wire [AW:0] wr_d; 
    wire [AW:0] rd_d; 
 
    wire wr_ce; 
    wire rd_ce; 
 
    LUT2 #(.INIT(4'b1000)) u_wr_ce (.I0(wr_en), .I1(~full), .O(wr_ce)); 
    LUT2 #(.INIT(4'b1000)) u_rd_ce (.I0(rd_en), .I1(~empty), .O(rd_ce)); 
 
    wire [AW:0] wr_inc; 
    wire [AW:0] rd_inc; 
 
    ptr_inc #(.AW(AW)) INCW (.q(wr_ptr), .d(wr_inc)); 
    ptr_inc #(.AW(AW)) INCR (.q(rd_ptr), .d(rd_inc)); 
 
    ptr_reg #(.AW(AW)) REGW (.clk(clk), .rst_n(rst_n), .ce(wr_ce), .d(wr_inc), .q(wr_ptr)); 
    ptr_reg #(.AW(AW)) REGR (.clk(clk), .rst_n(rst_n), .ce(rd_ce), .d(rd_inc), .q(rd_ptr)); 
 
endmodule 
module fifo_flags # 
( 
    parameter AW = 4, 
    parameter DEPTH = 16 
) 
( 
    input [AW:0] wr_ptr, 
    input [AW:0] rd_ptr, 
 
    output full, 
    output empty, 
    output almost_full, 
    output almost_empty 
); 
 
    wire eq0, eq1, eq2, eq3; 
 
    LUT2 #(.INIT(4'b1001)) x0 (.I0(wr_ptr[0]), .I1(rd_ptr[0]), .O(eq0)); 
    LUT2 #(.INIT(4'b1001)) x1 (.I0(wr_ptr[1]), .I1(rd_ptr[1]), .O(eq1)); 
    LUT2 #(.INIT(4'b1001)) x2 (.I0(wr_ptr[2]), .I1(rd_ptr[2]), .O(eq2)); 
    LUT2 #(.INIT(4'b1001)) x3 (.I0(wr_ptr[3]), .I1(rd_ptr[3]), .O(eq3)); 
 
    wire eq_and1, eq_and2; 
 
    LUT6 #(.INIT(64'h8000000000000000)) a1 ( 
        .I0(eq0), .I1(eq1), .I2(eq2), 
        .I3(eq3), .I4(1'b1), .I5(1'b1), 
        .O(empty) 
    ); 
 
    LUT2 #(.INIT(4'b0110)) msb_xor ( 
        .I0(wr_ptr[AW]), 
        .I1(rd_ptr[AW]), 
        .O(eq_and1) 
    ); 
 
    LUT4 #(.INIT(16'h8000)) addr_eq ( 
        .I0(eq0), .I1(eq1), .I2(eq2), .I3(eq3), 
        .O(eq_and2) 
    ); 
 
    LUT2 #(.INIT(4'b1000)) full_lut ( 
        .I0(eq_and1), 
        .I1(eq_and2), 
        .O(full) 
    ); 
 
    // approximate thresholds via LUT compare 
    LUT2 #(.INIT(4'b1110)) af (.I0(wr_ptr[3]), .I1(rd_ptr[3]), .O(almost_full)); 
    LUT2 #(.INIT(4'b0001)) ae (.I0(wr_ptr[1]), .I1(rd_ptr[1]), .O(almost_empty)); 
 
endmodule 
module fifo_top # 
( 
    parameter DW = 16, 
    parameter AW = 4 
) 
( 
    input clk, 
    input rst_n, 
    input wr_en, 
    input rd_en, 
    input [DW-1:0] din, 
 
    output [DW-1:0] dout, 
    output full, 
    output empty, 
    output almost_full, 
    output almost_empty 
); 
 
    wire [AW:0] wr_ptr; 
    wire [AW:0] rd_ptr; 
 
    wire wr_ce, rd_ce; 
    wire wr_we; 
 
    fifo_flags #(.AW(AW), .DEPTH(16)) 
    F (.wr_ptr(wr_ptr), .rd_ptr(rd_ptr), 
       .full(full), .empty(empty), 
       .almost_full(almost_full), 
       .almost_empty(almost_empty)); 
 
    fifo_ctrl #(.AW(AW)) 
    C (.clk(clk), .rst_n(rst_n), 
       .wr_en(wr_en), .rd_en(rd_en), 
       .full(full), .empty(empty), 
       .wr_ptr(wr_ptr), .rd_ptr(rd_ptr)); 
 
    LUT2 #(.INIT(4'b1000)) we_lut (.I0(wr_en), .I1(~full), .O(wr_we)); 
 
    fifo_mem #(.DW(DW), .AW(AW)) 
    M (.clk(clk), 
       .we(wr_we), 
       .waddr(wr_ptr[3:0]), 
       .raddr(rd_ptr[3:0]), 
       .din(din), 
       .dout(dout)); 
 
endmodule
