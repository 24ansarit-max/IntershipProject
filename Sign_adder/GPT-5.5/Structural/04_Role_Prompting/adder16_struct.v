Design module- 
//=====================================================================
======== 
// File : adder16_struct.v 
// Description : Strict Structural 16-bit Signed Adder Reference Implementation 
// Author : RTL Design Team 
// 
// Coding Rules: 
// - Top-level module uses ONLY structural modeling. 
// - No assign statements in top-level. 
// - No always blocks in top-level. 
// - No arithmetic operators in top-level. 
// - Logic is encapsulated inside primitive sub-modules. 
// 
// Modules: 
// 1. half_adder 
// 2. full_adder 
// 3. adder16_struct 
// 4. tb_adder16 
//=====================================================================
======== 
 
`timescale 1ns/1ps 
 
//=====================================================================
======== 
// HALF ADDER 
// Primitive Gate-Level Implementation 
//=====================================================================
======== 
module half_adder ( 
input a, 
input b, 
output sum, 
output cout 
); 
 
xor (sum, a, b); 
and (cout, a, b); 
 
endmodule 
 
 
//=====================================================================
======== 
// FULL ADDER 
// Structural Implementation Using Two Half Adders 
//=====================================================================
======== 
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
 
half_adder ha1 ( 
.a (a), 
.b (b), 
.sum (s1), 
.cout(c1) 
); 
 
half_adder ha2 ( 
.a (s1), 
.b (cin), 
.sum (sum), 
.cout(c2) 
); 
 
or g1 ( 
cout, 
c1, 
c2 
); 
 
endmodule 
 
 
//=====================================================================
======== 
// 16-BIT STRUCTURAL SIGNED ADDER 
// 
// Structural only: 
// - Exactly 16 full adder instances (fa0 ... fa15) 
// - Carry chain c[0] -> c[16] 
// - No assign 
// - No always 
// - No arithmetic operators 
//=====================================================================
======== 
module adder16_struct ( 
input signed [15:0] A, 
input signed [15:0] B, 
output signed [16:0] sum 
); 
 
wire [16:0] c; 
 
supply0 GND; 
 
// Carry-in = 0 
buf (c[0], GND); 
 
full_adder fa0 ( 
.a (A[0]), 
.b (B[0]), 
.cin (c[0]), 
.sum (sum[0]), 
.cout(c[1]) 
); 
 
full_adder fa1 ( 
.a (A[1]), 
.b (B[1]), 
.cin (c[1]), 
.sum (sum[1]), 
.cout(c[2]) 
); 
 
full_adder fa2 ( 
.a (A[2]), 
.b (B[2]), 
.cin (c[2]), 
.sum (sum[2]), 
.cout(c[3]) 
); 
 
full_adder fa3 ( 
.a (A[3]), 
.b (B[3]), 
.cin (c[3]), 
.sum (sum[3]), 
.cout(c[4]) 
); 
 
full_adder fa4 ( 
.a (A[4]), 
.b (B[4]), 
.cin (c[4]), 
.sum (sum[4]), 
.cout(c[5]) 
); 
 
full_adder fa5 ( 
.a (A[5]), 
.b (B[5]), 
.cin (c[5]), 
.sum (sum[5]), 
.cout(c[6]) 
); 
 
full_adder fa6 ( 
.a (A[6]), 
.b (B[6]), 
.cin (c[6]), 
.sum (sum[6]), 
.cout(c[7]) 
); 
 
full_adder fa7 ( 
.a (A[7]), 
.b (B[7]), 
.cin (c[7]), 
.sum (sum[7]), 
.cout(c[8]) 
); 
 
full_adder fa8 ( 
.a (A[8]), 
.b (B[8]), 
.cin (c[8]), 
.sum (sum[8]), 
.cout(c[9]) 
); 
 
full_adder fa9 ( 
.a (A[9]), 
.b (B[9]), 
.cin (c[9]), 
.sum (sum[9]), 
.cout(c[10]) 
); 
 
full_adder fa10 ( 
.a (A[10]), 
.b (B[10]), 
.cin (c[10]), 
.sum (sum[10]), 
.cout(c[11]) 
); 
 
full_adder fa11 ( 
.a (A[11]), 
.b (B[11]), 
.cin (c[11]), 
.sum (sum[11]), 
.cout(c[12]) 
); 
 
full_adder fa12 ( 
.a (A[12]), 
.b (B[12]), 
.cin (c[12]), 
.sum (sum[12]), 
.cout(c[13]) 
); 
 
full_adder fa13 ( 
.a (A[13]), 
.b (B[13]), 
.cin (c[13]), 
.sum (sum[13]), 
.cout(c[14]) 
); 
 
full_adder fa14 ( 
.a (A[14]), 
.b (B[14]), 
.cin (c[14]), 
.sum (sum[14]), 
.cout(c[15]) 
); 
 
full_adder fa15 ( 
.a (A[15]), 
.b (B[15]), 
.cin (c[15]), 
.sum (sum[15]), 
.cout(c[16]) 
); 
 
// MSB carry-out becomes bit[16] of result 
buf (sum[16], c[16]); 
 
endmodule