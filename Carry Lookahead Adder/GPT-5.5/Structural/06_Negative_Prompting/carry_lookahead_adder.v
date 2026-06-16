`timescale 1ns/1ps 
 
//---------------------------------------------------- 
// Responsibility: Compute bit Generate and Propagate 
// Area: ~2 gates 
// Delay: ~1 gate level 
//---------------------------------------------------- 
module pg_cell( 
    input  wire a, 
    input  wire b, 
    output wire g, 
    output wire p 
); 
    and G1(g,a,b); 
    xor P1(p,a,b); 
endmodule 
 
 
//---------------------------------------------------- 
// Responsibility: 4-bit carry lookahead equations 
// Area: ~20 gates 
// Delay: ~3 gate levels 
//---------------------------------------------------- 
module carry_logic_4( 
    input  wire [3:0] g, 
    input  wire [3:0] p, 
    input  wire       cin, 
    output wire [4:1] c 
); 
 
    assign c[1] = 
        g[0] | (p[0] & cin); 
 
    assign c[2] = 
        g[1] | 
        (p[1] & g[0]) | 
        (p[1] & p[0] & cin); 
 
    assign c[3] = 
        g[2] | 
        (p[2] & g[1]) | 
        (p[2] & p[1] & g[0]) | 
        (p[2] & p[1] & p[0] & cin); 
 
    assign c[4] = 
        g[3] | 
        (p[3] & g[2]) | 
        (p[3] & p[2] & g[1]) | 
        (p[3] & p[2] & p[1] & g[0]) | 
        (p[3] & p[2] & p[1] & p[0] & cin); 
 
endmodule 
 
 
//---------------------------------------------------- 
// Responsibility: Compute group generate/propagate 
// Area: ~10 gates 
// Delay: ~2-3 gate levels 
//---------------------------------------------------- 
module group_pg( 
    input  wire [3:0] g, 
    input  wire [3:0] p, 
    output wire       GG, 
    output wire       GP 
); 
 
    assign GP = 
        p[3] & p[2] & p[1] & p[0]; 
 
    assign GG = 
        g[3] | 
        (p[3] & g[2]) | 
        (p[3] & p[2] & g[1]) | 
        (p[3] & p[2] & p[1] & g[0]); 
 
endmodule 
 
 
//---------------------------------------------------- 
// Responsibility: Complete 4-bit CLA block 
// Area: ~40 gates 
// Delay: ~4 gate levels 
//---------------------------------------------------- 
module cla_4bit_block( 
    input  wire [3:0] a, 
    input  wire [3:0] b, 
    input  wire       cin, 
 
    output wire [3:0] sum, 
    output wire       GG, 
    output wire       GP , 
    output wire       cout 
); 
 
    wire [3:0] g; 
    wire [3:0] p; 
    wire [4:1] c; 
 
    pg_cell PG0(a[0],b[0],g[0],p[0]); 
    pg_cell PG1(a[1],b[1],g[1],p[1]); 
    pg_cell PG2(a[2],b[2],g[2],p[2]); 
    pg_cell PG3(a[3],b[3],g[3],p[3]); 
 
    carry_logic_4 CARRY( 
        .g(g), 
        .p(p), 
        .cin(cin), 
        .c(c) 
    ); 
 
    group_pg GPG( 
        .g(g), 
        .p(p), 
        .GG(GG), 
        .GP(GP) 
    ); 
 
    xor S0(sum[0],p[0],cin); 
    xor S1(sum[1],p[1],c[1]); 
    xor S2(sum[2],p[2],c[2]); 
    xor S3(sum[3],p[3],c[3]); 
 
    buf B0(cout,c[4]); 
 
endmodule 
 
 
//---------------------------------------------------- 
// Responsibility: 16-bit hierarchical CLA 
// Area: ~160 gates 
// Delay: ~5-6 gate levels 
//---------------------------------------------------- 
module cla_16bit( 
    input  wire [15:0] a, 
    input  wire [15:0] b, 
    input  wire        cin, 
 
    output wire [15:0] sum, 
    output wire        cout, 
    output wire        overflow 
); 
 
    wire GG0,GG1,GG2,GG3; 
    wire GP0,GP1,GP2,GP3; 
 
    wire C4,C8,C12,C16; 
 
    wire dummy0,dummy1,dummy2,dummy3; 
 
    // Group 0 
    cla_4bit_block U0( 
        .a(a[3:0]), 
        .b(b[3:0]), 
        .cin(cin), 
        .sum(sum[3:0]), 
        .GG(GG0), 
        .GP(GP0), 
        .cout(dummy0) 
    ); 
 
    // Inter-group carry lookahead 
    assign C4 = 
        GG0 | 
        (GP0 & cin); 
 
    // Group 1 
    cla_4bit_block U1( 
        .a(a[7:4]), 
        .b(b[7:4]), 
        .cin(C4), 
        .sum(sum[7:4]), 
        .GG(GG1), 
        .GP(GP1), 
        .cout(dummy1) 
    ); 
 
    assign C8 = 
        GG1 | 
        (GP1 & GG0) | 
        (GP1 & GP0 & cin); 
 
    // Group 2 
    cla_4bit_block U2( 
        .a(a[11:8]), 
        .b(b[11:8]), 
        .cin(C8), 
        .sum(sum[11:8]), 
        .GG(GG2), 
        .GP(GP2), 
        .cout(dummy2) 
    ); 
 
    assign C12 = 
        GG2 | 
        (GP2 & GG1) | 
        (GP2 & GP1 & GG0) | 
        (GP2 & GP1 & GP0 & cin); 
 
    // Group 3 
    cla_4bit_block U3( 
        .a(a[15:12]), 
        .b(b[15:12]), 
        .cin(C12), 
        .sum(sum[15:12]), 
        .GG(GG3), 
        .GP(GP3), 
        .cout(dummy3) 
    ); 
 
    assign C16 = 
        GG3 | 
        (GP3 & GG2) | 
        (GP3 & GP2 & GG1) | 
        (GP3 & GP2 & GP1 & GG0) | 
        (GP3 & GP2 & GP1 & GP0 & cin); 
 
    buf COUT_BUF(cout,C16); 
 
    xor OVF(overflow,C12,C16); 
 
endmodule
