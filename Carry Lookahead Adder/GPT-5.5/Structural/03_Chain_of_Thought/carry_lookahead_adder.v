`timescale 1ns/1ps 
 
module pg_cell( 
    input  a, 
    input  b, 
    output g, 
    output p 
); 
 
    and G1(g,a,b); 
    xor P1(p,a,b); 
 
endmodule 
module carry_chain_4( 
    input  [3:0] g, 
    input  [3:0] p, 
    input        cin, 
 
    output [3:1] c, 
    output       cout, 
    output       GP , 
    output       GG 
); 
 
    //------------------------- 
    // C1 
    //------------------------- 
    wire t10; 
 
    and A10(t10,p[0],cin); 
    or  O10(c[1],g[0],t10); 
 
    //------------------------- 
    // C2 
    //------------------------- 
    wire t20,t21,t22; 
 
    and A20(t20,p[1],g[0]); 
    and A21(t21,p[1],p[0]); 
    and A22(t22,t21,cin); 
 
    or O20(c[2],g[1],t20,t22); 
 
    //------------------------- 
    // C3 
    //------------------------- 
    wire t30,t31,t32,t33,t34; 
 
    and A30(t30,p[2],g[1]); 
 
    and A31(t31,p[2],p[1]); 
    and A32(t32,t31,g[0]); 
 
    and A33(t33,t31,p[0]); 
    and A34(t34,t33,cin); 
 
    or O30(c[3],g[2],t30,t32,t34); 
 
    //------------------------- 
    // C4 (cout) 
    //------------------------- 
    wire t40,t41,t42,t43,t44,t45; 
 
    and A40(t40,p[3],g[2]); 
 
    and A41(t41,p[3],p[2]); 
    and A42(t42,t41,g[1]); 
 
    and A43(t43,t41,p[1]); 
    and A44(t44,t43,g[0]); 
 
    and A45(t45,t43,p[0]); 
 
    wire t46; 
    and A46(t46,t45,cin); 
 
    or O40(cout,g[3],t40,t42,t44,t46); 
 
    //------------------------- 
    // Group Propagate 
    //------------------------- 
    wire gp01,gp23; 
 
    and GP1(gp01,p[0],p[1]); 
    and GP2(gp23,p[2],p[3]); 
    and GP3(GP ,gp01,gp23); 
 
    //------------------------- 
    // Group Generate 
    //------------------------- 
    or GG1(GG,g[3],t40,t42,t44); 
 
endmodule 
module cla_16bit_structural( 
    input  [15:0] a, 
    input  [15:0] b, 
    input         cin, 
 
    output [15:0] sum, 
    output        cout, 
    output        overflow 
); 
 
    wire [15:0] g; 
    wire [15:0] p; 
 
    genvar i; 
 
    generate 
        for(i=0;i<16;i=i+1) 
        begin:PG_STAGE 
            pg_cell PG( 
                .a(a[i]), 
                .b(b[i]), 
                .g(g[i]), 
                .p(p[i]) 
            ); 
        end 
    endgenerate 
 
    //---------------------------------- 
    // Four CLA Blocks 
    //---------------------------------- 
 
    wire [3:1] c0,c1,c2,c3; 
 
    wire GP0,GP1,GP2,GP3; 
    wire GG0,GG1,GG2,GG3; 
 
    wire C4,C8,C12,C16; 
 
    carry_chain_4 B0( 
        .g(g[3:0]), 
        .p(p[3:0]), 
        .cin(cin), 
        .c(c0), 
        .cout(), 
        .GP(GP0), 
        .GG(GG0) 
    ); 
 
    //---------------------------------- 
    // Group Carry Lookahead 
    //---------------------------------- 
 
    wire tg1,tg2,tg3,tg4; 
    wire tg5,tg6,tg7,tg8; 
    wire tg9,tg10,tg11; 
 
    and G40(tg1,GP0,cin); 
    or  G41(C4,GG0,tg1); 
 
    and G80(tg2,GP1,GG0); 
    and G81(tg3,GP1,GP0); 
    and G82(tg4,tg3,cin); 
    or  G83(C8,GG1,tg2,tg4); 
 
    and G120(tg5,GP2,GG1); 
    and G121(tg6,GP2,GP1); 
    and G122(tg7,tg6,GG0); 
    and G123(tg8,tg6,GP0); 
    wire tg8a; 
    and G124(tg8a,tg8,cin); 
    or  G125(C12,GG2,tg5,tg7,tg8a); 
 
    and G160(tg9,GP3,GG2); 
    and G161(tg10,GP3,GP2); 
    and G162(tg11,tg10,GG1); 
 
    wire tg12,tg13,tg14; 
    and G163(tg12,tg10,GP1); 
    and G164(tg13,tg12,GG0); 
    and G165(tg14,tg12,GP0); 
 
    wire tg15; 
    and G166(tg15,tg14,cin); 
 
    or G167(C16,GG3,tg9,tg11,tg13,tg15); 
 
    //---------------------------------- 
    // Remaining CLA blocks 
    //---------------------------------- 
 
    carry_chain_4 B1( 
        .g(g[7:4]), 
        .p(p[7:4]), 
        .cin(C4), 
        .c(c1), 
        .cout(), 
        .GP(GP1), 
        .GG(GG1) 
    ); 
 
    carry_chain_4 B2( 
        .g(g[11:8]), 
        .p(p[11:8]), 
        .cin(C8), 
        .c(c2), 
        .cout(), 
        .GP(GP2), 
        .GG(GG2) 
    ); 
 
    carry_chain_4 B3( 
        .g(g[15:12]), 
        .p(p[15:12]), 
        .cin(C12), 
        .c(c3), 
        .cout(), 
        .GP(GP3), 
        .GG(GG3) 
    ); 
 
    //---------------------------------- 
    // Sum Logic 
    //---------------------------------- 
 
    xor S0(sum[0], p[0], cin); 
    xor S1(sum[1], p[1], c0[1]); 
    xor S2(sum[2], p[2], c0[2]); 
    xor S3(sum[3], p[3], c0[3]); 
 
    xor S4(sum[4], p[4], C4); 
    xor S5(sum[5], p[5], c1[1]); 
    xor S6(sum[6], p[6], c1[2]); 
    xor S7(sum[7], p[7], c1[3]); 
 
    xor S8(sum[8], p[8], C8); 
    xor S9(sum[9], p[9], c2[1]); 
    xor S10(sum[10], p[10], c2[2]); 
    xor S11(sum[11], p[11], c2[3]); 
 
    xor S12(sum[12], p[12], C12); 
    xor S13(sum[13], p[13], c3[1]); 
    xor S14(sum[14], p[14], c3[2]); 
    xor S15(sum[15], p[15], c3[3]); 
 
    //---------------------------------- 
    // Outputs 
    //---------------------------------- 
 
    buf BOUT(cout,C16); 
 
    wire ov; 
    xor OV1(ov,c3[3],C16); 
    buf OV2(overflow,ov); 
 
endmodule
