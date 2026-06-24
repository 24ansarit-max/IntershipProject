`timescale 1ns/1ps 
 
// ============================================================ 
// Module  : full_adder 
// Function: 1-bit combinational full adder 
// FF      : 0   LUT: implementation dependent 
// Fmax_est: >100 MHz target 
// ============================================================ 
// iter3: PPA annotation 
// iter4: Coding style is compatible with CARRY4 inference by 
//        Xilinx synthesis tools when used in a ripple chain. 
// ============================================================ 
 
module full_adder 
( 
    input  wire a, 
    input  wire b, 
    input  wire cin, 
 
    output wire sum, 
    output wire cout 
); 
 
    assign sum = 
        a ^ b ^ cin; 
 

    assign cout = 
        (a & b) | 
        (a & cin) | 
        (b & cin); 
 
endmodule 
 
 
// ============================================================ 
// Module  : rca16 
// Function: Parameterized structural ripple carry adder 
// FF      : 0   LUT: target <= 16 
// Fmax_est: >100 MHz target 
// ============================================================ 
// iter2: parameterized 
// iter3: PPA annotation 
// iter4: Expected to map efficiently to Artix-7 CARRY4 carry 
//        resources during synthesis. 
// ============================================================ 
 
module rca16 
#( 
    parameter WIDTH = 16    // iter2 
) 
( 
    input  wire [WIDTH-1:0] a, 
    input  wire [WIDTH-1:0] b, 
    input  wire             cin, 

 
    output wire [WIDTH-1:0] sum, 
    output wire             cout 
); 
 
    // iter2: parameterized 
    wire [WIDTH:0] carry; 
 
    genvar i; 
 
    generate 
    begin : fa_chain 
 
        // Boundary conditions 
        assign carry[0] = cin; 
 
        // Structural replication 
        for (i = 0; i < WIDTH; i = i + 1) 
        begin : stage 
 
            full_adder fa_inst 
            ( 
                .a   (a[i]), 
                .b   (b[i]), 
                .cin (carry[i]), 
                .sum (sum[i]), 
                .cout(carry[i+1]) 
            ); 

 
        end 
 
        assign cout = carry[WIDTH]; 
 
    end 
    endgenerate 
 
endmodule