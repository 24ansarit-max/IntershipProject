`timescale 1ps/1ps

//============================================================
// 1-Bit Full Adder (Structural)
//============================================================
module full_adder(
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

    xor g1(axb, a, b);
    xor g2(sum, axb, cin);

    and g3(ab, a, b);
    and g4(ac, a, cin);
    and g5(bc, b, cin);

    or  g6(cout, ab, ac, bc);

endmodule


//============================================================
// 4-Bit Ripple Carry Adder
//============================================================
module rca4 #(
    parameter DELAY_PS = 200
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

    full_adder fa0(
        .a(a[0]), .b(b[0]), .cin(cin),
        .sum(sum[0]), .cout(c1)
    );

    full_adder fa1(
        .a(a[1]), .b(b[1]), .cin(c1),
        .sum(sum[1]), .cout(c2)
    );

    full_adder fa2(
        .a(a[2]), .b(b[2]), .cin(c2),
        .sum(sum[2]), .cout(c3)
    );

    full_adder fa3(
        .a(a[3]), .b(b[3]), .cin(c3),
        .sum(sum[3]), .cout(cout)
    );

endmodule


//============================================================
// 1-Bit 2:1 MUX (Structural)
//============================================================
module mux2_1b(
    input  in0,
    input  in1,
    input  sel,
    output out
);

    wire nsel;
    wire w0;
    wire w1;

    not g0(nsel, sel);
    and g1(w0, in0, nsel);
    and g2(w1, in1, sel);
    or  g3(out, w0, w1);

endmodule


//============================================================
// 4-Bit 2:1 MUX (Structural)
//============================================================
module mux2_4b(
    input  [3:0] in0,
    input  [3:0] in1,
    input        sel,
    output [3:0] out
);

    mux2_1b m0(.in0(in0[0]), .in1(in1[0]), .sel(sel), .out(out[0]));
    mux2_1b m1(.in0(in0[1]), .in1(in1[1]), .sel(sel), .out(out[1]));
    mux2_1b m2(.in0(in0[2]), .in1(in1[2]), .sel(sel), .out(out[2]));
    mux2_1b m3(.in0(in0[3]), .in1(in1[3]), .sel(sel), .out(out[3]));

endmodule


//============================================================
// 16-Bit Carry Select Adder
// Pure Structural Style
// No assign statements
// No always blocks
//============================================================
module carry_select_adder #(
    parameter BLOCK_SIZE = 4,
    parameter DELAY_PS   = 200,
    parameter AREA_UM2   = 100,
    parameter POWER_UW   = 50
)(
    input  [15:0] a,
    input  [15:0] b,
    input         cin,
    output [15:0] sum,
    output        cout
);

    //--------------------------------------------------------
    // Block 0 : bits [3:0]
    //--------------------------------------------------------
    wire c0;

    rca4 #(.DELAY_PS(DELAY_PS))
    RCA0 (
        .a   (a[3:0]),
        .b   (b[3:0]),
        .cin (cin),
        .sum (sum[3:0]),
        .cout(c0)
    );

    //--------------------------------------------------------
    // Block 1 : bits [7:4]
    //--------------------------------------------------------
    wire [3:0] sum10;
    wire [3:0] sum11;
    wire       c10;
    wire       c11;
    wire       c1;

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

    mux2_4b MUX_SUM1 (
        .in0(sum10),
        .in1(sum11),
        .sel(c0),
        .out(sum[7:4])
    );

    mux2_1b MUX_CARRY1 (
        .in0(c10),
        .in1(c11),
        .sel(c0),
        .out(c1)
    );

    //--------------------------------------------------------
    // Block 2 : bits [11:8]
    //--------------------------------------------------------
    wire [3:0] sum20;
    wire [3:0] sum21;
    wire       c20;
    wire       c21;
    wire       c2;

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

    mux2_4b MUX_SUM2 (
        .in0(sum20),
        .in1(sum21),
        .sel(c1),
        .out(sum[11:8])
    );

    mux2_1b MUX_CARRY2 (
        .in0(c20),
        .in1(c21),
        .sel(c1),
        .out(c2)
    );

    //--------------------------------------------------------
    // Block 3 : bits [15:12]
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

    mux2_4b MUX_SUM3 (
        .in0(sum30),
        .in1(sum31),
        .sel(c2),
        .out(sum[15:12])
    );

    mux2_1b MUX_CARRY3 (
        .in0(c30),
        .in1(c31),
        .sel(c2),
        .out(cout)
    );

    //--------------------------------------------------------
    // Timing Specification
    //--------------------------------------------------------
    specify
        specparam WORST_CASE_DELAY = (7 * DELAY_PS);

        (cin => cout) = WORST_CASE_DELAY;
        (a   *> sum ) = WORST_CASE_DELAY;
        (b   *> sum ) = WORST_CASE_DELAY;
    endspecify

endmodule
