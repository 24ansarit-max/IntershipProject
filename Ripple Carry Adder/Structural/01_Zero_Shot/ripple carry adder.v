`timescale 1ns/1ps 
//====================================================== 
// 1-Bit Full Adder (Pure Structural - No assign) 
//====================================================== 
 

module full_adder ( 
    input  wire a, 
    input  wire b, 
    input  wire cin, 
    output wire sum, 
    output wire cout 
); 
 
    wire xor1; 
    wire and1, and2, and3; 
 
    // Sum = a ^ b ^ cin 
    xor (xor1, a, b); 
    xor (sum, xor1, cin); 
 
    // Carry = (a & b) | (a & cin) | (b & cin) 
    and (and1, a, b); 
    and (and2, a, cin); 
    and (and3, b, cin); 
 
    or (cout, and1, and2, and3); 
 
endmodule 
 
 
//====================================================== 
// 16-Bit Ripple Carry Adder (Pure Structural) 
// No assign statements used 

//====================================================== 
 
module rca16 ( 
    input  wire [15:0] a, 
    input  wire [15:0] b, 
    input  wire        cin, 
    output wire [15:0] sum, 
    output wire        cout 
); 
 
    wire [16:0] carry; 
 
    // Connect input carry 
    buf (carry[0], cin); 
 
    genvar i; 
    generate 
        for (i = 0; i < 16; i = i + 1) begin : fa_chain 
 
            // Bit i Full Adder Instance 
 
            full_adder fa_inst ( 
                .a   (a[i]), 
                .b   (b[i]), 
                .cin (carry[i]), 
                .sum (sum[i]), 
                .cout(carry[i+1]) 
            ); 

 
        end 
    endgenerate 
 
    // Connect final carry-out 
    buf (cout, carry[16]); 
 
endmodule