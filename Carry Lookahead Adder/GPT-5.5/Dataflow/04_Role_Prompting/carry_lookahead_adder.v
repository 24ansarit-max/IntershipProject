`timescale 1ns/1ps 
 
module cla_16bit_low_power 
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
 
    //---------------------------------------------------------- 
    // Generate / Propagate 
    //---------------------------------------------------------- 
 
    wire [WIDTH-1:0] G; 
    wire [WIDTH-1:0] P; 
 
    genvar i; 
 
    generate 
        for(i=0;i<WIDTH;i=i+1) 
        begin : PG_GEN 
 
            assign G[i] = a[i] & b[i]; 
            // α ≈ 0.25 (AND gate, random inputs) 
 
            assign P[i] = a[i] ^ b[i]; 
            // α ≈ 0.50 (XOR gate, random inputs) 
 
        end 
    endgenerate 
 
    //---------------------------------------------------------- 
    // Carry Network 
    //---------------------------------------------------------- 
 
    wire [WIDTH:0] C; 
 
    assign C[0] = cin; 
    // α depends on external source 
 
    //---------------------------------------------------------- 
    // Group 0 
    //---------------------------------------------------------- 
 
    assign C[1] = 
        G[0] | 
        (P[0] & C[0]); 
    // α ≈ 0.25 
 
    assign C[2] = 
        G[1] | 
        (P[1] & G[0]) | 
        (P[1] & P[0] & C[0]); 
    // α ≈ 0.20 
 
    assign C[3] = 
        G[2] | 
        (P[2] & G[1]) | 
        (P[2] & P[1] & G[0]) | 
        (P[2] & P[1] & P[0] & C[0]); 
    // α ≈ 0.15 
 
    assign C[4] = 
        G[3] | 
        (P[3] & G[2]) | 
        (P[3] & P[2] & G[1]) | 
        (P[3] & P[2] & P[1] & G[0]) | 
        (P[3] & P[2] & P[1] & P[0] & C[0]); 
    // α ≈ 0.10 
    // HIGH-FAN-OUT NODE — consider buffering to reduce glitch propagation 
 
    //---------------------------------------------------------- 
    // Group 1 
    //---------------------------------------------------------- 
 
    assign C[5] = 
        G[4] | 
        (P[4] & C[4]); 
    // α ≈ 0.25 
 
    assign C[6] = 
        G[5] | 
        (P[5] & G[4]) | 
        (P[5] & P[4] & C[4]); 
    // α ≈ 0.20 
 
    assign C[7] = 
        G[6] | 
        (P[6] & G[5]) | 
        (P[6] & P[5] & G[4]) | 
        (P[6] & P[5] & P[4] & C[4]); 
    // α ≈ 0.15 
 
    assign C[8] = 
        G[7] | 
        (P[7] & G[6]) | 
        (P[7] & P[6] & G[5]) | 
        (P[7] & P[6] & P[5] & G[4]) | 
        (P[7] & P[6] & P[5] & P[4] & C[4]); 
    // α ≈ 0.10 
    // HIGH-FAN-OUT NODE — consider buffering to reduce glitch propagation 
 
    //---------------------------------------------------------- 
    // Group 2 
    //---------------------------------------------------------- 
 
    assign C[9] = 
        G[8] | 
        (P[8] & C[8]); 
    // α ≈ 0.25 
 
    assign C[10] = 
        G[9] | 
        (P[9] & G[8]) | 
        (P[9] & P[8] & C[8]); 
    // α ≈ 0.20 
 
    assign C[11] = 
        G[10] | 
        (P[10] & G[9]) | 
        (P[10] & P[9] & G[8]) | 
        (P[10] & P[9] & P[8] & C[8]); 
    // α ≈ 0.15 
 
    assign C[12] = 
        G[11] | 
        (P[11] & G[10]) | 
        (P[11] & P[10] & G[9]) | 
        (P[11] & P[10] & P[9] & G[8]) | 
        (P[11] & P[10] & P[9] & P[8] & C[8]); 
    // α ≈ 0.10 
    // HIGH-FAN-OUT NODE — consider buffering to reduce glitch propagation 
 
    //---------------------------------------------------------- 
    // Group 3 
    //---------------------------------------------------------- 
 
    assign C[13] = 
        G[12] | 
        (P[12] & C[12]); 
    // α ≈ 0.25 
 
    assign C[14] = 
        G[13] | 
        (P[13] & G[12]) | 
        (P[13] & P[12] & C[12]); 
    // α ≈ 0.20 
 
    assign C[15] = 
        G[14] | 
        (P[14] & G[13]) | 
        (P[14] & P[13] & G[12]) | 
        (P[14] & P[13] & P[12] & C[12]); 
    // α ≈ 0.15 
 
    assign C[16] = 
        G[15] | 
        (P[15] & G[14]) | 
        (P[15] & P[14] & G[13]) | 
        (P[15] & P[14] & P[13] & G[12]) | 
        (P[15] & P[14] & P[13] & P[12] & C[12]); 
    // α ≈ 0.10 
 
    //---------------------------------------------------------- 
    // Sum Logic 
    //---------------------------------------------------------- 
 
    generate 
        for(i=0;i<WIDTH;i=i+1) 
        begin : SUM_GEN 
 
            assign sum[i] = P[i] ^ C[i]; 
            // α ≈ 0.50 (XOR output) 
 
        end 
    endgenerate 
 
    //---------------------------------------------------------- 
    // Outputs 
    //---------------------------------------------------------- 
 
    assign cout = C[16]; 
    // α ≈ 0.10 
 
    assign overflow = C[15] ^ C[16]; 
    // α ≈ 0.25 
 
endmodule 
 
//-------------------------------------------------------------------- 
// Dynamic Power Estimate 
//-------------------------------------------------------------------- 
// 
// P_dyn = α × C_load × V² × f 
// 
// Assumptions: 
//   V       = 1.2 V 
//   f       = 250 MHz 
//   C_load  = 10 fF 
// 
// Example: Group Carry C4 
// 
//   α       ≈ 0.10 
//   P_dyn   = 0.10 × 10e-15 × (1.2)^2 × 250e6 
//           ≈ 0.36 µW 
// 
// Example: Group Carry C8 
// 
//   α       ≈ 0.10 
//   P_dyn   ≈ 0.36 µW 
// 
// Example: Group Carry C12 
// 
//   α       ≈ 0.10 
//   P_dyn   ≈ 0.36 µW 
// 
// Total CLA Dynamic Power (rough estimate) 
// 
//   ~50-100 equivalent switching nodes 
//   Average α ≈ 0.20 
// 
//   Estimated total: 
//   ≈ 35-70 µW @ 250 MHz, 1.2 V 
// 
// Actual power depends heavily on: 
//   - input statistics 
//   - wire capacitance 
//   - placement/routing 
//   - glitch activity 
// 
//-------------------------------------------------------------------- 
// POWER_OPT 
//-------------------------------------------------------------------- 
// 
// Replace upper 8 bits (bits[15:8]) with a Carry-Select Adder. 
// 
// Benefits: 
//   - Reduces large global lookahead fan-out 
//   - Reduces glitch propagation through deep CLA trees 
//   - Often lowers dynamic power at moderate frequencies 
//   - Maintains high performance 
// 
// Alternative: 
//   Pipeline the group carries (C4/C8/C12) 
//   to reduce simultaneous switching activity. 
// 
//-------------------------------------------------------------------- 
// Area  : ~160 equivalent gates 
// Delay : ~4-5 logic levels (faster than RCA) 
// Power : Higher than RCA due to parallel carry evaluation, 
//          but can be optimized through buffering and hierarchy. 
//--------------------------------------------------------------------
