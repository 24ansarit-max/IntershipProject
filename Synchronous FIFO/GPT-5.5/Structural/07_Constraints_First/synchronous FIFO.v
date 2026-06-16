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
    input [AW:0] q, 
    output [AW:0] d 
); 
 
    LUT1 #(.INIT(2'b01)) u0 (.I0(q[0]), .O(d[0])); 
 
    genvar i; 
    generate 
        for (i = 1; i <= AW; i = i + 1) 
        begin : INC 
            LUT2 #(.INIT(4'b0110)) u_add ( 
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
 
    wire wr_ce; 
    wire rd_ce; 
 
    LUT2 #(.INIT(4'b1000)) g1 (.I0(wr_en), .I1(~full), .O(wr_ce)); 
    LUT2 #(.INIT(4'b1000)) g2 (.I0(rd_en), .I1(~empty), .O(rd_ce)); 
 
    wire [AW:0] wr_next; 
    wire [AW:0] rd_next; 
 
    ptr_inc #(.AW(AW)) INCW (.q(wr_ptr), .d(wr_next)); 
    ptr_inc #(.AW(AW)) INCR (.q(rd_ptr), .d(rd_next)); 
 
    ptr_reg #(.AW(AW)) REGW (.clk(clk), .rst_n(rst_n), .ce(wr_ce), .d(wr_next), .q(wr_ptr)); 
    ptr_reg #(.AW(AW)) REGR (.clk(clk), .rst_n(rst_n), .ce(rd_ce), .d(rd_next), .q(rd_ptr)); 
 
endmodule 
module fifo_flags # 
( 
    parameter AW = 4 
) 
( 
    input [AW:0] wr_ptr, 
    input [AW:0] rd_ptr, 
 
    output full, 
    output empty, 
    output almost_full, 
    output almost_empty 
); 
 
    wire e0, e1, e2, e3; 
 
    LUT2 #(.INIT(4'b1001)) x0 (.I0(wr_ptr[0]), .I1(rd_ptr[0]), .O(e0)); 
    LUT2 #(.INIT(4'b1001)) x1 (.I0(wr_ptr[1]), .I1(rd_ptr[1]), .O(e1)); 
    LUT2 #(.INIT(4'b1001)) x2 (.I0(wr_ptr[2]), .I1(rd_ptr[2]), .O(e2)); 
    LUT2 #(.INIT(4'b1001)) x3 (.I0(wr_ptr[3]), .I1(rd_ptr[3]), .O(e3)); 
 
    LUT4 #(.INIT(16'h8000)) eq_tree ( 
        .I0(e0), .I1(e1), .I2(e2), .I3(e3), 
        .O(empty) 
    ); 
 
    wire msb_xor; 
    LUT2 #(.INIT(4'b0110)) m (.I0(wr_ptr[4]), .I1(rd_ptr[4]), .O(msb_xor)); 
 
    LUT2 #(.INIT(4'b1000)) f (.I0(msb_xor), .I1(empty), .O(full)); 
 
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
 
    wire wr_g; 
    wire rd_g; 
 
    fifo_flags #(.AW(ADDR_WIDTH)) F ( 
        .wr_ptr(wr_ptr), 
        .rd_ptr(rd_ptr), 
        .full(full), 
        .empty(empty), 
        .almost_full(almost_full), 
        .almost_empty(almost_empty) 
    ); 
 
    fifo_ctrl #(.AW(ADDR_WIDTH)) C ( 
        .clk(clk), 
        .rst_n(rst_n), 
        .wr_en(wr_en), 
        .rd_en(rd_en), 
        .full(full), 
        .empty(empty), 
        .wr_ptr(wr_ptr), 
        .rd_ptr(rd_ptr) 
    ); 
 
    LUT2 #(.INIT(4'b1000)) g1 (.I0(wr_en), .I1(~full), .O(wr_g)); 
    LUT2 #(.INIT(4'b1000)) g2 (.I0(rd_en), .I1(~empty), .O(rd_g)); 
 
    fifo_mem #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) M ( 
        .clk(clk), 
        .we(wr_g), 
        .waddr(wr_ptr[3:0]), 
        .raddr(rd_ptr[3:0]), 
        .din(din), 
        .dout(dout) 
    ); 
 
endmodule
