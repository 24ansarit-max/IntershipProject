design module must use ONLY assign statements (dataflow modeling).
No always blocks, no structural instantiation, no gate primitives anywhere in the design.

PLANNING PHASE — answer each question:

Q1. What is the module name and exact port signature?
Q2. How does dataflow modeling work — what is the only construct allowed?
Q3. How do I sign-extend a 16-bit signed value to 17 bits using concatenation?
Q4. Why is {A[15], A} + {B[15], B} the correct dataflow expression for signed addition?
Q5. What are ALL 20 corner case input pairs I will test in the for loop?
Q6. What does each loop (for, while, repeat, forever) uniquely contribute to coverage?
Q7. How do I compute expected result inside the testbench for PASS/FAIL checking?
Q8. How do I ensure $signed() is applied correctly in the testbench?

Write answers to Q1–Q8 as your PLAN section.

---

EXECUTION PHASE — write based on your plan:

Module 1: adder16_df
  - ONLY assign statements
  - assign sum = {A[15], A} + {B[15], B};

Module 2: tb_adder16 testbench containing:
  - for loop with 20 corner case pairs, #10 delays, PASS/FAIL display
  - while loop 100 iterations with $signed($random), error tracking
  - repeat loop 50 iterations with random inputs and display
  - forever loop with 5ns clock toggle, $finish at 1500ns

REVIEW PHASE — after writing, verify:
  - Is assign the only statement in adder16_df?
  - Is signed on all declarations?
  - Is output 17 bits?
  - Are all 4 loop types present?
  - Is $finish present?
