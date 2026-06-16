`timescale 1ns/1ps 
 
module cla_16bit_dataflow 
#( 
    parameter N = 16 
) 
( 
    input  [N-1:0] a, 
    input  [N-1:0] b, 
    input          cin, 
 
    output [N-1:0] sum, 
    output         cout 
); 
 
    //------------------------------------------ 
    // Generate / Propagate 
    //------------------------------------------ 
 
    wire [N-1:0] G; 
    wire [N-1:0] P; 
 
    genvar i; 
 
    generate 
        for(i=0;i<N;i=i+1) 
        begin : PG_GEN 
            assign G[i] = a[i] & b[i]; 
            assign P[i] = a[i] ^ b[i]; 
        end 
    endgenerate 
 
    //------------------------------------------ 
    // Carry Signals 
    //------------------------------------------ 
 
    wire [16:0] C; 
 
    assign C[0] = cin; 
 
    //------------------------------------------ 
    // Group 0 
    //------------------------------------------ 
 
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
 
    //------------------------------------------ 
    // Group 1 
    //------------------------------------------ 
 
    assign C[5] = 
        G[4] | 
        (P[4] & C[4]); 
 
    assign C[6] = 
        G[5] | 
        (P[5] & G[4]) | 
        (P[5] & P[4] & C[4]); 
 
    assign C[7] = 
        G[6] | 
        (P[6] & G[5]) | 
        (P[6] & P[5] & G[4]) | 
        (P[6] & P[5] & P[4] & C[4]); 
 
    assign C[8] = 
        G[7] | 
        (P[7] & G[6]) | 
        (P[7] & P[6] & G[5]) | 
        (P[7] & P[6] & P[5] & G[4]) | 
        (P[7] & P[6] & P[5] & P[4] & G[3]) | 
        (P[7] & P[6] & P[5] & P[4] & P[3] & G[2]) | 
        (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & G[1]) | 
        (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & G[0]) | 
        (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & cin); 
 
    //------------------------------------------ 
    // Group 2 
    //------------------------------------------ 
 
    assign C[9]  = G[8]  | (P[8]  & C[8]); 
 
    assign C[10] = G[9]  | 
                  (P[9]  & G[8]) | 
                  (P[9]  & P[8] & C[8]); 
 
    assign C[11] = G[10] | 
                  (P[10] & G[9]) | 
                  (P[10] & P[9] & G[8]) | 
                  (P[10] & P[9] & P[8] & C[8]); 
 
    // Fully expanded C12 omitted for brevity in lecture notes 
    // Same pattern as C8 continuing through bit 11 
 
    //------------------------------------------ 
    // Group 3 
    //------------------------------------------ 
 
    // Same expansion pattern 
 
    //------------------------------------------ 
    // Sum 
    //------------------------------------------ 
 
    generate 
        for(i=0;i<N;i=i+1) 
        begin : SUM_GEN 
            assign sum[i] = P[i] ^ C[i]; 
        end 
    endgenerate 
 
    assign cout = C[16]; 
 
endmodule 
 
// Power : Higher than RCA due to extensive lookahead network 
// Area  : Significantly larger than RCA 
// Delay : O(log N) carry computation; much faster than O(N) RCA
