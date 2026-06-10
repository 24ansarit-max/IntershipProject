
`timescale 1ps/1ps
module full_adder(
    input a, input b, input cin,
    output sum, output cout
);
    wire axb, ab, ac, bc;
    xor g1(axb, a, b);
    xor g2(sum, axb, cin);
    and g3(ab, a, b);
    and g4(ac, a, cin);
    and g5(bc, b, cin);
    or  g6(cout, ab, ac, bc);
endmodule

module rca4 #(
    parameter DELAY_PS = 200
)(
    input  [3:0] a, b,
    input  cin,
    output [3:0] sum,
    output cout
);
    wire c1, c2, c3;
    full_adder fa0(.a(a[0]), .b(b[0]), .cin(cin),  .sum(sum[0]), .cout(c1));
    full_adder fa1(.a(a[1]), .b(b[1]), .cin(c1),   .sum(sum[1]), .cout(c2));
    full_adder fa2(.a(a[2]), .b(b[2]), .cin(c2),   .sum(sum[2]), .cout(c3));
    full_adder fa3(.a(a[3]), .b(b[3]), .cin(c3),   .sum(sum[3]), .cout(cout));
endmodule

module mux2_1b(input in0, in1, sel, output out);
    wire nsel, w0, w1;
    not g0(nsel, sel);
    and g1(w0, in0, nsel);
    and g2(w1, in1, sel);
    or  g3(out, w0, w1);
endmodule

module mux2_4b(input [3:0] in0, in1, input sel, output [3:0] out);
    mux2_1b m0(.in0(in0[0]), .in1(in1[0]), .sel(sel), .out(out[0]));
    mux2_1b m1(.in0(in0[1]), .in1(in1[1]), .sel(sel), .out(out[1]));
    mux2_1b m2(.in0(in0[2]), .in1(in1[2]), .sel(sel), .out(out[2]));
    mux2_1b m3(.in0(in0[3]), .in1(in1[3]), .sel(sel), .out(out[3]));
endmodule


// FILE: csa16.v
// Module: csa16  Width: 16  Strategy: Carry-Select  Blocks: 4×4

module carry_select_adder #(
    // SECTION 1 — Parameters
    parameter BLOCK_SIZE = 4,     // bits per block
    parameter NUM_BLOCKS = 4,     // 16/BLOCK_SIZE
    parameter DELAY_PS   = 800,   // ps, worst-case path
    parameter AREA_UM2   = 1200,  // µm², 28nm typical
    parameter POWER_UW   = 450    // µW at 1GHz, 1V , α=0.1
)(
    input  [15:0] a,
    input  [15:0] b,
    input         cin,
    output [15:0] sum,
    output        cout
);

    // SECTION 2 — Internal wire declarations

    // RCA outputs: sum_c0_bN[3:0], cout_c0_bN, sum_c1_bN[3:0], cout_c1_bN  (N=0..3)
    wire [3:0] sum_c0_b0, sum_c1_b0;
    wire [3:0] sum_c0_b1, sum_c1_b1;
    wire [3:0] sum_c0_b2, sum_c1_b2;
    wire [3:0] sum_c0_b3, sum_c1_b3;

    wire cout_c0_b0, cout_c1_b0;
    wire cout_c0_b1, cout_c1_b1;
    wire cout_c0_b2, cout_c1_b2;
    wire cout_c0_b3, cout_c1_b3;

    // Mux outputs: sum_bN[3:0], carry_bN  (N=0..3)
    wire [3:0] sum_b0;
    wire [3:0] sum_b1;
    wire [3:0] sum_b2;
    wire [3:0] sum_b3;

    wire carry_b0;
    wire carry_b1;
    wire carry_b2;
    wire carry_b3;

    // SECTION 3 — Block 0 (bits [3:0]) — no mux needed, cin=0 hardwired

    rca4 #(.DELAY_PS(DELAY_PS)) rca_c0_b0 (
        .a   (a[3:0]),
        .b   (b[3:0]),
        .cin (1'b0),
        .sum (sum_c0_b0),
        .cout(cout_c0_b0)
    );

    rca4 #(.DELAY_PS(DELAY_PS)) rca_c1_b0 (
        .a   (a[3:0]),
        .b   (b[3:0]),
        .cin (1'b1),
        .sum (sum_c1_b0),
        .cout(cout_c1_b0)
    );

    mux2_4b mux_b0 (
        .in0(sum_c0_b0),
        .in1(sum_c1_b0),
        .sel(cin),
        .out(sum_b0)
    );

    assign carry_b0 = (cin) ? cout_c1_b0 : cout_c0_b0;

    // Block 0 carry goes directly to mux_sel of block 1

    // SECTION 4 — Block 1

    rca4 #(.DELAY_PS(DELAY_PS)) rca_c0_b1 (
        .a   (a[7:4]),
        .b   (b[7:4]),
        .cin (1'b0),
        .sum (sum_c0_b1),
        .cout(cout_c0_b1)
    );

    rca4 #(.DELAY_PS(DELAY_PS)) rca_c1_b1 (
        .a   (a[7:4]),
        .b   (b[7:4]),
        .cin (1'b1),
        .sum (sum_c1_b1),
        .cout(cout_c1_b1)
    );

    mux2_4b mux_b1 (
        .in0(sum_c0_b1),
        .in1(sum_c1_b1),
        .sel(carry_b0),
        .out(sum_b1)
    );

    assign carry_b1 = (carry_b0) ? cout_c1_b1 : cout_c0_b1;

    // SECTION 4 — Block 2

    rca4 #(.DELAY_PS(DELAY_PS)) rca_c0_b2 (
        .a   (a[11:8]),
        .b   (b[11:8]),
        .cin (1'b0),
        .sum (sum_c0_b2),
        .cout(cout_c0_b2)
    );

    rca4 #(.DELAY_PS(DELAY_PS)) rca_c1_b2 (
        .a   (a[11:8]),
        .b   (b[11:8]),
        .cin (1'b1),
        .sum (sum_c1_b2),
        .cout(cout_c1_b2)
    );

    mux2_4b mux_b2 (
        .in0(sum_c0_b2),
        .in1(sum_c1_b2),
        .sel(carry_b1),
        .out(sum_b2)
    );

    assign carry_b2 = (carry_b1) ? cout_c1_b2 : cout_c0_b2;

    // SECTION 4 — Block 3

    rca4 #(.DELAY_PS(DELAY_PS)) rca_c0_b3 (
        .a   (a[15:12]),
        .b   (b[15:12]),
        .cin (1'b0),
        .sum (sum_c0_b3),
        .cout(cout_c0_b3)
    );

    rca4 #(.DELAY_PS(DELAY_PS)) rca_c1_b3 (
        .a   (a[15:12]),
        .b   (b[15:12]),
        .cin (1'b1),
        .sum (sum_c1_b3),
        .cout(cout_c1_b3)
    );

    mux2_4b mux_b3 (
        .in0(sum_c0_b3),
        .in1(sum_c1_b3),
        .sel(carry_b2),
        .out(sum_b3)
    );

    assign carry_b3 = (carry_b2) ? cout_c1_b3 : cout_c0_b3;

    // SECTION 5 — Output assembly

    assign sum  = {sum_b3, sum_b2, sum_b1, sum_b0};
    assign cout = carry_b3;

    // SECTION 6 — specify block

    specify
        specparam tPD = DELAY_PS;
        (a, b, cin *> sum, cout) = tPD;
    endspecify

endmodule
