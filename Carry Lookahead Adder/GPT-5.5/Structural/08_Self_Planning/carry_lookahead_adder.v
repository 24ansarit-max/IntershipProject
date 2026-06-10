module pg_cell ( 
    input  a, 
    input  b, 
    output p, 
    output g 
); 
 
    xor (p, a, b); 
    and (g, a, b); 
 
endmodule 
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
 
    wire t10; 
 
    wire t20, t21; 
 
    wire t30, t31, t32; 
 
    wire t40, t41, t42, t43; 
 
    wire gg1, gg2, gg3; 
 
    and (t10, p[0], cin); 
    or  (c1, g[0], t10); 
 
    and (t20, p[1], g[0]); 
    and (t21, p[1], p[0], cin); 
    or  (c2, g[1], t20, t21); 
 
    and (t30, p[2], g[1]); 
    and (t31, p[2], p[1], g[0]); 
    and (t32, p[2], p[1], p[0], cin); 
    or  (c3, g[2], t30, t31, t32); 
 
    and (t40, p[3], g[2]); 
    and (t41, p[3], p[2], g[1]); 
    and (t42, p[3], p[2], p[1], g[0]); 
    and (t43, p[3], p[2], p[1], p[0], cin); 
    or  (c4, g[3], t40, t41, t42, t43); 
 
    and (PG, p[3], p[2], p[1], p[0]); 
 
    and (gg1, p[3], g[2]); 
    and (gg2, p[3], p[2], g[1]); 
    and (gg3, p[3], p[2], p[1], g[0]); 
 
    or  (GG, g[3], gg1, gg2, gg3); 
 
endmodule 
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
 
    wire t1; 
 
    wire t2, t3; 
 
    wire t4, t5, t6; 
 
    wire t7, t8, t9, t10; 
 
    and (t1, PG0, cin); 
    or  (C4, GG0, t1); 
 
    and (t2, PG1, GG0); 
    and (t3, PG1, PG0, cin); 
    or  (C8, GG1, t2, t3); 
 
    and (t4, PG2, GG1); 
    and (t5, PG2, PG1, GG0); 
    and (t6, PG2, PG1, PG0, cin); 
    or  (C12, GG2, t4, t5, t6); 
 
    and (t7,  PG3, GG2); 
    and (t8,  PG3, PG2, GG1); 
    and (t9,  PG3, PG2, PG1, GG0); 
    and (t10, PG3, PG2, PG1, PG0, cin); 
 
    or  (C16, GG3, t7, t8, t9, t10); 
 
endmodule 
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
 
    xor (s0, p0, cin); 
    xor (s1, p1, c1); 
    xor (s2, p2, c2); 
    xor (s3, p3, c3); 
 
endmodule 
module cla_16bit_structural ( 
 
    input  [15:0] a, 
    input  [15:0] b, 
    input         cin, 
 
    output [15:0] sum, 
    output        cout 
); 
 
    wire P0,P1,P2,P3,P4,P5,P6,P7; 
    wire P8,P9,P10,P11,P12,P13,P14,P15; 
 
    wire G0,G1,G2,G3,G4,G5,G6,G7; 
    wire G8,G9,G10,G11,G12,G13,G14,G15; 
 
    wire PG0,PG1,PG2,PG3; 
    wire GG0,GG1,GG2,GG3; 
 
    wire C4,C8,C12,C16; 
 
    wire c1,c2,c3; 
    wire c5,c6,c7; 
    wire c9,c10,c11; 
    wire c13,c14,c15; 
 
    pg_cell PGCELL0  (a[0],  b[0],  P0,  G0); 
    pg_cell PGCELL1  (a[1],  b[1],  P1,  G1); 
    pg_cell PGCELL2  (a[2],  b[2],  P2,  G2); 
    pg_cell PGCELL3  (a[3],  b[3],  P3,  G3); 
 
    pg_cell PGCELL4  (a[4],  b[4],  P4,  G4); 
    pg_cell PGCELL5  (a[5],  b[5],  P5,  G5); 
    pg_cell PGCELL6  (a[6],  b[6],  P6,  G6); 
    pg_cell PGCELL7  (a[7],  b[7],  P7,  G7); 
 
    pg_cell PGCELL8  (a[8],  b[8],  P8,  G8); 
    pg_cell PGCELL9  (a[9],  b[9],  P9,  G9); 
    pg_cell PGCELL10 (a[10], b[10], P10, G10); 
    pg_cell PGCELL11 (a[11], b[11], P11, G11); 
 
    pg_cell PGCELL12 (a[12], b[12], P12, G12); 
    pg_cell PGCELL13 (a[13], b[13], P13, G13); 
    pg_cell PGCELL14 (a[14], b[14], P14, G14); 
    pg_cell PGCELL15 (a[15], b[15], P15, G15); 
 
    carry_logic_4 CLA0( 
        {P3,P2,P1,P0}, 
        {G3,G2,G1,G0}, 
        cin, 
        c1,c2,c3, 
        , 
        PG0, 
        GG0 
    ); 
 
    carry_logic_4 CLA1( 
        {P7,P6,P5,P4}, 
        {G7,G6,G5,G4}, 
        C4, 
        c5,c6,c7, 
        , 
        PG1, 
        GG1 
    ); 
 
    carry_logic_4 CLA2( 
        {P11,P10,P9,P8}, 
        {G11,G10,G9,G8}, 
        C8, 
        c9,c10,c11, 
        , 
        PG2, 
        GG2 
    ); 
 
    carry_logic_4 CLA3( 
        {P15,P14,P13,P12}, 
        {G15,G14,G13,G12}, 
        C12, 
        c13,c14,c15, 
        , 
        PG3, 
        GG3 
    ); 
 
    group_lookahead GLA( 
        cin, 
        PG0,PG1,PG2,PG3, 
        GG0,GG1,GG2,GG3, 
        C4,C8,C12,C16 
    ); 
 
    sum_logic_4 SUM0( 
        P0,P1,P2,P3, 
        cin,c1,c2,c3, 
        sum[0],sum[1],sum[2],sum[3] 
    ); 
 
    sum_logic_4 SUM1( 
        P4,P5,P6,P7, 
        C4,c5,c6,c7, 
        sum[4],sum[5],sum[6],sum[7] 
    ); 
 
    sum_logic_4 SUM2( 
        P8,P9,P10,P11, 
        C8,c9,c10,c11, 
        sum[8],sum[9],sum[10],sum[11] 
    ); 
 
    sum_logic_4 SUM3( 
        P12,P13,P14,P15, 
        C12,c13,c14,c15, 
        sum[12],sum[13],sum[14],sum[15] 
    ); 
 
    buf (cout, C16); 
 
endmodule
