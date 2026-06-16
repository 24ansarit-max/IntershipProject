design modules needed and what does each contain? 
Q2. What gate primitives implement half adder logic (sum and cout)? 
Q3. How is full_adder built from two half_adder instances — draw the wire connections? 
Q4. How does the carry chain work across 16 full adder instances? 
Q5. Why is c[0] tied to 1'b0 and what happens if it is left floating? 
Q6. How is the 17th output bit (overflow) captured from c[16]? 
Q7. What are all 20 corner case pairs for the for loop? 
Q8. What does each loop (for, while, repeat, forever) uniquely contribute to verification? 
Q9. How do I compute expected value in the testbench for PASS/FAIL checking? 
Q10. How do I correctly declare signed regs and wires in the testbench? 
 
Write answers to Q1–Q10 as your PLAN section. 
 
--- 
 
EXECUTION PHASE — write based on your plan: 
 
Module 1: half_adder (gate primitives only) 
Module 2: full_adder (two half_adder instances + or gate, no assign) 
Module 3: adder16_struct (16 full_adder instances, wire carry chain, no assign, no always) 
Module 4: tb_adder16 testbench: 
  - for loop: 20 corner case pairs, #10 delays, PASS/FAIL display 
  - while loop: 100 iterations, $signed($random), error tracking 
  - repeat loop: 50 iterations, random inputs, display results 
  - forever loop: 5ns clock toggle, $finish at 1500ns 
 
REVIEW PHASE — after writing, verify: 
  - adder16_struct has ONLY wires and instantiations? 
  - signed on all ports? 
  - c[0] tied to 1'b0? 
  - All 16 full_adder instances (fa0–fa15) present? 
  - sum[16] = c[16]? 
  - All 4 loop types in testbench? 
  - $finish present? 
Fix any issues, then present final corrected code. 
 
Design module- 
// Half Adder 
//===================================================== 
module half_adder( 
input a, 
input b, 
output sum, 
output cout 
); 
 
xor (sum, a, b); 
and (cout, a, b); 
 
endmodule 
 
 
//===================================================== 
// Full Adder 
//===================================================== 
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
 
or (cout, c1, c2); 
 
endmodule 
 
 
//===================================================== 
// 16-Bit Structural Adder 
// STRICTLY WIRES + INSTANTIATIONS ONLY 
//===================================================== 
module adder16_struct( 
input signed [15:0] a, 
input signed [15:0] b, 
output signed [16:0] sum 
); 
 
wire [16:0] c; 
 
supply0 gnd; 
 
full_adder fa0 (.a(a[0]), .b(b[0]), .cin(c[0]), .sum(sum[0]), .cout(c[1])); 
full_adder fa1 (.a(a[1]), .b(b[1]), .cin(c[1]), .sum(sum[1]), .cout(c[2])); 
full_adder fa2 (.a(a[2]), .b(b[2]), .cin(c[2]), .sum(sum[2]), .cout(c[3])); 
full_adder fa3 (.a(a[3]), .b(b[3]), .cin(c[3]), .sum(sum[3]), .cout(c[4])); 
full_adder fa4 (.a(a[4]), .b(b[4]), .cin(c[4]), .sum(sum[4]), .cout(c[5])); 
full_adder fa5 (.a(a[5]), .b(b[5]), .cin(c[5]), .sum(sum[5]), .cout(c[6])); 
full_adder fa6 (.a(a[6]), .b(b[6]), .cin(c[6]), .sum(sum[6]), .cout(c[7])); 
full_adder fa7 (.a(a[7]), .b(b[7]), .cin(c[7]), .sum(sum[7]), .cout(c[8])); 
full_adder fa8 (.a(a[8]), .b(b[8]), .cin(c[8]), .sum(sum[8]), .cout(c[9])); 
full_adder fa9 (.a(a[9]), .b(b[9]), .cin(c[9]), .sum(sum[9]), .cout(c[10])); 
full_adder fa10 (.a(a[10]), .b(b[10]), .cin(c[10]), .sum(sum[10]), .cout(c[11])); 
full_adder fa11 (.a(a[11]), .b(b[11]), .cin(c[11]), .sum(sum[11]), .cout(c[12])); 
full_adder fa12 (.a(a[12]), .b(b[12]), .cin(c[12]), .sum(sum[12]), .cout(c[13])); 
full_adder fa13 (.a(a[13]), .b(b[13]), .cin(c[13]), .sum(sum[13]), .cout(c[14])); 
full_adder fa14 (.a(a[14]), .b(b[14]), .cin(c[14]), .sum(sum[14]), .cout(c[15])); 
full_adder fa15 (.a(a[15]), .b(b[15]), .cin(c[15]), .sum(sum[15]), .cout(c[16])); 
 
buf(sum[16], c[16]); 
 
endmodule