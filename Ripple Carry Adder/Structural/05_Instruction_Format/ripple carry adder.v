`timescale 1ns / 1ps 
 
// ==================================================================== 
// ===== MODULE NAME : full_adder ===== 
// ==================================================================== 
 
module full_adder 
( 
    input  wire a,    // Operand A bit 
    input  wire b,    // Operand B bit 
    input  wire cin,  // Carry-in from previous stage 

 
    output wire sum,  // Sum output 
    output wire cout  // Carry-out to next stage 
); 
 
    assign sum  = a ^ b ^ cin; 
 
    assign cout = (a & b) | 
                  (a & cin) | 
                  (b & cin); 
 
endmodule 
 
 
// ==================================================================== 
// ===== MODULE NAME : rca16 ===== 
// ==================================================================== 
 
module rca16 
( 
    input  wire [15:0] a,    // 16-bit operand A 
    input  wire [15:0] b,    // 16-bit operand B 
    input  wire        cin,  // Carry-in from LSB 
 
    output wire [15:0] sum,  // 16-bit sum 
    output wire        cout  // Final carry-out 
); 
 

    // Internal carry chain 
    wire [16:0] carry; 
 
    assign carry[0] = cin; 
 
    genvar i; 
 
    generate 
 
        begin : fa_gen 
 
            for (i = 0; i < 16; i = i + 1) begin : stage 
 
                full_adder fa_inst 
                ( 
                    .a   (a[i]), 
                    .b   (b[i]), 
                    .cin (carry[i]), 
                    .sum (sum[i]), 
                    .cout(carry[i + 1]) 
                ); 
 
            end 
 
        end 
 
    endgenerate 
 

    assign cout = carry[16]; 
 
endmodule 
 
 
// ==================================================================== 
// PPA SUMMARY 
// 
// LUT  = <= 16 (implementation dependent) 
// FF   = 0 
// Fmax = > 100 MHz target 
// ====================================================================