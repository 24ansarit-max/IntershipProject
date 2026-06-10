`timescale 1ns/1ps 
 
//==================================================== 
// 4-Bit Carry Lookahead Adder (Dataflow) 
//==================================================== 
module cla4_dataflow ( 
    input  [3:0] A, 
    input  [3:0] B, 
    input        Cin, 
 
    output [3:0] Sum, 
    output       Cout 
); 
 
    //------------------------------------------------ 
    // Propagate and Generate 
    //------------------------------------------------ 
    wire P0, P1, P2, P3; 
    wire G0, G1, G2, G3; 
 
    assign P0 = A[0] ^ B[0]; 
    assign P1 = A[1] ^ B[1]; 
    assign P2 = A[2] ^ B[2]; 
    assign P3 = A[3] ^ B[3]; 
 
    assign G0 = A[0] & B[0]; 
    assign G1 = A[1] & B[1]; 
    assign G2 = A[2] & B[2]; 
    assign G3 = A[3] & B[3]; 
 
    //------------------------------------------------ 
    // Carry Signals 
    //------------------------------------------------ 
    wire C1, C2, C3, C4; 
 
    assign C1 = G0 | 
                (P0 & Cin); 
 
    assign C2 = G1 | 
                (P1 & G0) | 
                (P1 & P0 & Cin); 
 
    assign C3 = G2 | 
                (P2 & G1) | 
                (P2 & P1 & G0) | 
                (P2 & P1 & P0 & Cin); 
 
    assign C4 = G3 | 
                (P3 & G2) | 
                (P3 & P2 & G1) | 
                (P3 & P2 & P1 & G0) | 
                (P3 & P2 & P1 & P0 & Cin); 
 
    //------------------------------------------------ 
    // Sum 
    //------------------------------------------------ 
    assign Sum[0] = P0 ^ Cin; 
    assign Sum[1] = P1 ^ C1; 
    assign Sum[2] = P2 ^ C2; 
    assign Sum[3] = P3 ^ C3; 
 
    assign Cout = C4; 
 
endmodule 
 
 
//==================================================== 
// 16-Bit CLA Using Four 4-Bit CLA Blocks 
//==================================================== 
module cla16_dataflow ( 
    input  [15:0] A, 
    input  [15:0] B, 
    input         Cin, 
 
    output [15:0] Sum, 
    output        Cout 
); 
 
    //------------------------------------------------ 
    // Inter-block Carry Wires 
    //------------------------------------------------ 
    wire C4; 
    wire C8; 
    wire C12; 
    wire C16; 
 
    //------------------------------------------------ 
    // CLA Block 0 
    //------------------------------------------------ 
    cla4_dataflow CLA_block0 ( 
        .A   (A[3:0]), 
        .B   (B[3:0]), 
        .Cin (Cin), 
        .Sum (Sum[3:0]), 
        .Cout(C4) 
    ); 
 
    //------------------------------------------------ 
    // CLA Block 1 
    //------------------------------------------------ 
    cla4_dataflow CLA_block1 ( 
        .A   (A[7:4]), 
        .B   (B[7:4]), 
        .Cin (C4), 
        .Sum (Sum[7:4]), 
        .Cout(C8) 
    ); 
 
    //------------------------------------------------ 
    // CLA Block 2 
    //------------------------------------------------ 
    cla4_dataflow CLA_block2 ( 
        .A   (A[11:8]), 
        .B   (B[11:8]), 
        .Cin (C8), 
        .Sum (Sum[11:8]), 
        .Cout(C12) 
    ); 
 
    //------------------------------------------------ 
    // CLA Block 3 
    //------------------------------------------------ 
    cla4_dataflow CLA_block3 ( 
        .A   (A[15:12]), 
        .B   (B[15:12]), 
        .Cin (C12), 
        .Sum (Sum[15:12]), 
        .Cout(C16) 
    ); 
 
    assign Cout = C16; 
 
endmodule
