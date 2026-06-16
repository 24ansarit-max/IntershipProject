`timescale 1ns/1ps 
 

//========================================================== 
// Module : full_adder 
// matches Plan: 1-bit combinational sub-module 
//========================================================== 
 
module full_adder 
( 
    input  wire a, 
    input  wire b, 
    input  wire cin, 
    output wire sum, 
    output wire cout 
); 
 
    assign sum  = a ^ b ^ cin; 
 
    assign cout = (a & b) | 
                  (a & cin) | 
                  (b & cin); 
 
endmodule 
 
 
//========================================================== 
// Module : rca16 
// matches Plan: generate-for replication of 16 full adders 
//========================================================== 
 

module rca16 
( 
    input  wire [15:0] a, 
    input  wire [15:0] b, 
    input  wire        cin, 
    output wire [15:0] sum, 
    output wire        cout 
); 
 
    // matches Plan: 17-bit carry chain 
    wire [16:0] carry; 
 
    // matches Plan: boundary condition 
    assign carry[0] = cin; 
 
    // matches Plan: generate-for with named label 
    genvar i; 
 
    generate 
        for (i = 0; i < 16; i = i + 1) begin : fa_gen 
 
            // matches Plan: named port connections 
            full_adder fa_inst 
            ( 
                .a   (a[i]), 
                .b   (b[i]), 
                .cin (carry[i]), 
                .sum (sum[i]), 

                .cout(carry[i+1]) 
            ); 
 
        end 
    endgenerate 
 
    // matches Plan: final carry output 
    assign cout = carry[16]; 
 
endmodule 
 
//========================================================== 
// Design Summary 
// 
// FF   = 0 
// LUT  <= 16 (target, implementation dependent) 
// Pure combinational 
// 
// Carry chain: 
// cin -> carry[0] -> carry[1] -> ... -> carry[16] -> cout 
// 
// No combinational loop: 
// carry index increases monotonically (0 -> 16) 
//==========================================================