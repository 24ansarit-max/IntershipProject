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

for (i = 0; i < 32; i = i + 1) begin : GEN_FA

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

input wire y_i,

input wire y_im1,

output wire add,

output wire sub

);

assign add = y_i & ~y_im1; // 01

assign sub = ~y_i & y_im1; // 10

endmodule

module booth_partial_product (

input wire [15:0] multiplicand,

input wire y_i,

input wire y_im1,

input wire [4:0] shift,

output wire [31:0] pp

);

wire add_sel;

wire sub_sel;

wire [31:0] mcand_ext;

wire [31:0] mcand_shifted;

wire [31:0] mcand_inverted;

wire [31:0] add_term;

wire [31:0] sub_term;

wire [31:0] sub_pp;

booth_encoder enc (

.y_i (y_i),

.y_im1 (y_im1),

.add (add_sel),

.sub (sub_sel)

);

assign mcand_ext = {{16{multiplicand[15]}}, multiplicand};

assign mcand_shifted = mcand_ext << shift;

assign mcand_inverted = ~mcand_shifted;

assign add_term = add_sel ? mcand_shifted : 32'b0;

assign sub_term = sub_sel ? mcand_inverted : 32'b0;

ripple_adder_32 sub_add (

.a (sub_term),

.b ({31'b0, sub_sel}),

.sum (sub_pp)

);

assign pp = add_term | sub_pp;

endmodule

module booth_multiplier_16x16_signed (

input wire [15:0] a,

input wire [15:0] b,

output wire [31:0] product

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

booth_partial_product pp_gen0 (

.multiplicand(a),

.y_i (b[0]),

.y_im1 (1'b0),

.shift (5'd0),

.pp (pp0)

);

booth_partial_product pp_gen1 (

.multiplicand(a),

.y_i (b[1]),

.y_im1 (b[0]),

.shift (5'd1),

.pp (pp1)

);

booth_partial_product pp_gen2 (

.multiplicand(a),

.y_i (b[2]),

.y_im1 (b[1]),

.shift (5'd2),

.pp (pp2)

);

booth_partial_product pp_gen3 (

.multiplicand(a),

.y_i (b[3]),

.y_im1 (b[2]),

.shift (5'd3),

.pp (pp3)

);

booth_partial_product pp_gen4 (

.multiplicand(a),

.y_i (b[4]),

.y_im1 (b[3]),

.shift (5'd4),

.pp (pp4)

);

booth_partial_product pp_gen5 (

.multiplicand(a),

.y_i (b[5]),

.y_im1 (b[4]),

.shift (5'd5),

.pp (pp5)

);

booth_partial_product pp_gen6 (

.multiplicand(a),

.y_i (b[6]),

.y_im1 (b[5]),

.shift (5'd6),

.pp (pp6)

);

booth_partial_product pp_gen7 (

.multiplicand(a),

.y_i (b[7]),

.y_im1 (b[6]),

.shift (5'd7),

.pp (pp7)

);

booth_partial_product pp_gen8 (

.multiplicand(a),

.y_i (b[8]),

.y_im1 (b[7]),

.shift (5'd8),

.pp (pp8)

);

booth_partial_product pp_gen9 (

.multiplicand(a),

.y_i (b[9]),

.y_im1 (b[8]),

.shift (5'd9),

.pp (pp9)

);

booth_partial_product pp_gen10 (

.multiplicand(a),

.y_i (b[10]),

.y_im1 (b[9]),

.shift (5'd10),

.pp (pp10)

);

booth_partial_product pp_gen11 (

.multiplicand(a),

.y_i (b[11]),

.y_im1 (b[10]),

.shift (5'd11),

.pp (pp11)

);

booth_partial_product pp_gen12 (

.multiplicand(a),

.y_i (b[12]),

.y_im1 (b[11]),

.shift (5'd12),

.pp (pp12)

);

booth_partial_product pp_gen13 (

.multiplicand(a),

.y_i (b[13]),

.y_im1 (b[12]),

.shift (5'd13),

.pp (pp13)

);

booth_partial_product pp_gen14 (

.multiplicand(a),

.y_i (b[14]),

.y_im1 (b[13]),

.shift (5'd14),

.pp (pp14)

);

booth_partial_product pp_gen15 (

.multiplicand(a),

.y_i (b[15]),

.y_im1 (b[14]),

.shift (5'd15),

.pp (pp15)

);

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

ripple_adder_32 add1 (.a(pp0), .b(pp1), .sum(s1));

ripple_adder_32 add2 (.a(s1), .b(pp2), .sum(s2));

ripple_adder_32 add3 (.a(s2), .b(pp3), .sum(s3));

ripple_adder_32 add4 (.a(s3), .b(pp4), .sum(s4));

ripple_adder_32 add5 (.a(s4), .b(pp5), .sum(s5));

ripple_adder_32 add6 (.a(s5), .b(pp6), .sum(s6));

ripple_adder_32 add7 (.a(s6), .b(pp7), .sum(s7));

ripple_adder_32 add8 (.a(s7), .b(pp8), .sum(s8));

ripple_adder_32 add9 (.a(s8), .b(pp9), .sum(s9));

ripple_adder_32 add10 (.a(s9), .b(pp10), .sum(s10));

ripple_adder_32 add11 (.a(s10), .b(pp11), .sum(s11));

ripple_adder_32 add12 (.a(s11), .b(pp12), .sum(s12));

ripple_adder_32 add13 (.a(s12), .b(pp13), .sum(s13));

ripple_adder_32 add14 (.a(s13), .b(pp14), .sum(s14));

ripple_adder_32 add15 (.a(s14), .b(pp15), .sum(s15));

assign product = s15;

endmodule