`timescale 1ns/1ps 
 
//========================================================= 
// 1-Bit Full Adder (No assign) 
//========================================================= 
module full_adder ( 
    input  a, 
    input  b, 
    input  cin, 
    output sum, 
    output cout 

); 
 
    wire x1; 
    wire w1, w2, w3; 
 
    // Sum = a ^ b ^ cin 
    xor (x1,  a,  b); 
    xor (sum, x1, cin); 
 
    // Carry = (a & b) | (a & cin) | (b & cin) 
    and (w1, a, b); 
    and (w2, a, cin); 
    and (w3, b, cin); 
 
    or  (cout, w1, w2, w3); 
 
endmodule 
 
 
//========================================================= 
// 16-Bit Ripple Carry Adder (No assign) 
//========================================================= 
module rca16 ( 
    input  [15:0] a, 
    input  [15:0] b, 
    input         cin, 
    output [15:0] sum, 
    output        cout 

); 
 
    wire [16:0] carry; 
 
    // carry[0] = cin 
    buf (carry[0], cin); 
 
    genvar i; 
    generate 
        for (i = 0; i < 16; i = i + 1) begin : fa_unit 
 
            // Full Adder for bit i 
 
            full_adder fa_inst ( 
                .a(a[i]), 
                .b(b[i]), 
                .cin(carry[i]), 
                .sum(sum[i]), 
                .cout(carry[i+1]) 
            ); 
 
        end 
    endgenerate 
 
    // cout = carry[16] 
    buf (cout, carry[16]); 
 
endmodule