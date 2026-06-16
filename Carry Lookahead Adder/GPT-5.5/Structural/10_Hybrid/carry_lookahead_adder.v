`timescale 1ns/1ps 
 
//==================================================== 
// Full Adder (gate-level structural) 
//==================================================== 
module full_adder_gate ( 
    input  A, 
    input  B, 
    input  Cin, 
    output Sum, 
    output Cout 
); 
 
    wire x1; 
    wire a1, a2, a3; 
 
    xor XOR1(x1, A, B); 
    xor XOR2(Sum, x1, Cin); 
 
    and AND1(a1, A, B); 
    and AND2(a2, A, Cin); 
    and AND3(a3, B, Cin); 
 
    or OR1(Cout, a1, a2, a3); 
 
endmodule 
 
 
//==================================================== 
// Generate / Propagate Unit 
//==================================================== 
module gp_unit_4bit ( 
    input  [3:0] A, 
    input  [3:0] B, 
    output [3:0] G, 
    output [3:0] P 
); 
 
    and GATE_G0(G[0], A[0], B[0]); 
    and GATE_G1(G[1], A[1], B[1]); 
    and GATE_G2(G[2], A[2], B[2]); 
    and GATE_G3(G[3], A[3], B[3]); 
 
    xor GATE_P0(P[0], A[0], B[0]); 
    xor GATE_P1(P[1], A[1], B[1]); 
    xor GATE_P2(P[2], A[2], B[2]); 
    xor GATE_P3(P[3], A[3], B[3]); 
 
endmodule 
 
 
//==================================================== 
// Carry Lookahead Logic (4-bit) 
//==================================================== 
module cla_logic_4bit ( 
    input  [3:0] G, 
    input  [3:0] P , 
    input        Cin, 
 
    output C1, 
    output C2, 
    output C3, 
    output C4 
); 
 
    wire t10; 
 
    wire t20, t21; 
 
    wire t30, t31, t32; 
 
    wire t40, t41, t42, t43; 
 
    and A10(t10, P[0], Cin); 
    or  O10(C1, G[0], t10); 
 
    and A20(t20, P[1], G[0]); 
    and A21(t21, P[1], P[0], Cin); 
    or  O20(C2, G[1], t20, t21); 
 
    and A30(t30, P[2], G[1]); 
    and A31(t31, P[2], P[1], G[0]); 
    and A32(t32, P[2], P[1], P[0], Cin); 
    or  O30(C3, G[2], t30, t31, t32); 
 
    and A40(t40, P[3], G[2]); 
    and A41(t41, P[3], P[2], G[1]); 
    and A42(t42, P[3], P[2], P[1], G[0]); 
    and A43(t43, P[3], P[2], P[1], P[0], Cin); 
 
    or O40(C4, G[3], t40, t41, t42, t43); 
 
endmodule 
 
 
//==================================================== 
// 4-bit CLA Block 
//==================================================== 
module cla4_structural ( 
    input  [3:0] A, 
    input  [3:0] B, 
    input        Cin, 
 
    output [3:0] Sum, 
    output       Cout 
); 
 
    wire [3:0] G; 
    wire [3:0] P; 
 
    wire C1; 
    wire C2; 
    wire C3; 
    wire C4; 
 
    wire FA_COUT0; 
    wire FA_COUT1; 
    wire FA_COUT2; 
    wire FA_COUT3; 
 
    gp_unit_4bit GP_UNIT ( 
        .A(A), 
        .B(B), 
        .G(G), 
        .P(P) 
    ); 
 
    cla_logic_4bit CLA_LOGIC ( 
        .G(G), 
        .P(P), 
        .Cin(Cin), 
        .C1(C1), 
        .C2(C2), 
        .C3(C3), 
        .C4(C4) 
    ); 
 
    full_adder_gate FA0 ( 
        .A(A[0]), 
        .B(B[0]), 
        .Cin(Cin), 
        .Sum(Sum[0]), 
        .Cout(FA_COUT0) 
    ); 
 
    full_adder_gate FA1 ( 
        .A(A[1]), 
        .B(B[1]), 
        .Cin(C1), 
        .Sum(Sum[1]), 
        .Cout(FA_COUT1) 
    ); 
 
    full_adder_gate FA2 ( 
        .A(A[2]), 
        .B(B[2]), 
        .Cin(C2), 
        .Sum(Sum[2]), 
        .Cout(FA_COUT2) 
    ); 
 
    full_adder_gate FA3 ( 
        .A(A[3]), 
        .B(B[3]), 
        .Cin(C3), 
        .Sum(Sum[3]), 
        .Cout(FA_COUT3) 
    ); 
 
    buf BUF_COUT(Cout, C4); 
 
endmodule 
 
 
//==================================================== 
// Top-Level 16-bit CLA 
//==================================================== 
module cla16_structural ( 
    input  [15:0] A, 
    input  [15:0] B, 
    input         Cin, 
 
    output [15:0] Sum, 
    output        Cout 
); 
 
    wire C4; 
    wire C8; 
    wire C12; 
    wire C16; 
 
    cla4_structural CLA_block0 ( 
        .A(A[3:0]), 
        .B(B[3:0]), 
        .Cin(Cin), 
        .Sum(Sum[3:0]), 
        .Cout(C4) 
    ); 
 
    cla4_structural CLA_block1 ( 
        .A(A[7:4]), 
        .B(B[7:4]), 
        .Cin(C4), 
        .Sum(Sum[7:4]), 
        .Cout(C8) 
    ); 
 
    cla4_structural CLA_block2 ( 
        .A(A[11:8]), 
        .B(B[11:8]), 
        .Cin(C8), 
        .Sum(Sum[11:8]), 
        .Cout(C12) 
    ); 
 
    cla4_structural CLA_block3 ( 
        .A(A[15:12]), 
        .B(B[15:12]), 
        .Cin(C12), 
        .Sum(Sum[15:12]), 
        .Cout(C16) 
    ); 
 
    buf BUF_FINAL(Cout, C16); 
 
endmodule
