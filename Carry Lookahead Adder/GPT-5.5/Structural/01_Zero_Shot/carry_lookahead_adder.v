`timescale 1ns/1ps 
 
module pg_cell ( 
    input  wire a, 
    input  wire b, 
    output wire p, 
    output wire g 
); 
 
    xor (p, a, b); 
    and (g, a, b); 
 
    // Power: 2 gate primitives 
    // Area: 2 cells 
    // Delay: 1 gate level 
endmodule 
module full_adder ( 
    input  wire a, 
    input  wire b, 
    input  wire cin, 
    output wire sum, 
    output wire cout 
); 
 
    wire p, g; 
    wire pcin; 
 
    pg_cell U1 (.a(a), .b(b), .p(p), .g(g)); 
 
    xor (sum, p, cin); 
    and (pcin, p, cin); 
    or  (cout, g, pcin); 
 
    // Power: ~4–5 gates 
    // Area: PG + XOR + AND + OR 
    // Delay: 2 levels 
endmodule 
module cla_logic_4bit ( 
    input  wire [3:0] p, 
    input  wire [3:0] g, 
    input  wire       cin, 
    output wire [3:1] c, 
    output wire       cout, 
    output wire       group_p, 
    output wire       group_g 
); 
 
    // ------------------------- 
    // C1 = G0 + P0·Cin 
    // ------------------------- 
    wire p0cin, c1; 
    and (p0cin, p[0], cin); 
    or  (c1, g[0], p0cin); 
    buf (c[1], c1); 
 
    // ------------------------- 
    // C2 = G1 + P1G0 + P1P0Cin 
    // ------------------------- 
    wire p1g0, p1p0, p1p0cin, t2_1, c2; 
 
    and (p1g0, p[1], g[0]); 
    and (p1p0, p[1], p[0]); 
    and (p1p0cin, p1p0, cin); 
 
    or (t2_1, g[1], p1g0); 
    or (c2, t2_1, p1p0cin); 
 
    buf (c[2], c2); 
 
    // ------------------------- 
    // C3 = G2 + P2G1 + P2P1G0 + P2P1P0Cin 
    // ------------------------- 
    wire p2g1, p2p1, p2p1g0, p2p1p0, p2p1p0cin; 
    wire t3_1, t3_2, c3; 
 
    and (p2g1, p[2], g[1]); 
    and (p2p1, p[2], p[1]); 
    and (p2p1g0, p2p1, g[0]); 
    and (p2p1p0, p2p1, p[0]); 
    and (p2p1p0cin, p2p1p0, cin); 
 
    or (t3_1, g[2], p2g1); 
    or (t3_2, t3_1, p2p1g0); 
    or (c3, t3_2, p2p1p0cin); 
 
    buf (c[3], c3); 
 
    // ------------------------- 
    // Cout = G3 + all propagate terms 
    // ------------------------- 
    wire p3g2, p3p2, p3p2g1, p3p2p1, p3p2p1g0, p3p2p1p0, p3p2p1p0cin; 
    wire t4_1, t4_2, t4_3, t4_4; 
 
    and (p3g2, p[3], g[2]); 
    and (p3p2, p[3], p[2]); 
    and (p3p2g1, p3p2, g[1]); 
    and (p3p2p1, p3p2, p[1]); 
    and (p3p2p1g0, p3p2p1, g[0]); 
    and (p3p2p1p0, p3p2p1, p[0]); 
    and (p3p2p1p0cin, p3p2p1p0, cin); 
 
    or (t4_1, g[3], p3g2); 
    or (t4_2, t4_1, p3p2g1); 
    or (t4_3, t4_2, p3p2p1g0); 
    or (t4_4, t4_3, p3p2p1p0); 
    or (cout, t4_4, p3p2p1p0cin); 
 
    // ------------------------- 
    // Group Propagate = p0&p1&p2&p3 
    // ------------------------- 
    wire gp1, gp2; 
    and (gp1, p[0], p[1]); 
    and (gp2, gp1, p[2]); 
    and (group_p, gp2, p[3]); 
 
    // ------------------------- 
    // Group Generate 
    // ------------------------- 
    wire gg1, gg2, gg3, gg4; 
 
    and (gg1, p[3], g[2]); 
    and (gg2, gg1, p[1]); 
    and (gg3, gg2, p[0]); 
 
    or  (gg4, g[3], gg1); 
    or  (group_g, gg4, gg3); 
 
    // Power: ~25–35 gates 
    // Area: ~30–40 cells 
    // Delay: 3–4 levels 
endmodule 
module cla_top_16bit ( 
    input  wire [15:0] a, 
    input  wire [15:0] b, 
    input  wire        cin, 
    output wire [15:0] sum, 
    output wire        cout, 
    output wire        overflow 
); 
 
    // ------------------------- 
    // PG wires 
    // ------------------------- 
    wire [15:0] p, g; 
 
    genvar i; 
    generate 
        for (i = 0; i < 16; i = i + 1) begin : PG_GEN 
            pg_cell U_PG ( 
                .a(a[i]), 
                .b(b[i]), 
                .p(p[i]), 
                .g(g[i]) 
            ); 
        end 
    endgenerate 
 
    // ------------------------- 
    // Carry wires per block 
    // ------------------------- 
    wire c4, c8, c12, c16; 
 
    wire [3:1] c0, c1, c2, c3; 
 
    cla_logic_4bit U0 (.p(p[3:0]),   .g(g[3:0]),   .cin(cin), .c(c0), .cout(c4),  .group_p(), .group_g()); 
    cla_logic_4bit U1 (.p(p[7:4]),   .g(g[7:4]),   .cin(c4),  .c(c1), .cout(c8),  .group_p(), .group_g()); 
    cla_logic_4bit U2 (.p(p[11:8]),  .g(g[11:8]),  .cin(c8),  .c(c2), .cout(c12), .group_p(), .group_g()); 
    cla_logic_4bit U3 (.p(p[15:12]), .g(g[15:12]), .cin(c12), .c(c3), .cout(c16), .group_p(), .group_g()); 
 
    // ------------------------- 
    // Sum (FULL STRUCTURAL) 
    // ------------------------- 
    xor (sum[0],  p[0],  cin); 
    xor (sum[1],  p[1],  c0[1]); 
    xor (sum[2],  p[2],  c0[2]); 
    xor (sum[3],  p[3],  c0[3]); 
 
    xor (sum[4],  p[4],  c4); 
    xor (sum[5],  p[5],  c1[1]); 
    xor (sum[6],  p[6],  c1[2]); 
    xor (sum[7],  p[7],  c1[3]); 
 
    xor (sum[8],  p[8],  c8); 
    xor (sum[9],  p[9],  c2[1]); 
    xor (sum[10], p[10], c2[2]); 
    xor (sum[11], p[11], c2[3]); 
 
    xor (sum[12], p[12], c12); 
    xor (sum[13], p[13], c3[1]); 
    xor (sum[14], p[14], c3[2]); 
    xor (sum[15], p[15], c3[3]); 
 
    // ------------------------- 
    // Final carry & overflow 
    // ------------------------- 
    buf (cout, c16); 
 
    wire ov; 
    xor (ov, c16, c12); 
    buf (overflow, ov); 
 
    // Power: ~150–200 gates 
    // Area: ~120–160 cells 
    // Delay: 4–5 CLA levels (logarithmic carry tree) 
endmodule
