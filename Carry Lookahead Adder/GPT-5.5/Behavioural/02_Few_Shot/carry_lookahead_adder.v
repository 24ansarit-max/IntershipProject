`timescale 1ns/1ps 
 
module cla_behav_16bit 
#( 
    parameter WIDTH      = 16, 
    parameter GROUP_SIZE = 4 
) 
( 
    input  [WIDTH-1:0] a, 
    input  [WIDTH-1:0] b, 
    input              cin, 
 
    output reg [WIDTH-1:0] sum, 
    output reg             cout, 
    output reg             overflow 
); 
 
    reg [WIDTH-1:0] g; 
    reg [WIDTH-1:0] p; 
 
    reg [WIDTH:0] c; 
 
    // Group Generate / Propagate 
    reg [3:0] GG; 
    reg [3:0] GP; 
 
    integer i; 
 
    always @(*) begin 
 
        //-------------------------------------------------- 
        // Step 1 : Generate and Propagate 
        //-------------------------------------------------- 
 
        for(i=0;i<WIDTH;i=i+1) begin 
            g[i] = a[i] & b[i]; 
            p[i] = a[i] ^ b[i]; 
        end 
 
        //-------------------------------------------------- 
        // Step 2 : Group Generate / Propagate 
        //-------------------------------------------------- 
 
        GP[0] = p[3] & p[2] & p[1] & p[0]; 
 
        GG[0] = g[3] | 
               (p[3] & g[2]) | 
               (p[3] & p[2] & g[1]) | 
               (p[3] & p[2] & p[1] & g[0]); 
 
        GP[1] = p[7] & p[6] & p[5] & p[4]; 
 
        GG[1] = g[7] | 
               (p[7] & g[6]) | 
               (p[7] & p[6] & g[5]) | 
               (p[7] & p[6] & p[5] & g[4]); 
 
        GP[2] = p[11] & p[10] & p[9] & p[8]; 
 
        GG[2] = g[11] | 
               (p[11] & g[10]) | 
               (p[11] & p[10] & g[9]) | 
               (p[11] & p[10] & p[9] & g[8]); 
 
        GP[3] = p[15] & p[14] & p[13] & p[12]; 
 
        GG[3] = g[15] | 
               (p[15] & g[14]) | 
               (p[15] & p[14] & g[13]) | 
               (p[15] & p[14] & p[13] & g[12]); 
 
        //-------------------------------------------------- 
        // Step 3 : Group Carry Lookahead 
        //-------------------------------------------------- 
 
        c[0]  = cin; 
 
        c[4]  = GG[0] | 
               (GP[0] & c[0]); 
 
        c[8]  = GG[1] | 
               (GP[1] & GG[0]) | 
               (GP[1] & GP[0] & c[0]); 
 
        c[12] = GG[2] | 
               (GP[2] & GG[1]) | 
               (GP[2] & GP[1] & GG[0]) | 
               (GP[2] & GP[1] & GP[0] & c[0]); 
 
        c[16] = GG[3] | 
               (GP[3] & GG[2]) | 
               (GP[3] & GP[2] & GG[1]) | 
               (GP[3] & GP[2] & GP[1] & GG[0]) | 
               (GP[3] & GP[2] & GP[1] & GP[0] & c[0]); 
 
        //-------------------------------------------------- 
        // Step 4 : Intra-Group CLA Carries 
        //-------------------------------------------------- 
 
        // Group 0 : Bits [3:0] 
 
        c[1] = g[0] | 
              (p[0] & c[0]); 
 
        c[2] = g[1] | 
              (p[1] & g[0]) | 
              (p[1] & p[0] & c[0]); 
 
        c[3] = g[2] | 
              (p[2] & g[1]) | 
              (p[2] & p[1] & g[0]) | 
              (p[2] & p[1] & p[0] & c[0]); 
 
        // Group 1 : Bits [7:4] 
 
        c[5] = g[4] | 
              (p[4] & c[4]); 
 
        c[6] = g[5] | 
              (p[5] & g[4]) | 
              (p[5] & p[4] & c[4]); 
 
        c[7] = g[6] | 
              (p[6] & g[5]) | 
              (p[6] & p[5] & g[4]) | 
              (p[6] & p[5] & p[4] & c[4]); 
 
        // Group 2 : Bits [11:8] 
 
        c[9] = g[8] | 
              (p[8] & c[8]); 
 
        c[10] = g[9] | 
               (p[9] & g[8]) | 
               (p[9] & p[8] & c[8]); 
 
        c[11] = g[10] | 
               (p[10] & g[9]) | 
               (p[10] & p[9] & g[8]) | 
               (p[10] & p[9] & p[8] & c[8]); 
 
        // Group 3 : Bits [15:12] 
 
        c[13] = g[12] | 
               (p[12] & c[12]); 
 
        c[14] = g[13] | 
               (p[13] & g[12]) | 
               (p[13] & p[12] & c[12]); 
 
        c[15] = g[14] | 
               (p[14] & g[13]) | 
               (p[14] & p[13] & g[12]) | 
               (p[14] & p[13] & p[12] & c[12]); 
 
        //-------------------------------------------------- 
        // Step 5 : Sum 
        //-------------------------------------------------- 
 
        for(i=0;i<WIDTH;i=i+1) 
            sum[i] = p[i] ^ c[i]; 
 
        //-------------------------------------------------- 
        // Step 6 : Outputs 
        //-------------------------------------------------- 
 
        cout = c[16]; 
 
        overflow = 
            (a[WIDTH-1] == b[WIDTH-1]) && 
            (sum[WIDTH-1] != a[WIDTH-1]); 
 
    end 
 
endmodule 
 
// Power : Moderate-to-high due to parallel P/G generation 
//          and group lookahead logic active simultaneously. 
// 
// Area  : Larger than RCA; includes bit-level CLA logic, 
//          group propagate/generate network, and lookahead tree. 
//          ~150–200 equivalent gates (implementation dependent). 
// 
// Delay : Hierarchical CLA. 
//          G/P generation → group lookahead → intra-group carries → sum. 
//          Approximately O(log N), significantly faster than 
//          O(N) ripple-carry propagation.
