`timescale 1ns/1ps 
 
//=====================================================================
= 
// SECTION 1: Bit-Stage Equation Table 
// 
//  Bit i   |  sum[i] Equation                  | carry[i+1] Equation 

// ----------+----------------------------------+---------------------------------- 
//    i      | sum[i] = a[i] ^ b[i] ^ carry[i]  | 
//           | carry[i+1] = (a[i] & b[i]) | 
//           |                (a[i] & carry[i]) | 
//           |                (b[i] & carry[i]) 
// 
//  Valid for i = 0,1,2,...,15 
//=====================================================================
= 
 
 
//=====================================================================
= 
// SECTION 2: Generate-Loop Structure Description 
// 
//  genvar bounds: 
//      i = 0 to 15 
// 
//  Internal carry width: 
//      wire [16:0] carry; 
// 
//  Carry mapping: 
//      carry[0]  = cin 
//      carry[1]  = carry from bit 0 
//      ... 
//      carry[16] = final carry 
// 
//  Output mapping: 
//      cout = carry[16] 

// 
//  Pure combinational implementation: 
//      • No clock 
//      • No flip-flops 
//      • No latches 
//=====================================================================
= 
 
 
module ripple_carry_adder_16 
( 
    input  wire [15:0] a, 
    input  wire [15:0] b, 
    input  wire        cin, 
 
    output wire [15:0] sum, 
    output wire        cout 
); 
 
    // 17-bit carry chain 
    wire [16:0] carry; 
 
    // Carry input 
    assign carry[0] = cin; 
 
    //================================================================== 
    // SECTION 3: Generate-For Loop 
    //================================================================== 

 
    genvar i; 
 
    generate 
 
        for (i = 0; i < 16; i = i + 1) begin : stage 
 
            // Bit i : SUM equation 
            assign sum[i] = 
                a[i] ^ b[i] ^ carry[i]; 
 
            // Bit i : CARRY equation 
            assign carry[i + 1] = 
                (a[i] & b[i]) | 
                (a[i] & carry[i]) | 
                (b[i] & carry[i]); 
 
        end 
 
    endgenerate 
 
    // Final carry output 
    assign cout = carry[16]; 
 
endmodule 
 
 

//=====================================================================
= 
// SECTION 4: PPA Summary 
// 
// Estimated LUT : <= 16 (implementation dependent) 
// Estimated FF  : 0 
// Target Fmax   : > 100 MHz 
// 
// Critical Path: 
//      cin -> carry[0] -> carry[1] -> ... -> carry[16] -> cout 
// 
// Synthesis Note: 
//      Vivado typically infers Artix-7 CARRY4 resources from 
//      this arithmetic coding style. A 16-bit ripple carry 
//      generally maps across four CARRY4 blocks. 
// 
// Dynamic Power: 
//      Depends on switching activity, routing, voltage, 
//      temperature, and implementation results. 
//=====================================================================
=