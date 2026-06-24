`timescale 1ns/1ps 
//=====================================================================
= 
// 16-bit Ripple Carry Adder (Dataflow Style) 
// Target Device : xc7a100tcsg324-2 (Artix-7) 
// 
// Pure combinational implementation 
// FF = 0 
// 
// Internal carry width: 
//   carry[16:0] 
//      carry[0]  = cin 
//      carry[16] = cout 
// 
// Vivado Note: 
//   This coding style is commonly recognized by Vivado and 
//   typically infers the dedicated CARRY4 carry chain for 
//   arithmetic addition rather than implementing the carry 
//   path entirely in LUT logic. 
// 
// Timing Note: 
//   Longest path is the ripple carry chain from carry[0] 
//   through carry[16]. 
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
 
    // Initial carry input 
    assign carry[0] = cin; 
 
    genvar i; 
 
    generate 
        for (i = 0; i < 16; i = i + 1) begin : carry_stage 
 
            // ---------------------------------------------------------- 
            // SUM PATH 
            // 
            // sum[i] = a[i] ^ b[i] ^ carry[i] 
            // 
            // Vivado typically maps the arithmetic sum function 
            // alongside the inferred CARRY4 structure (corresponding 

            // to the sum/output path of the carry logic). 
            // ---------------------------------------------------------- 
 
            assign sum[i] = 
                a[i] ^ b[i] ^ carry[i]; 
 
            // ---------------------------------------------------------- 
            // CARRY PATH 
            // 
            // carry[i+1] = 
            //      (a[i] & b[i]) 
            //    | (a[i] & carry[i]) 
            //    | (b[i] & carry[i]) 
            // 
            // Vivado typically recognizes this majority function as 
            // carry propagation and maps it onto the inferred CARRY4 
            // carry-output chain. 
            // ---------------------------------------------------------- 
 
            assign carry[i+1] = 
                (a[i] & b[i]) | 
                (a[i] & carry[i]) | 
                (b[i] & carry[i]); 
 
        end 
    endgenerate 
 
    // Final carry output 

    assign cout = carry[16]; 
 
endmodule