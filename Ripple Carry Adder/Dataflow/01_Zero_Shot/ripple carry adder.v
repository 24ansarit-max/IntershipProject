`timescale 1ns / 1ps 
//============================================================== 
// 16-bit Ripple Carry Adder (Dataflow Style) 
// Target FPGA : xc7a100tcsg324-2 (Artix-7 / Nexys A7) 

// 
// Features: 
// - Pure dataflow implementation 
// - Generate-for loop with continuous assign statements 
// - No always blocks 
// - No flip-flops or latches 
// - Fully synthesizable 
// - Optimized for FPGA carry-chain inference 
//============================================================== 
 
module ripple_carry_adder_16_dataflow ( 
    input  wire [15:0] a, 
    input  wire [15:0] b, 
    input  wire        cin, 
 
    output wire [15:0] sum, 
    output wire        cout 
); 
 
    // Internal carry chain 
    wire [16:0] carry; 
 
    // Initial carry input 
    assign carry[0] = cin; 
 
    // Generate 16 full-adder stages 
    genvar i; 
    generate 

        for (i = 0; i < 16; i = i + 1) begin : GEN_FULL_ADDER 
 
            // -------------------------------------------------- 
            // Full Adder Instance Index: i 
            // 
            // sum[i]     = a[i] ^ b[i] ^ carry[i] 
            // carry[i+1] = (a[i] & b[i]) | 
            //              (b[i] & carry[i]) | 
            //              (a[i] & carry[i]) 
            // -------------------------------------------------- 
 
            assign sum[i] = 
                a[i] ^ b[i] ^ carry[i]; 
 
            assign carry[i + 1] = 
                (a[i] & b[i]) | 
                (b[i] & carry[i]) | 
                (a[i] & carry[i]); 
 
        end 
    endgenerate 
 
    // Final carry-out 
    assign cout = carry[16]; 
 
endmodule