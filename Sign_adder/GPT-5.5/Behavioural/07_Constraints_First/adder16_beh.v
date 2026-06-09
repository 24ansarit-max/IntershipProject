DESIGN MODULE: 
      - assign statements 
      - structural module instantiation 
      - gate primitives (and, or, xor, etc.) 
      - always @(posedge clk) 
      - non-blocking assignments (<=) 
 
[C3]  ALWAYS BLOCK TYPE: Use always @(*) for combinational sensitivity. 
      This re-evaluates whenever A or B changes. 
 
[C4]  BLOCKING ASSIGNMENT: Use = inside always @(*). 
      Sequential execution order matters — compute sum before ovf. 
 
[C5]  OUTPUT REG: Declare both outputs as reg: 
      output reg signed [16:0] sum 
      output reg ovf 
      Reason: signals driven from always blocks must be reg in Verilog. 
 
[C6]  SIGN EXTENSION: Inside always block use exactly: 
      sum = $signed({A[15],A}) + $signed({B[15],B}); 
      Reason: prevents unsigned truncation, correctly handles two's complement. 
 
[C7]  OVERFLOW FLAG: Compute after sum, inside same always block: 
      ovf = sum[16] ^ sum[15]; 
      Reason: detects when extended sign bit disagrees with result sign bit. 
 
[C8]  PORT WIDTHS: 
      input  signed [15:0] A   — range -32768 to +32767 
      input  signed [15:0] B   — range -32768 to +32767 
      output reg signed [16:0] sum — 17 bits to capture signed overflow 
      output reg ovf            — 1-bit signed overflow flag 
 
[C9]  SIGNED KEYWORD: Must appear on every port, reg, and wire declaration. 
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
━━━━━ 
TESTBENCH CONSTRAINTS 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
━━━━━ 
 
[C10] FOR LOOP: Test exactly these 20 pairs in order: 
      (0,0),(1,0),(0,1),(-1,0),(0,-1),(1,1),(-1,-1),(1,-1), 
      (32767,0),(-32768,0),(32767,1),(-32768,-1), 
      (32767,32767),(-32768,-32768),(32767,-32768),(-32768,32767), 
      (16384,16384),(-16384,-16384),(32766,1),(-32767,-1) 
 
[C11] WHILE LOOP: test_count < 100. Use $signed($random) for both A and B. 
      Track error_count. Display PASS or FAIL with full values each iteration. 
 
[C12] REPEAT LOOP: Exactly 50 iterations. $signed($random) inputs. 
      Display A, B, sum, ovf every iteration. 
 
[C13] FOREVER LOOP: Toggle clk every 5ns. 
      Terminate via $finish at 2000ns in a SEPARATE initial block. 
 
[C14] PASS/FAIL: Compute expected = $signed(A) + $signed(B) in testbench. 
      Compare $signed(sum) vs expected. PASS if equal, FAIL + increment error_count if not. 
 
[C15] DISPLAY FORMAT: 
      %0d for all signed decimal values 
      %b  for ovf flag 
      Include: test number, A, B, expected, actual, ovf, status 
 
[C16] FINAL SUMMARY: 
      $display("═══ Simulation Complete. Total Errors: %0d ═══", error_count); 
 
NOW write complete Verilog satisfying ALL constraints C1 through C16. 
 
... 
Design Module: 
module adder16_beh ( 
input signed [15:0] A, 
input signed [15:0] B, 
output reg signed [16:0] sum, 
output reg signed ovf 
); 
 
always @(*) begin 
sum = $signed({A[15],A}) + $signed({B[15],B}); 
ovf = sum[16] ^ sum[15]; 
end 
 
endmodule 
 
 
...