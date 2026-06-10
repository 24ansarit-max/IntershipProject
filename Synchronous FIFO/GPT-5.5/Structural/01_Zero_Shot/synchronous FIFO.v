module wr_ptr # 
( 
    parameter ADDR_WIDTH = 4 
) 
( 
    input clk, 
    input rst_n, 
    input inc, 
 
    output [ADDR_WIDTH:0] wr_ptr 
); 
 
    wire [ADDR_WIDTH:0] d; 
 
    // simple increment using LUT-based +1 chain 
    LUT1 #(.INIT(2'b01)) u0 (.I0(wr_ptr[0]), .O(d[0])); 
 
    generate 
        genvar i; 
        for (i = 1; i <= ADDR_WIDTH; i = i + 1) 
        begin : INC_CHAIN 
            LUT2 #(.INIT(4'b0110)) u_inc ( 
                .I0(wr_ptr[i]), 
                .I1(wr_ptr[i-1]), 
                .O(d[i]) 
            ); 
        end 
    endgenerate 
 
    genvar k; 
    generate 
        for (k = 0; k <= ADDR_WIDTH; k = k + 1) 
        begin : FF 
            FDRE ff ( 
                .C(clk), 
                .CE(inc), 
                .D(d[k]), 
                .Q(wr_ptr[k]), 
                .R(~rst_n) 
            ); 
        end 
    endgenerate 
 
endmodule 
module rd_ptr # 
( 
    parameter ADDR_WIDTH = 4 
) 
( 
    input clk, 
    input rst_n, 
    input inc, 
 
    output [ADDR_WIDTH:0] rd_ptr 
); 
 
    wire [ADDR_WIDTH:0] d; 
 
    LUT1 #(.INIT(2'b01)) u0 (.I0(rd_ptr[0]), .O(d[0])); 
 
    genvar i; 
    generate 
        for (i = 1; i <= ADDR_WIDTH; i = i + 1) 
        begin : INC 
            LUT2 #(.INIT(4'b0110)) u_inc ( 
                .I0(rd_ptr[i]), 
                .I1(rd_ptr[i-1]), 
                .O(d[i]) 
            ); 
        end 
    endgenerate 
 
    genvar k; 
    generate 
        for (k = 0; k <= ADDR_WIDTH; k = k + 1) 
        begin : FF 
            FDRE ff ( 
                .C(clk), 
                .CE(inc), 
                .D(d[k]), 
                .Q(rd_ptr[k]), 
                .R(~rst_n) 
            ); 
        end 
    endgenerate 
 
endmodule 
module fifo_flags # 
( 
    parameter ADDR_WIDTH = 4 
) 
( 
    input  [ADDR_WIDTH:0] wr_ptr, 
    input  [ADDR_WIDTH:0] rd_ptr, 
 
    output full, 
    output empty 
); 
 
    // EMPTY = wr_ptr == rd_ptr 
    wire [ADDR_WIDTH:0] eq; 
 
    genvar i; 
    generate 
        for (i = 0; i <= ADDR_WIDTH; i = i + 1) 
        begin : XNOR_BITS 
            LUT2 #(.INIT(4'b1001)) xnor_i ( 
                .I0(wr_ptr[i]), 
                .I1(rd_ptr[i]), 
                .O(eq[i]) 
            ); 
        end 
    endgenerate 
 
    // AND all bits (tree using LUT6) 
    wire e1, e2, e3; 
 
    LUT6 #(.INIT(64'h8000000000000000)) and1 ( 
        .I0(eq[0]), .I1(eq[1]), .I2(eq[2]), 
        .I3(eq[3]), .I4(1'b1), .I5(1'b1), 
        .O(e1) 
    ); 
 
    assign empty = e1; 
 
    // FULL detection (MSB flip + address equal) 
    wire msb_xor; 
 
    LUT2 #(.INIT(4'b0110)) msb ( 
        .I0(wr_ptr[ADDR_WIDTH]), 
        .I1(rd_ptr[ADDR_WIDTH]), 
        .O(msb_xor) 
    ); 
 
    wire addr_eq; 
 
    LUT4 #(.INIT(16'h8000)) addr_and ( 
        .I0(eq[0]), 
        .I1(eq[1]), 
        .I2(eq[2]), 
        .I3(eq[3]), 
        .O(addr_eq) 
    ); 
 
    LUT2 #(.INIT(4'b1000)) full_lut ( 
        .I0(msb_xor), 
        .I1(addr_eq), 
        .O(full) 
    ); 
 
endmodule 
module fifo_mem # 
( 
    parameter DATA_WIDTH = 16 
) 
( 
    input clk, 
 
    input  [3:0] waddr, 
    input  [3:0] raddr, 
    input  [DATA_WIDTH-1:0] din, 
    input  we, 
 
    output [DATA_WIDTH-1:0] dout 
); 
 
    RAMB18E1 #( 
        .READ_WIDTH_A(18), 
        .WRITE_WIDTH_A(18), 
        .READ_WIDTH_B(18), 
        .WRITE_WIDTH_B(18), 
        .DOA_REG(0), 
        .DOB_REG(0), 
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
    output empty 
); 
 
    wire [ADDR_WIDTH:0] wrp; 
    wire [ADDR_WIDTH:0] rdp; 
 
    wire wr_inc; 
    wire rd_inc; 
 
    // decode enables (structural LUT) 
    LUT2 #(.INIT(4'b1000)) u_wr_en ( 
        .I0(wr_en), 
        .I1(~full), 
        .O(wr_inc) 
    ); 
 
    LUT2 #(.INIT(4'b1000)) u_rd_en ( 
        .I0(rd_en), 
        .I1(~empty), 
        .O(rd_inc) 
    ); 
 
    wr_ptr #(ADDR_WIDTH) WP ( 
        .clk(clk), 
        .rst_n(rst_n), 
        .inc(wr_inc), 
        .wr_ptr(wrp) 
    ); 
 
    rd_ptr #(ADDR_WIDTH) RP ( 
        .clk(clk), 
        .rst_n(rst_n), 
        .inc(rd_inc), 
        .rd_ptr(rdp) 
    ); 
 
    fifo_flags #(ADDR_WIDTH) FL ( 
        .wr_ptr(wrp), 
        .rd_ptr(rdp), 
        .full(full), 
        .empty(empty) 
    ); 
 
    fifo_mem MEM ( 
        .clk(clk), 
        .waddr(wrp[3:0]), 
        .raddr(rdp[3:0]), 
        .din(din), 
        .we(wr_inc), 
        .dout(dout) 
    ); 
 
endmodule
