`timescale 1ns / 1ps 
//========================================================= 
// 16-bit Ripple Carry Adder (Behavioral) 
// Target FPGA : xc7a100tcsg324-2 
// 
// - Pure combinational 
// - 16-iteration for loop 
// - 17-bit internal carry register 
// - No clock 
// - No inferred latches 
//========================================================= 
 

module rca_16bit ( 
    input  [15:0] a, 
    input  [15:0] b, 
    input         cin, 
    output reg [15:0] sum, 
    output reg        cout 
); 
 
    reg [16:0] carry; 
    integer i; 
 
    always @(*) begin 
 
        // Initialize carry input (same pattern as 4-bit example) 
        carry[0] = cin; 
 
        // Initialize outputs to avoid latch inference 
        sum  = 16'b0; 
        cout = 1'b0; 
 
        // Same for-loop pattern as the 4-bit example, 
        // scaled from 4 iterations to 16 iterations. 
        for (i = 0; i < 16; i = i + 1) begin 
 
            // Example pattern: 
            // sum[i]     = a[i] ^ b[i] ^ carry[i]; 
            // carry[i+1] = (a[i] & b[i]) | 
            //              (b[i] & carry[i]) | 

            //              (a[i] & carry[i]); 
 
            sum[i]     = a[i] ^ b[i] ^ carry[i]; 
            carry[i+1] = (a[i] & b[i]) | 
                          (b[i] & carry[i]) | 
                          (a[i] & carry[i]); 
        end 
 
        // Final carry-out (same pattern as 4-bit example) 
        cout = carry[16]; 
 
    end 
 
endmodule