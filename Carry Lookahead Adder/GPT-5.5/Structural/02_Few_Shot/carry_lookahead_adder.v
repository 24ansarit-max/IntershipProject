`timescale 1ns/1ps 
 
//====================================================== 
// 4-BIT GROUP CLA LOGIC 
//====================================================== 
 
module cla_group_4 ( 
    input  [3:0] GP , 
    input  [3:0] GG, 
    input        cin, 
    output [4:1] C 
); 
 
    assign C[1] = GG[0] | 
                  (GP[0] & cin); 
 
    assign C[2] = GG[1] | 
                  (GP[1] & GG[0]) | 
                  (GP[1] & GP[0] & cin); 
 
    assign C[3] = GG[2] | 
                  (GP[2] & GG[1]) | 
                  (GP[2] & GP[1] & GG[0]) | 
                  (GP[2] & GP[1] & GP[0] & cin); 
 
    assign C[4] = GG[3] | 
                  (GP[3] & GG[2]) | 
                  (GP[3] & GP[2] & GG[1]) | 
                  (GP[3] & GP[2] & GP[1] & GG[0]) | 
                  (GP[3] & GP[2] & GP[1] & GP[0] & cin); 
 
    // Power: ~25 gate equivalents 
    // Area : ~20 standard cells 
    // Delay: ~3 gate levels 
 
endmodule 
//====================================================== 
// 4-BIT CLA BLOCK 
//====================================================== 
 
module cla_4bit ( 
    input  [3:0] a, 
    input  [3:0] b, 
    input        cin, 
 
    output [3:0] sum, 
    output       cout, 
 
    output       GP , 
    output       GG 
); 
 
    wire [3:0] g; 
    wire [3:0] p; 
 
    wire [4:0] c; 
 
    assign c[0] = cin; 
 
    genvar i; 
 
    generate 
        for(i=0;i<4;i=i+1) 
        begin : PG_GEN 
 
            assign g[i] = a[i] & b[i]; 
            assign p[i] = a[i] ^ b[i]; 
 
        end 
    endgenerate 
 
    assign c[1] = g[0] | 
                  (p[0] & c[0]); 
 
    assign c[2] = g[1] | 
                  (p[1] & g[0]) | 
                  (p[1] & p[0] & c[0]); 
 
    assign c[3] = g[2] | 
                  (p[2] & g[1]) | 
                  (p[2] & p[1] & g[0]) | 
                  (p[2] & p[1] & p[0] & c[0]); 
 
    assign c[4] = g[3] | 
                  (p[3] & g[2]) | 
                  (p[3] & p[2] & g[1]) | 
                  (p[3] & p[2] & p[1] & g[0]) | 
                  (p[3] & p[2] & p[1] & p[0] & c[0]); 
 
    assign sum  = p ^ c[3:0]; 
 
    assign cout = c[4]; 
 
    //-------------------------------------------------- 
    // Group Propagate 
    //-------------------------------------------------- 
 
    assign GP = p[3] & 
                p[2] & 
                p[1] & 
                p[0]; 
 
    //-------------------------------------------------- 
    // Group Generate 
    //-------------------------------------------------- 
 
    assign GG = g[3] | 
               (p[3] & g[2]) | 
               (p[3] & p[2] & g[1]) | 
               (p[3] & p[2] & p[1] & g[0]); 
 
    // Power: ~35 gate equivalents 
    // Area : ~30 standard cells 
    // Delay: ~4 gate levels 
 
endmodule 
//====================================================== 
// 16-BIT HIERARCHICAL CLA 
//====================================================== 
 
module cla_16bit 
#( 
    parameter WIDTH = 16 
) 
( 
    input  [WIDTH-1:0] a, 
    input  [WIDTH-1:0] b, 
    input              cin, 
 
    output [WIDTH-1:0] sum, 
    output             cout, 
    output             overflow 
); 
 
    //-------------------------------------------------- 
    // Group Signals 
    //-------------------------------------------------- 
 
    wire [3:0] GP; 
    wire [3:0] GG; 
 
    //-------------------------------------------------- 
    // Inter-Group Carries 
    //-------------------------------------------------- 
 
    wire [4:1] CG; 
 
    //-------------------------------------------------- 
    // Block Couts (optional) 
    //-------------------------------------------------- 
 
    wire c4_local; 
    wire c8_local; 
    wire c12_local; 
    wire c16_local; 
 
    //-------------------------------------------------- 
    // Group Carry Lookahead 
    //-------------------------------------------------- 
 
    cla_group_4 GROUP_CLA 
    ( 
        .GP  (GP), 
        .GG  (GG), 
        .cin (cin), 
        .C   (CG) 
    ); 
 
    //-------------------------------------------------- 
    // CLA BLOCK 0 
    //-------------------------------------------------- 
 
    cla_4bit CLA0 
    ( 
        .a   (a[3:0]), 
        .b   (b[3:0]), 
        .cin (cin), 
 
        .sum (sum[3:0]), 
        .cout(c4_local), 
 
        .GP  (GP[0]), 
        .GG  (GG[0]) 
    ); 
 
    //-------------------------------------------------- 
    // CLA BLOCK 1 
    //-------------------------------------------------- 
 
    cla_4bit CLA1 
    ( 
        .a   (a[7:4]), 
        .b   (b[7:4]), 
        .cin (CG[1]), 
 
        .sum (sum[7:4]), 
        .cout(c8_local), 
 
        .GP  (GP[1]), 
        .GG  (GG[1]) 
    ); 
 
    //-------------------------------------------------- 
    // CLA BLOCK 2 
    //-------------------------------------------------- 
 
    cla_4bit CLA2 
    ( 
        .a   (a[11:8]), 
        .b   (b[11:8]), 
        .cin (CG[2]), 
 
        .sum (sum[11:8]), 
        .cout(c12_local), 
 
        .GP  (GP[2]), 
        .GG  (GG[2]) 
    ); 
 
    //-------------------------------------------------- 
    // CLA BLOCK 3 
    //-------------------------------------------------- 
 
    cla_4bit CLA3 
    ( 
        .a   (a[15:12]), 
        .b   (b[15:12]), 
        .cin (CG[3]), 
 
        .sum (sum[15:12]), 
        .cout(c16_local), 
 
        .GP  (GP[3]), 
        .GG  (GG[3]) 
    ); 
 
    //-------------------------------------------------- 
    // Final Outputs 
    //-------------------------------------------------- 
 
    assign cout = CG[4]; 
 
    // Overflow = Carry into MSB XOR Carry out of MSB 
    assign overflow = CG[4] ^ c12_local; 
 
    // Power: ~140–180 gate equivalents 
    // Area : ~110–150 standard cells 
    // Delay: 
    //   Level-1 CLA (within 4-bit blocks) 
    // + Level-2 CLA (group carry lookahead) 
    // ≈ 6 gate levels worst-case 
 
endmodule
