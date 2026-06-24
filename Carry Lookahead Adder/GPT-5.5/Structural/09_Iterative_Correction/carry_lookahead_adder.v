//==================================================== 
// Module: pg_cell 
//==================================================== 
module pg_cell ( 
    input  a, 
    input  b, 
    output p, 
    output g 
); 
 
    // TODO: implement 
 
endmodule 
 
 
//==================================================== 
// Module: carry_logic_4 
// Computes carries within one 4-bit CLA block 
//==================================================== 
module carry_logic_4 ( 
    input  [3:0] p, 
    input  [3:0] g, 
    input        cin, 
 
    output       c1, 
    output       c2, 
    output       c3, 
    output       c4, 
 
    output       PG, 
    output       GG 
); 
 
    // TODO: implement 
 
endmodule 
 
 
//==================================================== 
// Module: group_lookahead 
// Computes carries between 4-bit CLA blocks 
//==================================================== 
module group_lookahead ( 
 
    input  cin, 
 
    input  PG0, 
    input  PG1, 
    input  PG2, 
    input  PG3, 
 
    input  GG0, 
    input  GG1, 
    input  GG2, 
    input  GG3, 
 
    output C4, 
    output C8, 
    output C12, 
    output C16 
); 
 
    // TODO: implement 
 
endmodule 
 
 
//==================================================== 
// Module: sum_logic_4 
// Computes 4 sum bits 
//==================================================== 
module sum_logic_4 ( 
 
    input p0, 
    input p1, 
    input p2, 
    input p3, 
 
    input cin, 
    input c1, 
    input c2, 
    input c3, 
 
    output s0, 
    output s1, 
    output s2, 
    output s3 
); 
 
    // TODO: implement 
 
