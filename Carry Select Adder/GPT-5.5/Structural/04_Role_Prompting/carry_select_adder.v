`timescale 1ps/1ps
//=====================================================================
// Carry Select Adder (CSA) - 16-bit
//
// Design Philosophy:
// 1. Pure structural RTL (gate primitives + module instantiation only)
// 2. No assign statements
// 3. No always blocks
// 4. Synthesis-clean and SDF friendly
// 5. Explicitly unrolled four 4-bit CSA blocks
// 6. Eight RCA instances (cin=0 and cin=1 for every block)
// 7. PPA parameters exposed for architecture exploration
//
// Notes:
// - CSA trades area for speed.
// - Each block precomputes both carry possibilities.
// - Only a mux delay remains on the carry-select path.
//=====================================================================


//=====================================================================
// 1-BIT FULL ADDER
//
// Gate-level implementation.
// Chosen because gate primitives map predictably to standard cells.
//=====================================================================
module full_adder #(
    parameter integer FA_DELAY_PS = 50
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

    xor #(FA_DELAY_PS) G1(axb,  a, b);
    xor #(FA_DELAY_PS) G2(sum,  axb, cin);

    and #(FA_DELAY_PS) G3(ab, a, b);
    and #(FA_DELAY_PS) G4(ac, a, cin);
    and #(FA_DELAY_PS) G5(bc, b, cin);

    or  #(FA_DELAY_PS) G6(cout, ab, ac, bc);

endmodule


//=====================================================================
// 4-BIT RIPPLE CARRY ADDER
//
// Local carry chain kept short (4 bits)
// which is the key CSA optimization.
//=====================================================================
module rca4 #(
    parameter integer FA_DELAY_PS = 50
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

    full_adder #(.FA_DELAY_PS(FA_DELAY_PS))
    fa0(.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(c1));

    full_adder #(.FA_DELAY_PS(FA_DELAY_PS))
    fa1(.a(a[1]), .b(b[1]), .cin(c1), .sum(sum[1]), .cout(c2));

    full_adder #(.FA_DELAY_PS(FA_DELAY_PS))
    fa2(.a(a[2]), .b(b[2]), .cin(c2), .sum(sum[2]), .cout(c3));

    full_adder #(.FA_DELAY_PS(FA_DELAY_PS))
    fa3(.a(a[3]), .b(b[3]), .cin(c3), .sum(sum[3]), .cout(cout));

endmodule


//=====================================================================
// 1-BIT MUX
//
// Structural implementation using select gates.
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

    not G0(nsel, sel);

    and G1(p0, in0, nsel);
    and G2(p1, in1, sel);

    or  G3(out, p0, p1);

endmodule


//=====================================================================
// 4-BIT MUX
//
// Separate mux stage minimizes critical path.
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
// 16-BIT CARRY SELECT ADDER
//
// Block0 : bits [3:0]
// Block1 : bits [7:4]
// Block2 : bits [11:8]
// Block3 : bits [15:12]
//
// Eight RCAs:
//   rca4_c0_b0, rca4_c1_b0
//   rca4_c0_b1, rca4_c1_b1
//   rca4_c0_b2, rca4_c1_b2
//   rca4_c0_b3, rca4_c1_b3
//
// Carry propagation:
//   cin -> muxc_b0 -> muxc_b1 -> muxc_b2 -> muxc_b3 -> cout
//=====================================================================
module carry_select_adder #(
    parameter integer BLOCK_SIZE    = 4,

    // Worst case:
    // One RCA delay + one mux stage delay
    parameter integer TOTAL_DELAY_PS = 250,

    // Technology dependent PPA annotations
    parameter integer AREA_UM2 = 120,

    // Dynamic power estimate:
    // P = αCV²f
    // α=0.1, V=1.0V , f=1GHz
    parameter integer POWER_UW = 40
)(
    input  [15:0] a,
    input  [15:0] b,
    input         cin,

    output [15:0] sum,
    output        cout
);

    //------------------------------------------------------------------
    // Block 0
    //------------------------------------------------------------------
    wire [3:0] sum_b0_c0;
    wire [3:0] sum_b0_c1;
    wire       carry_b0_c0;
    wire       carry_b0_c1;
    wire       carry_sel0;

    rca4 rca4_c0_b0(
        .a(a[3:0]), .b(b[3:0]),
        .cin(1'b0),
        .sum(sum_b0_c0),
        .cout(carry_b0_c0)
    );

    rca4 rca4_c1_b0(
        .a(a[3:0]), .b(b[3:0]),
        .cin(1'b1),
        .sum(sum_b0_c1),
        .cout(carry_b0_c1)
    );

    mux2_4b mux4_b0(
        .in0(sum_b0_c0),
        .in1(sum_b0_c1),
        .sel(cin),
        .out(sum[3:0])
    );

    mux2_1b muxc_b0(
        .in0(carry_b0_c0),
        .in1(carry_b0_c1),
        .sel(cin),
        .out(carry_sel0)
    );

    //------------------------------------------------------------------
    // Block 1
    //------------------------------------------------------------------
    wire [3:0] sum_b1_c0;
    wire [3:0] sum_b1_c1;
    wire       carry_b1_c0;
    wire       carry_b1_c1;
    wire       carry_sel1;

    rca4 rca4_c0_b1(
        .a(a[7:4]), .b(b[7:4]),
        .cin(1'b0),
        .sum(sum_b1_c0),
        .cout(carry_b1_c0)
    );

    rca4 rca4_c1_b1(
        .a(a[7:4]), .b(b[7:4]),
        .cin(1'b1),
        .sum(sum_b1_c1),
        .cout(carry_b1_c1)
    );

    mux2_4b mux4_b1(
        .in0(sum_b1_c0),
        .in1(sum_b1_c1),
        .sel(carry_sel0),
        .out(sum[7:4])
    );

    mux2_1b muxc_b1(
        .in0(carry_b1_c0),
        .in1(carry_b1_c1),
        .sel(carry_sel0),
        .out(carry_sel1)
    );

    //------------------------------------------------------------------
    // Block 2
    //------------------------------------------------------------------
    wire [3:0] sum_b2_c0;
    wire [3:0] sum_b2_c1;
    wire       carry_b2_c0;
    wire       carry_b2_c1;
    wire       carry_sel2;

    rca4 rca4_c0_b2(
        .a(a[11:8]), .b(b[11:8]),
        .cin(1'b0),
        .sum(sum_b2_c0),
        .cout(carry_b2_c0)
    );

    rca4 rca4_c1_b2(
        .a(a[11:8]), .b(b[11:8]),
        .cin(1'b1),
        .sum(sum_b2_c1),
        .cout(carry_b2_c1)
    );

    mux2_4b mux4_b2(
        .in0(sum_b2_c0),
        .in1(sum_b2_c1),
        .sel(carry_sel1),
        .out(sum[11:8])
    );

    mux2_1b muxc_b2(
        .in0(carry_b2_c0),
        .in1(carry_b2_c1),
        .sel(carry_sel1),
        .out(carry_sel2)
    );

    //------------------------------------------------------------------
    // Block 3
    //------------------------------------------------------------------
    wire [3:0] sum_b3_c0;
    wire [3:0] sum_b3_c1;
    wire       carry_b3_c0;
    wire       carry_b3_c1;

    rca4 rca4_c0_b3(
        .a(a[15:12]), .b(b[15:12]),
        .cin(1'b0),
        .sum(sum_b3_c0),
        .cout(carry_b3_c0)
    );

    rca4 rca4_c1_b3(
        .a(a[15:12]), .b(b[15:12]),
        .cin(1'b1),
        .sum(sum_b3_c1),
        .cout(carry_b3_c1)
    );

    mux2_4b mux4_b3(
        .in0(sum_b3_c0),
        .in1(sum_b3_c1),
        .sel(carry_sel2),
        .out(sum[15:12])
    );

    mux2_1b muxc_b3(
        .in0(carry_b3_c0),
        .in1(carry_b3_c1),
        .sel(carry_sel2),
        .out(cout)
    );

    //------------------------------------------------------------------
    // Timing Annotation
    //
    // Critical path:
    // selected carry from block0
    // -> carry mux chain
    // -> final carry output
    //------------------------------------------------------------------
    specify
        specparam TPD_CSA = TOTAL_DELAY_PS;

        (cin => cout) = TPD_CSA;
        (a   *> sum ) = TPD_CSA;
        (b   *> sum ) = TPD_CSA;
    endspecify

endmodule
