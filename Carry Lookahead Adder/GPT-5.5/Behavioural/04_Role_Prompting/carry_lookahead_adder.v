`timescale 1ns/1ps 
 
//====================================================================== 
// 16-Bit Carry Lookahead Adder (CLA) 
//---------------------------------------------------------------------- 
// THEORY: 
// 
// A Ripple Carry Adder (RCA) computes carries sequentially: 
// 
//   C1 depends on C0 
//   C2 depends on C1 
//   C3 depends on C2 
//   ... 
// 
// Therefore the worst-case delay grows linearly: 
// 
//   Delay_RCA = O(N) 
// 
// Carry Lookahead Adders remove this dependency by precomputing: 
// 
//   Generate : G[i] = A[i] & B[i] 
//   Propagate: P[i] = A[i] ^ B[i] 
// 
// and using these signals to predict carries directly. 
// 
// This implementation divides the 16-bit adder into four 4-bit groups 
// and uses a second level of lookahead between groups. 
// 
// Result: 
// 
//   Faster carry computation 
//   Higher area 
//   Higher dynamic power 
// 
// but significantly better timing than a ripple adder. 
//====================================================================== 
 
module cla_16bit_behavioral 
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
 
    //------------------------------------------------------------------ 
    // Internal Signals 
    //------------------------------------------------------------------ 
    // 
    // g[i] = Generate 
    // p[i] = Propagate 
    // 
    // c[i] = Carry into bit i 
    // 
    //------------------------------------------------------------------ 
 
    reg [WIDTH-1:0] g; 
    reg [WIDTH-1:0] p; 
 
    reg [WIDTH:0] c; 
 
    //------------------------------------------------------------------ 
    // Group Generate / Propagate 
    //------------------------------------------------------------------ 
    // 
    // GG[k] indicates that the entire group generates a carry 
    // regardless of the incoming carry. 
    // 
    // GP[k] indicates that the entire group propagates an incoming carry. 
    // 
    //------------------------------------------------------------------ 
 
    reg [3:0] GG; 
    reg [3:0] GP; 
 
    integer i; 
 
    always @(*) begin 
 
        //------------------------------------------------------------------ 
        // 1. Generate / Propagate Computation 
        //------------------------------------------------------------------ 
        // 
        // For each bit: 
        // 
        // G[i] = A[i] * B[i] 
        // P[i] = A[i] XOR B[i] 
        // 
        // Generate means: 
        //   this bit definitely produces a carry. 
        // 
        // Propagate means: 
        //   this bit passes an incoming carry through. 
        // 
        // Power: 
        //   XOR gates tend to have relatively high switching activity. 
        // 
        // Area: 
        //   Requires additional logic compared to RCA. 
        // 
        // Delay: 
        //   Enables parallel carry prediction instead of carry ripple. 
        //------------------------------------------------------------------ 
 
        for(i=0;i<WIDTH;i=i+1) begin 
            g[i] = a[i] & b[i]; 
            p[i] = a[i] ^ b[i]; 
        end 
 
        //------------------------------------------------------------------ 
        // 2. Group Generate / Group Propagate 
        //------------------------------------------------------------------ 
        // 
        // Each 4-bit block is summarized by: 
        // 
        // GP = P3P2P1P0 
        // 
        // GG = G3 
        //    + P3G2 
        //    + P3P2G1 
        //    + P3P2P1G0 
        // 
        // This reduces a 4-bit block into a single carry entity. 
        // 
        // Power: 
        //   Additional logic toggles every cycle. 
        // 
        // Area: 
        //   Larger than RCA due to lookahead network. 
        // 
        // Delay: 
        //   Allows group carries to be computed in parallel. 
        //------------------------------------------------------------------ 
 
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
 
        //------------------------------------------------------------------ 
        // 3. Inter-Group Carry Lookahead 
        //------------------------------------------------------------------ 
        // 
        // Instead of waiting for carries to travel through groups, 
        // compute them directly. 
        // 
        // C4  = GG0 + GP0*C0 
        // 
        // C8  = GG1 + GP1*GG0 
        //             + GP1*GP0*C0 
        // 
        // C12 = GG2 + GP2*GG1 
        //             + GP2*GP1*GG0 
        //             + GP2*GP1*GP0*C0 
        // 
        // C16 = GG3 + GP3*GG2 
        //             + GP3*GP2*GG1 
        //             + GP3*GP2*GP1*GG0 
        //             + GP3*GP2*GP1*GP0*C0 
        // 
        // Power: 
        //   High-fanout carry nodes may consume significant power. 
        // 
        // Area: 
        //   Additional carry logic required. 
        // 
        // Delay: 
        //   Major improvement over ripple carry. 
        //------------------------------------------------------------------ 
 
        c[0] = cin; 
 
        c[4] = 
            GG[0] | 
            (GP[0] & c[0]); 
 
        c[8] = 
            GG[1] | 
            (GP[1] & GG[0]) | 
            (GP[1] & GP[0] & c[0]); 
 
        c[12] = 
            GG[2] | 
            (GP[2] & GG[1]) | 
            (GP[2] & GP[1] & GG[0]) | 
            (GP[2] & GP[1] & GP[0] & c[0]); 
 
        c[16] = 
            GG[3] | 
            (GP[3] & GG[2]) | 
            (GP[3] & GP[2] & GG[1]) | 
            (GP[3] & GP[2] & GP[1] & GG[0]) | 
            (GP[3] & GP[2] & GP[1] & GP[0] & c[0]); 
 
        //------------------------------------------------------------------ 
        // 4. Intra-Group Carry Lookahead 
        //------------------------------------------------------------------ 
        // 
        // Within each 4-bit group we also avoid ripple carry. 
        // 
        // Example: 
        // 
        // C2 = G1 + P1G0 + P1P0Cin 
        // 
        // Every carry is derived directly from G/P terms. 
        // 
        // Delay: 
        //   Constant within each group. 
        //------------------------------------------------------------------ 
 
        c[1] = g[0] | (p[0] & c[0]); 
 
        c[2] = g[1] | 
              (p[1] & g[0]) | 
              (p[1] & p[0] & c[0]); 
 
        c[3] = g[2] | 
              (p[2] & g[1]) | 
              (p[2] & p[1] & g[0]) | 
              (p[2] & p[1] & p[0] & c[0]); 
 
        c[5] = g[4] | (p[4] & c[4]); 
 
        c[6] = g[5] | 
              (p[5] & g[4]) | 
              (p[5] & p[4] & c[4]); 
 
        c[7] = g[6] | 
              (p[6] & g[5]) | 
              (p[6] & p[5] & g[4]) | 
              (p[6] & p[5] & p[4] & c[4]); 
 
        c[9] = g[8] | (p[8] & c[8]); 
 
        c[10] = g[9] | 
               (p[9] & g[8]) | 
               (p[9] & p[8] & c[8]); 
 
        c[11] = g[10] | 
               (p[10] & g[9]) | 
               (p[10] & p[9] & g[8]) | 
               (p[10] & p[9] & p[8] & c[8]); 
 
        c[13] = g[12] | (p[12] & c[12]); 
 
        c[14] = g[13] | 
               (p[13] & g[12]) | 
               (p[13] & p[12] & c[12]); 
 
        c[15] = g[14] | 
               (p[14] & g[13]) | 
               (p[14] & p[13] & g[12]) | 
               (p[14] & p[13] & p[12] & c[12]); 
 
        //------------------------------------------------------------------ 
        // 5. Sum Computation 
        //------------------------------------------------------------------ 
        // 
        // Once carries are known: 
        // 
        // SUM[i] = P[i] XOR C[i] 
        // 
        // Since carries were predicted in parallel, 
        // sum bits become available much sooner than RCA. 
        // 
        // Power: 
        //   XOR stage has relatively high switching activity. 
        // 
        // Area: 
        //   Same XOR count as RCA. 
        // 
        // Delay: 
        //   Carry delay is greatly reduced. 
        //------------------------------------------------------------------ 
 
        for(i=0;i<WIDTH;i=i+1) 
            sum[i] = p[i] ^ c[i]; 
 
        //------------------------------------------------------------------ 
        // 6. Output Carry 
        //------------------------------------------------------------------ 
 
        cout = c[16]; 
 
        //------------------------------------------------------------------ 
        // 7. Overflow Detection 
        //------------------------------------------------------------------ 
        // 
        // Signed overflow occurs when: 
        // 
        // Carry into MSB ≠ Carry out of MSB 
        // 
        // Overflow = C15 XOR C16 
        // 
        // Example: 
        // 
        //   0111_1111 + 0000_0001 
        // 
        // produces: 
        // 
        //   1000_0000 
        // 
        // which cannot be represented correctly as a signed value. 
        //------------------------------------------------------------------ 
 
        overflow = c[15] ^ c[16]; 
 
    end 
 
endmodule 
 
//====================================================================== 
// SUMMARY 
//---------------------------------------------------------------------- 
// Ripple Carry Adder: 
//     Delay = O(N) 
// 
// Carry Lookahead Adder: 
//     Delay ≈ O(log N) 
// 
// Trade-Offs: 
// 
//   Faster: 
//       Carries computed in parallel. 
// 
//   Larger: 
//       Additional lookahead logic required. 
// 
//   Higher Dynamic Power: 
//       More gates evaluate simultaneously. 
// 
// The CLA is therefore preferred in high-performance ALUs where 
// timing is more important than minimum area. 
//======================================================================