Fix any issues found, then present the final corrected code.
Design module-
module adder16_df (input signed [15:0] A,input signed [15:0] B,output signed [16:0] sum);assign sum = {A[15], A} + {B[15], B};endmodule
Testbench-
`timescale 1ns/1psmodule tb_adder16;reg signed [15:0] A;reg signed [15:0] B;wire signed [16:0] sum;reg signed clk;integer test_count;integer error_count;integer i;reg signed [16:0] expected;reg signed [15:0] testA [0:19];reg signed [15:0] testB [0:19];// DUTadder16_df dut (.A(A),.B(B),.sum(sum));//==========================================================// FOREVER LOOP//==========================================================initial beginclk = 0;forever #5 clk = ~clk;end//==========================================================// TERMINATION BLOCK//==========================================================initial begin#2000;$finish;end//==========================================================// MAIN TEST PROCESS//==========================================================initial beginerror_count = 0;// Required 20 pairs in exact ordertestA[0] = 0; testB[0] = 0;testA[1] = 1; testB[1] = 0;testA[2] = 0; testB[2] = 1;testA[3] = -1; testB[3] = 0;testA[4] = 0; testB[4] = -1;testA[5] = 1; testB[5] = 1;testA[6] = -1; testB[6] = -1;testA[7] = 1; testB[7] = -1;testA[8] = 32767; testB[8] = 0;testA[9] = -32768; testB[9] = 0;testA[10] = 32767; testB[10] = 1;testA[11] = -32768; testB[11] = -1;testA[12] = 32767; testB[12] = 32767;testA[13] = -32768; testB[13] = -32768;testA[14] = 32767; testB[14] = -32768;testA[15] = -32768; testB[15] = 32767;testA[16] = 16384; testB[16] = 16384;testA[17] = -16384; testB[17] = -16384;testA[18] = 32766; testB[18] = 1;testA[19] = -32767; testB[19] = -1;//======================================================// FOR LOOP//======================================================for (i = 0; i < 20; i = i + 1) beginA = testA[i];B = testB[i];#10;expected = $signed(A) + $signed(B);if (sum === expected)$display("FOR TEST=%0d A=%0d B=%0d EXPECTED=%0d ACTUAL=%0d STATUS=PASS",i, A, B, expected, sum);else begin$display("FOR TEST=%0d A=%0d B=%0d EXPECTED=%0d ACTUAL=%0d STATUS=FAIL",i, A, B, expected, sum);error_count = error_count + 1;endend//======================================================// WHILE LOOP//======================================================test_count = 0;while (test_count < 100) beginA = $signed($random);B = $signed($random);#10;expected = $signed(A) + $signed(B);if (sum === expected)$display("WHILE TEST=%0d A=%0d B=%0d EXPECTED=%0d ACTUAL=%0d STATUS=PASS",test_count, A, B, expected, sum);else begin$display("WHILE TEST=%0d A=%0d B=%0d EXPECTED=%0d ACTUAL=%0d STATUS=MISMATCH",test_count, A, B, expected, sum);error_count = error_count + 1;endtest_count = test_count + 1;end//======================================================// REPEAT LOOP//======================================================test_count = 0;repeat (50) beginA = $signed($random);B = $signed($random);#10;expected = $signed(A) + $signed(B);if (sum === expected)$display("REPEAT TEST=%0d A=%0d B=%0d EXPECTED=%0d ACTUAL=%0d STATUS=PASS",test_count, A, B, expected, sum);else begin$display("REPEAT TEST=%0d A=%0d B=%0d EXPECTED=%0d ACTUAL=%0d STATUS=FAIL",test_count, A, B, expected, sum);error_count = error_count + 1;endtest_count = test_count + 1;end$display("TOTAL_ERRORS=%0d", error_count);endendmodule
8. Self-Planning Prompt
Prompt-
Before writing any Verilog code, create a plan and then execute it.
STRICT RULE: The design module must use ONLY assign statements (dataflow modeling).
No always blocks, no structural instantiation, no gate primitives anywhere in the design.

PLANNING PHASE — answer each question:

Q1. What is the module name and exact port signature?
Q2. How does dataflow modeling work — what is the only construct allowed?
Q3. How do I sign-extend a 16-bit signed value to 17 bits using concatenation?
Q4. Why is {A[15], A} + {B[15], B} the correct dataflow expression for signed addition?
Q5. What are ALL 20 corner case input pairs I will test in the for loop?
Q6. What does each loop (for, while, repeat, forever) uniquely contribute to coverage?
Q7. How do I compute expected result inside the testbench for PASS/FAIL checking?
Q8. How do I ensure $signed() is applied correctly in the testbench?

Write answers to Q1–Q8 as your PLAN section.

---

EXECUTION PHASE — write based on your plan:

Module 1: adder16_df
  - ONLY assign statements
  - assign sum = {A[15], A} + {B[15], B};

Module 2: tb_adder16 testbench containing:
  - for loop with 20 corner case pairs, #10 delays, PASS/FAIL display
  - while loop 100 iterations with $signed($random), error tracking
  - repeat loop 50 iterations with random inputs and display
  - forever loop with 5ns clock toggle, $finish at 1500ns

REVIEW PHASE — after writing, verify:
  - Is assign the only statement in adder16_df?
  - Is signed on all declarations?
  - Is output 17 bits?
  - Are all 4 loop types present?
  - Is $finish present?
Fix any issues found, then present the final corrected code.
Design module-
module adder16_df (input signed [15:0] A,input signed [15:0] B,output signed [16:0] sum);assign sum = {A[15], A} + {B[15], B};endmodule
Testbench-
`timescale 1ns/1psmodule tb_adder16;reg signed [15:0] A;reg signed [15:0] B;wire signed [16:0] sum;reg signed clk;integer test_count;integer error_count;integer i;reg signed [16:0] expected;reg signed [15:0] testA [0:19];reg signed [15:0] testB [0:19];adder16_df dut (.A(A),.B(B),.sum(sum));//==========================================================// FOREVER LOOP//==========================================================initial beginclk = 0;forever #5 clk = ~clk;end//==========================================================// TERMINATION//==========================================================initial begin#1500;$finish;endinitial beginerror_count = 0;testA[0]=0; testB[0]=0;testA[1]=1; testB[1]=0;testA[2]=0; testB[2]=1;testA[3]=-1; testB[3]=0;testA[4]=0; testB[4]=-1;testA[5]=1; testB[5]=1;testA[6]=-1; testB[6]=-1;testA[7]=1; testB[7]=-1;testA[8]=32767; testB[8]=0;testA[9]=-32768; testB[9]=0;testA[10]=32767; testB[10]=1;testA[11]=-32768; testB[11]=-1;testA[12]=32767; testB[12]=32767;testA[13]=-32768; testB[13]=-32768;testA[14]=32767; testB[14]=-32768;testA[15]=-32768; testB[15]=32767;testA[16]=16384; testB[16]=16384;testA[17]=-16384; testB[17]=-16384;testA[18]=32766; testB[18]=1;testA[19]=-32767; testB[19]=-1;//======================================================// FOR LOOP//======================================================for (i = 0; i < 20; i = i + 1) beginA = testA[i];B = testB[i];#10;expected = $signed(A) + $signed(B);if (sum === expected)$display("FOR TEST=%0d A=%0d B=%0d EXPECTED=%0d ACTUAL=%0d PASS",i, A, B, expected, sum);else begin$display("FOR TEST=%0d A=%0d B=%0d EXPECTED=%0d ACTUAL=%0d FAIL",i, A, B, expected, sum);error_count = error_count + 1;endend//======================================================// WHILE LOOP//======================================================test_count = 0;while (test_count < 100) beginA = $signed($random);B = $signed($random);#10;expected = $signed(A) + $signed(B);if (sum === expected)$display("WHILE TEST=%0d A=%0d B=%0d EXPECTED=%0d ACTUAL=%0d PASS",test_count, A, B, expected, sum);else begin$display("WHILE TEST=%0d A=%0d B=%0d EXPECTED=%0d ACTUAL=%0d MISMATCH",test_count, A, B, expected, sum);error_count = error_count + 1;endtest_count = test_count + 1;end//======================================================// REPEAT LOOP//======================================================test_count = 0;repeat (50) beginA = $signed($random);B = $signed($random);#10;expected = $signed(A) + $signed(B);if (sum === expected)$display("REPEAT TEST=%0d A=%0d B=%0d EXPECTED=%0d ACTUAL=%0d PASS",test_count, A, B, expected, sum);else begin$display("REPEAT TEST=%0d A=%0d B=%0d EXPECTED=%0d ACTUAL=%0d FAIL",test_count, A, B, expected, sum);error_count = error_count + 1;endtest_count = test_count + 1;end$display("TOTAL_ERRORS=%0d", error_count);endendmodule