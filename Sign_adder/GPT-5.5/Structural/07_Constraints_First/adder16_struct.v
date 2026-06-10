design modules required in this order: 
     half_adder → full_adder (uses 2 half_adder instances) → adder16_struct (uses 16 
full_adder instances) 
 
[C3] HALF ADDER: Implement using ONLY Verilog gate primitives: xor g1(sum,a,b); and 
g2(cout,a,b); 
 
[C4] FULL ADDER: Implement using ONLY two half_adder instantiations and one or gate. 
No assign inside. 
 
[C5] CARRY CHAIN: Declare wire [16:0] c inside adder16_struct. 
     c[0] must be tied to 1'b0. c[1] through c[16] come from full adder cout ports. 
 
[C6] 16 EXPLICIT INSTANTIATIONS: Name them fa0 through fa15. No generate loops. 
     Each: full_adder faX(.a(A[X]),.b(B[X]),.cin(c[X]),.sum(sum[X]),.cout(c[X+1])); 
 
[C7] OUTPUT: signed [16:0] sum. sum[15:0] from fa outputs. sum[16] = c[16]. 
 
[C8] SIGNED: signed keyword must appear on A, B, sum ports in adder16_struct. 
 
[C9] FOR LOOP: Test exactly these 20 pairs in order: 
     (0,0),(1,0),(0,1),(-1,0),(0,-1),(1,1),(-1,-1),(1,-1), 
     (32767,0),(-32768,0),(32767,1),(-32768,-1), 
     (32767,32767),(-32768,-32768),(32767,-32768),(-32768,32767), 
     (16384,16384),(-16384,-16384),(32766,1),(-32767,-1) 
 
[C10] WHILE LOOP: test_count < 100, $signed($random) for A and B, track error_count. 
 
[C11] REPEAT LOOP: exactly 50 iterations, $signed($random) inputs, $display each result. 
 
[C12] FOREVER LOOP: clk toggle every 5ns. Separate initial block with $finish at 2000ns. 
 
[C13] PASS/FAIL: Compute expected = $signed(A) + $signed(B) in testbench. 
      Compare $signed(sum) vs expected. Print PASS or FAIL with all values. 
 
[C14] DISPLAY FORMAT: Use %0d for signed decimal. Print test number, A, B, expected, 
actual, status. 
 
NOW write complete Verilog satisfying ALL constraints [C1] through [C14] strictly. 
 
Design module- 
`timescale 1ns/1ps 
 
//============================================================ 
// Half Adder 
// [C3] Only gate primitives 
//============================================================ 
module half_adder( 
input a, 
input b, 
output sum, 
output cout 
); 
xor g1(sum, a, b); 
and g2(cout, a, b); 
endmodule 
 
//============================================================ 
// Full Adder 
// [C4] Uses exactly two half_adders and one OR gate 
//============================================================ 
module full_adder( 
input a, 
input b, 
input cin, 
output sum, 
output cout 
); 
wire s1; 
wire c1; 
wire c2; 
 
half_adder ha1( 
.a(a), 
.b(b), 
.sum(s1), 
.cout(c1) 
); 
 
half_adder ha2( 
.a(s1), 
.b(cin), 
.sum(sum), 
.cout(c2) 
); 
 
or g1(cout, c1, c2); 
endmodule 
 
//============================================================ 
// 16-bit Structural Adder 
// [C1] Structural only 
// [C5] Carry chain wire [16:0] c 
// [C6] Explicit instantiations fa0-fa15 
// [C7] sum[16] = c[16] 
// [C8] signed ports 
//============================================================ 
module adder16_struct( 
input signed [15:0] A, 
input signed [15:0] B, 
output signed [16:0] sum 
); 
 
wire [16:0] c; 
wire [15:0] sum_int; 
 
assign c[0] = 1'b0; 
assign sum[15:0] = sum_int; 
assign sum[16] = c[16]; 
 
full_adder fa0 ( 
.a(A[0]), .b(B[0]), .cin(c[0]), 
.sum(sum_int[0]), .cout(c[1]) 
); 
 
full_adder fa1 ( 
.a(A[1]), .b(B[1]), .cin(c[1]), 
.sum(sum_int[1]), .cout(c[2]) 
); 
 
full_adder fa2 ( 
.a(A[2]), .b(B[2]), .cin(c[2]), 
.sum(sum_int[2]), .cout(c[3]) 
); 
 
full_adder fa3 ( 
.a(A[3]), .b(B[3]), .cin(c[3]), 
.sum(sum_int[3]), .cout(c[4]) 
); 
 
full_adder fa4 ( 
.a(A[4]), .b(B[4]), .cin(c[4]), 
.sum(sum_int[4]), .cout(c[5]) 
); 
 
full_adder fa5 ( 
.a(A[5]), .b(B[5]), .cin(c[5]), 
.sum(sum_int[5]), .cout(c[6]) 
); 
 
full_adder fa6 ( 
.a(A[6]), .b(B[6]), .cin(c[6]), 
.sum(sum_int[6]), .cout(c[7]) 
); 
 
full_adder fa7 ( 
.a(A[7]), .b(B[7]), .cin(c[7]), 
.sum(sum_int[7]), .cout(c[8]) 
); 
 
full_adder fa8 ( 
.a(A[8]), .b(B[8]), .cin(c[8]), 
.sum(sum_int[8]), .cout(c[9]) 
); 
 
full_adder fa9 ( 
.a(A[9]), .b(B[9]), .cin(c[9]), 
.sum(sum_int[9]), .cout(c[10]) 
); 
 
full_adder fa10 ( 
.a(A[10]), .b(B[10]), .cin(c[10]), 
.sum(sum_int[10]), .cout(c[11]) 
); 
 
full_adder fa11 ( 
.a(A[11]), .b(B[11]), .cin(c[11]), 
.sum(sum_int[11]), .cout(c[12]) 
); 
 
full_adder fa12 ( 
.a(A[12]), .b(B[12]), .cin(c[12]), 
.sum(sum_int[12]), .cout(c[13]) 
); 
 
full_adder fa13 ( 
.a(A[13]), .b(B[13]), .cin(c[13]), 
.sum(sum_int[13]), .cout(c[14]) 
); 
 
full_adder fa14 ( 
.a(A[14]), .b(B[14]), .cin(c[14]), 
.sum(sum_int[14]), .cout(c[15]) 
); 
 
full_adder fa15 ( 
.a(A[15]), .b(B[15]), .cin(c[15]), 
.sum(sum_int[15]), .cout(c[16]) 
); 
 
endmodule