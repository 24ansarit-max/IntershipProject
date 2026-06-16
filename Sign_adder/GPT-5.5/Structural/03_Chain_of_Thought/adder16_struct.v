Design module- 
`timescale 1ns/1ps 
 
//==================================================== 
// Half Adder 
//==================================================== 
module half_adder( 
input a, 
input b, 
output sum, 
output cout 
); 
 
xor (sum, a, b); 
and (cout, a, b); 
 
endmodule 
 
 
//==================================================== 
// Full Adder 
// Built structurally from two half adders 
//==================================================== 
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
 
half_adder ha1 ( 
.a(a), 
.b(b), 
.sum(s1), 
.cout(c1) 
); 
 
half_adder ha2 ( 
.a(s1), 
.b(cin), 
.sum(sum), 
.cout(c2) 
); 
 
or (cout, c1, c2); 
 
endmodule 
 
 
//==================================================== 
// 16-Bit Signed Structural Adder 
// Top level contains ONLY module instantiations 
// and wire connections. 
//==================================================== 
module adder16_struct( 
input signed [15:0] A, 
input signed [15:0] B, 
output signed [16:0] SUM 
); 
 
wire [15:1] c; 
 
full_adder fa0 ( 
.a (A[0]), 
.b (B[0]), 
.cin (1'b0), 
.sum (SUM[0]), 
.cout(c[1]) 
); 
 
full_adder fa1 ( 
.a (A[1]), 
.b (B[1]), 
.cin (c[1]), 
.sum (SUM[1]), 
.cout(c[2]) 
); 
 
full_adder fa2 ( 
.a (A[2]), 
.b (B[2]), 
.cin (c[2]), 
.sum (SUM[2]), 
.cout(c[3]) 
); 
 
full_adder fa3 ( 
.a (A[3]), 
.b (B[3]), 
.cin (c[3]), 
.sum (SUM[3]), 
.cout(c[4]) 
); 
 
full_adder fa4 ( 
.a (A[4]), 
.b (B[4]), 
.cin (c[4]), 
.sum (SUM[4]), 
.cout(c[5]) 
); 
 
full_adder fa5 ( 
.a (A[5]), 
.b (B[5]), 
.cin (c[5]), 
.sum (SUM[5]), 
.cout(c[6]) 
); 
 
full_adder fa6 ( 
.a (A[6]), 
.b (B[6]), 
.cin (c[6]), 
.sum (SUM[6]), 
.cout(c[7]) 
); 
 
full_adder fa7 ( 
.a (A[7]), 
.b (B[7]), 
.cin (c[7]), 
.sum (SUM[7]), 
.cout(c[8]) 
); 
 
full_adder fa8 ( 
.a (A[8]), 
.b (B[8]), 
.cin (c[8]), 
.sum (SUM[8]), 
.cout(c[9]) 
); 
 
full_adder fa9 ( 
.a (A[9]), 
.b (B[9]), 
.cin (c[9]), 
.sum (SUM[9]), 
.cout(c[10]) 
); 
 
full_adder fa10 ( 
.a (A[10]), 
.b (B[10]), 
.cin (c[10]), 
.sum (SUM[10]), 
.cout(c[11]) 
); 
 
full_adder fa11 ( 
.a (A[11]), 
.b (B[11]), 
.cin (c[11]), 
.sum (SUM[11]), 
.cout(c[12]) 
); 
 
full_adder fa12 ( 
.a (A[12]), 
.b (B[12]), 
.cin (c[12]), 
.sum (SUM[12]), 
.cout(c[13]) 
); 
 
full_adder fa13 ( 
.a (A[13]), 
.b (B[13]), 
.cin (c[13]), 
.sum (SUM[13]), 
.cout(c[14]) 
); 
 
full_adder fa14 ( 
.a (A[14]), 
.b (B[14]), 
.cin (c[14]), 
.sum (SUM[14]), 
.cout(c[15]) 
); 
 
full_adder fa15 ( 
.a (A[15]), 
.b (B[15]), 
.cin (c[15]), 
.sum (SUM[15]), 
.cout(SUM[16]) 
); 
 
endmodule