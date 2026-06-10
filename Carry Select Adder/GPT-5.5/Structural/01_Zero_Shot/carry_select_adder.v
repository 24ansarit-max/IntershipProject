`timescale 1ps/1ps

//============================================================
// 1-Bit Full Adder (Structural)
//============================================================
module full_adder #(
    parameter integer DELAY_PS = 20,
    parameter integer AREA_UM2 = 2,
    parameter integer POWER_UW = 1
)(
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);

    wire axb;
    wire ab;
    wire ac;
    wire bc;

    xor #(DELAY_PS) U1(axb, a, b);
    xor #(DELAY_PS) U2(sum, axb, cin);

    and #(DELAY_PS) U3(ab, a, b);
    and #(DELAY_PS) U4(ac, a, cin);
    and #(DELAY_PS) U5(bc, b, cin);

    or  #(DELAY_PS) U6(cout, ab, ac, bc);

    specify
        (a   => sum)  = DELAY_PS;
        (b   => sum)  = DELAY_PS;
        (cin => sum)  = DELAY_PS;

        (a   => cout) = DELAY_PS;
        (b   => cout) = DELAY_PS;
        (cin => cout) = DELAY_PS;
    endspecify

endmodule


//============================================================
// 4-Bit Ripple Carry Adder
//============================================================
module rca4 #(
    parameter integer DELAY_PS = 20,
    parameter integer AREA_UM2 = 8,
    parameter integer POWER_UW = 4
)(
    input  [3:0] a,
    input  [3:0] b,
    input        cin,
    output [3:0] sum,
    output       cout
);

    wire c1;
    wire c2;
    wire c3;

    full_adder #(
        .DELAY_PS(DELAY_PS),
        .AREA_UM2(AREA_UM2/4),
        .POWER_UW(POWER_UW/4)
    ) FA0 (
        .a(a[0]), .b(b[0]), .cin(cin),
        .sum(sum[0]), .cout(c1)
    );

    full_adder #(
        .DELAY_PS(DELAY_PS),
        .AREA_UM2(AREA_UM2/4),
        .POWER_UW(POWER_UW/4)
    ) FA1 (
        .a(a[1]), .b(b[1]), .cin(c1),
        .sum(sum[1]), .cout(c2)
    );

    full_adder #(
        .DELAY_PS(DELAY_PS),
        .AREA_UM2(AREA_UM2/4),
        .POWER_UW(POWER_UW/4)
    ) FA2 (
        .a(a[2]), .b(b[2]), .cin(c2),
        .sum(sum[2]), .cout(c3)
    );

    full_adder #(
        .DELAY_PS(DELAY_PS),
        .AREA_UM2(AREA_UM2/4),
        .POWER_UW(POWER_UW/4)
    ) FA3 (
        .a(a[3]), .b(b[3]), .cin(c3),
        .sum(sum[3]), .cout(cout)
    );

    specify
        (cin => cout) = (4*DELAY_PS);
    endspecify

endmodule


//============================================================
// 2:1 Multiplexer
//============================================================
module mux2 #(
    parameter WIDTH = 1,
    parameter integer DELAY_PS = 10,
    parameter integer AREA_UM2 = 1,
    parameter integer POWER_UW = 1
)(
    input  [WIDTH-1:0] d0,
    input  [WIDTH-1:0] d1,
    input              sel,
    output [WIDTH-1:0] y
);

    assign #(DELAY_PS) y = sel ? d1 : d0;

    specify
        (sel => y) = DELAY_PS;
    endspecify

endmodule


//============================================================
// 16-Bit Carry Select Adder
// BLOCK_SIZE = 4
// Explicit Block Instantiations (0..3)
//============================================================
module carry_select_adder #(
    parameter integer BLOCK_SIZE = 4,
    parameter integer DELAY_PS   = 20,
    parameter integer AREA_UM2   = 120,
    parameter integer POWER_UW   = 40
)(
    input  [15:0] a,
    input  [15:0] b,
    input         cin,
    output [15:0] sum,
    output        cout
);

    //--------------------------------------------------------
    // Block 0 : Actual Carry Propagation
    // Bits [3:0]
    //--------------------------------------------------------
    wire c1;

    rca4 #(
        .DELAY_PS(DELAY_PS)
    ) RCA0 (
        .a   (a[3:0]),
        .b   (b[3:0]),
        .cin (cin),
        .sum (sum[3:0]),
        .cout(c1)
    );

    //--------------------------------------------------------
    // Block 1 : Bits [7:4]
    //--------------------------------------------------------
    wire [3:0] sum10;
    wire [3:0] sum11;
    wire       c10;
    wire       c11;
    wire       c2;

    rca4 #(.DELAY_PS(DELAY_PS))
    RCA10 (
        .a(a[7:4]),
        .b(b[7:4]),
        .cin(1'b0),
        .sum(sum10),
        .cout(c10)
    );

    rca4 #(.DELAY_PS(DELAY_PS))
    RCA11 (
        .a(a[7:4]),
        .b(b[7:4]),
        .cin(1'b1),
        .sum(sum11),
        .cout(c11)
    );

    mux2 #(.WIDTH(4), .DELAY_PS(DELAY_PS))
    MUX1_SUM (
        .d0(sum10),
        .d1(sum11),
        .sel(c1),
        .y(sum[7:4])
    );

    mux2 #(.WIDTH(1), .DELAY_PS(DELAY_PS))
    MUX1_CARRY (
        .d0(c10),
        .d1(c11),
        .sel(c1),
        .y(c2)
    );

    //--------------------------------------------------------
    // Block 2 : Bits [11:8]
    //--------------------------------------------------------
    wire [3:0] sum20;
    wire [3:0] sum21;
    wire       c20;
    wire       c21;
    wire       c3;

    rca4 #(.DELAY_PS(DELAY_PS))
    RCA20 (
        .a(a[11:8]),
        .b(b[11:8]),
        .cin(1'b0),
        .sum(sum20),
        .cout(c20)
    );

    rca4 #(.DELAY_PS(DELAY_PS))
    RCA21 (
        .a(a[11:8]),
        .b(b[11:8]),
        .cin(1'b1),
        .sum(sum21),
        .cout(c21)
    );

    mux2 #(.WIDTH(4), .DELAY_PS(DELAY_PS))
    MUX2_SUM (
        .d0(sum20),
        .d1(sum21),
        .sel(c2),
        .y(sum[11:8])
    );

    mux2 #(.WIDTH(1), .DELAY_PS(DELAY_PS))
    MUX2_CARRY (
        .d0(c20),
        .d1(c21),
        .sel(c2),
        .y(c3)
    );

    //--------------------------------------------------------
    // Block 3 : Bits [15:12]
    //--------------------------------------------------------
    wire [3:0] sum30;
    wire [3:0] sum31;
    wire       c30;
    wire       c31;

    rca4 #(.DELAY_PS(DELAY_PS))
    RCA30 (
        .a(a[15:12]),
        .b(b[15:12]),
        .cin(1'b0),
        .sum(sum30),
        .cout(c30)
    );

    rca4 #(.DELAY_PS(DELAY_PS))
    RCA31 (
        .a(a[15:12]),
        .b(b[15:12]),
        .cin(1'b1),
        .sum(sum31),
        .cout(c31)
    );

    mux2 #(.WIDTH(4), .DELAY_PS(DELAY_PS))
    MUX3_SUM (
        .d0(sum30),
        .d1(sum31),
        .sel(c3),
        .y(sum[15:12])
    );

    mux2 #(.WIDTH(1), .DELAY_PS(DELAY_PS))
    MUX3_CARRY (
        .d0(c30),
        .d1(c31),
        .sel(c3),
        .y(cout)
    );

    //--------------------------------------------------------
    // CSA Timing Specification
    //--------------------------------------------------------
    specify
        (cin => cout) = (16*DELAY_PS);
        (a *> sum)    = (16*DELAY_PS);
        (b *> sum)    = (16*DELAY_PS);
    endspecify

endmodule
