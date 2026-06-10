
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
    // Block 0
    // a[3:0], b[3:0]
    //--------------------------------------------------------

    wire [3:0] sum_b0_c0;
    wire [3:0] sum_b0_c1;
    wire       carry_b0_c0;
    wire       carry_b0_c1;
    wire       sel_carry0;

    rca4 #(.DELAY_PS(DELAY_PS))
    rca4_c0_b0 (
        .a(a[3:0]),
        .b(b[3:0]),
        .cin(1'b0),
        .sum(sum_b0_c0),
        .cout(carry_b0_c0)
    );

    rca4 #(.DELAY_PS(DELAY_PS))
    rca4_c1_b0 (
        .a(a[3:0]),
        .b(b[3:0]),
        .cin(1'b1),
        .sum(sum_b0_c1),
        .cout(carry_b0_c1)
    );

    mux2_4b mux4_b0 (
        .in0(sum_b0_c0),
        .in1(sum_b0_c1),
        .sel(cin),
        .out(sum[3:0])
    );

    mux2_1b muxc_b0 (
        .in0(carry_b0_c0),
        .in1(carry_b0_c1),
        .sel(cin),
        .out(sel_carry0)
    );

    //--------------------------------------------------------
    // Block 1
    // a[7:4], b[7:4]
    //--------------------------------------------------------

    wire [3:0] sum_b1_c0;
    wire [3:0] sum_b1_c1;
    wire       carry_b1_c0;
    wire       carry_b1_c1;
    wire       sel_carry1;

    rca4 #(.DELAY_PS(DELAY_PS))
    rca4_c0_b1 (
        .a(a[7:4]),
        .b(b[7:4]),
        .cin(1'b0),
        .sum(sum_b1_c0),
        .cout(carry_b1_c0)
    );

    rca4 #(.DELAY_PS(DELAY_PS))
    rca4_c1_b1 (
        .a(a[7:4]),
        .b(b[7:4]),
        .cin(1'b1),
        .sum(sum_b1_c1),
        .cout(carry_b1_c1)
    );

    mux2_4b mux4_b1 (
        .in0(sum_b1_c0),
        .in1(sum_b1_c1),
        .sel(sel_carry0),
        .out(sum[7:4])
    );

    mux2_1b muxc_b1 (
        .in0(carry_b1_c0),
        .in1(carry_b1_c1),
        .sel(sel_carry0),
        .out(sel_carry1)
    );

    //--------------------------------------------------------
    // Block 2
    // a[11:8], b[11:8]
    //--------------------------------------------------------

    wire [3:0] sum_b2_c0;
    wire [3:0] sum_b2_c1;
    wire       carry_b2_c0;
    wire       carry_b2_c1;
    wire       sel_carry2;

    rca4 #(.DELAY_PS(DELAY_PS))
    rca4_c0_b2 (
        .a(a[11:8]),
        .b(b[11:8]),
        .cin(1'b0),
        .sum(sum_b2_c0),
        .cout(carry_b2_c0)
    );

    rca4 #(.DELAY_PS(DELAY_PS))
    rca4_c1_b2 (
        .a(a[11:8]),
        .b(b[11:8]),
        .cin(1'b1),
        .sum(sum_b2_c1),
        .cout(carry_b2_c1)
    );

    mux2_4b mux4_b2 (
        .in0(sum_b2_c0),
        .in1(sum_b2_c1),
        .sel(sel_carry1),
        .out(sum[11:8])
    );

    mux2_1b muxc_b2 (
        .in0(carry_b2_c0),
        .in1(carry_b2_c1),
        .sel(sel_carry1),
        .out(sel_carry2)
    );

    //--------------------------------------------------------
    // Block 3
    // a[15:12], b[15:12]
    //--------------------------------------------------------

    wire [3:0] sum_b3_c0;
    wire [3:0] sum_b3_c1;
    wire       carry_b3_c0;
    wire       carry_b3_c1;

    rca4 #(.DELAY_PS(DELAY_PS))
    rca4_c0_b3 (
        .a(a[15:12]),
        .b(b[15:12]),
        .cin(1'b0),
        .sum(sum_b3_c0),
        .cout(carry_b3_c0)
    );

    rca4 #(.DELAY_PS(DELAY_PS))
    rca4_c1_b3 (
        .a(a[15:12]),
        .b(b[15:12]),
        .cin(1'b1),
        .sum(sum_b3_c1),
        .cout(carry_b3_c1)
    );

    mux2_4b mux4_b3 (
        .in0(sum_b3_c0),
        .in1(sum_b3_c1),
        .sel(sel_carry2),
        .out(sum[15:12])
    );

    mux2_1b muxc_b3 (
        .in0(carry_b3_c0),
        .in1(carry_b3_c1),
        .sel(sel_carry2),
        .out(cout)
    );

    //--------------------------------------------------------
    // Worst-Case Timing
    //--------------------------------------------------------
    specify

        specparam CSA_DELAY =
              DELAY_PS
            + (DELAY_PS/10)
            + (DELAY_PS/10)
            + (DELAY_PS/10);

        (cin => cout) = CSA_DELAY;
        (a   *> sum ) = CSA_DELAY;
        (b   *> sum ) = CSA_DELAY;

    endspecify

endmodule
