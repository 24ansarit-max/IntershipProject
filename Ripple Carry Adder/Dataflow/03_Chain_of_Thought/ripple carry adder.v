`timescale 1ns/1ps 
//========================================================= 
// 16-bit Ripple Carry Adder 
// Dataflow Style (generate-for + assign) 
// 
// Target: xc7a100tcsg324-2 
// 
// Pure combinational 
// FF = 0 

//========================================================= 
 
module rca16 ( 
    input  wire [15:0] a, 
    input  wire [15:0] b, 
    input  wire        cin, 
    output wire [15:0] sum, 
    output wire        cout 
); 
 
    // 17-bit carry chain 
    wire [16:0] carry; 
 
    // Step 3: 
    // Initial carry 
    assign carry[0] = cin; 
 
    genvar i; 
 
    generate 
        for (i = 0; i < 16; i = i + 1) begin : stage 
 
            // stage[i] 
 
            // Step 1: 
            // sum = XOR3(a,b,carry) 
            assign sum[i] = 
                a[i] ^ b[i] ^ carry[i]; 

 
            // Step 2: 
            // carry = majority(a,b,carry) 
            assign carry[i+1] = 
                (a[i] & b[i]) | 
                (a[i] & carry[i]) | 
                (b[i] & carry[i]); 
 
        end 
    endgenerate 
 
    // Step 3: 
    // Final carry-out 
    assign cout = carry[16]; 
 
endmodule