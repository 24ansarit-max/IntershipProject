`timescale 1ns/1ps 
 
//=====================================================================
= 
// Module : full_adder 
// 
// Budget Row: 
//   Sub-module       | FF | LUT  | Critical Path 
//   -----------------+----+------+--------------------------- 
//   full_adder (×16) |  0 | <=16 | a/b/cin -> cout (~0.3 ns) 
// 
// Description: 

//   1-bit combinational full adder. 
//=====================================================================
= 
 
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
 
 
//=====================================================================
= 
// Module : rca16 
// 
// Budget Row: 
//   Sub-module       | FF | LUT | Critical Path 

//   -----------------+----+-----+------------------------------ 
//   rca16 (wiring)   |  0 |  0  | Wiring only 
// 
// Overall Design Target: 
//   TOTAL            |  0 | <=16 | <= 5 ns full carry chain 
// 
// Description: 
//   Structural 16-bit ripple carry adder using a generate-for loop. 
//   Target device: xc7a100tcsg324-2 
//=====================================================================
= 
 
module rca16 
( 
    input  wire [15:0] a, 
    input  wire [15:0] b, 
    input  wire        cin, 
 
    output wire [15:0] sum, 
    output wire        cout 
); 
 
    // 17-bit carry chain 
    wire [16:0] carry; 
 
    genvar i; 
 
    generate 

        begin : fa_gen 
 
            // Initial carry 
            assign carry[0] = cin; 
 
            // 16 generated full-adder instances 
            for (i = 0; i < 16; i = i + 1) begin : stage 
 
                full_adder fa_inst 
                ( 
                    .a   (a[i]), 
                    .b   (b[i]), 
                    .cin (carry[i]), 
                    .sum (sum[i]), 
                    .cout(carry[i+1]) 
                ); 
 
            end 
 
            // Final carry output 
            assign cout = carry[16]; 
 
        end 
    endgenerate 
 
endmodule