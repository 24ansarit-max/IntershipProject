module booth_encoder (

input wire y_i,

input wire y_im1,

output wire add,

output wire sub

);

assign add = y_i & ~y_im1;

assign sub = ~y_i & y_im1;

endmodule

module pp_gen (

input wire signed [15:0] multiplicand,

input wire add,

input wire sub,

input wire [4:0] shift,

output wire signed [31:0] pp

);

wire signed [31:0] m_ext;

wire signed [31:0] pos_pp;

wire signed [31:0] neg_pp;

assign m_ext = {{16{multiplicand[15]}}, multiplicand};

assign pos_pp = m_ext <<< shift;

assign neg_pp = (~pos_pp) + 32'sd1;

assign pp = add ? pos_pp :

sub ? neg_pp :

32'sd0;

endmodule

module adder32 (

input wire [31:0] a,

input wire [31:0] b,

output wire [31:0] s

);

wire [32:0] c;

assign c[0] = 1'b0;

genvar i;

generate

for (i = 0; i < 32; i = i + 1) begin : GEN_ADD

assign s[i] = a[i] ^ b[i] ^ c[i];

assign c[i+1] = (a[i] & b[i]) |

(a[i] & c[i]) |

(b[i] & c[i]);

end

endgenerate

endmodule

module booth_multiplier_16 (

input wire signed [15:0] multiplicand,

input wire signed [15:0] multiplier,

output wire signed [31:0] product

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

booth_encoder BE0 (.y_i(multiplier[0]), .y_im1(1'b0), .add(add0), .sub(sub0));

booth_encoder BE1 (.y_i(multiplier[1]), .y_im1(multiplier[0]), .add(add1), .sub(sub1));

booth_encoder BE2 (.y_i(multiplier[2]), .y_im1(multiplier[1]), .add(add2), .sub(sub2));

booth_encoder BE3 (.y_i(multiplier[3]), .y_im1(multiplier[2]), .add(add3), .sub(sub3));

booth_encoder BE4 (.y_i(multiplier[4]), .y_im1(multiplier[3]), .add(add4), .sub(sub4));

booth_encoder BE5 (.y_i(multiplier[5]), .y_im1(multiplier[4]), .add(add5), .sub(sub5));

booth_encoder BE6 (.y_i(multiplier[6]), .y_im1(multiplier[5]), .add(add6), .sub(sub6));

booth_encoder BE7 (.y_i(multiplier[7]), .y_im1(multiplier[6]), .add(add7), .sub(sub7));

booth_encoder BE8 (.y_i(multiplier[8]), .y_im1(multiplier[7]), .add(add8), .sub(sub8));

booth_encoder BE9 (.y_i(multiplier[9]), .y_im1(multiplier[8]), .add(add9), .sub(sub9));

booth_encoder BE10 (.y_i(multiplier[10]), .y_im1(multiplier[9]), .add(add10), .sub(sub10));

booth_encoder BE11 (.y_i(multiplier[11]), .y_im1(multiplier[10]),.add(add11), .sub(sub11));

booth_encoder BE12 (.y_i(multiplier[12]), .y_im1(multiplier[11]),.add(add12), .sub(sub12));

booth_encoder BE13 (.y_i(multiplier[13]), .y_im1(multiplier[12]),.add(add13), .sub(sub13));

booth_encoder BE14 (.y_i(multiplier[14]), .y_im1(multiplier[13]),.add(add14), .sub(sub14));

booth_encoder BE15 (.y_i(multiplier[15]), .y_im1(multiplier[14]),.add(add15), .sub(sub15));

wire signed [31:0] pp0, pp1, pp2, pp3;

wire signed [31:0] pp4, pp5, pp6, pp7;

wire signed [31:0] pp8, pp9, pp10, pp11;

wire signed [31:0] pp12, pp13, pp14, pp15;

pp_gen PPG0 (.multiplicand(multiplicand), .add(add0), .sub(sub0), .shift(5'd0), .pp(pp0));

pp_gen PPG1 (.multiplicand(multiplicand), .add(add1), .sub(sub1), .shift(5'd1), .pp(pp1));

pp_gen PPG2 (.multiplicand(multiplicand), .add(add2), .sub(sub2), .shift(5'd2), .pp(pp2));

pp_gen PPG3 (.multiplicand(multiplicand), .add(add3), .sub(sub3), .shift(5'd3), .pp(pp3));

pp_gen PPG4 (.multiplicand(multiplicand), .add(add4), .sub(sub4), .shift(5'd4), .pp(pp4));

pp_gen PPG5 (.multiplicand(multiplicand), .add(add5), .sub(sub5), .shift(5'd5), .pp(pp5));

pp_gen PPG6 (.multiplicand(multiplicand), .add(add6), .sub(sub6), .shift(5'd6), .pp(pp6));

pp_gen PPG7 (.multiplicand(multiplicand), .add(add7), .sub(sub7), .shift(5'd7), .pp(pp7));

pp_gen PPG8 (.multiplicand(multiplicand), .add(add8), .sub(sub8), .shift(5'd8), .pp(pp8));

pp_gen PPG9 (.multiplicand(multiplicand), .add(add9), .sub(sub9), .shift(5'd9), .pp(pp9));

pp_gen PPG10 (.multiplicand(multiplicand), .add(add10), .sub(sub10), .shift(5'd10), .pp(pp10));

pp_gen PPG11 (.multiplicand(multiplicand), .add(add11), .sub(sub11), .shift(5'd11), .pp(pp11));

pp_gen PPG12 (.multiplicand(multiplicand), .add(add12), .sub(sub12), .shift(5'd12), .pp(pp12));

pp_gen PPG13 (.multiplicand(multiplicand), .add(add13), .sub(sub13), .shift(5'd13), .pp(pp13));

pp_gen PPG14 (.multiplicand(multiplicand), .add(add14), .sub(sub14), .shift(5'd14), .pp(pp14));

pp_gen PPG15 (.multiplicand(multiplicand), .add(add15), .sub(sub15), .shift(5'd15), .pp(pp15));

wire [31:0] s0, s1, s2, s3, s4, s5, s6, s7;

wire [31:0] t0, t1, t2, t3;

wire [31:0] u0, u1;

adder32 A0 (.a(pp0), .b(pp1), .s(s0));

adder32 A1 (.a(pp2), .b(pp3), .s(s1));

adder32 A2 (.a(pp4), .b(pp5), .s(s2));

adder32 A3 (.a(pp6), .b(pp7), .s(s3));

adder32 A4 (.a(pp8), .b(pp9), .s(s4));

adder32 A5 (.a(pp10), .b(pp11), .s(s5));

adder32 A6 (.a(pp12), .b(pp13), .s(s6));

adder32 A7 (.a(pp14), .b(pp15), .s(s7));

adder32 B0 (.a(s0), .b(s1), .s(t0));

adder32 B1 (.a(s2), .b(s3), .s(t1));

adder32 B2 (.a(s4), .b(s5), .s(t2));

adder32 B3 (.a(s6), .b(s7), .s(t3));

adder32 C0 (.a(t0), .b(t1), .s(u0));

adder32 C1 (.a(t2), .b(t3), .s(u1));

adder32 D0 (.a(u0), .b(u1), .s(product));

endmodule