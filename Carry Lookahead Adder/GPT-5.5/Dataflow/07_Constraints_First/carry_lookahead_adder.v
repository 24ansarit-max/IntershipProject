module cla_16bit_dataflow ( 
    input  [15:0] a, 
    input  [15:0] b, 
    input         cin, 
    output [15:0] sum, 
    output        cout 
); 
 
    //======================================================== 
    // Step 1 : Bit-Level Generate and Propagate Signals 
    //======================================================== 
    wire [15:0] g; 
    wire [15:0] p; 
 
    assign g = a & b; 
    assign p = a ^ b; 
 
    //======================================================== 
    // Step 2 : Block-Level Group Generate/Propagate 
    //======================================================== 
    wire [3:0] PG; 
    wire [3:0] GG; 
 
    // Block 0 : Bits [3:0] 
    assign PG[0] = p[3] & p[2] & p[1] & p[0]; 
 
    assign GG[0] = g[3] | 
                   (p[3] & g[2]) | 
                   (p[3] & p[2] & g[1]) | 
                   (p[3] & p[2] & p[1] & g[0]); 
 
    // Block 1 : Bits [7:4] 
    assign PG[1] = p[7] & p[6] & p[5] & p[4]; 
 
    assign GG[1] = g[7] | 
                   (p[7] & g[6]) | 
                   (p[7] & p[6] & g[5]) | 
                   (p[7] & p[6] & p[5] & g[4]); 
 
    // Block 2 : Bits [11:8] 
    assign PG[2] = p[11] & p[10] & p[9] & p[8]; 
 
    assign GG[2] = g[11] | 
                   (p[11] & g[10]) | 
                   (p[11] & p[10] & g[9]) | 
                   (p[11] & p[10] & p[9] & g[8]); 
 
    // Block 3 : Bits [15:12] 
    assign PG[3] = p[15] & p[14] & p[13] & p[12]; 
 
    assign GG[3] = g[15] | 
                   (p[15] & g[14]) | 
                   (p[15] & p[14] & g[13]) | 
                   (p[15] & p[14] & p[13] & g[12]); 
 
    //======================================================== 
    // Step 3 : Carry Signals 
    //======================================================== 
    wire [16:0] c; 
 
    assign c[0] = cin; 
 
    // Inter-Group Carries 
    assign c[4]  = GG[0] | (PG[0] & c[0]); 
    assign c[8]  = GG[1] | (PG[1] & c[4]); 
    assign c[12] = GG[2] | (PG[2] & c[8]); 
    assign c[16] = GG[3] | (PG[3] & c[12]); 
 
    // Intra-Group Carries : Block 0 
    assign c[1] = g[0] | (p[0] & c[0]); 
    assign c[2] = g[1] | (p[1] & c[1]); 
    assign c[3] = g[2] | (p[2] & c[2]); 
 
    // Intra-Group Carries : Block 1 
    assign c[5] = g[4] | (p[4] & c[4]); 
    assign c[6] = g[5] | (p[5] & c[5]); 
    assign c[7] = g[6] | (p[6] & c[6]); 
 
    // Intra-Group Carries : Block 2 
    assign c[9]  = g[8]  | (p[8]  & c[8]); 
    assign c[10] = g[9]  | (p[9]  & c[9]); 
    assign c[11] = g[10] | (p[10] & c[10]); 
 
    // Intra-Group Carries : Block 3 
    assign c[13] = g[12] | (p[12] & c[12]); 
    assign c[14] = g[13] | (p[13] & c[13]); 
    assign c[15] = g[14] | (p[14] & c[14]); 
 
    //======================================================== 
    // Step 4 : Sum Outputs 
    //======================================================== 
    assign sum[0]  = p[0]  ^ c[0]; 
    assign sum[1]  = p[1]  ^ c[1]; 
    assign sum[2]  = p[2]  ^ c[2]; 
    assign sum[3]  = p[3]  ^ c[3]; 
    assign sum[4]  = p[4]  ^ c[4]; 
    assign sum[5]  = p[5]  ^ c[5]; 
    assign sum[6]  = p[6]  ^ c[6]; 
    assign sum[7]  = p[7]  ^ c[7]; 
    assign sum[8]  = p[8]  ^ c[8]; 
    assign sum[9]  = p[9]  ^ c[9]; 
    assign sum[10] = p[10] ^ c[10]; 
    assign sum[11] = p[11] ^ c[11]; 
    assign sum[12] = p[12] ^ c[12]; 
    assign sum[13] = p[13] ^ c[13]; 
    assign sum[14] = p[14] ^ c[14]; 
    assign sum[15] = p[15] ^ c[15]; 
 
    assign cout = c[16]; 
 
endmodule
