design modules must use ONLY always @(*) with blocking assignments (=). 
NO assign statements. NO structural instantiation. NO gate primitives. 
NO always @(posedge clk) in design modules. 
All outputs driven from always blocks must be declared as output reg. 
 
EXAMPLE 1 — 4-bit behavioral adder: 
module adder4_beh( 
  input  signed [3:0]  A, B, 
  output reg signed [4:0] sum 
); 
  always @(*) begin 
    sum = $signed({A[3],A}) + $signed({B[3],B}); 
  end 
endmodule 
 
EXAMPLE 2 — 8-bit behavioral adder with overflow flag: 
module adder8_beh( 
  input  signed [7:0]  A, B, 
  output reg signed [8:0] sum, 
  output reg ovf 
); 
  always @(*) begin 
    sum = $signed({A[7],A}) + $signed({B[7],B}); 
    ovf = sum[8] ^ sum[7]; 
  end 
endmodule 
 
EXAMPLE 3 — Behavioral adder with conditional logic inside always: 
module adder8_cond( 
  input  signed [7:0]  A, B, 
  output reg signed [8:0] sum, 
  output reg ovf, 
  output reg zero_flag 
); 
  always @(*) begin 
    sum       = $signed({A[7],A}) + $signed({B[7],B}); 
    ovf       = sum[8] ^ sum[7]; 
    zero_flag = (sum == 9'b0) ? 1'b1 : 1'b0; 
  end 
endmodule 
 
EXAMPLE 4 — Testbench for loop pattern: 
initial begin 
  for (i = 0; i < 8; i = i + 1) begin 
    A = i; B = ~i + 1; #10; 
    $display("A=%0d B=%0d Sum=%0d", $signed(A), $signed(B), $signed(sum)); 
  end 
end 
 
NOW DO THE FOLLOWING: 
1. Scale EXAMPLE 2 to a 16-bit signed behavioral adder (adder16_beh): 
   - always @(*) only — no assign, no structural code 
   - sum = $signed({A[15],A}) + $signed({B[15],B}); 
   - ovf = sum[16] ^ sum[15]; 
   - Add zero_flag = (sum == 17'b0) from EXAMPLE 3 
   - All outputs declared as output reg 
 
2. Build testbench from EXAMPLE 4 with ALL four loop types: 
   - for loop:    20 corner case pairs with PASS/FAIL check 
   - while loop:  100 iterations with $signed($random), error tracking 
   - repeat loop: 50 iterations with $signed($random), display results 
   - forever loop: clk toggle every 5ns, $finish at 1000ns 
   PASS/FAIL check in every loop. Display A, B, sum, ovf, zero_flag each time. 
 
... 
Design Module: 
//====================================================== 
// 16-bit Signed Behavioral Adder 
//====================================================== 
module adder16_beh( 
input signed [15:0] A, 
input signed [15:0] B, 
output reg signed [16:0] sum, 
output reg ovf, 
output reg zero_flag 
); 
 
always @(*) begin 
sum = $signed({A[15],A}) + $signed({B[15],B}); 
ovf = sum[16] ^ sum[15]; 
zero_flag = (sum == 17'b0) ? 1'b1 : 1'b0; 
end 
 
endmodule 
 
 
...