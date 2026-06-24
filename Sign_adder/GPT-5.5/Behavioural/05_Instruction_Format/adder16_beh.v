design module must contain ONLY always @(*) blocks with blocking assignments (=). 
No assign statements. No structural instantiation. No gate primitives. 
No always @(posedge clk) in the design module. 
Every output driven by an always block MUST be declared as output reg. 
 
DELIVER IN EXACTLY THIS FORMAT: 
 
═══════════════════════════════════════ 
SECTION 1: BEHAVIORAL DESIGN MODULE 
═══════════════════════════════════════ 
Module name   : adder16_beh 
Ports         : 
  input  signed [15:0] A 
  input  signed [15:0] B 
  output reg signed [16:0] sum 
  output reg ovf 
Logic         : always @(*) ONLY — blocking assignments ONLY 
Key statements: 
  sum = $signed({A[15],A}) + $signed({B[15],B}); 
  ovf = sum[16] ^ sum[15]; 
Forbidden     : assign, structural, gate primitives, <=, always @(posedge clk) 
[Write complete Verilog module here] 
 
═══════════════════════════════════════ 
SECTION 2: TESTBENCH 
═══════════════════════════════════════ 
Module name   : tb_adder16 
DUT instance  : adder16_beh dut(.A(A),.B(B),.sum(sum),.ovf(ovf)); 
Declarations  : 
  reg  signed [15:0] A, B 
  wire signed [16:0] sum 
  wire ovf 
  integer i, test_count, error_count 
  reg signed [16:0] expected 
 
--- FOR LOOP --- 
Iterate over exactly 20 pairs: 
(0,0),(1,0),(0,1),(-1,0),(0,-1),(1,1),(-1,-1),(1,-1), 
(32767,0),(-32768,0),(32767,1),(-32768,-1), 
(32767,32767),(-32768,-32768),(32767,-32768),(-32768,32767), 
(16384,16384),(-16384,-16384),(32766,1),(-32767,-1) 
Action per iteration: 
  Apply A,B → wait #10 
  expected = $signed(A) + $signed(B) 
  if match: PASS display with test#, A, B, expected, got, ovf 
  if mismatch: FAIL display + increment error_count 
 
--- WHILE LOOP --- 
  test_count = 0; 
  while (test_count < 100) begin 
    A=$signed($random); B=$signed($random); #10; 
    expected=$signed(A)+$signed(B); 
    // Compare, display PASS/FAIL, track error_count 
    test_count=test_count+1; 
  end 
 
--- REPEAT LOOP --- 
  repeat(50) begin 
    A=$signed($random); B=$signed($random); #10; 
    $display("REPEAT A=%0d B=%0d sum=%0d ovf=%b", 
              $signed(A),$signed(B),$signed(sum),ovf); 
  end 
 
--- FOREVER LOOP --- 
  reg clk=0; 
  initial forever #5 clk=~clk; 
  initial #2000 $finish; 
 
--- END --- 
  $display("Simulation done. Errors: %0d", error_count); 
  $finish; 
 
... 
Design Module: 
module adder16_beh( 
    input  signed [15:0] A, 
    input  signed [15:0] B, 
    output reg signed [16:0] sum, 
    output reg ovf 
); 
 
always @(*) begin 
    sum = $signed({A[15], A}) + $signed({B[15], B}); 
    ovf = sum[16] ^ sum[15]; 
end 
 
endmodule 
 
...