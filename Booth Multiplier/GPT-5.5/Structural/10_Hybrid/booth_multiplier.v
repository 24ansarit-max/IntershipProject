// ============================================================================

// 16-bit Signed Radix-2 Booth Multiplier

// Structural RTL

// Target: Xilinx Artix-7 xc7a100tcsg324-2

//

// Features:

// - Radix-2 Booth encoding

// - Explicit partial-product generation

// - Structural hierarchy

// - No multiplication operator

// - No always blocks

// - Synthesizable Verilog

// ============================================================================

module half_adder (

input a,

input b,

output sum,

output cout

);

assign sum = a ^ b;

assign cout = a & b;

endmodule

module full_adder (

input a,

input b,

input cin,

output sum,

output cout

);

wire s1;

wire c1;

wire c2;

assign s1 = a ^ b;

assign sum = s1 ^ cin;

assign c1 = a & b;

assign c2 = s1 & cin;

assign cout = c1 | c2;

endmodule

// ---------------------------------------------------------------------------

// Structural Ripple Carry Adder

// ---------------------------------------------------------------------------

module ripple_adder_32 (

input [31:0] a,

input [31:0] b,

output [31:0] sum

);

wire [32:0] c;

assign c[0] = 1'b0;

genvar i;

generate

for(i=0;i<32;i=i+1)

begin : FA_GEN

full_adder fa (

.a (a[i]),

.b (b[i]),

.cin (c[i]),

.sum (sum[i]),

.cout(c[i+1])

);

end

endgenerate

endmodule

// ---------------------------------------------------------------------------

// Booth Encoder

//

// Booth Table:

//

// y[i] y[i-1]

// 0 0 -> 0

// 0 1 -> +M

// 1 0 -> -M

// 1 1 -> 0

// ---------------------------------------------------------------------------

module booth_encoder (

input y_i,

input y_im1,

output add,

output sub

);

assign add = (~y_i) & y_im1;

assign sub = y_i & (~y_im1);

endmodule

// ---------------------------------------------------------------------------

// Booth Partial Product Generator

// Generates:

// 0

// +(M << shift)

// -(M << shift)

//

// Output width = 32 bits

// ---------------------------------------------------------------------------

module booth_partial_product #(

parameter SHIFT = 0

)(

input [15:0] multiplicand,

input add,

input sub,

output [31:0] pp

);

wire [31:0] m_ext;

wire [31:0] m_shift;

wire [31:0] neg_shift;

assign m_ext = {{16{multiplicand[15]}}, multiplicand};

assign m_shift = m_ext << SHIFT;

assign neg_shift = ~m_shift + 32'd1;

assign pp =

({32{add}} & m_shift)

| ({32{sub}} & neg_shift);

endmodule

// ---------------------------------------------------------------------------

// Top-Level 16-bit Signed Booth Multiplier

// ---------------------------------------------------------------------------

module booth_multiplier_16 (

input signed [15:0] multiplicand,

input signed [15:0] multiplier,

output signed [31:0] product

);

// -----------------------------------------------------------------------

// Booth control signals

// -----------------------------------------------------------------------

wire add0, sub0;

wire add1, sub1;

wire add2, sub2;

wire add3, sub3;

wire add4, sub4;

wire add5, sub5;

wire add6, sub6;

wire add7, sub7;

wire add8, sub8;

wire add9, sub9;

wire add10, sub10;

wire add11, sub11;

wire add12, sub12;

wire add13, sub13;

wire add14, sub14;

wire add15, sub15;

