`timescale 1ns / 1ps 
//========================================================= 
// 16-bit Ripple Carry Adder (Dataflow Style) 
// Target FPGA : xc7a100tcsg324-2 
// 
// - Pure dataflow implementation 
// - generate-for + assign pattern 
// - 17-bit internal carry wire 
// - No always blocks 
// - Fully synthesizable 
//========================================================= 

 
module rca_16bit ( 
    input  wire [15:0] a, 
    input  wire [15:0] b, 
    input  wire        cin, 
    output wire [15:0] sum, 
    output wire        cout 
); 
 
    // Internal carry chain 
    wire [16:0] c; 
 
    // Initial carry input 
    assign c[0] = cin; 
 
    // Generate 16 ripple-carry stages 
    genvar j; 
    generate 
        for (j = 0; j < 16; j = j + 1) begin : stage 
 
            // stage[0]  -> Bit 0 
            // stage[1]  -> Bit 1 
            // ... 
            // stage[15] -> Bit 15 
 
            assign sum[j] = a[j] ^ b[j] ^ c[j]; 
 
            assign c[j+1] = (a[j] & b[j]) | 

                            (c[j] & (a[j] | b[j])); 
 
        end 
    endgenerate 
 
    // Final carry output 
    assign cout = c[16]; 
 
endmodule