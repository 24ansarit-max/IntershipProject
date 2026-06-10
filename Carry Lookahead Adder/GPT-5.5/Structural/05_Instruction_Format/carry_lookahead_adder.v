`timescale 1ns/1ps 
 
//---------------------------------------------------- 
// Module : pg_cell 
// Purpose: Compute single-bit generate and propagate. 
// Inputs : a, b 
// Outputs: G, P 
// Power  : ~2 gate toggles estimate 
// Area   : ~2 gate equivalent count 
// Delay  : ~1 critical path gate level 
//---------------------------------------------------- 
module pg_cell ( 
  input  wire a, 
  input  wire b, 
  output wire G, 
  output wire P 
); 
 
  assign G = a & b; 
  assign P = a ^ b; 
 
endmodule 
 
 
//---------------------------------------------------- 
// Module : carry_logic_4 
// Purpose: Compute 4-bit carry lookahead signals. 
// Inputs : G[3:0], P[3:0], cin 
// Outputs: C[4:1] 
// Power  : Moderate carry network activity 
// Area   : ~20 gate equivalent count 
// Delay  : ~3 critical path gate levels 
//---------------------------------------------------- 
module carry_logic_4 ( 
  input  wire [3:0] G, 
  input  wire [3:0] P , 
  input  wire       cin, 
  output wire [4:1] C 
); 
 
  assign C[1] = 
      G[0] | 
      (P[0] & cin); 
 
  assign C[2] = 
      G[1] | 
      (P[1] & G[0]) | 
      (P[1] & P[0] & cin); 
 
  assign C[3] = 
      G[2] | 
      (P[2] & G[1]) | 
      (P[2] & P[1] & G[0]) | 
      (P[2] & P[1] & P[0] & cin); 
 
  assign C[4] = 
      G[3] | 
      (P[3] & G[2]) | 
      (P[3] & P[2] & G[1]) | 
      (P[3] & P[2] & P[1] & G[0]) | 
      (P[3] & P[2] & P[1] & P[0] & cin); 
 
endmodule 
 
 
//---------------------------------------------------- 
// Module : sum_logic_4 
// Purpose: Compute 4-bit sum outputs. 
// Inputs : P[3:0], C[4:1], cin 
// Outputs: sum[3:0] 
// Power  : XOR switching dominates 
// Area   : ~4 gate equivalent count 
// Delay  : ~1 critical path gate level 
//---------------------------------------------------- 
module sum_logic_4 ( 
  input  wire [3:0] P , 
  input  wire [4:1] C, 
  input  wire       cin, 
  output wire [3:0] sum 
); 
 
  assign sum[0] = P[0] ^ cin; 
  assign sum[1] = P[1] ^ C[1]; 
  assign sum[2] = P[2] ^ C[2]; 
  assign sum[3] = P[3] ^ C[3]; 
 
endmodule 
 
 
//---------------------------------------------------- 
// Module : group_pg 
// Purpose: Compute group generate and propagate. 
// Inputs : G[3:0], P[3:0], cin 
// Outputs: GG, GP 
// Power  : Low-to-moderate toggle activity 
// Area   : ~10 gate equivalent count 
// Delay  : ~2 critical path gate levels 
//---------------------------------------------------- 
module group_pg ( 
  input  wire [3:0] G, 
  input  wire [3:0] P , 
  input  wire       cin, 
  output wire       GG, 
  output wire       GP 
); 
 
  assign GP = 
      P[3] & 
      P[2] & 
      P[1] & 
      P[0]; 
 
  assign GG = 
      G[3] | 
      (P[3] & G[2]) | 
      (P[3] & P[2] & G[1]) | 
      (P[3] & P[2] & P[1] & G[0]); 
 
endmodule 
 
 
//---------------------------------------------------- 
// Module : cla_16bit_structural 
// Purpose: Hierarchical 16-bit Carry Lookahead Adder. 
// Inputs : a[15:0], b[15:0], cin 
// Outputs: sum[15:0], cout, overflow 
// Power  : Higher than RCA due to parallel carry logic 
// Area   : ~150 gate equivalent count 
// Delay  : ~5 critical path gate levels 
//---------------------------------------------------- 
module cla_16bit_structural ( 
  input  wire [15:0] a, 
  input  wire [15:0] b, 
  input  wire        cin, 
  output wire [15:0] sum, 
  output wire        cout, 
  output wire        overflow 
); 
 
  wire [15:0] G; 
  wire [15:0] P; 
 
  wire [4:1] C0; 
  wire [4:1] C1; 
  wire [4:1] C2; 
  wire [4:1] C3; 
 
  wire GG0, GG1, GG2, GG3; 
  wire GP0, GP1, GP2, GP3; 
 
  wire C4; 
  wire C8; 
  wire C12; 
  wire C16; 
 
  genvar i; 
 
  generate 
    for(i=0;i<16;i=i+1) 
    begin : PG_GEN 
      pg_cell PG( 
        .a(a[i]), 
        .b(b[i]), 
        .G(G[i]), 
        .P(P[i]) 
      ); 
    end 
  endgenerate 
 
  group_pg GPG0(.G(G[3:0]),   .P(P[3:0]),   .cin(cin), .GG(GG0), .GP(GP0)); 
  group_pg GPG1(.G(G[7:4]),   .P(P[7:4]),   .cin(C4),  .GG(GG1), .GP(GP1)); 
  group_pg GPG2(.G(G[11:8]),  .P(P[11:8]),  .cin(C8),  .GG(GG2), .GP(GP2)); 
  group_pg GPG3(.G(G[15:12]), .P(P[15:12]), .cin(C12), .GG(GG3), .GP(GP3)); 
 
  assign C4 = 
      GG0 | 
      (GP0 & cin); 
 
  assign C8 = 
      GG1 | 
      (GP1 & GG0) | 
      (GP1 & GP0 & cin); 
 
  assign C12 = 
      GG2 | 
      (GP2 & GG1) | 
      (GP2 & GP1 & GG0) | 
      (GP2 & GP1 & GP0 & cin); 
 
  assign C16 = 
      GG3 | 
      (GP3 & GG2) | 
      (GP3 & GP2 & GG1) | 
      (GP3 & GP2 & GP1 & GG0) | 
      (GP3 & GP2 & GP1 & GP0 & cin); 
 
  carry_logic_4 CLA0(.G(G[3:0]),   .P(P[3:0]),   .cin(cin), .C(C0)); 
  carry_logic_4 CLA1(.G(G[7:4]),   .P(P[7:4]),   .cin(C4),  .C(C1)); 
  carry_logic_4 CLA2(.G(G[11:8]),  .P(P[11:8]),  .cin(C8),  .C(C2)); 
  carry_logic_4 CLA3(.G(G[15:12]), .P(P[15:12]), .cin(C12), .C(C3)); 
 
  sum_logic_4 SUM0(.P(P[3:0]),   .C(C0), .cin(cin), .sum(sum[3:0])); 
  sum_logic_4 SUM1(.P(P[7:4]),   .C(C1), .cin(C4),  .sum(sum[7:4])); 
  sum_logic_4 SUM2(.P(P[11:8]),  .C(C2), .cin(C8),  .sum(sum[11:8])); 
  sum_logic_4 SUM3(.P(P[15:12]), .C(C3), .cin(C12), .sum(sum[15:12])); 
 
  assign cout = C16; 
 
  assign overflow = C3[4] ^ C16; 
 
endmodule
