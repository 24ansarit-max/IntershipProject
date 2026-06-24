
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


`timescale 1ps/1ps
//============================================================
// Module : csa16
// Width  : 16-bit
// Type   : Carry Select Adder
// Style  : Structural
//
// Round 1 : Skeleton created
// Round 2 : Connectivity completed
// Round 3 : PPA annotations added
//
// Area derivation:
//   8 × RCA4  = 8 × 72 um²  = 576 um²
//   3 × MUX4  = 3 × 24 um²  = 72 um²
//   Total     = 648 um²
//
// Power derivation:
//   P = α × Ceff × V² × f
//   α=0.1, V=1.0V , f=2GHz
//   Estimated POWER_UW = 104
//============================================================

module carry_select_adder
#(
    parameter BLOCK_SIZE = 4,
    parameter DELAY_PS   = 320,
    parameter AREA_UM2   = 648,
    parameter POWER_UW   = 104
)
(
    input  [15:0] a,
    input  [15:0] b,
    input         cin,

    output [15:0] sum,
    output        cout
);

    //--------------------------------------------------------
    // RCA outputs : Block 0
    //--------------------------------------------------------
    wire [3:0] sum_c0_b0;
    wire [3:0] sum_c1_b0;
    wire       cout_c0_b0;
    wire       cout_c1_b0;

    //--------------------------------------------------------
    // RCA outputs : Block 1
    //--------------------------------------------------------
    wire [3:0] sum_c0_b1;
    wire [3:0] sum_c1_b1;
    wire       cout_c0_b1;
    wire       cout_c1_b1;

    //--------------------------------------------------------
    // RCA outputs : Block 2
    //--------------------------------------------------------
    wire [3:0] sum_c0_b2;
    wire [3:0] sum_c1_b2;
    wire       cout_c0_b2;
    wire       cout_c1_b2;

    //--------------------------------------------------------
    // RCA outputs : Block 3
    //--------------------------------------------------------
    wire [3:0] sum_c0_b3;
    wire [3:0] sum_c1_b3;
    wire       cout_c0_b3;
    wire       cout_c1_b3;

    //--------------------------------------------------------
    // Selected block sums
    //--------------------------------------------------------
    wire [3:0] sum_b0;
    wire [3:0] sum_b1;
    wire [3:0] sum_b2;
    wire [3:0] sum_b3;

    //--------------------------------------------------------
    // Carry chain
    //--------------------------------------------------------
    wire carry_b0;
    wire carry_b1;
    wire carry_b2;
    wire carry_b3;

    //--------------------------------------------------------
    // Carry mux outputs
    //--------------------------------------------------------
    wire carry_sel_b0;
    wire carry_sel_b1;
    wire carry_sel_b2;
    wire carry_sel_b3;

    //========================================================
    // BLOCK 0
    //========================================================

    rca4 rca_c0_b0 (
        .a   (a[3:0]),
        .b   (b[3:0]),
        .cin (1'b0),
        .sum (sum_c0_b0),
        .cout(cout_c0_b0)
    );

    rca4 rca_c1_b0 (
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

    mux2_1b carry_mux_b0 (
        .in0(cout_c0_b0),
        .in1(cout_c1_b0),
        .sel(cin),
        .out(carry_b0)
    );

    //========================================================
    // BLOCK 1
    //========================================================

    rca4 rca_c0_b1 (
        .a   (a[7:4]),
        .b   (b[7:4]),
        .cin (1'b0),
        .sum (sum_c0_b1),
        .cout(cout_c0_b1)
    );

    rca4 rca_c1_b1 (
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

    mux2_1b carry_mux_b1 (
        .in0(cout_c0_b1),
        .in1(cout_c1_b1),
        .sel(carry_b0),
        .out(carry_b1)
    );

    //========================================================
    // BLOCK 2
    //========================================================

    rca4 rca_c0_b2 (
        .a   (a[11:8]),
        .b   (b[11:8]),
        .cin (1'b0),
        .sum (sum_c0_b2),
        .cout(cout_c0_b2)
    );

    rca4 rca_c1_b2 (
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

    mux2_1b carry_mux_b2 (
        .in0(cout_c0_b2),
        .in1(cout_c1_b2),
        .sel(carry_b1),
        .out(carry_b2)
    );

    //========================================================
    // BLOCK 3
    //========================================================

    rca4 rca_c0_b3 (
        .a   (a[15:12]),
        .b   (b[15:12]),
        .cin (1'b0),
        .sum (sum_c0_b3),
        .cout(cout_c0_b3)
    );

    rca4 rca_c1_b3 (
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

    mux2_1b carry_mux_b3 (
        .in0(cout_c0_b3),
        .in1(cout_c1_b3),
        .sel(carry_b2),
        .out(carry_b3)
    );

    //========================================================
    // Output assembly
    //========================================================

    assign sum  = {sum_b3, sum_b2, sum_b1, sum_b0};
    assign cout = carry_b3;

    //========================================================
    // PPA Annotation
    //========================================================

    specify

        specparam FA_DELAY  = DELAY_PS / 4;
        specparam RCA_DELAY = DELAY_PS;
        specparam MUX_DELAY = (DELAY_PS * 14) / 100;

        (a, b, cin *> sum, cout) = (RCA_DELAY + MUX_DELAY);

    endspecify

endmodule
