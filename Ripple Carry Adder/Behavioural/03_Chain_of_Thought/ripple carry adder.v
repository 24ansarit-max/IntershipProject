`timescale 1ns/1ps 
//========================================================= 
// 16-bit Ripple Carry Adder 
// Behavioral RTL using a for loop 
// 
// Target: xc7a100tcsg324-2 
// 
// Notes: 
// Step 1: Uses full-adder equations 
// Step 2: for-loop is an RTL coding convenience and is 
//         synthesized into combinational hardware 
// Step 3: Critical path is the carry ripple to bit 15 
// Step 4: All outputs assigned in every execution 
// 
// Expected implementation: 
//   FF   : 0 
//   LUTs : Tool/device dependent; typically optimized using 
//          Xilinx carry-chain (CARRY4) resources 

//========================================================= 
 
module rca_16bit ( 
    input  wire [15:0] a, 
    input  wire [15:0] b, 
    input  wire        cin, 
    output reg  [15:0] sum, 
    output reg         cout 
); 
 
    reg [16:0] carry; 
    integer i; 
 
    always @(*) begin 
 
        // Step 4: Initialize outputs 
        sum  = 16'b0; 
        cout = 1'b0; 
 
        // Step 1: Initial carry 
        carry[0] = cin; 
 
        // Step 2: Synthesizer unrolls this into 
        // 16 combinational full-adder stages. 
        for (i = 0; i < 16; i = i + 1) begin 
 
            // Full-adder sum equation 
            sum[i] = a[i] ^ b[i] ^ carry[i]; 

 
            // Full-adder carry (majority function) 
            carry[i+1] = 
                (a[i] & b[i]) | 
                (a[i] & carry[i]) | 
                (b[i] & carry[i]); 
 
            // Step 3: 
            // When i == 15, this stage lies on the 
            // longest ripple-carry critical path. 
        end 
 
        // Final carry-out 
        cout = carry[16]; 
    end 
 
endmodule