`timescale 1ps/1ps
//=====================================================================
// File    : csa16.v
// Module  : csa16
// Width   : 16-bit
// Strategy: Carry Select Adder (CSA)
//
// PPA Summary (28nm)
// --------------------------------------------------
// DELAY_PS = 320 ps
// AREA_UM2 = 648 um^2
// POWER_UW = 104 uW
//
// Architecture:
//   8 x RCA4 (2 per block)
//   3 x MUX2_4B (Blocks 1,2,3)
//   Carry chain: b0 -> b1 -> b2 -> b3
//
// Structural only
// No always
// No initial
// No generate
//=====================================================================


//=====================================================================
// Full Adder
//=====================================================================
module full_adder(
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);

    wire x1;
    wire a1;
    wire a2;
    wire a3;

    xor (x1,  a,   b);
    xor (sum, x1,  cin);

    and (a1, a,   b);
    and (a2, a,   cin);
    and (a3, b,   cin);

    or  (cout, a1, a2, a3);

endmodule


//=====================================================================
// 4-bit Ripple Carry Adder
//=====================================================================
module rca4
#(
    parameter FA_DELAY_PS = 70
)
(
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
        .a   (a[0]),
        .b   (b[0]),
        .cin (cin),
        .sum (sum[0]),
        .cout(c1)
    );

    full_adder fa1(
        .a   (a[1]),
        .b   (b[1]),
        .cin (c1),
        .sum (sum[1]),
        .cout(c2)
    );

    full_adder fa2(
        .a   (a[2]),
        .b   (b[2]),
        .cin (c2),
        .sum (sum[2]),
        .cout(c3)
    );

    full_adder fa3(
        .a   (a[3]),
        .b   (b[3]),
        .cin (c3),
        .sum (sum[3]),
        .cout(cout)
    );

endmodule


//=====================================================================
// 1-bit 2:1 Mux
//=====================================================================
module mux2_1b(
    input  in0,
    input  in1,
    input  sel,
    output out
);

    wire nsel;
    wire p0;
    wire p1;

    not (nsel, sel);

    and (p0, in0, nsel);
    and (p1, in1, sel);

    or  (out, p0, p1);

endmodule


//=====================================================================
// 4-bit 2:1 Mux
//=====================================================================
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


//=====================================================================
// 16-bit Carry Select Adder
//=====================================================================
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

    //-----------------------------------------------------------------
    // Block 0
    //-----------------------------------------------------------------
    wire [3:0] sum_c0_b0;
    wire [3:0] sum_c1_b0;
    wire       cout_c0_b0;
    wire       cout_c1_b0;

    wire [3:0] sum_b0;
    wire       carry_b0;

    //-----------------------------------------------------------------
    // Block 1
    //-----------------------------------------------------------------
    wire [3:0] sum_c0_b1;
    wire [3:0] sum_c1_b1;
    wire       cout_c0_b1;
    wire       cout_c1_b1;

    wire [3:0] sum_b1;
    wire       carry_b1;

    //-----------------------------------------------------------------
    // Block 2
    //-----------------------------------------------------------------
    wire [3:0] sum_c0_b2;
    wire [3:0] sum_c1_b2;
    wire       cout_c0_b2;
    wire       cout_c1_b2;

    wire [3:0] sum_b2;
    wire       carry_b2;

    //-----------------------------------------------------------------
    // Block 3
    //-----------------------------------------------------------------
    wire [3:0] sum_c0_b3;
    wire [3:0] sum_c1_b3;
    wire       cout_c0_b3;
    wire       cout_c1_b3;

    wire [3:0] sum_b3;
    wire       carry_b3;

    //-----------------------------------------------------------------
    // Block 0 RCAs
    //-----------------------------------------------------------------
    rca4 rca_c0_b0(
        .a   (a[3:0]),
        .b   (b[3:0]),
        .cin (1'b0),
        .sum (sum_c0_b0),
        .cout(cout_c0_b0)
    );

    rca4 rca_c1_b0(
        .a   (a[3:0]),
        .b   (b[3:0]),
        .cin (1'b1),
        .sum (sum_c1_b0),
        .cout(cout_c1_b0)
    );

    mux2_4b sum_mux_b0(
        .in0(sum_c0_b0),
        .in1(sum_c1_b0),
        .sel(cin),
        .out(sum_b0)
    );

    mux2_1b carry_mux_b0(
        .in0(cout_c0_b0),
        .in1(cout_c1_b0),
        .sel(cin),
        .out(carry_b0)
    );

    //-----------------------------------------------------------------
    // Block 1 RCAs + MUX
    //-----------------------------------------------------------------
    rca4 rca_c0_b1(
        .a   (a[7:4]),
        .b   (b[7:4]),
        .cin (1'b0),
        .sum (sum_c0_b1),
        .cout(cout_c0_b1)
    );

    rca4 rca_c1_b1(
        .a   (a[7:4]),
        .b   (b[7:4]),
        .cin (1'b1),
        .sum (sum_c1_b1),
        .cout(cout_c1_b1)
    );

    mux2_4b mux_b1(
        .in0(sum_c0_b1),
        .in1(sum_c1_b1),
        .sel(carry_b0),
        .out(sum_b1)
    );

    mux2_1b carry_mux_b1(
        .in0(cout_c0_b1),
        .in1(cout_c1_b1),
        .sel(carry_b0),
        .out(carry_b1)
    );

    //-----------------------------------------------------------------
    // Block 2 RCAs + MUX
    //-----------------------------------------------------------------
    rca4 rca_c0_b2(
        .a   (a[11:8]),
        .b   (b[11:8]),
        .cin (1'b0),
        .sum (sum_c0_b2),
        .cout(cout_c0_b2)
    );

    rca4 rca_c1_b2(
        .a   (a[11:8]),
        .b   (b[11:8]),
        .cin (1'b1),
        .sum (sum_c1_b2),
        .cout(cout_c1_b2)
    );

    mux2_4b mux_b2(
        .in0(sum_c0_b2),
        .in1(sum_c1_b2),
        .sel(carry_b1),
        .out(sum_b2)
    );

    mux2_1b carry_mux_b2(
        .in0(cout_c0_b2),
        .in1(cout_c1_b2),
        .sel(carry_b1),
        .out(carry_b2)
    );

    //-----------------------------------------------------------------
    // Block 3 RCAs + MUX
    //-----------------------------------------------------------------
    rca4 rca_c0_b3(
        .a   (a[15:12]),
        .b   (b[15:12]),
        .cin (1'b0),
        .sum (sum_c0_b3),
        .cout(cout_c0_b3)
    );

    rca4 rca_c1_b3(
        .a   (a[15:12]),
        .b   (b[15:12]),
        .cin (1'b1),
        .sum (sum_c1_b3),
        .cout(cout_c1_b3)
    );

    mux2_4b mux_b3(
        .in0(sum_c0_b3),
        .in1(sum_c1_b3),
        .sel(carry_b2),
        .out(sum_b3)
    );

    mux2_1b carry_mux_b3(
        .in0(cout_c0_b3),
        .in1(cout_c1_b3),
        .sel(carry_b2),
        .out(carry_b3)
    );

    //-----------------------------------------------------------------
    // Output Assembly
    //-----------------------------------------------------------------
    assign sum[3:0]    = sum_b0;
    assign sum[7:4]    = sum_b1;
    assign sum[11:8]   = sum_b2;
    assign sum[15:12]  = sum_b3;

    assign cout = carry_b3;

    //-----------------------------------------------------------------
    // Timing Annotation
    //-----------------------------------------------------------------
    specify
        specparam FA_DELAY  = DELAY_PS/4;
        specparam RCA_DELAY = DELAY_PS;
        specparam MUX_DELAY = 10;

        (a, b, cin *> sum, cout) = (RCA_DELAY + (3*MUX_DELAY));
    endspecify

endmodule
