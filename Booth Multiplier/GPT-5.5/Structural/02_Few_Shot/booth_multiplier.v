module full_adder(

input a,

input b,

input cin,

output sum,

output cout

);

assign sum = a ^ b ^ cin;

assign cout = (a & b) | (a & cin) | (b & cin);

endmodule

module ripple_adder32(

input [31:0] a,

input [31:0] b,

output [31:0] sum

);

wire [32:0] c;

assign c[0] = 1'b0;

genvar i;

generate

for(i=0;i<32;i=i+1) begin : FA_GEN

full_adder fa(

.a(a[i]),

.b(b[i]),

.cin(c[i]),

.sum(sum[i]),

.cout(c[i+1])

);

end

endgenerate

endmodule

module ripple_adder32_cin1(

input [31:0] a,

input [31:0] b,

output [31:0] sum

);

wire [32:0] c;

assign c[0] = 1'b1;

genvar i;

generate

for(i=0;i<32;i=i+1) begin : FA_GEN

full_adder fa(

.a(a[i]),

.b(b[i]),

.cin(c[i]),

.sum(sum[i]),

.cout(c[i+1])

);

end

endgenerate

endmodule

module booth_encoder(

input y_i,

input y_im1,

output add,

output sub

);

assign add = y_i & ~y_im1; // 01

assign sub = ~y_i & y_im1; // 10

endmodule

module booth_partial_product #

(

parameter SHIFT = 0

)

(

input [15:0] x,

input add,

input sub,

output [31:0] pp

);

wire [31:0] x_ext;

wire [31:0] x_shift;

wire [31:0] x_shift_inv;

wire [31:0] x_shift_neg;

assign x_ext = {{16{x[15]}}, x};

assign x_shift = x_ext << SHIFT;

assign x_shift_inv = ~x_shift;

ripple_adder32_cin1 neg_gen(

.a(x_shift_inv),

.b(32'b0),

.sum(x_shift_neg)

);

genvar k;

generate

for(k=0;k<32;k=k+1) begin : PP_SEL

assign pp[k] =

(add & x_shift[k]) |

(sub & x_shift_neg[k]);

end

endgenerate

endmodule

module booth_multiplier_16x16_signed(

input [15:0] multiplicand,

input [15:0] multiplier,

output [31:0] product

);

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

booth_partial_product #(.SHIFT(0 )) ppg0 (.x(multiplicand), .add(add0), .sub(sub0), .pp(pp0));

booth_partial_product #(.SHIFT(1 )) ppg1 (.x(multiplicand), .add(add1), .sub(sub1), .pp(pp1));

booth_partial_product #(.SHIFT(2 )) ppg2 (.x(multiplicand), .add(add2), .sub(sub2), .pp(pp2));

booth_partial_product #(.SHIFT(3 )) ppg3 (.x(multiplicand), .add(add3), .sub(sub3), .pp(pp3));

booth_partial_product #(.SHIFT(4 )) ppg4 (.x(multiplicand), .add(add4), .sub(sub4), .pp(pp4));

booth_partial_product #(.SHIFT(5 )) ppg5 (.x(multiplicand), .add(add5), .sub(sub5), .pp(pp5));

booth_partial_product #(.SHIFT(6 )) ppg6 (.x(multiplicand), .add(add6), .sub(sub6), .pp(pp6));

booth_partial_product #(.SHIFT(7 )) ppg7 (.x(multiplicand), .add(add7), .sub(sub7), .pp(pp7));

booth_partial_product #(.SHIFT(8 )) ppg8 (.x(multiplicand), .add(add8), .sub(sub8), .pp(pp8));

booth_partial_product #(.SHIFT(9 )) ppg9 (.x(multiplicand), .add(add9), .sub(sub9), .pp(pp9));

booth_partial_product #(.SHIFT(10)) ppg10 (.x(multiplicand), .add(add10), .sub(sub10), .pp(pp10));

booth_partial_product #(.SHIFT(11)) ppg11 (.x(multiplicand), .add(add11), .sub(sub11), .pp(pp11));

booth_partial_product #(.SHIFT(12)) ppg12 (.x(multiplicand), .add(add12), .sub(sub12), .pp(pp12));

booth_partial_product #(.SHIFT(13)) ppg13 (.x(multiplicand), .add(add13), .sub(sub13), .pp(pp13));

booth_partial_product #(.SHIFT(14)) ppg14 (.x(multiplicand), .add(add14), .sub(sub14), .pp(pp14));

booth_partial_product #(.SHIFT(15)) ppg15 (.x(multiplicand), .add(add15), .sub(sub15), .pp(pp15));

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

ripple_adder32 a1 (.a(pp0), .b(pp1), .sum(s1));

ripple_adder32 a2 (.a(s1), .b(pp2), .sum(s2));

ripple_adder32 a3 (.a(s2), .b(pp3), .sum(s3));

ripple_adder32 a4 (.a(s3), .b(pp4), .sum(s4));

ripple_adder32 a5 (.a(s4), .b(pp5), .sum(s5));

ripple_adder32 a6 (.a(s5), .b(pp6), .sum(s6));

ripple_adder32 a7 (.a(s6), .b(pp7), .sum(s7));

ripple_adder32 a8 (.a(s7), .b(pp8), .sum(s8));

ripple_adder32 a9 (.a(s8), .b(pp9), .sum(s9));

ripple_adder32 a10 (.a(s9), .b(pp10), .sum(s10));

ripple_adder32 a11 (.a(s10), .b(pp11), .sum(s11));

ripple_adder32 a12 (.a(s11), .b(pp12), .sum(s12));

ripple_adder32 a13 (.a(s12), .b(pp13), .sum(s13));

ripple_adder32 a14 (.a(s13), .b(pp14), .sum(s14));

ripple_adder32 a15 (.a(s14), .b(pp15), .sum(s15));

assign product = s15;

endmodule