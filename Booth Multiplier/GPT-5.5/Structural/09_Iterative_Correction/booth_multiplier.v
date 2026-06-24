module full_adder (

input wire a,

input wire b,

input wire cin,

output wire sum,

output wire cout

);

assign sum = a ^ b ^ cin;

assign cout = (a & b) | (a & cin) | (b & cin);

endmodule

module ripple_adder_32 (

input wire [31:0] a,

input wire [31:0] b,

output wire [31:0] sum

);

wire [32:0] c;

assign c[0] = 1'b0;

genvar i;

generate

for (i = 0; i < 32; i = i + 1) begin : FA_CHAIN

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

module booth_encoder (

input wire q_i,

input wire q_im1,

output wire add,

output wire sub

);

assign add = q_i & ~q_im1; // 10 -> -M handled by sub

assign sub = ~q_i & q_im1; // 01 -> +M handled by add path

endmodule

module booth_partial_product (

input wire signed [15:0] multiplicand,

input wire add,

input wire sub,

input wire [4:0] shift_amt,

output wire [31:0] pp

);

wire signed [31:0] mcand_ext;

wire signed [31:0] shifted_mcand;

wire signed [31:0] pos_pp;

wire signed [31:0] neg_pp;

assign mcand_ext = {{16{multiplicand[15]}}, multiplicand};

assign shifted_mcand = mcand_ext <<< shift_amt;

assign pos_pp = add ? shifted_mcand : 32'd0;

assign neg_pp = sub ? (~shifted_mcand + 32'd1) : 32'd0;

assign pp = pos_pp | neg_pp;

endmodule

module booth_multiplier_16 (

input wire signed [15:0] multiplicand,

input wire signed [15:0] multiplier,

output wire signed [31:0] product

);

wire [15:0] add_sel;

wire [15:0] sub_sel;

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

booth_encoder be0 (.q_i(multiplier[0]), .q_im1(1'b0), .add(add_sel[0]), .sub(sub_sel[0]));

booth_encoder be1 (.q_i(multiplier[1]), .q_im1(multiplier[0]), .add(add_sel[1]), .sub(sub_sel[1]));

booth_encoder be2 (.q_i(multiplier[2]), .q_im1(multiplier[1]), .add(add_sel[2]), .sub(sub_sel[2]));

booth_encoder be3 (.q_i(multiplier[3]), .q_im1(multiplier[2]), .add(add_sel[3]), .sub(sub_sel[3]));

booth_encoder be4 (.q_i(multiplier[4]), .q_im1(multiplier[3]), .add(add_sel[4]), .sub(sub_sel[4]));

booth_encoder be5 (.q_i(multiplier[5]), .q_im1(multiplier[4]), .add(add_sel[5]), .sub(sub_sel[5]));

booth_encoder be6 (.q_i(multiplier[6]), .q_im1(multiplier[5]), .add(add_sel[6]), .sub(sub_sel[6]));

booth_encoder be7 (.q_i(multiplier[7]), .q_im1(multiplier[6]), .add(add_sel[7]), .sub(sub_sel[7]));

booth_encoder be8 (.q_i(multiplier[8]), .q_im1(multiplier[7]), .add(add_sel[8]), .sub(sub_sel[8]));

booth_encoder be9 (.q_i(multiplier[9]), .q_im1(multiplier[8]), .add(add_sel[9]), .sub(sub_sel[9]));

booth_encoder be10 (.q_i(multiplier[10]), .q_im1(multiplier[9]), .add(add_sel[10]), .sub(sub_sel[10]));

booth_encoder be11 (.q_i(multiplier[11]), .q_im1(multiplier[10]),.add(add_sel[11]), .sub(sub_sel[11]));

booth_encoder be12 (.q_i(multiplier[12]), .q_im1(multiplier[11]),.add(add_sel[12]), .sub(sub_sel[12]));

booth_encoder be13 (.q_i(multiplier[13]), .q_im1(multiplier[12]),.add(add_sel[13]), .sub(sub_sel[13]));

booth_encoder be14 (.q_i(multiplier[14]), .q_im1(multiplier[13]),.add(add_sel[14]), .sub(sub_sel[14]));

booth_encoder be15 (.q_i(multiplier[15]), .q_im1(multiplier[14]),.add(add_sel[15]), .sub(sub_sel[15]));

booth_partial_product ppg0 (.multiplicand(multiplicand), .add(sub_sel[0]), .sub(add_sel[0]), .shift_amt(5'd0), .pp(pp0));

booth_partial_product ppg1 (.multiplicand(multiplicand), .add(sub_sel[1]), .sub(add_sel[1]), .shift_amt(5'd1), .pp(pp1));

booth_partial_product ppg2 (.multiplicand(multiplicand), .add(sub_sel[2]), .sub(add_sel[2]), .shift_amt(5'd2), .pp(pp2));

booth_partial_product ppg3 (.multiplicand(multiplicand), .add(sub_sel[3]), .sub(add_sel[3]), .shift_amt(5'd3), .pp(pp3));

booth_partial_product ppg4 (.multiplicand(multiplicand), .add(sub_sel[4]), .sub(add_sel[4]), .shift_amt(5'd4), .pp(pp4));

booth_partial_product ppg5 (.multiplicand(multiplicand), .add(sub_sel[5]), .sub(add_sel[5]), .shift_amt(5'd5), .pp(pp5));

booth_partial_product ppg6 (.multiplicand(multiplicand), .add(sub_sel[6]), .sub(add_sel[6]), .shift_amt(5'd6), .pp(pp6));

booth_partial_product ppg7 (.multiplicand(multiplicand), .add(sub_sel[7]), .sub(add_sel[7]), .shift_amt(5'd7), .pp(pp7));

booth_partial_product ppg8 (.multiplicand(multiplicand), .add(sub_sel[8]), .sub(add_sel[8]), .shift_amt(5'd8), .pp(pp8));

booth_partial_product ppg9 (.multiplicand(multiplicand), .add(sub_sel[9]), .sub(add_sel[9]), .shift_amt(5'd9), .pp(pp9));

booth_partial_product ppg10 (.multiplicand(multiplicand), .add(sub_sel[10]), .sub(add_sel[10]), .shift_amt(5'd10), .pp(pp10));

booth_partial_product ppg11 (.multiplicand(multiplicand), .add(sub_sel[11]), .sub(add_sel[11]), .shift_amt(5'd11), .pp(pp11));

booth_partial_product ppg12 (.multiplicand(multiplicand), .add(sub_sel[12]), .sub(add_sel[12]), .shift_amt(5'd12), .pp(pp12));

booth_partial_product ppg13 (.multiplicand(multiplicand), .add(sub_sel[13]), .sub(add_sel[13]), .shift_amt(5'd13), .pp(pp13));

booth_partial_product ppg14 (.multiplicand(multiplicand), .add(sub_sel[14]), .sub(add_sel[14]), .shift_amt(5'd14), .pp(pp14));

booth_partial_product ppg15 (.multiplicand(multiplicand), .add(sub_sel[15]), .sub(add_sel[15]), .shift_amt(5'd15), .pp(pp15));

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