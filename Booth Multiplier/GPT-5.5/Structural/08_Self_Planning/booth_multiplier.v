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

for(i=0;i<32;i=i+1)

begin:FA_GEN

full_adder fa(

.a (a[i]),

.b (b[i]),

.cin (c[i]),

.sum (sum[i]),

.cout(c[i+1])

);

end

endgenerate

endmodule

module booth_encoder(

input yi,

input yim1,

output add,

output sub

);

assign add = (~yi) & yim1;

assign sub = yi & (~yim1);

endmodule

module partial_product_generator(

input [15:0] multiplicand,

input add,

input sub,

input [4:0] shift,

output [31:0] pp

);

wire [31:0] m_ext;

wire [31:0] m_shift;

wire [31:0] m_neg;

assign m_ext = {{16{multiplicand[15]}}, multiplicand};

assign m_shift = m_ext << shift;

assign m_neg = ~m_shift + 32'd1;

assign pp =

add ? m_shift :

sub ? m_neg :

32'd0;

endmodule

module booth_multiplier_16(

input signed [15:0] multiplicand,

input signed [15:0] multiplier,

output signed [31:0] product

);

wire [15:0] add_sel;

wire [15:0] sub_sel;

booth_encoder be0 (

.yi(multiplier[0]),

.yim1(1'b0),

.add(add_sel[0]),

.sub(sub_sel[0])

);

genvar k;

generate

for(k=1;k<16;k=k+1)

begin:ENCODERS

booth_encoder be(

.yi(multiplier[k]),

.yim1(multiplier[k-1]),

.add(add_sel[k]),

.sub(sub_sel[k])

);

end

endgenerate

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

partial_product_generator ppg0 (

.multiplicand(multiplicand),

.add(add_sel[0]),

.sub(sub_sel[0]),

.shift(5'd0),

.pp(pp0)

);

partial_product_generator ppg1 (

.multiplicand(multiplicand),

.add(add_sel[1]),

.sub(sub_sel[1]),

.shift(5'd1),

.pp(pp1)

);

partial_product_generator ppg2 (

.multiplicand(multiplicand),

.add(add_sel[2]),

.sub(sub_sel[2]),

.shift(5'd2),

.pp(pp2)

);

partial_product_generator ppg3 (

.multiplicand(multiplicand),

.add(add_sel[3]),

.sub(sub_sel[3]),

.shift(5'd3),

.pp(pp3)

);

partial_product_generator ppg4 (

.multiplicand(multiplicand),

.add(add_sel[4]),

.sub(sub_sel[4]),

.shift(5'd4),

.pp(pp4)

);

partial_product_generator ppg5 (

.multiplicand(multiplicand),

.add(add_sel[5]),

.sub(sub_sel[5]),

.shift(5'd5),

.pp(pp5)

);

partial_product_generator ppg6 (

.multiplicand(multiplicand),

.add(add_sel[6]),

.sub(sub_sel[6]),

.shift(5'd6),

.pp(pp6)

);

partial_product_generator ppg7 (

.multiplicand(multiplicand),

.add(add_sel[7]),

.sub(sub_sel[7]),

.shift(5'd7),

.pp(pp7)

);

partial_product_generator ppg8 (

.multiplicand(multiplicand),

.add(add_sel[8]),

.sub(sub_sel[8]),

.shift(5'd8),

.pp(pp8)

);

partial_product_generator ppg9 (

.multiplicand(multiplicand),

.add(add_sel[9]),

.sub(sub_sel[9]),

.shift(5'd9),

.pp(pp9)

);

partial_product_generator ppg10 (

.multiplicand(multiplicand),

.add(add_sel[10]),

.sub(sub_sel[10]),

.shift(5'd10),

.pp(pp10)

);

partial_product_generator ppg11 (

.multiplicand(multiplicand),

.add(add_sel[11]),

.sub(sub_sel[11]),

.shift(5'd11),

.pp(pp11)

);

partial_product_generator ppg12 (

.multiplicand(multiplicand),

.add(add_sel[12]),

.sub(sub_sel[12]),

.shift(5'd12),

.pp(pp12)

);

partial_product_generator ppg13 (

.multiplicand(multiplicand),

.add(add_sel[13]),

.sub(sub_sel[13]),

.shift(5'd13),

.pp(pp13)

);

partial_product_generator ppg14 (

.multiplicand(multiplicand),

.add(add_sel[14]),

.sub(sub_sel[14]),

.shift(5'd14),

.pp(pp14)

);

partial_product_generator ppg15 (

.multiplicand(multiplicand),

.add(add_sel[15]),

.sub(sub_sel[15]),

.shift(5'd15),

.pp(pp15)

);

wire [31:0] s1_0;

wire [31:0] s1_1;

wire [31:0] s1_2;

wire [31:0] s1_3;

wire [31:0] s1_4;

wire [31:0] s1_5;

wire [31:0] s1_6;

wire [31:0] s1_7;

ripple_adder_32 a10(.a(pp0), .b(pp1), .sum(s1_0));

ripple_adder_32 a11(.a(pp2), .b(pp3), .sum(s1_1));

ripple_adder_32 a12(.a(pp4), .b(pp5), .sum(s1_2));

ripple_adder_32 a13(.a(pp6), .b(pp7), .sum(s1_3));

ripple_adder_32 a14(.a(pp8), .b(pp9), .sum(s1_4));

ripple_adder_32 a15(.a(pp10), .b(pp11), .sum(s1_5));

ripple_adder_32 a16(.a(pp12), .b(pp13), .sum(s1_6));

ripple_adder_32 a17(.a(pp14), .b(pp15), .sum(s1_7));

wire [31:0] s2_0;

wire [31:0] s2_1;

wire [31:0] s2_2;

wire [31:0] s2_3;

ripple_adder_32 a20(.a(s1_0), .b(s1_1), .sum(s2_0));

ripple_adder_32 a21(.a(s1_2), .b(s1_3), .sum(s2_1));

ripple_adder_32 a22(.a(s1_4), .b(s1_5), .sum(s2_2));

ripple_adder_32 a23(.a(s1_6), .b(s1_7), .sum(s2_3));

wire [31:0] s3_0;

wire [31:0] s3_1;

ripple_adder_32 a30(.a(s2_0), .b(s2_1), .sum(s3_0));

ripple_adder_32 a31(.a(s2_2), .b(s2_3), .sum(s3_1));

wire [31:0] s4;

ripple_adder_32 a40(.a(s3_0), .b(s3_1), .sum(s4));

assign product = s4;

endmodule