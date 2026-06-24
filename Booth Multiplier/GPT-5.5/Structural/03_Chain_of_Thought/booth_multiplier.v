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

module ripple_adder_32(

input [31:0] a,

input [31:0] b,

output [31:0] sum

);

wire [32:0] c;

assign c[0] = 1'b0;

genvar i;

generate

for(i=0;i<32;i=i+1) begin : FA_CHAIN

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

module booth_pp_gen(

input [15:0] a,

input y_i,

input y_im1,

input [4:0] shift,

output [31:0] pp

);

wire add_op;

wire sub_op;

wire [15:0] a_ext;

wire [15:0] a_inv;

wire [16:0] mag17;

wire [31:0] mag32;

wire [31:0] shifted_mag;

wire [31:0] shifted_sub;

assign add_op = y_i & ~y_im1;

assign sub_op = ~y_i & y_im1;

assign a_ext = a;

assign a_inv = ~a_ext;

assign mag17 = sub_op ? {a_inv[15], a_inv} + 17'd1 :

{a_ext[15], a_ext};

assign mag32 = {{15{mag17[16]}}, mag17};

assign shifted_mag = mag32 << shift;

assign shifted_sub = (~shifted_mag) + 32'd1;

assign pp = add_op ? shifted_mag :

sub_op ? shifted_sub :

32'd0;

endmodule

module booth_multiplier_16s(

input [15:0] multiplicand,

input [15:0] multiplier,

output [31:0] product

);

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

booth_pp_gen g0 (.a(multiplicand), .y_i(multiplier[0]), .y_im1(1'b0), .shift(5'd0), .pp(pp0));

booth_pp_gen g1 (.a(multiplicand), .y_i(multiplier[1]), .y_im1(multiplier[0]), .shift(5'd1), .pp(pp1));

booth_pp_gen g2 (.a(multiplicand), .y_i(multiplier[2]), .y_im1(multiplier[1]), .shift(5'd2), .pp(pp2));

booth_pp_gen g3 (.a(multiplicand), .y_i(multiplier[3]), .y_im1(multiplier[2]), .shift(5'd3), .pp(pp3));

booth_pp_gen g4 (.a(multiplicand), .y_i(multiplier[4]), .y_im1(multiplier[3]), .shift(5'd4), .pp(pp4));

booth_pp_gen g5 (.a(multiplicand), .y_i(multiplier[5]), .y_im1(multiplier[4]), .shift(5'd5), .pp(pp5));

booth_pp_gen g6 (.a(multiplicand), .y_i(multiplier[6]), .y_im1(multiplier[5]), .shift(5'd6), .pp(pp6));

booth_pp_gen g7 (.a(multiplicand), .y_i(multiplier[7]), .y_im1(multiplier[6]), .shift(5'd7), .pp(pp7));

booth_pp_gen g8 (.a(multiplicand), .y_i(multiplier[8]), .y_im1(multiplier[7]), .shift(5'd8), .pp(pp8));

booth_pp_gen g9 (.a(multiplicand), .y_i(multiplier[9]), .y_im1(multiplier[8]), .shift(5'd9), .pp(pp9));

booth_pp_gen g10 (.a(multiplicand), .y_i(multiplier[10]), .y_im1(multiplier[9]), .shift(5'd10), .pp(pp10));

booth_pp_gen g11 (.a(multiplicand), .y_i(multiplier[11]), .y_im1(multiplier[10]),.shift(5'd11), .pp(pp11));

booth_pp_gen g12 (.a(multiplicand), .y_i(multiplier[12]), .y_im1(multiplier[11]),.shift(5'd12), .pp(pp12));

booth_pp_gen g13 (.a(multiplicand), .y_i(multiplier[13]), .y_im1(multiplier[12]),.shift(5'd13), .pp(pp13));

booth_pp_gen g14 (.a(multiplicand), .y_i(multiplier[14]), .y_im1(multiplier[13]),.shift(5'd14), .pp(pp14));

booth_pp_gen g15 (.a(multiplicand), .y_i(multiplier[15]), .y_im1(multiplier[14]),.shift(5'd15), .pp(pp15));

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