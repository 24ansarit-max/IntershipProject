module cla16_dataflow ( 
    input  [15:0] a, 
    input  [15:0] b, 
    input         cin, 
    output [15:0] sum, 
    output        cout, 
    output        overflow 
); 
 
    wire [15:0] P; 
    wire [15:0] G; 
 
    wire [3:0] GP; 
    wire [3:0] GG; 
 
    wire [16:0] C; 
 
    //-------------------------------------------------- 
    // Bit Generate / Propagate 
    //-------------------------------------------------- 
 
    assign P = a ^ b; 
    assign G = a & b; 
 
    //-------------------------------------------------- 
    // Group Propagate 
    //-------------------------------------------------- 
 
    assign GP[0] = P[3]  & P[2]  & P[1]  & P[0]; 
    assign GP[1] = P[7]  & P[6]  & P[5]  & P[4]; 
    assign GP[2] = P[11] & P[10] & P[9]  & P[8]; 
    assign GP[3] = P[15] & P[14] & P[13] & P[12]; 
 
    //-------------------------------------------------- 
    // Group Generate 
    //-------------------------------------------------- 
 
    assign GG[0] = G[3] | 
                   (P[3] & G[2]) | 
                   (P[3] & P[2] & G[1]) | 
                   (P[3] & P[2] & P[1] & G[0]); 
 
    assign GG[1] = G[7] | 
                   (P[7] & G[6]) | 
                   (P[7] & P[6] & G[5]) | 
                   (P[7] & P[6] & P[5] & G[4]); 
 
    assign GG[2] = G[11] | 
                   (P[11] & G[10]) | 
                   (P[11] & P[10] & G[9]) | 
                   (P[11] & P[10] & P[9] & G[8]); 
 
    assign GG[3] = G[15] | 
                   (P[15] & G[14]) | 
                   (P[15] & P[14] & G[13]) | 
                   (P[15] & P[14] & P[13] & G[12]); 
 
    //-------------------------------------------------- 
    // Carry Network 
    //-------------------------------------------------- 
 
    assign C[0] = cin; 
 
    assign C[1] = G[0] | (P[0] & C[0]); 
 
    assign C[2] = G[1] | 
                  (P[1] & G[0]) | 
                  (P[1] & P[0] & C[0]); 
 
    assign C[3] = G[2] | 
                  (P[2] & G[1]) | 
                  (P[2] & P[1] & G[0]) | 
                  (P[2] & P[1] & P[0] & C[0]); 
 
    assign C[4] = GG[0] | 
                  (GP[0] & C[0]); 
 
    assign C[5] = G[4] | 
                  (P[4] & C[4]); 
 
    assign C[6] = G[5] | 
                  (P[5] & G[4]) | 
                  (P[5] & P[4] & C[4]); 
 
    assign C[7] = G[6] | 
                  (P[6] & G[5]) | 
                  (P[6] & P[5] & G[4]) | 
                  (P[6] & P[5] & P[4] & C[4]); 
 
    assign C[8] = GG[1] | 
                  (GP[1] & C[4]); 
 
    assign C[9] = G[8] | 
                  (P[8] & C[8]); 
 
    assign C[10] = G[9] | 
                   (P[9] & G[8]) | 
                   (P[9] & P[8] & C[8]); 
 
    assign C[11] = G[10] | 
                   (P[10] & G[9]) | 
                   (P[10] & P[9] & G[8]) | 
                   (P[10] & P[9] & P[8] & C[8]); 
 
    assign C[12] = GG[2] | 
                   (GP[2] & C[8]); 
 
    assign C[13] = G[12] | 
                   (P[12] & C[12]); 
 
    assign C[14] = G[13] | 
                   (P[13] & G[12]) | 
                   (P[13] & P[12] & C[12]); 
 
    assign C[15] = G[14] | 
                   (P[14] & G[13]) | 
                   (P[14] & P[13] & G[12]) | 
                   (P[14] & P[13] & P[12] & C[12]); 
 
    assign C[16] = GG[3] | 
                   (GP[3] & C[12]); 
 
    //-------------------------------------------------- 
    // Sum 
    //-------------------------------------------------- 
 
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
 
    assign overflow = C[15] ^ C[16]; 
 
endmodule
