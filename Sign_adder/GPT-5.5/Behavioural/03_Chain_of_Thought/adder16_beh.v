design module must use ONLY always @(*) with blocking assignments. 
No assign, no structural instantiation, no gate primitives anywhere in the design. 
All outputs driven from always blocks must be declared as output reg. 
 
STEP 1 — UNDERSTAND BEHAVIORAL MODELING: 
Think: What does behavioral modeling mean in Verilog? 
It describes WHAT a circuit does using procedural always blocks, not HOW it is  
physically built. always @(*) automatically includes all inputs in the sensitivity  
list and re-evaluates whenever any input changes — correct for combinational logic. 
Why not assign? assign only allows a single continuous expression. always @(*)  
allows if/else, case, multiple statements, local variable computation — far more  
expressive for describing behavior. 
 
STEP 2 — UNDERSTAND REG VS WIRE: 
Think: Why must sum and ovf be declared as reg? 
In Verilog, any signal assigned inside a procedural block (always, initial) must be  
declared as reg. Wire is only for signals driven by assign or module output ports. 
If sum is declared as wire and driven from always, the simulator will throw an error. 
 
STEP 3 — UNDERSTAND BLOCKING VS NON-BLOCKING: 
Think: What is the difference between = and <=? 
Blocking (=): executes immediately in sequence — correct for combinational always @(*) 
Non-blocking (<=): schedules update at end of time step — correct for clocked always 
@(posedge clk) 
For a combinational adder, ALWAYS use blocking (=) inside always @(*). 
 
STEP 4 — UNDERSTAND SIGN EXTENSION: 
Think: Why use $signed({A[15],A}) instead of just A? 
A is 16 bits. The sum output is 17 bits. Simply writing A + B would do unsigned  
16-bit addition. We need to sign-extend A and B to 17 bits first. 
{A[15],A} concatenates the sign bit MSB with A making a 17-bit value. 
$signed() tells Verilog to treat this 17-bit value as signed. 
Result: $signed({A[15],A}) + $signed({B[15],B}) gives correct 17-bit signed sum. 
 
STEP 5 — UNDERSTAND OVERFLOW DETECTION: 
Think: How does ovf = sum[16] ^ sum[15] detect signed overflow? 
sum[16] is the extended sign bit (carry into sign position). 
sum[15] is the actual result sign bit. 
If they differ, overflow occurred — two positives gave negative or vice versa. 
Example: 32767 + 1 = 32768 → in 17-bit binary sum[16]=0, sum[15]=1 → XOR=1 → 
overflow. 
 
STEP 6 — WRITE THE BEHAVIORAL MODULE: 
Write adder16_beh with: 
  - input signed [15:0] A, B 
  - output reg signed [16:0] sum 
  - output reg ovf 
  - always @(*) begin 
      sum = $signed({A[15],A}) + $signed({B[15],B}); 
      ovf = sum[16] ^ sum[15]; 
    end 
 
STEP 7 — WRITE THE TESTBENCH: 
Think through all corner cases: 0+0, max+0, max+1 (overflow), min+(-1) (overflow), 
max+max, min+min, max+min, -1+1, random positives, random negatives, mixed signs. 
 
Write tb_adder16 with: 
  - for loop:    20 corner case pairs, #10 delay, PASS/FAIL per iteration 
  - while loop:  100 random iterations, error_count tracking 
  - repeat loop: 50 random iterations, display A, B, sum, ovf 
  - forever loop: clk every 5ns, $finish at 1000ns 
 
STEP 8 — VERIFY: 
Check: Only always @(*) in design? sum and ovf are reg? signed on all declarations? 
17-bit output? Blocking assignments used? All 4 loops present? $finish present? 
Fix all issues before outputting final code. 
 
... 
Design Module: 
//===================================================== 
// 16-bit Signed Behavioral Adder 
//===================================================== 
module adder16_beh( 
input signed [15:0] A, 
input signed [15:0] B, 
output reg signed [16:0] sum, 
output reg ovf 
); 
 
always @(*) begin 
sum = $signed({A[15], A}) + $signed({B[15], B}); 
ovf = sum[16] ^ sum[15]; 
end 
 
endmodule  
...