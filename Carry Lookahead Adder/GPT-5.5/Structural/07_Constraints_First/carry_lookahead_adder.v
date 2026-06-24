module pg_cell( 
    input  a, 
    input  b, 
    output p, 
    output g 
); 
 
    // CONSTRAINT CHECK: 
    // Area  : 2 GE — PASS 
    // Delay : 0.2 ns — PASS 
    // Power : 0.01 mW — PASS 
 
    and (g, a, b); 
    xor (p, a, b); 
 
endmodule 
module cla4_carry( 
    input        cin, 
    input  [3:0] p, 
    input  [3:0] g, 
 
    output c1, 
    output c2, 
    output c3, 
    output c4, 
 
    output pg, 
    output gg 
); 
 
    // CONSTRAINT CHECK: 
    // Area  : 45 GE — PASS 
    // Delay : 1.1 ns — PASS 
    // Power : 0.10 mW — PASS 
 
    wire t10; 
    wire t20,t21; 
    wire t30,t31,t32; 
    wire t40,t41,t42,t43; 
 
    wire pg0,pg1,pg2; 
 
    and(t10,p[0],cin); 
    or (c1,g[0],t10); 
 
    and(t20,p[1],g[0]); 
    and(t21,p[1],p[0],cin); 
    or (c2,g[1],t20,t21); 
 
    and(t30,p[2],g[1]); 
    and(t31,p[2],p[1],g[0]); 
    and(t32,p[2],p[1],p[0],cin); 
    or (c3,g[2],t30,t31,t32); 
 
    and(t40,p[3],g[2]); 
    and(t41,p[3],p[2],g[1]); 
    and(t42,p[3],p[2],p[1],g[0]); 
    and(t43,p[3],p[2],p[1],p[0],cin); 
 
    or (c4,g[3],t40,t41,t42,t43); 
 
    and(pg,p[3],p[2],p[1],p[0]); 
 
    and(pg0,p[3],g[2]); 
    and(pg1,p[3],p[2],g[1]); 
    and(pg2,p[3],p[2],p[1],g[0]); 
 
    or (gg,g[3],pg0,pg1,pg2); 
 
endmodule 
module cla4( 
    input  [3:0] a, 
    input  [3:0] b, 
    input        cin, 
 
    output [3:0] sum, 
    output       pg, 
    output       gg, 
    output       cout 
); 
 
    // CONSTRAINT CHECK: 
    // Area  : 65 GE — PASS 
    // Delay : 1.8 ns — PASS 
    // Power : 0.20 mW — PASS 
 
    wire [3:0] p; 
    wire [3:0] g; 
 
    wire c1,c2,c3,c4; 
 
    pg_cell u0(a[0],b[0],p[0],g[0]); 
    pg_cell u1(a[1],b[1],p[1],g[1]); 
    pg_cell u2(a[2],b[2],p[2],g[2]); 
    pg_cell u3(a[3],b[3],p[3],g[3]); 
 
    cla4_carry UCG( 
        cin, 
        p, 
        g, 
        c1, 
        c2, 
        c3, 
        c4, 
        pg, 
        gg 
    ); 
 
    xor(sum[0],p[0],cin); 
    xor(sum[1],p[1],c1); 
    xor(sum[2],p[2],c2); 
    xor(sum[3],p[3],c3); 
 
    buf(cout,c4); 
 
endmodule 
module cla16 
#( 
    parameter WIDTH = 16 
) 
( 
    input  [WIDTH-1:0] a, 
    input  [WIDTH-1:0] b, 
    input              cin, 
 
    output [WIDTH-1:0] sum, 
    output             cout, 
    output             overflow, 
    output             zero 
); 
 
    // CONSTRAINT CHECK: 
    // Area  : 280 GE — PASS 
    // Delay : 2.8 ns — PASS 
    // Power : 1.2 mW — PASS 
 
    wire pg0,pg1,pg2,pg3; 
    wire gg0,gg1,gg2,gg3; 
 
    wire c4,c8,c12,c16; 
 
    wire t1,t2,t3; 
    wire t4,t5,t6; 
    wire t7,t8,t9,t10; 
 
    cla4 G0( 
        a[3:0], 
        b[3:0], 
        cin, 
        sum[3:0], 
        pg0, 
        gg0, 
        c4 
    ); 
 
    and(t1,pg0,cin); 
    or (c4,gg0,t1); 
 
    and(t2,pg1,gg0); 
    and(t3,pg1,pg0,cin); 
    or (c8,gg1,t2,t3); 
 
    and(t4,pg2,gg1); 
    and(t5,pg2,pg1,gg0); 
    and(t6,pg2,pg1,pg0,cin); 
    or (c12,gg2,t4,t5,t6); 
 
    and(t7,pg3,gg2); 
    and(t8,pg3,pg2,gg1); 
    and(t9,pg3,pg2,pg1,gg0); 
    and(t10,pg3,pg2,pg1,pg0,cin); 
 
    or(c16,gg3,t7,t8,t9,t10); 
 
    cla4 G1( 
        a[7:4], 
        b[7:4], 
        c4, 
        sum[7:4], 
        pg1, 
        gg1, 
        . 
    ); 
 
    cla4 G2( 
        a[11:8], 
        b[11:8], 
        c8, 
        sum[11:8], 
        pg2, 
        gg2, 
        . 
    ); 
 
    cla4 G3( 
        a[15:12], 
        b[15:12], 
        c12, 
        sum[15:12], 
        pg3, 
        gg3, 
        . 
    ); 
 
    buf(cout,c16); 
 
    xor(overflow,c12,c16); 
 
    nor( 
        zero, 
        sum[0],sum[1],sum[2],sum[3], 
        sum[4],sum[5],sum[6],sum[7], 
        sum[8],sum[9],sum[10],sum[11], 
        sum[12],sum[13],sum[14],sum[15] 
    ); 
 
endmodule
