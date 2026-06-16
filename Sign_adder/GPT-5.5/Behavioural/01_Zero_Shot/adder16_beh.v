design module must contain ONLY always @(*) procedural blocks with  
blocking assignments (=). No assign statements, no structural instantiation,  
no gate primitives, no module instantiation of any kind is allowed inside  
the design module. All outputs driven from always blocks MUST be declared as reg. 
 
DESIGN MODULE REQUIREMENTS: 
- Module name: adder16_beh 
- input  signed [15:0] A 
- input  signed [15:0] B 
- output reg signed [16:0] sum 
- output reg ovf 
- Inside always @(*): 
    sum = $signed({A[15],A}) + $signed({B[15],B}); 
    ovf = sum[16] ^ sum[15]; 
 
TESTBENCH REQUIREMENTS: 
Write tb_adder16 that instantiates adder16_beh and tests it using  
ALL FOUR loop types: 
 
FOR LOOP — iterate over these 20 corner case pairs (A,B): 
  (0,0),(1,0),(0,1),(-1,0),(0,-1), 
  (1,1),(-1,-1),(1,-1), 
  (32767,0),(-32768,0), 
  (32767,1),(-32768,-1), 
  (32767,32767),(-32768,-32768), 
  (32767,-32768),(-32768,32767), 
  (16384,16384),(-16384,-16384), 
  (32766,1),(-32767,-1) 
  Per iteration: apply A,B → #10 → compute expected=$signed(A)+$signed(B) 
  → compare $signed(sum) → print PASS or FAIL with all values 
 
WHILE LOOP: 
  Run while test_count < 100 
  A = $signed($random); B = $signed($random); #10; 
  Compare result, track error_count, print PASS or FAIL each iteration 
 
REPEAT LOOP: 
  Repeat 50 times 
  A = $signed($random); B = $signed($random); #10; 
  $display A, B, sum, ovf each iteration 
 
FOREVER LOOP: 
  reg clk = 0; 
  Toggle clk every 5ns 
  Terminate with $finish at 1000ns in a separate initial block 
 
Print final error summary before $finish. 
Use %0d for signed decimal and %b for binary flags in all $display calls. 
 
... 
Design Module: 
`timescale 1ns/1ps 
 
//==================================================== 
// 16-bit Signed Adder (Behavioral Modeling Only) 
//==================================================== 
module adder16_beh( 
input signed [15:0] A, 
input signed [15:0] B, 
output reg signed [16:0] sum, 
output reg ovf 
); 
 
always @(*) begin 
sum = $signed({A[15],A}) + $signed({B[15],B}); 
ovf = sum[16] ^ sum[15]; 
end 
 
endmodule  
...