`timescale 1ns/1ps 

 
//=====================================================================
= 
// ITERATION 1 - Flat Version 
// Single-module dataflow ripple carry adder 
//=====================================================================
= 
 
module rca16_flat 
( 
    input  wire [15:0] a, 
    input  wire [15:0] b, 
    input  wire        cin, 
    output wire [15:0] sum, 
    output wire        cout 
); 
 
    wire [16:0] carry; 
 
    assign carry[0] = cin; 
 
    genvar i; 
 
    generate 
        for (i = 0; i < 16; i = i + 1) begin : stage 
 
            assign sum[i] = 
                a[i] ^ b[i] ^ carry[i]; 
 

            assign carry[i+1] = 
                (a[i] & b[i]) | 
                (a[i] & carry[i]) | 
                (b[i] & carry[i]); 
 
        end 
    endgenerate 
 
    assign cout = carry[16]; 
 
endmodule 
 
 
 
//=====================================================================
= 
// ITERATION 2 / 3 / 4 
// Structural refactor + parameterization + PPA annotation 
//=====================================================================
= 
 
 
//-------------------------------------------------------------- 
// full_adder 
// 
// refactored to structural 
// 
// PPA: 
//   FF=0 

//   LUT=~1 (tool dependent) 
//   critical_path≈0.3ns (target estimate) 
//   Fmax_est=>100MHz (implementation dependent) 
//-------------------------------------------------------------- 
 
module full_adder 
( 
    input  wire a, 
    input  wire b, 
    input  wire cin, 
 
    output wire sum, 
    output wire cout 
); 
 
    // refactored to structural 
    assign sum = 
        a ^ b ^ cin; 
 
    // refactored to structural 
    assign cout = 
        (a & b) | 
        (a & cin) | 
        (b & cin); 
 
endmodule 
 
 

 
//-------------------------------------------------------------- 
// rca16 
// 
// iter3: parameterized 
// 
// PPA: 
//   FF=0 
//   LUT<=16 target (implementation dependent) 
//   critical_path=carry chain 
//   Fmax_est=>100MHz (implementation dependent) 
//-------------------------------------------------------------- 
 
module rca16 
#( 
    parameter WIDTH = 16      // iter3: parameterized 
) 
( 
    input  wire [WIDTH-1:0] a,    // iter3: parameterized 
    input  wire [WIDTH-1:0] b,    // iter3: parameterized 
    input  wire             cin, 
 
    output wire [WIDTH-1:0] sum,  // iter3: parameterized 
    output wire             cout 
); 
 
    // iter3: parameterized 
    wire [WIDTH:0] carry; 

 
    assign carry[0] = cin; 
 
    genvar i; 
 
    generate 
 
        // refactored to structural 
        for (i = 0; i < WIDTH; i = i + 1) begin : fa_gen 
 
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
 
    assign cout = carry[WIDTH]; 
 
endmodule