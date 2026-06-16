`timescale 1ns/1ps 
 
module cla_16bit_dataflow ( 
    input  wire [15:0] a, 
    input  wire [15:0] b, 
    input  wire        cin, 
    output wire [15:0] sum, 
    output wire        cout, 
    output wire        overflow 
); 
 
    // Generate, Propagate, Carry 
    wire [15:0] G; 
    wire [15:0] P; 
    wire [16:0] C; 
 
    // Group Generate / Propagate 
    wire [3:0] GG; 
    wire [3:0] GP; 
 
    assign C[0] = cin; 
 
    //================================================== 
    // Generate / Propagate 
    //================================================== 
 
    assign G[0]  = a[0]  & b[0]; 
    assign G[1]  = a[1]  & b[1]; 
    assign G[2]  = a[2]  & b[2]; 
    assign G[3]  = a[3]  & b[3]; 
    assign G[4]  = a[4]  & b[4]; 
    assign G[5]  = a[5]  & b[5]; 
    assign G[6]  = a[6]  & b[6]; 
    assign G[7]  = a[7]  & b[7]; 
    assign G[8]  = a[8]  & b[8]; 
    assign G[9]  = a[9]  & b[9]; 
    assign G[10] = a[10] & b[10]; 
    assign G[11] = a[11] & b[11]; 
    assign G[12] = a[12] & b[12]; 
    assign G[13] = a[13] & b[13]; 
    assign G[14] = a[14] & b[14]; 
    assign G[15] = a[15] & b[15]; 
 
    assign P[0]  = a[0]  ^ b[0]; 
    assign P[1]  = a[1]  ^ b[1]; 
    assign P[2]  = a[2]  ^ b[2]; 
    assign P[3]  = a[3]  ^ b[3]; 
    assign P[4]  = a[4]  ^ b[4]; 
    assign P[5]  = a[5]  ^ b[5]; 
    assign P[6]  = a[6]  ^ b[6]; 
    assign P[7]  = a[7]  ^ b[7]; 
    assign P[8]  = a[8]  ^ b[8]; 
    assign P[9]  = a[9]  ^ b[9]; 
    assign P[10] = a[10] ^ b[10]; 
    assign P[11] = a[11] ^ b[11]; 
    assign P[12] = a[12] ^ b[12]; 
    assign P[13] = a[13] ^ b[13]; 
    assign P[14] = a[14] ^ b[14]; 
    assign P[15] = a[15] ^ b[15]; 
 
    //================================================== 
    // Group Generate / Propagate 
    //================================================== 
 
    assign GP[0] = P[3] & P[2] & P[1] & P[0]; 
    assign GG[0] = G[3] 
                 | (P[3] & G[2]) 
                 | (P[3] & P[2] & G[1]) 
                 | (P[3] & P[2] & P[1] & G[0]); 
 
    assign GP[1] = P[7] & P[6] & P[5] & P[4]; 
    assign GG[1] = G[7] 
                 | (P[7] & G[6]) 
                 | (P[7] & P[6] & G[5]) 
                 | (P[7] & P[6] & P[5] & G[4]); 
 
    assign GP[2] = P[11] & P[10] & P[9] & P[8]; 
    assign GG[2] = G[11] 
                 | (P[11] & G[10]) 
                 | (P[11] & P[10] & G[9]) 
                 | (P[11] & P[10] & P[9] & G[8]); 
 
    assign GP[3] = P[15] & P[14] & P[13] & P[12]; 
    assign GG[3] = G[15] 
                 | (P[15] & G[14]) 
                 | (P[15] & P[14] & G[13]) 
                 | (P[15] & P[14] & P[13] & G[12]); 
 
    //================================================== 
    // Inter-Group Lookahead Carries 
    //================================================== 
 
    assign C[4]  = GG[0] 
                 | (GP[0] & cin); 
 
    assign C[8]  = GG[1] 
                 | (GP[1] & GG[0]) 
                 | (GP[1] & GP[0] & cin); 
 
    assign C[12] = GG[2] 
                 | (GP[2] & GG[1]) 
                 | (GP[2] & GP[1] & GG[0]) 
                 | (GP[2] & GP[1] & GP[0] & cin); 
 
    assign C[16] = GG[3] 
                 | (GP[3] & GG[2]) 
                 | (GP[3] & GP[2] & GG[1]) 
                 | (GP[3] & GP[2] & GP[1] & GG[0]) 
                 | (GP[3] & GP[2] & GP[1] & GP[0] & cin); 
 
    //================================================== 
    // Intra-Group Carries 
    // Group 0 (start carry = cin) 
    //================================================== 
 
    assign C[1] = G[0] 
                | (P[0] & cin); 
 
    assign C[2] = G[1] 
                | (P[1] & G[0]) 
                | (P[1] & P[0] & cin); 
 
    assign C[3] = G[2] 
                | (P[2] & G[1]) 
                | (P[2] & P[1] & G[0]) 
                | (P[2] & P[1] & P[0] & cin); 
 
    //================================================== 
    // Group 1 (start carry = C4) 
    //================================================== 
 
    assign C[5] = G[4] 
                | (P[4] & C[4]); 
 
    assign C[6] = G[5] 
                | (P[5] & G[4]) 
                | (P[5] & P[4] & C[4]); 
 
    assign C[7] = G[6] 
                | (P[6] & G[5]) 
                | (P[6] & P[5] & G[4]) 
                | (P[6] & P[5] & P[4] & C[4]); 
 
    //================================================== 
    // Group 2 (start carry = C8) 
    //================================================== 
 
    assign C[9]  = G[8] 
                 | (P[8] & C[8]); 
 
    assign C[10] = G[9] 
                 | (P[9] & G[8]) 
                 | (P[9] & P[8] & C[8]); 
 
    assign C[11] = G[10] 
                 | (P[10] & G[9]) 
                 | (P[10] & P[9] & G[8]) 
                 | (P[10] & P[9] & P[8] & C[8]); 
 
    //================================================== 
    // Group 3 (start carry = C12) 
    //================================================== 
 
    assign C[13] = G[12] 
                 | (P[12] & C[12]); 
 
    assign C[14] = G[13] 
                 | (P[13] & G[12]) 
                 | (P[13] & P[12] & C[12]); 
 
    assign C[15] = G[14] 
                 | (P[14] & G[13]) 
                 | (P[14] & P[13] & G[12]) 
                 | (P[14] & P[13] & P[12] & C[12]); 
 
    //================================================== 
    // Sum Outputs 
    //================================================== 
 
    assign sum[0]  = P[0]  ^ C[0]; 
    assign sum[1]  = P[1]  ^ C[1]; 
    assign sum[2]  = P[2]  ^ C[2]; 
    assign sum[3]  = P[3]  ^ C[3]; 
    assign sum[4]  = P[4]  ^ C[4]; 
    assign sum[5]  = P[5]  ^ C[5]; 
    assign sum[6]  = P[6]  ^ C[6]; 
    assign sum[7]  = P[7]  ^ C[7]; 
    assign sum[8]  = P[8]  ^ C[8]; 
    assign sum[9]  = P[9]  ^ C[9]; 
    assign sum[10] = P[10] ^ C[10]; 
    assign sum[11] = P[11] ^ C[11]; 
    assign sum[12] = P[12] ^ C[12]; 
    assign sum[13] = P[13] ^ C[13]; 
    assign sum[14] = P[14] ^ C[14]; 
    assign sum[15] = P[15] ^ C[15]; 
 
    assign cout = C[16]; 
 
    // Signed overflow 
    assign overflow = 
           (a[15] ^ sum[15]) 
         & ~(a[15] ^ b[15]); 
 
endmodule 
 
//====================================================== 
// Power : ~0.10–0.20 mW @ 100 MHz, 1.2 V (library dependent) 
// Area  : ~150–180 gate equivalents 
// Delay : ~5–6 logic levels (two-level CLA hierarchy) 
//======================================================
