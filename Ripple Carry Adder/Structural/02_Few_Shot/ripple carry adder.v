`timescale 1ns/1ps 
 
//========================================================= 
// 1-Bit Full Adder (No assign statements) 
//========================================================= 
 
module fa ( 
    input  a, 
    input  b, 
    input  cin, 
    output sum, 

    output cout 
); 
 
    wire x1; 
    wire a1, a2, a3; 
 
    // Sum = a ^ b ^ cin 
    xor (x1,  a,  b); 
    xor (sum, x1, cin); 
 
    // Carry = (a & b) | (b & cin) | (a & cin) 
    and (a1, a, b); 
    and (a2, b, cin); 
    and (a3, a, cin); 
 
    or (cout, a1, a2, a3); 
 
endmodule 
 
 
//========================================================= 
// 16-Bit Ripple Carry Adder (Structural) 
// No assign statements used 
//========================================================= 
 
module rca16 ( 
    input  [15:0] a, 
    input  [15:0] b, 

    input         cin, 
    output [15:0] sum, 
    output        cout 
); 
 
    wire [16:0] c; 
 
    // Connect input carry without assign 
    buf (c[0], cin); 
 
    genvar k; 
    generate 
        for (k = 0; k < 16; k = k + 1) begin : fa_unit 
 
            // fa_unit[k] : Full Adder for bit k 
 
            fa u_fa ( 
                .a   (a[k]), 
                .b   (b[k]), 
                .cin (c[k]), 
                .sum (sum[k]), 
                .cout(c[k+1]) 
            ); 
 
        end 
    endgenerate 
 
    // Connect final carry without assign 

    buf (cout, c[16]); 
 
endmodule