endmodule 
 
 
//==================================================== 
// Top Module: cla_16bit_structural 
//==================================================== 
module cla_16bit_structural ( 
 
    input  [15:0] a, 
    input  [15:0] b, 
    input         cin, 
 
    output [15:0] sum, 
    output        cout 
); 
 
    //------------------------------------------------ 
    // PG signals 
    //------------------------------------------------ 
    wire P0,  P1,  P2,  P3; 
    wire P4,  P5,  P6,  P7; 
    wire P8,  P9,  P10, P11; 
    wire P12, P13, P14, P15; 
 
    //------------------------------------------------ 
    // GG signals 
    //------------------------------------------------ 
    wire G0,  G1,  G2,  G3; 
    wire G4,  G5,  G6,  G7; 
    wire G8,  G9,  G10, G11; 
    wire G12, G13, G14, G15; 
 
    //------------------------------------------------ 
    // Group signals 
    //------------------------------------------------ 
    wire PG0, PG1, PG2, PG3; 
    wire GG0, GG1, GG2, GG3; 
 
    //------------------------------------------------ 
    // Inter-group carries 
    //------------------------------------------------ 
    wire C4; 
    wire C8; 
    wire C12; 
    wire C16; 
 
    //------------------------------------------------ 
    // Intra-group carries 
    //------------------------------------------------ 
    wire c1,  c2,  c3; 
    wire c5,  c6,  c7; 
    wire c9,  c10, c11; 
    wire c13, c14, c15; 
 
    //------------------------------------------------ 
    // Unused local c4 outputs from carry blocks 
    //------------------------------------------------ 
    wire c4_local0; 
    wire c4_local1; 
    wire c4_local2; 
    wire c4_local3; 
 
    //------------------------------------------------ 
    // PG Cells 
    //------------------------------------------------ 
    pg_cell pg0  (.a(a[0]),  .b(b[0]),  .p(P0),  .g(G0)); 
    pg_cell pg1  (.a(a[1]),  .b(b[1]),  .p(P1),  .g(G1)); 
    pg_cell pg2  (.a(a[2]),  .b(b[2]),  .p(P2),  .g(G2)); 
    pg_cell pg3  (.a(a[3]),  .b(b[3]),  .p(P3),  .g(G3)); 
 
    pg_cell pg4  (.a(a[4]),  .b(b[4]),  .p(P4),  .g(G4)); 
    pg_cell pg5  (.a(a[5]),  .b(b[5]),  .p(P5),  .g(G5)); 
    pg_cell pg6  (.a(a[6]),  .b(b[6]),  .p(P6),  .g(G6)); 
    pg_cell pg7  (.a(a[7]),  .b(b[7]),  .p(P7),  .g(G7)); 
 
    pg_cell pg8  (.a(a[8]),  .b(b[8]),  .p(P8),  .g(G8)); 
    pg_cell pg9  (.a(a[9]),  .b(b[9]),  .p(P9),  .g(G9)); 
    pg_cell pg10 (.a(a[10]), .b(b[10]), .p(P10), .g(G10)); 
    pg_cell pg11 (.a(a[11]), .b(b[11]), .p(P11), .g(G11)); 
 
    pg_cell pg12 (.a(a[12]), .b(b[12]), .p(P12), .g(G12)); 
    pg_cell pg13 (.a(a[13]), .b(b[13]), .p(P13), .g(G13)); 
    pg_cell pg14 (.a(a[14]), .b(b[14]), .p(P14), .g(G14)); 
    pg_cell pg15 (.a(a[15]), .b(b[15]), .p(P15), .g(G15)); 
 
    //------------------------------------------------ 
    // Carry Blocks 
    //------------------------------------------------ 
    carry_logic_4 cla0 ( 
        .p({P3,P2,P1,P0}), 
        .g({G3,G2,G1,G0}), 
        .cin(cin), 
        .c1(c1), 
        .c2(c2), 
        .c3(c3), 
        .c4(c4_local0), 
        .PG(PG0), 
        .GG(GG0) 
    ); 
 
    carry_logic_4 cla1 ( 
        .p({P7,P6,P5,P4}), 
        .g({G7,G6,G5,G4}), 
        .cin(C4), 
        .c1(c5), 
        .c2(c6), 
        .c3(c7), 
        .c4(c4_local1), 
        .PG(PG1), 
        .GG(GG1) 
    ); 
 
    carry_logic_4 cla2 ( 
        .p({P11,P10,P9,P8}), 
        .g({G11,G10,G9,G8}), 
        .cin(C8), 
        .c1(c9), 
        .c2(c10), 
        .c3(c11), 
        .c4(c4_local2), 
        .PG(PG2), 
        .GG(GG2) 
    ); 
 
    carry_logic_4 cla3 ( 
        .p({P15,P14,P13,P12}), 
        .g({G15,G14,G13,G12}), 
        .cin(C12), 
        .c1(c13), 
        .c2(c14), 
        .c3(c15), 
        .c4(c4_local3), 
        .PG(PG3), 
        .GG(GG3) 
    ); 
 
    //------------------------------------------------ 
    // Group Lookahead 
    //------------------------------------------------ 
    group_lookahead gla ( 
        .cin(cin), 
 
        .PG0(PG0), 
        .PG1(PG1), 
        .PG2(PG2), 
        .PG3(PG3), 
 
        .GG0(GG0), 
        .GG1(GG1), 
        .GG2(GG2), 
        .GG3(GG3), 
 
        .C4(C4), 
        .C8(C8), 
        .C12(C12), 
        .C16(C16) 
    ); 
 
    //------------------------------------------------ 
    // Sum Blocks 
    //------------------------------------------------ 
    sum_logic_4 sum0 ( 
        .p0(P0), .p1(P1), .p2(P2), .p3(P3), 
        .cin(cin), .c1(c1), .c2(c2), .c3(c3), 
        .s0(sum[0]), .s1(sum[1]), .s2(sum[2]), .s3(sum[3]) 
    ); 
 
    sum_logic_4 sum1 ( 
        .p0(P4), .p1(P5), .p2(P6), .p3(P7), 
        .cin(C4), .c1(c5), .c2(c6), .c3(c7), 
        .s0(sum[4]), .s1(sum[5]), .s2(sum[6]), .s3(sum[7]) 
    ); 
 
    sum_logic_4 sum2 ( 
        .p0(P8), .p1(P9), .p2(P10), .p3(P11), 
        .cin(C8), .c1(c9), .c2(c10), .c3(c11), 
        .s0(sum[8]), .s1(sum[9]), .s2(sum[10]), .s3(sum[11]) 
    ); 
 
    sum_logic_4 sum3 ( 
        .p0(P12), .p1(P13), .p2(P14), .p3(P15), 
        .cin(C12), .c1(c13), .c2(c14), .c3(c15), 
        .s0(sum[12]), .s1(sum[13]), .s2(sum[14]), .s3(sum[15]) 
    ); 
 
    //------------------------------------------------ 
    // TODO: connect cout from C16 
    //------------------------------------------------ 
 
endmodule
