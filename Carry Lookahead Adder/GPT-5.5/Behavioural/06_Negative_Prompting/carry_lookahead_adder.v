`timescale 1ns/1ps 
 
module cla_16bit_behavioral 
#( 
    parameter WIDTH = 16 
) 
( 
    input  wire [WIDTH-1:0] a, 
    input  wire [WIDTH-1:0] b, 
    input  wire             cin, 
 
    output reg  [WIDTH-1:0] sum, 
    output reg              cout, 
    output reg              overflow 
); 
 
    // Generate, Propagate, Carry 
    reg [WIDTH-1:0] g; 
    reg [WIDTH-1:0] p; 
    reg [WIDTH:0]   c; 
 
    // Group Generate / Propagate 
    reg [3:0] gg; 
    reg [3:0] gp; 
 
    integer i; 
 
    always @(*) begin 
 
        //-------------------------------------------------- 
        // Generate / Propagate 
        //-------------------------------------------------- 
        for(i=0;i<WIDTH;i=i+1) begin 
            g[i] = a[i] & b[i]; 
            p[i] = a[i] ^ b[i]; 
        end 
 
        c[0] = cin; 
 
        //-------------------------------------------------- 
        // Group Generate / Propagate 
        //-------------------------------------------------- 
 
        gp[0] = p[3] & p[2] & p[1] & p[0]; 
        gg[0] = g[3] 
              | (p[3] & g[2]) 
              | (p[3] & p[2] & g[1]) 
              | (p[3] & p[2] & p[1] & g[0]); 
 
        gp[1] = p[7] & p[6] & p[5] & p[4]; 
        gg[1] = g[7] 
              | (p[7] & g[6]) 
              | (p[7] & p[6] & g[5]) 
              | (p[7] & p[6] & p[5] & g[4]); 
 
        gp[2] = p[11] & p[10] & p[9] & p[8]; 
        gg[2] = g[11] 
              | (p[11] & g[10]) 
              | (p[11] & p[10] & g[9]) 
              | (p[11] & p[10] & p[9] & g[8]); 
 
        gp[3] = p[15] & p[14] & p[13] & p[12]; 
        gg[3] = g[15] 
              | (p[15] & g[14]) 
              | (p[15] & p[14] & g[13]) 
              | (p[15] & p[14] & p[13] & g[12]); 
 
        //-------------------------------------------------- 
        // Second-Level Group Lookahead 
        // (Computed in parallel from GG/GP) 
        //-------------------------------------------------- 
 
        c[4]  = gg[0] 
              | (gp[0] & c[0]); 
 
        c[8]  = gg[1] 
              | (gp[1] & gg[0]) 
              | (gp[1] & gp[0] & c[0]); 
 
        c[12] = gg[2] 
              | (gp[2] & gg[1]) 
              | (gp[2] & gp[1] & gg[0]) 
              | (gp[2] & gp[1] & gp[0] & c[0]); 
 
        c[16] = gg[3] 
              | (gp[3] & gg[2]) 
              | (gp[3] & gp[2] & gg[1]) 
              | (gp[3] & gp[2] & gp[1] & gg[0]) 
              | (gp[3] & gp[2] & gp[1] & gp[0] & c[0]); 
 
        //-------------------------------------------------- 
        // Group 0 : bits [3:0] 
        //-------------------------------------------------- 
 
        c[1] = g[0] 
             | (p[0] & c[0]); 
 
        c[2] = g[1] 
             | (p[1] & g[0]) 
             | (p[1] & p[0] & c[0]); 
 
        c[3] = g[2] 
             | (p[2] & g[1]) 
             | (p[2] & p[1] & g[0]) 
             | (p[2] & p[1] & p[0] & c[0]); 
 
        //-------------------------------------------------- 
        // Group 1 : bits [7:4] 
        // Uses group-start carry C4 
        //-------------------------------------------------- 
 
        c[5] = g[4] 
             | (p[4] & c[4]); 
 
        c[6] = g[5] 
             | (p[5] & g[4]) 
             | (p[5] & p[4] & c[4]); 
 
        c[7] = g[6] 
             | (p[6] & g[5]) 
             | (p[6] & p[5] & g[4]) 
             | (p[6] & p[5] & p[4] & c[4]); 
 
        //-------------------------------------------------- 
        // Group 2 : bits [11:8] 
        // Uses group-start carry C8 
        //-------------------------------------------------- 
 
        c[9] = g[8] 
             | (p[8] & c[8]); 
 
        c[10] = g[9] 
              | (p[9] & g[8]) 
              | (p[9] & p[8] & c[8]); 
 
        c[11] = g[10] 
              | (p[10] & g[9]) 
              | (p[10] & p[9] & g[8]) 
              | (p[10] & p[9] & p[8] & c[8]); 
 
        //-------------------------------------------------- 
        // Group 3 : bits [15:12] 
        // Uses group-start carry C12 
        //-------------------------------------------------- 
 
        c[13] = g[12] 
              | (p[12] & c[12]); 
 
        c[14] = g[13] 
              | (p[13] & g[12]) 
              | (p[13] & p[12] & c[12]); 
 
        c[15] = g[14] 
              | (p[14] & g[13]) 
              | (p[14] & p[13] & g[12]) 
              | (p[14] & p[13] & p[12] & c[12]); 
 
        //-------------------------------------------------- 
        // Sum Computation 
        //-------------------------------------------------- 
 
        for(i=0;i<WIDTH;i=i+1) 
            sum[i] = p[i] ^ c[i]; 
 
        //-------------------------------------------------- 
        // Output Flags 
        //-------------------------------------------------- 
 
        cout = c[16]; 
 
        // Signed overflow: 
        // operands same sign, result different sign 
        overflow = 
            (~(a[15] ^ b[15])) & 
             (a[15] ^ sum[15]); 
 
    end 
 
endmodule 
 
//-------------------------------------------------- 
// Power : Moderate (~1.5–2× RCA due to parallel 
//          carry-generation logic toggling) 
// Area  : ~150–180 gate equivalents after synthesis 
// Delay : ~5–6 logic levels (hierarchical CLA) 
// 
// Compared with RCA: 
// RCA Delay ≈ O(N) 
// CLA Delay ≈ O(log N) using group lookahead 
//--------------------------------------------------
