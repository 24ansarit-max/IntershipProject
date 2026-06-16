`timescale 1ns/1ps 
//=====================================================================
= 
// 16-bit Ripple Carry Adder 
// Style  : Dataflow (generate-for + assign only) 
// Target : xc7a100tcsg324-2 (Artix-7) 
// 
// Design Constraints: 
// 
// [C1] Carry-chain optimized coding style intended to enable 
//      synthesis-tool inference of dedicated carry resources. 
// 
// [C2] Area-conscious implementation using one generated stage 
//      per bit. Actual LUT mapping is synthesis dependent. 
// 
// [C3] Pure combinational logic with minimal logic depth. 
//      Actual dynamic power depends on switching activity, 
//      placement/routing, voltage, and operating conditions. 
// 

// [C4] Mandatory generate-for loop with genvar. 
// 
// [C5] FF = 0 (no sequential logic). 
// 
// [C6] No latches (no always blocks used). 
// 
// [C7] Dataflow style: assign statements only. 
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
 
    // Initial carry 
    // 
    // [C4] generate-based architecture 
    // [C5] pure combinational 
    // [C7] assign-only style 

    assign carry[0] = cin; 
 
    genvar i; 
 
    generate 
 
        for (i = 0; i < 16; i = i + 1) begin : carry_stage 
 
            // ---------------------------------------------------------- 
            // SUM STAGE i 
            // 
            // [C1] stage i, carry-chain compatible arithmetic form 
            // [C2] contributes one bit of the 16-bit datapath 
            // [C7] assign-only dataflow implementation 
            // ---------------------------------------------------------- 
 
            assign sum[i] = 
                a[i] ^ b[i] ^ carry[i]; 
 
            // ---------------------------------------------------------- 
            // CARRY STAGE i 
            // 
            // [C1] stage i, depth = 1 ripple stage 
            // [C2] expected grouping into: 
            //      bits  0-3  -> CARRY4 block 0 
            //      bits  4-7  -> CARRY4 block 1 
            //      bits  8-11 -> CARRY4 block 2 
            //      bits 12-15 -> CARRY4 block 3 

            // 
            // [C7] assign-only dataflow implementation 
            // ---------------------------------------------------------- 
 
            assign carry[i + 1] = 
                (a[i] & b[i]) | 
                (a[i] & carry[i]) | 
                (b[i] & carry[i]); 
 
        end 
 
    endgenerate 
 
    // Final carry output 
    // 
    // [C1] terminates ripple carry chain 
    // [C5] pure combinational 
    // [C7] assign-only style 
    assign cout = carry[16]; 
 
endmodule