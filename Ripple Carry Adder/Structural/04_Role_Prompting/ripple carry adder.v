`timescale 1ns / 1ps 
 
//============================================================ 
// Module  : full_adder 
// Function: 1-bit combinational full adder 
// Inputs  : a, b, cin 
// Outputs : sum, cout 
// PPA     : FF = 0, typically maps efficiently to FPGA 
//           arithmetic resources; critical path is through 
//           carry generation. 
//============================================================ 
module full_adder ( 
    input  wire a, 
    input  wire b, 
    input  wire cin, 
    output wire sum, 
    output wire cout 
); 
 
    // Sum logic 
    xor (sum_ab, a, b); 
    xor (sum, sum_ab, cin); 
 
    // Carry logic 
    wire ab; 
    wire ac; 
    wire bc; 

 
    and (ab, a, b); 
    and (ac, a, cin); 
    and (bc, b, cin); 
 
    or (cout, ab, ac, bc); 
 
endmodule 
 
 
//============================================================ 
// Module  : rca16 
// Function: 16-bit structural ripple carry adder 
// Inputs  : a[15:0], b[15:0], cin 
// Outputs : sum[15:0], cout 
// PPA     : FF = 0, LUT estimate depends on synthesis and 
//           carry-chain inference, critical path is the 
//           ripple carry chain from cin to cout. 
//============================================================ 
module rca16 ( 
    input  wire [15:0] a, 
    input  wire [15:0] b, 
    input  wire        cin, 
    output wire [15:0] sum, 
    output wire        cout 
); 
 
    // Internal carry chain (17 bits) 

    wire [16:0] carry; 
 
    // Connect input carry without assign 
    buf (carry[0], cin); 
 
    // 16 generated full-adder instances 
    genvar i; 
    generate 
        for (i = 0; i < 16; i = i + 1) begin : fa_chain 
 
            full_adder fa_inst ( 
                .a   (a[i]), 
                .b   (b[i]), 
                .cin (carry[i]), 
                .sum (sum[i]), 
                .cout(carry[i+1]) 
            ); 
 
        end 
    endgenerate 
 
    // Connect final carry-out without assign 
    buf (cout, carry[16]); 
 
endmodule