booth_encoder be0 (

.y_i (multiplier[0]),

.y_im1 (1'b0),

.add (add0),

.sub (sub0)

);

booth_encoder be1 (

.y_i (multiplier[1]),

.y_im1 (multiplier[0]),

.add (add1),

.sub (sub1)

);

booth_encoder be2 (

.y_i (multiplier[2]),

.y_im1 (multiplier[1]),

.add (add2),

.sub (sub2)

);

booth_encoder be3 (

.y_i (multiplier[3]),

.y_im1 (multiplier[2]),

.add (add3),

.sub (sub3)

);

booth_encoder be4 (

.y_i (multiplier[4]),

.y_im1 (multiplier[3]),

.add (add4),

.sub (sub4)

);

booth_encoder be5 (

.y_i (multiplier[5]),

.y_im1 (multiplier[4]),

.add (add5),

.sub (sub5)

);

booth_encoder be6 (

.y_i (multiplier[6]),

.y_im1 (multiplier[5]),

.add (add6),

.sub (sub6)

);

booth_encoder be7 (

.y_i (multiplier[7]),

.y_im1 (multiplier[6]),

.add (add7),

.sub (sub7)

);

booth_encoder be8 (

.y_i (multiplier[8]),

.y_im1 (multiplier[7]),

.add (add8),

.sub (sub8)

);

booth_encoder be9 (

.y_i (multiplier[9]),

.y_im1 (multiplier[8]),

.add (add9),

.sub (sub9)

);

booth_encoder be10 (

.y_i (multiplier[10]),

.y_im1 (multiplier[9]),

.add (add10),

.sub (sub10)

);

booth_encoder be11 (

.y_i (multiplier[11]),

.y_im1 (multiplier[10]),

.add (add11),

.sub (sub11)

);

booth_encoder be12 (

.y_i (multiplier[12]),

.y_im1 (multiplier[11]),

.add (add12),

.sub (sub12)

);

booth_encoder be13 (

.y_i (multiplier[13]),

.y_im1 (multiplier[12]),

.add (add13),

.sub (sub13)

);

booth_encoder be14 (

.y_i (multiplier[14]),

.y_im1 (multiplier[13]),

.add (add14),

.sub (sub14)

);

booth_encoder be15 (

.y_i (multiplier[15]),

.y_im1 (multiplier[14]),

.add (add15),

.sub (sub15)

);

// -----------------------------------------------------------------------

// Partial Products

// -----------------------------------------------------------------------

wire [31:0] pp0;

wire [31:0] pp1;

wire [31:0] pp2;

wire [31:0] pp3;

wire [31:0] pp4;

wire [31:0] pp5;

wire [31:0] pp6;

wire [31:0] pp7;

wire [31:0] pp8;

wire [31:0] pp9;

wire [31:0] pp10;

wire [31:0] pp11;

wire [31:0] pp12;

wire [31:0] pp13;

wire [31:0] pp14;

wire [31:0] pp15;

booth_partial_product #(0) p0 (.multiplicand(multiplicand), .add(add0), .sub(sub0), .pp(pp0));

booth_partial_product #(1) p1 (.multiplicand(multiplicand), .add(add1), .sub(sub1), .pp(pp1));

booth_partial_product #(2) p2 (.multiplicand(multiplicand), .add(add2), .sub(sub2), .pp(pp2));

booth_partial_product #(3) p3 (.multiplicand(multiplicand), .add(add3), .sub(sub3), .pp(pp3));

booth_partial_product #(4) p4 (.multiplicand(multiplicand), .add(add4), .sub(sub4), .pp(pp4));

booth_partial_product #(5) p5 (.multiplicand(multiplicand), .add(add5), .sub(sub5), .pp(pp5));

booth_partial_product #(6) p6 (.multiplicand(multiplicand), .add(add6), .sub(sub6), .pp(pp6));

booth_partial_product #(7) p7 (.multiplicand(multiplicand), .add(add7), .sub(sub7), .pp(pp7));

booth_partial_product #(8) p8 (.multiplicand(multiplicand), .add(add8), .sub(sub8), .pp(pp8));

booth_partial_product #(9) p9 (.multiplicand(multiplicand), .add(add9), .sub(sub9), .pp(pp9));

booth_partial_product #(10) p10 (.multiplicand(multiplicand), .add(add10), .sub(sub10), .pp(pp10));

booth_partial_product #(11) p11 (.multiplicand(multiplicand), .add(add11), .sub(sub11), .pp(pp11));

booth_partial_product #(12) p12 (.multiplicand(multiplicand), .add(add12), .sub(sub12), .pp(pp12));

booth_partial_product #(13) p13 (.multiplicand(multiplicand), .add(add13), .sub(sub13), .pp(pp13));

booth_partial_product #(14) p14 (.multiplicand(multiplicand), .add(add14), .sub(sub14), .pp(pp14));

booth_partial_product #(15) p15 (.multiplicand(multiplicand), .add(add15), .sub(sub15), .pp(pp15));

// -----------------------------------------------------------------------

// Structural Adder Tree

// -----------------------------------------------------------------------

wire [31:0] s01;

wire [31:0] s23;

wire [31:0] s45;

wire [31:0] s67;

wire [31:0] s89;

wire [31:0] s1011;

wire [31:0] s1213;

wire [31:0] s1415;

ripple_adder_32 a01 (.a(pp0), .b(pp1), .sum(s01));

ripple_adder_32 a23 (.a(pp2), .b(pp3), .sum(s23));

ripple_adder_32 a45 (.a(pp4), .b(pp5), .sum(s45));

ripple_adder_32 a67 (.a(pp6), .b(pp7), .sum(s67));

ripple_adder_32 a89 (.a(pp8), .b(pp9), .sum(s89));

ripple_adder_32 a1011 (.a(pp10), .b(pp11), .sum(s1011));

ripple_adder_32 a1213 (.a(pp12), .b(pp13), .sum(s1213));

ripple_adder_32 a1415 (.a(pp14), .b(pp15), .sum(s1415));

wire [31:0] s0123;

wire [31:0] s4567;

wire [31:0] s891011;

wire [31:0] s12131415;

ripple_adder_32 a0123 (.a(s01), .b(s23), .sum(s0123));

ripple_adder_32 a4567 (.a(s45), .b(s67), .sum(s4567));

ripple_adder_32 a891011 (.a(s89), .b(s1011), .sum(s891011));

ripple_adder_32 a12131415 (.a(s1213), .b(s1415), .sum(s12131415));

wire [31:0] s0_7;

wire [31:0] s8_15;

ripple_adder_32 a0_7 (.a(s0123), .b(s4567), .sum(s0_7));

ripple_adder_32 a8_15 (.a(s891011), .b(s12131415), .sum(s8_15));

ripple_adder_32 afinal (

.a (s0_7),

.b (s8_15),

.sum (product)

);

endmodule