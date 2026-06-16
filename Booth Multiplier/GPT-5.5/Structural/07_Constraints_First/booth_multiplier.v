//============================================================

// 16-bit Signed Radix-2 Booth Multiplier

// Structural RTL

// No *, no always blocks, explicit hierarchy

//============================================================

module full_adder (

input a,

input b,

input cin,

output sum,

output cout

);

assign sum = a ^ b ^ cin;

assign cout = (a & b) | (a & cin) | (b & cin);

endmodule

//============================================================

// 32-bit Ripple Carry Adder

//============================================================

module ripple_adder_32 (

input [31:0] a,

input [31:0] b,

output [31:0] sum

);

wire [32:0] c;

assign c[0] = 1'b0;

genvar i;

generate

for(i=0;i<32;i=i+1) begin : FA_GEN

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

//============================================================

// Booth Encoder

//============================================================

module booth_encoder (

input y_i,

input y_im1,

output add,

output sub

);

assign add = (~y_i) & y_im1; // 01

assign sub = y_i & (~y_im1); // 10

endmodule

//============================================================

// Booth Partial Product Generator

// Produces shifted 32-bit partial product

//============================================================

module booth_partial_product (

input signed [15:0] multiplicand,

input add,

input sub,

input [4:0] shift,

output [31:0] pp

);

wire [31:0] m_ext;

wire [31:0] m_neg;

wire [31:0] selected;

assign m_ext = {{16{multiplicand[15]}}, multiplicand};

assign m_neg = ~m_ext + 32'd1;

assign selected =

({32{add}} & m_ext) |

({32{sub}} & m_neg);

assign pp = selected << shift;

endmodule

//============================================================

// Top-Level 16-bit Signed Radix-2 Booth Multiplier

//============================================================

module booth_multiplier_16 (

input signed [15:0] multiplicand,

input signed [15:0] multiplier,

output signed [31:0] product

);

//--------------------------------------------------------

// Booth Encoding Signals

//--------------------------------------------------------

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

booth_encoder be0 (.y_i(multiplier[0]), .y_im1(1'b0), .add(add0), .sub(sub0));

booth_encoder be1 (.y_i(multiplier[1]), .y_im1(multiplier[0]), .add(add1), .sub(sub1));

booth_encoder be2 (.y_i(multiplier[2]), .y_im1(multiplier[1]), .add(add2), .sub(sub2));

booth_encoder be3 (.y_i(multiplier[3]), .y_im1(multiplier[2]), .add(add3), .sub(sub3));

booth_encoder be4 (.y_i(multiplier[4]), .y_im1(multiplier[3]), .add(add4), .sub(sub4));

booth_encoder be5 (.y_i(multiplier[5]), .y_im1(multiplier[4]), .add(add5), .sub(sub5));

booth_encoder be6 (.y_i(multiplier[6]), .y_im1(multiplier[5]), .add(add6), .sub(sub6));

booth_encoder be7 (.y_i(multiplier[7]), .y_im1(multiplier[6]), .add(add7), .sub(sub7));

booth_encoder be8 (.y_i(multiplier[8]), .y_im1(multiplier[7]), .add(add8), .sub(sub8));

booth_encoder be9 (.y_i(multiplier[9]), .y_im1(multiplier[8]), .add(add9), .sub(sub9));

booth_encoder be10 (.y_i(multiplier[10]), .y_im1(multiplier[9]), .add(add10), .sub(sub10));

booth_encoder be11 (.y_i(multiplier[11]), .y_im1(multiplier[10]),.add(add11), .sub(sub11));

booth_encoder be12 (.y_i(multiplier[12]), .y_im1(multiplier[11]),.add(add12), .sub(sub12));

booth_encoder be13 (.y_i(multiplier[13]), .y_im1(multiplier[12]),.add(add13), .sub(sub13));

booth_encoder be14 (.y_i(multiplier[14]), .y_im1(multiplier[13]),.add(add14), .sub(sub14));

booth_encoder be15 (.y_i(multiplier[15]), .y_im1(multiplier[14]),.add(add15), .sub(sub15));

//--------------------------------------------------------

// Partial Products

//--------------------------------------------------------

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

booth_partial_product ppg0 (multiplicand, add0, sub0, 5'd0, pp0);

booth_partial_product ppg1 (multiplicand, add1, sub1, 5'd1, pp1);

booth_partial_product ppg2 (multiplicand, add2, sub2, 5'd2, pp2);

booth_partial_product ppg3 (multiplicand, add3, sub3, 5'd3, pp3);

booth_partial_product ppg4 (multiplicand, add4, sub4, 5'd4, pp4);

booth_partial_product ppg5 (multiplicand, add5, sub5, 5'd5, pp5);

booth_partial_product ppg6 (multiplicand, add6, sub6, 5'd6, pp6);

booth_partial_product ppg7 (multiplicand, add7, sub7, 5'd7, pp7);

booth_partial_product ppg8 (multiplicand, add8, sub8, 5'd8, pp8);

booth_partial_product ppg9 (multiplicand, add9, sub9, 5'd9, pp9);

booth_partial_product ppg10 (multiplicand, add10, sub10, 5'd10, pp10);

booth_partial_product ppg11 (multiplicand, add11, sub11, 5'd11, pp11);

booth_partial_product ppg12 (multiplicand, add12, sub12, 5'd12, pp12);

booth_partial_product ppg13 (multiplicand, add13, sub13, 5'd13, pp13);

booth_partial_product ppg14 (multiplicand, add14, sub14, 5'd14, pp14);

booth_partial_product ppg15 (multiplicand, add15, sub15, 5'd15, pp15);

//--------------------------------------------------------

// Structural Adder Tree

//--------------------------------------------------------

wire [31:0] s1;

wire [31:0] s2;

wire [31:0] s3;

wire [31:0] s4;

wire [31:0] s5;

wire [31:0] s6;

wire [31:0] s7;

wire [31:0] s8;

wire [31:0] s9;

wire [31:0] s10;

wire [31:0] s11;

wire [31:0] s12;

wire [31:0] s13;

wire [31:0] s14;

wire [31:0] s15;

ripple_adder_32 a1 (.a(pp0), .b(pp1), .sum(s1));

ripple_adder_32 a2 (.a(s1), .b(pp2), .sum(s2));

ripple_adder_32 a3 (.a(s2), .b(pp3), .sum(s3));

ripple_adder_32 a4 (.a(s3), .b(pp4), .sum(s4));

ripple_adder_32 a5 (.a(s4), .b(pp5), .sum(s5));

ripple_adder_32 a6 (.a(s5), .b(pp6), .sum(s6));

ripple_adder_32 a7 (.a(s6), .b(pp7), .sum(s7));

ripple_adder_32 a8 (.a(s7), .b(pp8), .sum(s8));

ripple_adder_32 a9 (.a(s8), .b(pp9), .sum(s9));

ripple_adder_32 a10 (.a(s9), .b(pp10), .sum(s10));

ripple_adder_32 a11 (.a(s10), .b(pp11), .sum(s11));

ripple_adder_32 a12 (.a(s11), .b(pp12), .sum(s12));

ripple_adder_32 a13 (.a(s12), .b(pp13), .sum(s13));

ripple_adder_32 a14 (.a(s13), .b(pp14), .sum(s14));

ripple_adder_32 a15 (.a(s14), .b(pp15), .sum(s15));

assign product = s15;

endmodule